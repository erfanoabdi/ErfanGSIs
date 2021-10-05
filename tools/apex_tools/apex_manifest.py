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

import apex_manifest_pb2
from google.protobuf import message
from google.protobuf.json_format import MessageToJson
import zipfile

class ApexManifestError(Exception):

  def __init__(self, errmessage):
    # Apex Manifest parse error (extra fields) or if required fields not present
    self.errmessage = errmessage


def ValidateApexManifest(file):
  try:
    with open(file, "rb") as f:
      manifest_pb = apex_manifest_pb2.ApexManifest()
      manifest_pb.ParseFromString(f.read())
  except message.DecodeError as err:
    raise ApexManifestError(err)
  # Checking required fields
  if manifest_pb.name == "":
    raise ApexManifestError("'name' field is required.")
  if manifest_pb.version == 0:
    raise ApexManifestError("'version' field is required.")
  if manifest_pb.noCode and (manifest_pb.preInstallHook or
                             manifest_pb.postInstallHook):
    raise ApexManifestError(
        "'noCode' can't be true when either preInstallHook or postInstallHook is set"
    )
  return manifest_pb

def fromApex(apexFilePath):
  with zipfile.ZipFile(apexFilePath, 'r') as apexFile:
    with apexFile.open('apex_manifest.pb') as manifestFile:
      manifest = apex_manifest_pb2.ApexManifest()
      manifest.ParseFromString(manifestFile.read())
      return manifest

def toJsonString(manifest):
  return MessageToJson(manifest, indent=2)