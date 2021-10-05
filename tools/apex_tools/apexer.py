#!/usr/bin/env python
#
# Copyright (C) 2018 The Android Open Source Project
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
"""apexer is a command line tool for creating an APEX file, a package format for system components.

Typical usage: apexer input_dir output.apex

"""

import apex_build_info_pb2
import argparse
import hashlib
import os
import pkgutil
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import uuid
import xml.etree.ElementTree as ET
import zipfile
from apex_manifest import ValidateApexManifest
from apex_manifest import ApexManifestError
from manifest import android_ns
from manifest import find_child_with_attribute
from manifest import get_children_with_tag
from manifest import get_indent
from manifest import parse_manifest
from manifest import write_xml
from xml.dom import minidom

tool_path_list = None
BLOCK_SIZE = 4096


def ParseArgs(argv):
  parser = argparse.ArgumentParser(description='Create an APEX file')
  parser.add_argument(
      '-f', '--force', action='store_true', help='force overwriting output')
  parser.add_argument(
      '-v', '--verbose', action='store_true', help='verbose execution')
  parser.add_argument(
      '--manifest',
      default='apex_manifest.pb',
      help='path to the APEX manifest file (.pb)')
  parser.add_argument(
      '--manifest_json',
      required=False,
      help='path to the APEX manifest file (Q compatible .json)')
  parser.add_argument(
      '--android_manifest',
      help='path to the AndroidManifest file. If omitted, a default one is created and used'
  )
  parser.add_argument(
      '--logging_parent',
      help=('specify logging parent as an additional <meta-data> tag.'
            'This value is ignored if the logging_parent meta-data tag is present.'))
  parser.add_argument(
      '--assets_dir',
      help='an assets directory to be included in the APEX'
  )
  parser.add_argument(
      '--file_contexts',
      help='selinux file contexts file. Required for "image" APEXs.')
  parser.add_argument(
      '--canned_fs_config',
      help='canned_fs_config specifies uid/gid/mode of files. Required for ' +
      '"image" APEXS.')
  parser.add_argument(
      '--key', help='path to the private key file. Required for "image" APEXs.')
  parser.add_argument(
      '--pubkey',
      help='path to the public key file. Used to bundle the public key in APEX for testing.'
  )
  parser.add_argument(
      '--signing_args',
      help='the extra signing arguments passed to avbtool. Used for "image" APEXs.'
  )
  parser.add_argument(
      'input_dir',
      metavar='INPUT_DIR',
      help='the directory having files to be packaged')
  parser.add_argument('output', metavar='OUTPUT', help='name of the APEX file')
  parser.add_argument(
      '--payload_type',
      metavar='TYPE',
      required=False,
      default='image',
      choices=['zip', 'image'],
      help='type of APEX payload being built "zip" or "image"')
  parser.add_argument(
      '--payload_fs_type',
      metavar='FS_TYPE',
      required=False,
      default='ext4',
      choices=['ext4', 'f2fs'],
      help='type of filesystem being used for payload image "ext4" or "f2fs"')
  parser.add_argument(
      '--override_apk_package_name',
      required=False,
      help='package name of the APK container. Default is the apex name in --manifest.'
  )
  parser.add_argument(
      '--no_hashtree',
      required=False,
      action='store_true',
      help='hashtree is omitted from "image".'
  )
  parser.add_argument(
      '--android_jar_path',
      required=False,
      default='prebuilts/sdk/current/public/android.jar',
      help='path to use as the source of the android API.')
  apexer_path_in_environ = 'APEXER_TOOL_PATH' in os.environ
  parser.add_argument(
      '--apexer_tool_path',
      required=not apexer_path_in_environ,
      default=os.environ['APEXER_TOOL_PATH'].split(':')
      if apexer_path_in_environ else None,
      type=lambda s: s.split(':'),
      help="""A list of directories containing all the tools used by apexer (e.g.
                              mke2fs, avbtool, etc.) separated by ':'. Can also be set using the
                              APEXER_TOOL_PATH environment variable""")
  parser.add_argument(
      '--target_sdk_version',
      required=False,
      help='Default target SDK version to use for AndroidManifest.xml')
  parser.add_argument(
      '--min_sdk_version',
      required=False,
      help='Default Min SDK version to use for AndroidManifest.xml')
  parser.add_argument(
      '--do_not_check_keyname',
      required=False,
      action='store_true',
      help='Do not check key name. Use the name of apex instead of the basename of --key.')
  parser.add_argument(
      '--include_build_info',
      required=False,
      action='store_true',
      help='Include build information file in the resulting apex.')
  parser.add_argument(
      '--include_cmd_line_in_build_info',
      required=False,
      action='store_true',
      help='Include the command line in the build information file in the resulting apex. '
           'Note that this makes it harder to make deterministic builds.')
  parser.add_argument(
      '--build_info',
      required=False,
      help='Build information file to be used for default values.')
  parser.add_argument(
      '--payload_only',
      action='store_true',
      help='Outputs the payload image/zip only.'
  )
  parser.add_argument(
      '--unsigned_payload_only',
      action='store_true',
      help="""Outputs the unsigned payload image/zip only. Also, setting this flag implies
                                    --payload_only is set too."""
  )
  parser.add_argument(
      '--unsigned_payload',
      action='store_true',
      help="""Skip signing the apex payload. Used only for testing purposes."""
  )
  return parser.parse_args(argv)


