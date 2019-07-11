#!/system/bin/sh

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
#

alias log_info="log -t art_apex -p i"
alias log_error="log -t art_apex -p f"

# Set |ARCHES| to a string containing the architectures of the device.
function set_arches {
  # Derive architectures. For now, stop at two.
  local abilist_prop=`getprop ro.product.cpu.abilist`
  local abilist=`echo $abilist_prop | tr "," "\n"`
  ARCHES=""
  for abi in $abilist ; do
    case "$abi" in
      arm64-v8a)
        ARCHES="$ARCHES\narm64"
        ;;
      armeabi-v7a|armeabi)
        ARCHES="$ARCHES\narm"
        ;;
      x86)
        ARCHES="$ARCHES\nx86"
        ;;
      x86_64)
        ARCHES="$ARCHES\nx86_64"
        ;;
      *)
        log_error "Unsupported ABI $abi"
        return 1
        ;;
    esac
  done
  ARCHES=`echo $ARCHES | uniq`
  return 0
}

function setup_fsverity {
  local full_shell_path=`readlink -f $0`
  local bin_dir=`dirname $full_shell_path`
  local apex_dir=`dirname $bin_dir`
  local sig_dir="${apex_dir}.signatures"
  local file=$1
  local signature_file="$sig_dir/$file.sig"
  # Setup.
  log_info "fsverity setup for $file"
  SETUP_MSG=`fsverity setup $file --signature=$signature_file --hash=sha256 2>&1` || \
    { log_error "Setup failed: $SETUP_MSG" ; return 300 ; }
  # Enable.
  log_info "fsverity enable for $file"
  ENABLE_MSG=`fsverity enable $file 2>&1` || \
    { log_error "Enable failed: $ENABLE_MSG" ; return 301 ; }
  # Test integrity.
  INTEGRITY_MSG=`dd if=$file of=/dev/null bs=4k 2>&1` || \
    { log_error "Integrity failed: $INTEGRITY_MSG" ; return 302 ; }
  return 0
}
