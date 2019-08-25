#!/bin/bash

# How this works
# 0) Wait for boot complete and surfaceflinger crash (on .rc script)
# 1) Read logcat for isHDRLayer
# 2) Find isHDRLayer offset
# 3) Find first "cbz" offset
# 4) Patch it to "cbnz" and save to /data/local/tmp/
# 5) Stop surfaceflinger
# 6) Patch lib
# 7) Start surfaceflinger

DUMPSURF="/data/local/tmp/dumpsurf.txt"

PATCH()
{
    local HDROFFSET=$1
    local LIBSURFACEFLINGER=$2
    echo $HDROFFSET $LIBSURFACEFLINGER
    objdump -d "$LIBSURFACEFLINGER" | grep " $HDROFFSET:" -B 7 > $DUMPSURF

    if [ -z "$(cat $DUMPSURF | head -n 1 | grep cbz)" ]; then
        echo "Live Patch not supported on this lib"
        exit
    fi
    CBZ=$(cat $DUMPSURF | head -n 1 | awk '{ print "\\x"$2"\\x"$3"\\x"$4 }')
    BL=$(cat $DUMPSURF | head -n 2 | tail -n 1 | awk '{ print "\\x"$2"\\x"$3"\\x"$4"\\x"$5 }')

    sed -i "s|$CBZ\xb4$BL|$CBZ\xb5$BL|" "$LIBSURFACEFLINGER"
}

while true; do
    HDRLINE=$(logcat -d | grep isHDRLayer)
    if [ -z "$HDRLINE" ]; then
        continue
    fi
    break
done

LIBSURFACEFLINGER=$(echo $HDRLINE | grep -o "/system/lib.*/libsurfaceflinger.so")
HDROFFSET=$(echo $HDRLINE | sed "s|/system/lib.*/libsurfaceflinger.so.*||" | rev | awk '{ print $1 }' | rev | sed 's/^0*//')
stop surfaceflinger

if mount -o remount,rw /system_root; then
    PATCH "$HDROFFSET" "/system_root$LIBSURFACEFLINGER"
    mount -o remount,ro /system_root || true
fi
if mount -o remount,rw /system; then
    PATCH "$HDROFFSET" "/system$LIBSURFACEFLINGER"
    mount -o remount,ro /system || true
fi

start surfaceflinger