def FindBinaryPath(binary):
  for path in tool_path_list:
    binary_path = os.path.join(path, binary)
    if os.path.exists(binary_path):
      return binary_path
  raise Exception('Failed to find binary ' + binary + ' in path ' +
                  ':'.join(tool_path_list))


def RunCommand(cmd, verbose=False, env=None, expected_return_values={0}):
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

  assert p.returncode in expected_return_values, 'Failed to execute: ' + ' '.join(cmd)

  return (output, p.returncode)


def GetDirSize(dir_name):
  size = 0
  for dirpath, _, filenames in os.walk(dir_name):
    size += RoundUp(os.path.getsize(dirpath), BLOCK_SIZE)
    for f in filenames:
      path = os.path.join(dirpath, f)
      if not os.path.isfile(path):
        continue
      size += RoundUp(os.path.getsize(path), BLOCK_SIZE)
  return size


def GetFilesAndDirsCount(dir_name):
  count = 0
  for root, dirs, files in os.walk(dir_name):
    count += (len(dirs) + len(files))
  return count


def RoundUp(size, unit):
  assert unit & (unit - 1) == 0
  return (size + unit - 1) & (~(unit - 1))


def PrepareAndroidManifest(package, version):
  template = """\
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
  package="{package}" android:versionCode="{version}">
  <!-- APEX does not have classes.dex -->
  <application android:hasCode="false" />
</manifest>
"""
  return template.format(package=package, version=version)


def ValidateAndroidManifest(package, android_manifest):
  tree = ET.parse(android_manifest)
  manifest_tag = tree.getroot()
  package_in_xml = manifest_tag.attrib['package']
  if package_in_xml != package:
    raise Exception("Package name '" + package_in_xml + "' in '" +
                    android_manifest + " differ from package name '" + package +
                    "' in the apex_manifest.pb")


def ValidateArgs(args):
  build_info = None

  if args.build_info is not None:
    if not os.path.exists(args.build_info):
      print("Build info file '" + args.build_info + "' does not exist")
      return False
    with open(args.build_info) as buildInfoFile:
      build_info = apex_build_info_pb2.ApexBuildInfo()
      build_info.ParseFromString(buildInfoFile.read())

  if not os.path.exists(args.manifest):
    print("Manifest file '" + args.manifest + "' does not exist")
    return False

  if not os.path.isfile(args.manifest):
    print("Manifest file '" + args.manifest + "' is not a file")
    return False

  if args.android_manifest is not None:
    if not os.path.exists(args.android_manifest):
      print("Android Manifest file '" + args.android_manifest +
            "' does not exist")
      return False

    if not os.path.isfile(args.android_manifest):
      print("Android Manifest file '" + args.android_manifest +
            "' is not a file")
      return False
  elif build_info is not None:
    with tempfile.NamedTemporaryFile(delete=False) as temp:
      temp.write(build_info.android_manifest)
      args.android_manifest = temp.name

  if not os.path.exists(args.input_dir):
    print("Input directory '" + args.input_dir + "' does not exist")
    return False

  if not os.path.isdir(args.input_dir):
    print("Input directory '" + args.input_dir + "' is not a directory")
    return False

  if not args.force and os.path.exists(args.output):
    print(args.output + ' already exists. Use --force to overwrite.')
    return False

  if args.unsigned_payload_only:
    args.payload_only = True;
    args.unsigned_payload = True;

  if args.payload_type == 'image':
    if not args.key and not args.unsigned_payload:
      print('Missing --key {keyfile} argument!')
      return False

    if not args.file_contexts:
      if build_info is not None:
        with tempfile.NamedTemporaryFile(delete=False) as temp:
          temp.write(build_info.file_contexts)
          args.file_contexts = temp.name
      else:
        print('Missing --file_contexts {contexts} argument, or a --build_info argument!')
        return False

    if not args.canned_fs_config:
      if not args.canned_fs_config:
        if build_info is not None:
          with tempfile.NamedTemporaryFile(delete=False) as temp:
            temp.write(build_info.canned_fs_config)
            args.canned_fs_config = temp.name
        else:
          print('Missing ----canned_fs_config {config} argument, or a --build_info argument!')
          return False

  if not args.target_sdk_version:
    if build_info is not None:
      if build_info.target_sdk_version:
        args.target_sdk_version = build_info.target_sdk_version

  if not args.no_hashtree:
    if build_info is not None:
      if build_info.no_hashtree:
        args.no_hashtree = True

  if not args.min_sdk_version:
    if build_info is not None:
      if build_info.min_sdk_version:
        args.min_sdk_version = build_info.min_sdk_version

  if not args.override_apk_package_name:
    if build_info is not None:
      if build_info.override_apk_package_name:
        args.override_apk_package_name = build_info.override_apk_package_name

  if not args.logging_parent:
    if build_info is not None:
      if build_info.logging_parent:
        args.logging_parent = build_info.logging_parent

  return True

