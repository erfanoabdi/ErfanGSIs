#!/bin/bash

# How this works
# 0) Wait for boot complete and surfaceflinger crash (on .rc script)
# 1) Read logcat for isHDRLayer
# 2) Find isHDRLayer offset
# 3) Find first "cbz" offset
# 4) Patch it to "cbnz" and save to /data/local/tmp/
# 5) Stop surfaceflinger and replaced patched lib
# 6) Start surfaceflinger

HDRLINE="08-24 18:53:40.892  7601  7601 F DEBUG   :     #00 pc 00000000000e75f8  /system/lib64/libsurfaceflinger.so (android::ExBufferLayer::isHDRLayer() const+48)"
PATCHED="/Users/erfanabdi/Downloads/motosurface/libsurfaceflinger.so"
#PATCHED="/data/local/tmp/libsurfaceflinger.so"

PATCH()
{
    local HDROFFSET=$1
    local LIBSURFACEFLINGER=$2
    local PATCHED=$3
    echo $HDROFFSET $LIBSURFACEFLINGER $PATCHED
}

while true; do
    #HDRLINE=$(adb logcat -d | grep isHDRLayer)
    #HDRLINE=$(logcat -d | grep isHDRLayer)
    if [ -z "$HDRLINE" ]; then
        continue
    fi
    break
done

LIBSURFACEFLINGER=$(echo $HDRLINE | grep -o "/system/lib.*/libsurfaceflinger.so")
HDROFFSET=$(echo $HDRLINE | sed "s|/system/lib.*/libsurfaceflinger.so.*||" | rev | awk '{ print $1 }' | rev)
PATCH "$HDROFFSET" "$LIBSURFACEFLINGER" "$PATCHED"

stop surfaceflinger

if mount -o remount,rw /system_root; then
    cp -fpr "$PATCHED" "/system_root$LIBSURFACEFLINGER"
    mount -o remount,ro /system_root || true
fi
if mount -o remount,rw /system; then
    cp -fpr "$PATCHED" "/system$LIBSURFACEFLINGER"
    mount -o remount,ro /system || true
fi

start surfaceflinger
