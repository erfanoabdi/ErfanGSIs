#!/usr/bin/env python3
#
# Copyright (C) 2020 The Android Open Source Project
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

"""apex_compression_tool is a tool that can compress/decompress APEX.

Example:
  apex_compression_tool compress --input /apex/to/compress --output output/path
  apex_compression_tool decompress --input /apex/to/decompress --output dir/
  apex_compression_tool verify-compressed --input /file/to/check
"""
from __future__ import print_function

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from zipfile import ZipFile

import apex_manifest_pb2

tool_path_list = None


def FindBinaryPath(binary):
  for path in tool_path_list:
    binary_path = os.path.join(path, binary)
    if os.path.exists(binary_path):
      return binary_path
  raise Exception('Failed to find binary ' + binary + ' in path ' +
                  ':'.join(tool_path_list))


def RunCommand(cmd, verbose=False, env=None, expected_return_values=None):
  expected_return_values = expected_return_values or {0}
  env = env or {}
  env.update(os.environ.copy())

  cmd[0] = FindBinaryPath(cmd[0])

  if verbose:
    print('Running: ' + ' '.join(cmd))
  p = subprocess.Popen(
      cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env)
  output, _ = p.communicate()

  if verbose or p.returncode not in expected_return_values:
    print(output.rstrip())

  assert p.returncode in expected_return_values, 'Failed to execute: ' \
                                                 + ' '.join(cmd)

  return output, p.returncode


def RunCompress(args, work_dir):
  """RunCompress takes an uncompressed APEX and compresses into compressed APEX

  Compressed apex will contain the following items:
      - original_apex: The original uncompressed APEX
      - Duplicates of various meta files inside the input APEX, e.g
        AndroidManifest.xml, public_key

  Args:
      args.input: file path to uncompressed APEX
      args.output: file path to where compressed APEX will be placed
      work_dir: file path to a temporary folder
  Returns:
      True if compression was executed successfully, otherwise False
  """
  global tool_path_list
  tool_path_list = args.apex_compression_tool_path

  cmd = ['soong_zip']
  cmd.extend(['-o', args.output])

  # We want to put the input apex inside the compressed APEX with name
  # "original_apex". So we create a hard link and put the renamed file inside
  # the zip
  original_apex = os.path.join(work_dir, 'original_apex')
  os.link(args.input, original_apex)
  cmd.extend(['-C', work_dir])
  cmd.extend(['-f', original_apex])

  # We also need to extract some files from inside of original_apex and zip
  # together with compressed apex
  with ZipFile(original_apex, 'r') as zip_obj:
    extract_dir = os.path.join(work_dir, 'extract')
    for meta_file in ['apex_manifest.json', 'apex_manifest.pb',
                      'apex_pubkey', 'apex_build_info.pb',
                      'AndroidManifest.xml']:
      if meta_file in zip_obj.namelist():
        zip_obj.extract(meta_file, path=extract_dir)
        file_path = os.path.join(extract_dir, meta_file)
        cmd.extend(['-C', extract_dir])
        cmd.extend(['-f', file_path])
        cmd.extend(['-s', meta_file])
    # Extract the image for retrieving root digest
    zip_obj.extract('apex_payload.img', path= work_dir)
    image_path = os.path.join(work_dir, 'apex_payload.img')

  # Set digest of original_apex to apex_manifest.pb
  apex_manifest_path = os.path.join(extract_dir, 'apex_manifest.pb')
  assert AddOriginalApexDigestToManifest(apex_manifest_path, image_path, args.verbose)

  # Don't forget to compress
  cmd.extend(['-L', '9'])

  RunCommand(cmd, verbose=args.verbose)

  return True


def AddOriginalApexDigestToManifest(capex_manifest_path, apex_image_path, verbose=False):
  # Retrieve the root digest of the image
  avbtool_cmd = [
        'avbtool',
        'print_partition_digests', '--image',
        apex_image_path]
  # avbtool_cmd output has format "<name>: <value>"
  root_digest = RunCommand(avbtool_cmd, verbose=verbose)[0].decode().split(': ')[1].strip()
  # Update the manifest proto file
  with open(capex_manifest_path, 'rb') as f:
    pb = apex_manifest_pb2.ApexManifest()
    pb.ParseFromString(f.read())
  # Populate CompressedApexMetadata
  capex_metadata = apex_manifest_pb2.ApexManifest().CompressedApexMetadata()
  capex_metadata.originalApexDigest = root_digest
  # Set updated value to protobuf
  pb.capexMetadata.CopyFrom(capex_metadata)
  with open(capex_manifest_path, 'wb') as f:
    f.write(pb.SerializeToString())
  return True


def ParseArgs(argv):
  parser = argparse.ArgumentParser()
  subparsers = parser.add_subparsers(required=True, dest='cmd')

  # Handle sub-command "compress"
  parser_compress = subparsers.add_parser('compress',
                                          help='compresses an APEX')
  parser_compress.add_argument('-v', '--verbose', action='store_true',
                               help='verbose execution')
  parser_compress.add_argument('--input', type=str, required=True,
                               help='path to input APEX file that will be '
                                    'compressed')
  parser_compress.add_argument('--output', type=str, required=True,
                               help='output path to compressed APEX file')
  apex_compression_tool_path_in_environ = \
    'APEX_COMPRESSION_TOOL_PATH' in os.environ
  parser_compress.add_argument(
      '--apex_compression_tool_path',
      required=not apex_compression_tool_path_in_environ,
      default=os.environ['APEX_COMPRESSION_TOOL_PATH'].split(':')
      if apex_compression_tool_path_in_environ else None,
      type=lambda s: s.split(':'),
      help="""A list of directories containing all the tools used by
        apex_compression_tool (e.g. soong_zip etc.) separated by ':'. Can also
        be set using the APEX_COMPRESSION_TOOL_PATH environment variable""")
  parser_compress.set_defaults(func=RunCompress)

  return parser.parse_args(argv)


class TempDirectory(object):

  def __enter__(self):
    self.name = tempfile.mkdtemp()
    return self.name

  def __exit__(self, *unused):
    shutil.rmtree(self.name)


def main(argv):
  args = ParseArgs(argv)

  with TempDirectory() as work_dir:
    success = args.func(args, work_dir)

  if not success:
    sys.exit(1)


if __name__ == '__main__':
  main(sys.argv[1:])