def GenerateBuildInfo(args):
  build_info = apex_build_info_pb2.ApexBuildInfo()
  if (args.include_cmd_line_in_build_info):
    build_info.apexer_command_line = str(sys.argv)

  with open(args.file_contexts) as f:
    build_info.file_contexts = f.read()

  with open(args.canned_fs_config) as f:
    build_info.canned_fs_config = f.read()

  with open(args.android_manifest) as f:
    build_info.android_manifest = f.read()

  if args.target_sdk_version:
    build_info.target_sdk_version = args.target_sdk_version

  if args.min_sdk_version:
    build_info.min_sdk_version = args.min_sdk_version

  if args.no_hashtree:
    build_info.no_hashtree = True

  if args.override_apk_package_name:
    build_info.override_apk_package_name = args.override_apk_package_name

  if args.logging_parent:
    build_info.logging_parent = args.logging_parent

  if args.payload_type == 'image':
    build_info.payload_fs_type = args.payload_fs_type

  return build_info

def AddLoggingParent(android_manifest, logging_parent_value):
  """Add logging parent as an additional <meta-data> tag.

  Args:
    android_manifest: A string representing AndroidManifest.xml
    logging_parent_value: A string representing the logging
      parent value.
  Raises:
    RuntimeError: Invalid manifest
  Returns:
    A path to modified AndroidManifest.xml
  """
  doc = minidom.parse(android_manifest)
  manifest = parse_manifest(doc)
  logging_parent_key = 'android.content.pm.LOGGING_PARENT'
  elems = get_children_with_tag(manifest, 'application')
  application = elems[0] if len(elems) == 1 else None
  if len(elems) > 1:
    raise RuntimeError('found multiple <application> tags')
  elif not elems:
    application = doc.createElement('application')
    indent = get_indent(manifest.firstChild, 1)
    first = manifest.firstChild
    manifest.insertBefore(doc.createTextNode(indent), first)
    manifest.insertBefore(application, first)

  indent = get_indent(application.firstChild, 2)
  last = application.lastChild
  if last is not None and last.nodeType != minidom.Node.TEXT_NODE:
    last = None

  if not find_child_with_attribute(application, 'meta-data', android_ns,
                                   'name', logging_parent_key):
    ul = doc.createElement('meta-data')
    ul.setAttributeNS(android_ns, 'android:name', logging_parent_key)
    ul.setAttributeNS(android_ns, 'android:value', logging_parent_value)
    application.insertBefore(doc.createTextNode(indent), last)
    application.insertBefore(ul, last)
    last = application.lastChild

  if last and last.nodeType != minidom.Node.TEXT_NODE:
    indent = get_indent(application.previousSibling, 1)
    application.appendChild(doc.createTextNode(indent))

  with tempfile.NamedTemporaryFile(delete=False) as temp:
      write_xml(temp, doc)
      return temp.name

