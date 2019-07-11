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

. `dirname $0`/art_prepostinstall_utils || exit 100

log_info "=== ART runtime pre-install ==="

set_arches || exit 101
log_info "Arches = `echo $ARCHES`"

# The runtime update uses /data/ota as a staging directory, similar to
# A/B OTA. (There is no overlap, as A/B uses slot prefixes.)

# Create OTA base folder.
mkdir -p /data/ota/dalvik-cache || exit 102
# Bind-mount to perceive as normal structure.
mount -o bind /data/ota/dalvik-cache /data/dalvik-cache || exit 103

for ARCH in $ARCHES ; do
  log_info "Preparing compilation output directories for $ARCH"

  # Create OTA folders.
  mkdir -p /data/ota/dalvik-cache/$ARCH || exit 104
  rm -rf /data/ota/dalvik-cache/$ARCH/* || exit 105

  `dirname $0`/art_preinstall_hook_boot $ARCH || exit 200
done

PRIMARY_ARCH=`echo $ARCHES | sed -e 's/ .*//'`
`dirname $0`/art_preinstall_hook_system_server $PRIMARY_ARCH || exit 300

FILES=`find /data/dalvik-cache -type f`
for FILE in $FILES ; do
  setup_fsverity $FILE || exit 400
done
