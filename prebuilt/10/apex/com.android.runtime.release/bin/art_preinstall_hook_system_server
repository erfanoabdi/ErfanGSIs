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

function dalvik_cache_name {
  local input=$1
  # Strip first /, replace rest with @.
  DALVIK_CACHE_NAME=`echo $input | sed -e 's,^/,,' -e 's,/,@,g'`
  # Append @classes.dex.
  DALVIK_CACHE_NAME="${DALVIK_CACHE_NAME}@classes.dex"
}

log_info "Preparing system server compilation parameters"

if [ "x$SYSTEMSERVERCLASSPATH" = "x" ] ; then
  log_info "SYSTEMSERVERCLASSPATH is not set! Trying to retrieve from init.environ.rc."
  SYSTEMSERVERCLASSPATH=`grep "export SYSTEMSERVERCLASSPATH" init.environ.rc | sed -e "s/.* //"`
  if [ "x$SYSTEMSERVERCLASSPATH" = "x" ] ; then
    log_error "Could not find SYSTEMSERVERCLASSPATH"
    exit 101
  fi
fi
SYSCP=`echo $SYSTEMSERVERCLASSPATH | tr ":" "\n"`

BOOTCPPARAM=
if [ ! -z "$DEX2OATBOOTCLASSPATH" ] ; then
  BOOTCPPARAM="--runtime-arg -Xbootclasspath:$DEX2OATBOOTCLASSPATH"
fi

DEX2OAT_IMAGE_XMX=`getprop dalvik.vm.dex2oat-Xmx`

DEX2OAT_TARGET_ARCH=$1
DEX2OAT_TARGET_CPU_VARIANT=`getprop dalvik.vm.isa.${DEX2OAT_TARGET_ARCH}.variant`
DEX2OAT_TARGET_INSTRUCTION_SET_FEATURES=`getprop dalvik.vm.isa.${DEX2OAT_TARGET_ARCH}.features`

# Do this like preopt: speed compile, no classpath, possibly pick up profiles.

# TODO: App image? Would have to scan /system for an existing image.

for COMPONENT in $SYSCP ; do
  log_info "Compiling $COMPONENT"
  dalvik_cache_name $COMPONENT
  PROFILING=
  if [ -f "${COMPONENT}.prof" ] ; then
    PROFILING="--profile-file=${COMPONENT}.prof"
  fi
  dex2oat \
    --avoid-storing-invocation \
    --runtime-arg -Xmx$DEX2OAT_IMAGE_XMX \
    $BOOTCPPARAM \
    --class-loader-context=\& \
    --boot-image=/data/dalvik-cache/system@framework@boot.art \
    --dex-file=$COMPONENT \
    --dex-location=$COMPONENT \
    --oat-file=/data/dalvik-cache/$DEX2OAT_TARGET_ARCH/$DALVIK_CACHE_NAME \
    --android-root=/system \
    --instruction-set=$DEX2OAT_TARGET_ARCH \
    --instruction-set-variant=$DEX2OAT_TARGET_CPU_VARIANT \
    --instruction-set-features=$DEX2OAT_TARGET_INSTRUCTION_SET_FEATURES \
    --no-generate-debug-info \
    --abort-on-hard-verifier-error \
    --force-determinism \
    --no-inline-from=core-oj.jar \
    --copy-dex-files=false \
    --compiler-filter=speed \
    --generate-mini-debug-info \
    $PROFILING \
      || { log_error "Dex2oat failed" ; exit 102 ; }
done