def CreateApex(args, work_dir):
  if not ValidateArgs(args):
    return False

  if args.verbose:
    print 'Using tools from ' + str(tool_path_list)

  def copyfile(src, dst):
    if args.verbose:
      print('Copying ' + src + ' to ' + dst)
    shutil.copyfile(src, dst)

  try:
    manifest_apex = ValidateApexManifest(args.manifest)
  except ApexManifestError as err:
    print("'" + args.manifest + "' is not a valid manifest file")
    print err.errmessage
    return False
  except IOError:
    print("Cannot read manifest file: '" + args.manifest + "'")
    return False

  # create an empty image that is sufficiently big
  size_in_mb = (GetDirSize(args.input_dir) / (1024 * 1024))

  content_dir = os.path.join(work_dir, 'content')
  os.mkdir(content_dir)

  # APEX manifest is also included in the image. The manifest is included
  # twice: once inside the image and once outside the image (but still
  # within the zip container).
  manifests_dir = os.path.join(work_dir, 'manifests')
  os.mkdir(manifests_dir)
  copyfile(args.manifest, os.path.join(manifests_dir, 'apex_manifest.pb'))
  if args.manifest_json:
    # manifest_json is for compatibility
    copyfile(args.manifest_json, os.path.join(manifests_dir, 'apex_manifest.json'))

  if args.payload_type == 'image':
    if args.do_not_check_keyname or args.unsigned_payload:
      key_name = manifest_apex.name
    else:
      key_name = os.path.basename(os.path.splitext(args.key)[0])

    img_file = os.path.join(content_dir, 'apex_payload.img')

    if args.payload_fs_type == 'ext4':
      # sufficiently big = size + 16MB margin
      size_in_mb += 16

      # margin is for files that are not under args.input_dir. this consists of
      # n inodes for apex_manifest files and 11 reserved inodes for ext4.
      # TOBO(b/122991714) eliminate these details. use build_image.py which
      # determines the optimal inode count by first building an image and then
      # count the inodes actually used.
      inode_num_margin = GetFilesAndDirsCount(manifests_dir) + 11
      inode_num = GetFilesAndDirsCount(args.input_dir) + inode_num_margin

      cmd = ['mke2fs']
      cmd.extend(['-O', '^has_journal'])  # because image is read-only
      cmd.extend(['-b', str(BLOCK_SIZE)])
      cmd.extend(['-m', '0'])  # reserved block percentage
      cmd.extend(['-t', 'ext4'])
      cmd.extend(['-I', '256'])  # inode size
      cmd.extend(['-N', str(inode_num)])
      uu = str(uuid.uuid5(uuid.NAMESPACE_URL, 'www.android.com'))
      cmd.extend(['-U', uu])
      cmd.extend(['-E', 'hash_seed=' + uu])
      cmd.append(img_file)
      cmd.append(str(size_in_mb) + 'M')
      with tempfile.NamedTemporaryFile(dir=work_dir, suffix="mke2fs.conf") as conf_file:
        conf_data = pkgutil.get_data('apexer', 'mke2fs.conf')
        conf_file.write(conf_data)
        conf_file.flush()
        RunCommand(cmd, args.verbose,
            {"MKE2FS_CONFIG": conf_file.name, 'E2FSPROGS_FAKE_TIME': '1'})

      # Compile the file context into the binary form
      compiled_file_contexts = os.path.join(work_dir, 'file_contexts.bin')
      cmd = ['sefcontext_compile']
      cmd.extend(['-o', compiled_file_contexts])
      cmd.append(args.file_contexts)
      RunCommand(cmd, args.verbose)

      # Add files to the image file
      cmd = ['e2fsdroid']
      cmd.append('-e')  # input is not android_sparse_file
      cmd.extend(['-f', args.input_dir])
      cmd.extend(['-T', '0'])  # time is set to epoch
      cmd.extend(['-S', compiled_file_contexts])
      cmd.extend(['-C', args.canned_fs_config])
      cmd.append('-s')  # share dup blocks
      cmd.append(img_file)
      RunCommand(cmd, args.verbose, {'E2FSPROGS_FAKE_TIME': '1'})

      cmd = ['e2fsdroid']
      cmd.append('-e')  # input is not android_sparse_file
      cmd.extend(['-f', manifests_dir])
      cmd.extend(['-T', '0'])  # time is set to epoch
      cmd.extend(['-S', compiled_file_contexts])
      cmd.extend(['-C', args.canned_fs_config])
      cmd.append('-s')  # share dup blocks
      cmd.append(img_file)
      RunCommand(cmd, args.verbose, {'E2FSPROGS_FAKE_TIME': '1'})

      # Resize the image file to save space
      cmd = ['resize2fs']
      cmd.append('-M')  # shrink as small as possible
      cmd.append(img_file)
      RunCommand(cmd, args.verbose, {'E2FSPROGS_FAKE_TIME': '1'})

    elif args.payload_fs_type == 'f2fs':
      # F2FS requires a ~100M minimum size (necessary for ART, could be reduced a bit for other)
      # TODO(b/158453869): relax these requirements for readonly devices
      size_in_mb += 100

      # Create an empty image
      cmd = ['/usr/bin/fallocate']
      cmd.extend(['-l', str(size_in_mb)+'M'])
      cmd.append(img_file)
      RunCommand(cmd, args.verbose)

      # Format the image to F2FS
      cmd = ['make_f2fs']
      cmd.extend(['-g', 'android'])
      uu = str(uuid.uuid5(uuid.NAMESPACE_URL, 'www.android.com'))
      cmd.extend(['-U', uu])
      cmd.extend(['-T', '0'])
      cmd.append('-r') # sets checkpointing seed to 0 to remove random bits
      cmd.append(img_file)
      RunCommand(cmd, args.verbose)

      # Add files to the image
      cmd = ['sload_f2fs']
      cmd.extend(['-C', args.canned_fs_config])
      cmd.extend(['-f', manifests_dir])
      cmd.extend(['-s', args.file_contexts])
      cmd.extend(['-T', '0'])
      cmd.append(img_file)
      RunCommand(cmd, args.verbose, expected_return_values={0,1})

      cmd = ['sload_f2fs']
      cmd.extend(['-C', args.canned_fs_config])
      cmd.extend(['-f', args.input_dir])
      cmd.extend(['-s', args.file_contexts])
      cmd.extend(['-T', '0'])
      cmd.append(img_file)
      RunCommand(cmd, args.verbose, expected_return_values={0,1})

      # TODO(b/158453869): resize the image file to save space

    if args.unsigned_payload_only:
      shutil.copyfile(img_file, args.output)
      if (args.verbose):
        print('Created (unsigned payload only) ' + args.output)
      return True

    if not args.unsigned_payload:
      cmd = ['avbtool']
      cmd.append('add_hashtree_footer')
      cmd.append('--do_not_generate_fec')
      cmd.extend(['--algorithm', 'SHA256_RSA4096'])
      cmd.extend(['--hash_algorithm', 'sha256'])
      cmd.extend(['--key', args.key])
      cmd.extend(['--prop', 'apex.key:' + key_name])
      # Set up the salt based on manifest content which includes name
      # and version
      salt = hashlib.sha256(manifest_apex.SerializeToString()).hexdigest()
      cmd.extend(['--salt', salt])
      cmd.extend(['--image', img_file])
      if args.no_hashtree:
        cmd.append('--no_hashtree')
      if args.signing_args:
        cmd.extend(shlex.split(args.signing_args))
      RunCommand(cmd, args.verbose)

      # Get the minimum size of the partition required.
      # TODO(b/113320014) eliminate this step
      info, _ = RunCommand(['avbtool', 'info_image', '--image', img_file],
                           args.verbose)
      vbmeta_offset = int(re.search('VBMeta\ offset:\ *([0-9]+)', info).group(1))
      vbmeta_size = int(re.search('VBMeta\ size:\ *([0-9]+)', info).group(1))
      partition_size = RoundUp(vbmeta_offset + vbmeta_size,
                               BLOCK_SIZE) + BLOCK_SIZE

      # Resize to the minimum size
      # TODO(b/113320014) eliminate this step
      cmd = ['avbtool']
      cmd.append('resize_image')
      cmd.extend(['--image', img_file])
      cmd.extend(['--partition_size', str(partition_size)])
      RunCommand(cmd, args.verbose)
  else:
    img_file = os.path.join(content_dir, 'apex_payload.zip')
    cmd = ['soong_zip']
    cmd.extend(['-o', img_file])
    cmd.extend(['-C', args.input_dir])
    cmd.extend(['-D', args.input_dir])
    cmd.extend(['-C', manifests_dir])
    cmd.extend(['-D', manifests_dir])
    RunCommand(cmd, args.verbose)

  if args.payload_only:
    shutil.copyfile(img_file, args.output)
    if (args.verbose):
      print('Created (payload only) ' + args.output)
    return True

  # package the image file and APEX manifest as an APK.
  # The AndroidManifest file is automatically generated if not given.
  android_manifest_file = os.path.join(work_dir, 'AndroidManifest.xml')
  if not args.android_manifest:
    if args.verbose:
      print('Creating AndroidManifest ' + android_manifest_file)
    with open(android_manifest_file, 'w+') as f:
      app_package_name = manifest_apex.name
      f.write(PrepareAndroidManifest(app_package_name, manifest_apex.version))
    args.android_manifest = android_manifest_file
  else:
    ValidateAndroidManifest(manifest_apex.name, args.android_manifest)
    shutil.copyfile(args.android_manifest, android_manifest_file)

  # If logging parent is specified, add it to the AndroidManifest.
  if args.logging_parent != "":
    android_manifest_file = AddLoggingParent(android_manifest_file,
                                             args.logging_parent)

  # copy manifest to the content dir so that it is also accessible
  # without mounting the image
  copyfile(args.manifest, os.path.join(content_dir, 'apex_manifest.pb'))
  if args.manifest_json:
    copyfile(args.manifest_json, os.path.join(content_dir, 'apex_manifest.json'))

  # copy the public key, if specified
  if args.pubkey:
    shutil.copyfile(args.pubkey, os.path.join(content_dir, 'apex_pubkey'))

  if args.include_build_info:
    build_info = GenerateBuildInfo(args)
    with open(os.path.join(content_dir, 'apex_build_info.pb'), "wb") as f:
      f.write(build_info.SerializeToString())

  apk_file = os.path.join(work_dir, 'apex.apk')
  cmd = ['aapt2']
  cmd.append('link')
  cmd.extend(['--manifest', android_manifest_file])
  if args.override_apk_package_name:
    cmd.extend(['--rename-manifest-package', args.override_apk_package_name])
  # This version from apex_manifest.json is used when versionCode isn't
  # specified in AndroidManifest.xml
  cmd.extend(['--version-code', str(manifest_apex.version)])
  if manifest_apex.versionName:
    cmd.extend(['--version-name', manifest_apex.versionName])
  if args.target_sdk_version:
    cmd.extend(['--target-sdk-version', args.target_sdk_version])
  if args.min_sdk_version:
    cmd.extend(['--min-sdk-version', args.min_sdk_version])
  else:
    # Default value for minSdkVersion.
    cmd.extend(['--min-sdk-version', '29'])
  if args.assets_dir:
    cmd.extend(['-A', args.assets_dir])
  cmd.extend(['-o', apk_file])
  cmd.extend(['-I', args.android_jar_path])
  RunCommand(cmd, args.verbose)

  zip_file = os.path.join(work_dir, 'apex.zip')
  CreateZip(content_dir, zip_file)
  MergeZips([apk_file, zip_file], args.output)

  if (args.verbose):
    print('Created ' + args.output)

  return True


