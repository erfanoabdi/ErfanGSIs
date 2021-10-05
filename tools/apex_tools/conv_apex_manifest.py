#!/usr/bin/env python
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
"""conv_apex_manifest converts apex_manifest.json in two ways

To remove keys which are unknown to Q
  conv_apex_manifest strip apex_manifest.json (-o apex_manifest_stripped.json)

To convert into .pb
  conv_apex_manifest proto apex_manifest.json -o apex_manifest.pb

To change property value
  conv_apex_manifest setprop version 137 apex_manifest.pb
"""

import argparse
import collections
import json

import apex_manifest_pb2
from google.protobuf.descriptor import FieldDescriptor
from google.protobuf.json_format import ParseDict
from google.protobuf.json_format import ParseError
from google.protobuf.text_format import MessageToString

Q_compat_keys = ["name", "version", "preInstallHook", "postInstallHook", "versionName"]

def Strip(args):
  with open(args.input) as f:
      obj = json.load(f, object_pairs_hook=collections.OrderedDict)

  # remove unknown keys
  for key in list(obj):
    if key not in Q_compat_keys:
      del obj[key]

  if args.out:
    with open(args.out, "w") as f:
      json.dump(obj, f, indent=2)
  else:
    print(json.dumps(obj, indent=2))

def Proto(args):
  with open(args.input) as f:
    obj = json.load(f, object_pairs_hook=collections.OrderedDict)
  pb = ParseDict(obj, apex_manifest_pb2.ApexManifest())
  with open(args.out, "wb") as f:
    f.write(pb.SerializeToString())

def SetProp(args):
  with open(args.input, "rb") as f:
    pb = apex_manifest_pb2.ApexManifest()
    pb.ParseFromString(f.read())

  if getattr(type(pb), args.property).DESCRIPTOR.label == FieldDescriptor.LABEL_REPEATED:
    getattr(pb, args.property)[:] = args.value.split(",")
  else:
    setattr(pb, args.property, type(getattr(pb, args.property))(args.value))
  with open(args.input, "wb") as f:
    f.write(pb.SerializeToString())

def Print(args):
  with open(args.input, "rb") as f:
    pb = apex_manifest_pb2.ApexManifest()
    pb.ParseFromString(f.read())
  print(MessageToString(pb))

def main():
  parser = argparse.ArgumentParser()
  subparsers = parser.add_subparsers()

  parser_strip = subparsers.add_parser('strip', help='remove unknown keys from APEX manifest (JSON)')
  parser_strip.add_argument('input', type=str, help='APEX manifest file (JSON)')
  parser_strip.add_argument('-o', '--out', type=str, help='Output filename. If omitted, prints to stdout')
  parser_strip.set_defaults(func=Strip)

  parser_proto = subparsers.add_parser('proto', help='write protobuf binary format')
  parser_proto.add_argument('input', type=str, help='APEX manifest file (JSON)')
  parser_proto.add_argument('-o', '--out', required=True, type=str, help='Directory to extract content of APEX to')
  parser_proto.set_defaults(func=Proto)

  parser_proto = subparsers.add_parser('setprop', help='change proprety value')
  parser_proto.add_argument('property', type=str, help='name of property')
  parser_proto.add_argument('value', type=str, help='new value of property')
  parser_proto.add_argument('input', type=str, help='APEX manifest file (PB)')
  parser_proto.set_defaults(func=SetProp)

  parser_proto = subparsers.add_parser('print', help='print APEX manifest')
  parser_proto.add_argument('input', type=str, help='APEX manifest file (PB)')
  parser_proto.set_defaults(func=Print)

  args = parser.parse_args()
  args.func(args)

if __name__ == '__main__':
  main()
