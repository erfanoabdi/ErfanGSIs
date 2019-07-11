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

log_info "Preparing boot image compilation parameters"

# Prefer DEX2OATBOOTCLASSPATH, then BOOTCLASSPATH.
USED_CLASSPATH=$DEX2OATBOOTCLASSPATH
if [ -z "$USED_CLASSPATH" ] ; then
  USED_CLASSPATH=$BOOTCLASSPATH
  if [ -z "$USED_CLASSPATH" ] ; then
    log_error "Could not find boot class-path to compile"
    exit 101
  fi
fi
BOOTCP=`echo $USED_CLASSPATH | tr ":" "\n"`

DEX_FILES=
DEX_LOCATIONS=
for component in $BOOTCP ; do
  DEX_FILES="$DEX_FILES --dex-file=$component"
  DEX_LOCATIONS="$DEX_LOCATIONS --dex-location=$component"
done

PROFILING=
if [ -f "/system/etc/boot-image.prof" ] ; then
  PROFILING="--compiler-filter=speed-profile --profile-file=/system/etc/boot-image.prof"
elif [ -f "/system/etc/preloaded-classes" ]; then
  PROFILING="--image-classes=/system/etc/preloaded-classes"
fi
if [ -f "/system/etc/dirty-image-objects" ] ; then
  PROFILING="$PROFILING --dirty-image-objects=/system/etc/dirty-image-objects"
fi

DEX2OAT_IMAGE_XMX=`getprop dalvik.vm.image-dex2oat-Xmx`

DEX2OAT_TARGET_ARCH=$1
DEX2OAT_TARGET_CPU_VARIANT=`getprop dalvik.vm.isa.${DEX2OAT_TARGET_ARCH}.variant`
DEX2OAT_TARGET_INSTRUCTION_SET_FEATURES=`getprop dalvik.vm.isa.${DEX2OAT_TARGET_ARCH}.features`

log_info "Compiling boot image for $DEX2OAT_TARGET_ARCH"

dex2oat \
  --avoid-storing-invocation \
  --runtime-arg -Xmx$DEX2OAT_IMAGE_XMX \
  $PROFILING \
  $DEX_FILES \
  $DEX_LOCATIONS \
  --generate-mini-debug-info \
  --strip \
  --oat-file=/data/dalvik-cache/$DEX2OAT_TARGET_ARCH/system@framework@boot.oat \
  --oat-location=/data/dalvik-cache/$DEX2OAT_TARGET_ARCH/system@framework@boot.oat \
  --image=/data/dalvik-cache/$DEX2OAT_TARGET_ARCH/system@framework@boot.art --base=0x70000000 \
  --instruction-set=$DEX2OAT_TARGET_ARCH \
  --instruction-set-variant=$DEX2OAT_TARGET_CPU_VARIANT \
  --instruction-set-features=$DEX2OAT_TARGET_INSTRUCTION_SET_FEATURES \
  --android-root=/system \
  --no-inline-from=core-oj.jar \
  --abort-on-hard-verifier-error \
  --force-determinism || { log_error "Dex2oat failed" ; exit 102 ; }