class TempDirectory(object):

  def __enter__(self):
    self.name = tempfile.mkdtemp()
    return self.name

  def __exit__(self, *unused):
    shutil.rmtree(self.name)

def CreateZip(content_dir, apex_zip):
  with zipfile.ZipFile(apex_zip, 'w', compression=zipfile.ZIP_DEFLATED) as out:
    for root, _, files in os.walk(content_dir):
      for file in files:
        path = os.path.join(root, file)
        rel_path = os.path.relpath(path, content_dir)
        # "apex_payload.img" shouldn't be compressed
        if rel_path == "apex_payload.img":
          out.write(path, rel_path, compress_type=zipfile.ZIP_STORED)
        else:
          out.write(path, rel_path)

def MergeZips(zip_files, output_zip):
  with zipfile.ZipFile(output_zip, 'w') as out:
    for file in zip_files:
      # copy to output_zip
      with zipfile.ZipFile(file, 'r') as inzip:
        for info in inzip.infolist():
          # "apex_payload.img" should be 4K aligned
          if info.filename == "apex_payload.img":
            data_offset = out.fp.tell() + len(info.FileHeader())
            info.extra = b'\0' * (BLOCK_SIZE - data_offset % BLOCK_SIZE)
          data = inzip.read(info)
          out.writestr(info, data)

def main(argv):
  global tool_path_list
  args = ParseArgs(argv)
  tool_path_list = args.apexer_tool_path
  with TempDirectory() as work_dir:
    success = CreateApex(args, work_dir)

  if not success:
    sys.exit(1)


if __name__ == '__main__':
  main(sys.argv[1:])
