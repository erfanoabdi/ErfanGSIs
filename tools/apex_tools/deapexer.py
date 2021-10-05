#!/usr/bin/env python3
#
# Copyright (C) 2019 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""deapexer is a tool that prints out content of an APEX.

To print content of an APEX to stdout:
  deapexer list foo.apex

To extract content of an APEX to the given directory:
  deapexer extract foo.apex dest
"""
from __future__ import print_function

import argparse
import apex_manifest
import enum
import os
import shutil
import sys
import subprocess
import tempfile
import zipfile

BLOCK_SIZE = 4096

class ApexImageEntry(object):

  def __init__(self, name, base_dir, permissions, size, ino, extents, is_directory=False,
               is_symlink=False):
    self._name = name
    self._base_dir = base_dir
    self._permissions = permissions
    self._size = size
    self._is_directory = is_directory
    self._is_symlink = is_symlink
    self._ino = ino
    self._extents = extents

  @property
  def name(self):
    return self._name

  @property
  def full_path(self):
    return os.path.join(self._base_dir, self._name)

  @property
  def is_directory(self):
    return self._is_directory

  @property
  def is_symlink(self):
    return self._is_symlink

  @property
  def is_regular_file(self):
    return not self.is_directory and not self.is_symlink

  @property
  def permissions(self):
    return self._permissions

  @property
  def size(self):
    return self._size

  @property
  def ino(self):
    return self._ino

  @property
  def extents(self):
    return self._extents

  def __str__(self):
    ret = ''
    if self._is_directory:
      ret += 'd'
    elif self._is_symlink:
      ret += 'l'
    else:
      ret += '-'

    def mask_as_string(m):
      ret = 'r' if m & 4 == 4 else '-'
      ret += 'w' if m & 2 == 2 else '-'
      ret += 'x' if m & 1 == 1 else '-'
      return ret

    ret += mask_as_string(self._permissions >> 6)
    ret += mask_as_string((self._permissions >> 3) & 7)
    ret += mask_as_string(self._permissions & 7)

    return ret + ' ' + self._size + ' ' + self._name


class ApexImageDirectory(object):

  def __init__(self, path, entries, apex):
    self._path = path
    self._entries = sorted(entries, key=lambda e: e.name)
    self._apex = apex

  def list(self, is_recursive=False):
    for e in self._entries:
      yield e
      if e.is_directory and e.name != '.' and e.name != '..':
        for ce in self.enter_subdir(e).list(is_recursive):
          yield ce

  def enter_subdir(self, entry):
    return self._apex._list(self._path + entry.name + '/')

  def extract(self, dest):
    path = self._path
    self._apex._extract(self._path, dest)


class Apex(object):

  def __init__(self, args):
    self._debugfs = args.debugfs_path
    self._apex = args.apex
    self._tempdir = tempfile.mkdtemp()
    # TODO(b/139125405): support flattened APEXes.
    with zipfile.ZipFile(self._apex, 'r') as zip_ref:
      self._payload = zip_ref.extract('apex_payload.img', path=self._tempdir)
    self._cache = {}

  def __del__(self):
    shutil.rmtree(self._tempdir)

  def __enter__(self):
    return self._list('./')

  def __exit__(self, type, value, traceback):
    pass

  def _list(self, path):
    if path in self._cache:
      return self._cache[path]
    process = subprocess.Popen([self._debugfs, '-R', 'ls -l -p %s' % path, self._payload],
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               universal_newlines=True)
    stdout, _ = process.communicate()
    res = str(stdout)
    entries = []
    for line in res.split('\n'):
      if not line:
        continue
      parts = line.split('/')
      if len(parts) != 8:
        continue
      name = parts[5]
      if not name:
        continue
      ino = parts[1]
      bits = parts[2]
      size = parts[6]
      extents = []
      is_symlink = bits[1]=='2'
      is_directory=bits[1]=='4'

      if not is_symlink and not is_directory:
        process = subprocess.Popen([self._debugfs, '-R', 'dump_extents <%s>' % ino,
                                    self._payload], stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                    universal_newlines=True)
        stdout, _ = process.communicate()
        # Output of dump_extents for an inode fragmented in 3 blocks (length and addresses represent
        # block-sized sections):
        # Level Entries       Logical      Physical Length Flags
        # 0/ 0   1/  3     0 -     0    18 -    18      1
        # 0/ 0   2/  3     1 -    15    20 -    34     15
        # 0/ 0   3/  3    16 -  1863    37 -  1884   1848
        res = str(stdout).splitlines()
        res.pop(0) # the first line contains only columns names
        left_length = int(size)
        try: # dump_extents sometimes has an unexpected output
          for line in res:
            tokens = line.split()
            offset = int(tokens[7]) * BLOCK_SIZE
            length = min(int(tokens[-1]) * BLOCK_SIZE, left_length)
            left_length -= length
            extents.append((offset, length))
          if (left_length != 0): # dump_extents sometimes fails to display "hole" blocks
            raise ValueError
        except:
          extents = [] # [] means that we failed to retrieve the file location successfully

      entries.append(ApexImageEntry(name, base_dir=path, permissions=int(bits[3:], 8), size=size,
                                    is_directory=is_directory, is_symlink=is_symlink, ino=ino,
                                    extents=extents))

    return ApexImageDirectory(path, entries, self)

  def _extract(self, path, dest):
    process = subprocess.Popen([self._debugfs, '-R', 'rdump %s %s' % (path, dest), self._payload],
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               universal_newlines=True)
    _, stderr = process.communicate()
    if process.returncode != 0:
      print(stderr, file=sys.stderr)


def RunList(args):
  if GetType(args.apex) == ApexType.COMPRESSED:
    with tempfile.TemporaryDirectory() as temp:
      decompressed_apex = os.path.join(temp, 'temp.apex')
      decompress(args.apex, decompressed_apex)
      args.apex = decompressed_apex

      RunList(args)
      return

  with Apex(args) as apex:
    for e in apex.list(is_recursive=True):
      if e.is_directory:
        continue
      res = ''
      if args.size:
        res += e.size + ' '
      res += e.full_path
      if args.extents:
        res += ' [' + '-'.join(str(x) for x in e.extents) + ']'
      print(res)


def RunExtract(args):
  if GetType(args.apex) == ApexType.COMPRESSED:
    with tempfile.TemporaryDirectory() as temp:
      decompressed_apex = os.path.join(temp, "temp.apex")
      decompress(args.apex, decompressed_apex)
      args.apex = decompressed_apex

      RunExtract(args)
      return

  with Apex(args) as apex:
    if not os.path.exists(args.dest):
      os.makedirs(args.dest, mode=0o755)
    apex.extract(args.dest)
    shutil.rmtree(os.path.join(args.dest, "lost+found"))


class ApexType(enum.Enum):
  INVALID = 0
  UNCOMPRESSED = 1
  COMPRESSED = 2


def GetType(apex_path):
  with zipfile.ZipFile(apex_path, 'r') as zip_file:
    names = zip_file.namelist()
    has_payload = 'apex_payload.img' in names
    has_original_apex = 'original_apex' in names
    if has_payload and has_original_apex:
      return ApexType.INVALID
    if has_payload:
      return ApexType.UNCOMPRESSED
    if has_original_apex:
      return ApexType.COMPRESSED
    return ApexType.INVALID


def RunInfo(args):
  if args.print_type:
    res = GetType(args.apex)
    if res == ApexType.INVALID:
      print(args.apex + ' is not a valid apex')
      sys.exit(1)
    print(res.name)
  else:
    manifest = apex_manifest.fromApex(args.apex)
    print(apex_manifest.toJsonString(manifest))


def RunDecompress(args):
  """RunDecompress takes path to compressed APEX and decompresses it to
  produce the original uncompressed APEX at give output path

  See apex_compression_tool.py#RunCompress for details on compressed APEX
  structure.

  Args:
      args.input: file path to compressed APEX
      args.output: file path to where decompressed APEX will be placed
  """
  compressed_apex_fp = args.input
  decompressed_apex_fp = args.output
  return decompress(compressed_apex_fp, decompressed_apex_fp)

def decompress(compressed_apex_fp, decompressed_apex_fp):
  if os.path.exists(decompressed_apex_fp):
    print("Output path '" + decompressed_apex_fp + "' already exists")
    sys.exit(1)

  with zipfile.ZipFile(compressed_apex_fp, 'r') as zip_obj:
    if 'original_apex' not in zip_obj.namelist():
      print(compressed_apex_fp + ' is not a compressed APEX. Missing '
                                 "'original_apex' file inside it.")
      sys.exit(1)
    # Rename original_apex file to what user provided as output filename
    original_apex_info = zip_obj.getinfo('original_apex')
    original_apex_info.filename = os.path.basename(decompressed_apex_fp)
    # Extract the original_apex as desired name
    zip_obj.extract(original_apex_info,
                    path=os.path.dirname(decompressed_apex_fp))


def main(argv):
  parser = argparse.ArgumentParser()

  debugfs_default = None
  if 'ANDROID_HOST_OUT' in os.environ:
    debugfs_default = '%s/bin/debugfs_static' % os.environ['ANDROID_HOST_OUT']
  parser.add_argument('--debugfs_path', help='The path to debugfs binary', default=debugfs_default)

  subparsers = parser.add_subparsers(required=True, dest='cmd')

  parser_list = subparsers.add_parser('list', help='prints content of an APEX to stdout')
  parser_list.add_argument('apex', type=str, help='APEX file')
  parser_list.add_argument('--size', help='also show the size of the files', action="store_true")
  parser_list.add_argument('--extents', help='also show the location of the files', action="store_true")
  parser_list.set_defaults(func=RunList)

  parser_extract = subparsers.add_parser('extract', help='extracts content of an APEX to the given '
                                                         'directory')
  parser_extract.add_argument('apex', type=str, help='APEX file')
  parser_extract.add_argument('dest', type=str, help='Directory to extract content of APEX to')
  parser_extract.set_defaults(func=RunExtract)

  parser_info = subparsers.add_parser('info', help='prints APEX manifest')
  parser_info.add_argument('apex', type=str, help='APEX file')
  parser_info.add_argument('--print-type',
                           help='Prints type of the apex (COMPRESSED or UNCOMPRESSED)',
                           action='store_true')
  parser_info.set_defaults(func=RunInfo)

  # Handle sub-command "decompress"
  parser_decompress = subparsers.add_parser('decompress',
                                            help='decompresses a compressed '
                                                 'APEX')
  parser_decompress.add_argument('--input', type=str, required=True,
                                 help='path to compressed APEX file that '
                                      'will be decompressed')
  parser_decompress.add_argument('--output', type=str, required=True,
                                 help='output directory path where '
                                      'decompressed APEX will be extracted')
  parser_decompress.set_defaults(func=RunDecompress)

  args = parser.parse_args(argv)

  debugfs_required_for_cmd = ['list', 'extract']
  if args.cmd in debugfs_required_for_cmd and not args.debugfs_path:
    print('ANDROID_HOST_OUT environment variable is not defined, --debugfs_path must be set',
          file=sys.stderr)
    sys.exit(1)

  args.func(args)


if __name__ == '__main__':
  main(sys.argv[1:])
