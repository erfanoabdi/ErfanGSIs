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
#
"""A tool for inserting values from the build system into a manifest or a test config."""

from __future__ import print_function
from xml.dom import minidom


android_ns = 'http://schemas.android.com/apk/res/android'


def get_children_with_tag(parent, tag_name):
  children = []
  for child in  parent.childNodes:
    if child.nodeType == minidom.Node.ELEMENT_NODE and \
       child.tagName == tag_name:
      children.append(child)
  return children


def find_child_with_attribute(element, tag_name, namespace_uri,
                              attr_name, value):
  for child in get_children_with_tag(element, tag_name):
    attr = child.getAttributeNodeNS(namespace_uri, attr_name)
    if attr is not None and attr.value == value:
      return child
  return None


def parse_manifest(doc):
  """Get the manifest element."""

  manifest = doc.documentElement
  if manifest.tagName != 'manifest':
    raise RuntimeError('expected manifest tag at root')
  return manifest


def ensure_manifest_android_ns(doc):
  """Make sure the manifest tag defines the android namespace."""

  manifest = parse_manifest(doc)

  ns = manifest.getAttributeNodeNS(minidom.XMLNS_NAMESPACE, 'android')
  if ns is None:
    attr = doc.createAttributeNS(minidom.XMLNS_NAMESPACE, 'xmlns:android')
    attr.value = android_ns
    manifest.setAttributeNode(attr)
  elif ns.value != android_ns:
    raise RuntimeError('manifest tag has incorrect android namespace ' +
                       ns.value)


def parse_test_config(doc):
  """ Get the configuration element. """

  test_config = doc.documentElement
  if test_config.tagName != 'configuration':
    raise RuntimeError('expected configuration tag at root')
  return test_config


def as_int(s):
  try:
    i = int(s)
  except ValueError:
    return s, False
  return i, True


def compare_version_gt(a, b):
  """Compare two SDK versions.

  Compares a and b, treating codenames like 'Q' as higher
  than numerical versions like '28'.

  Returns True if a > b

  Args:
    a: value to compare
    b: value to compare
  Returns:
    True if a is a higher version than b
  """

  a, a_is_int = as_int(a.upper())
  b, b_is_int = as_int(b.upper())

  if a_is_int == b_is_int:
    # Both are codenames or both are versions, compare directly
    return a > b
  else:
    # One is a codename, the other is not.  Return true if
    # b is an integer version
    return b_is_int


def get_indent(element, default_level):
  indent = ''
  if element is not None and element.nodeType == minidom.Node.TEXT_NODE:
    text = element.nodeValue
    indent = text[:len(text)-len(text.lstrip())]
  if not indent or indent == '\n':
    # 1 indent = 4 space
    indent = '\n' + (' ' * default_level * 4)
  return indent


def write_xml(f, doc):
  f.write('<?xml version="1.0" encoding="utf-8"?>\n')
  for node in doc.childNodes:
    f.write(node.toxml(encoding='utf-8') + '\n')
