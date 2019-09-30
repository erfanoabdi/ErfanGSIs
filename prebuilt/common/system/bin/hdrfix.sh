#!/system/bin/sh

# Project OEM-GSI Porter by Erfan Abdi <erfangplus@gmail.com>

# How this works
# 0) Wait for boot complete and surfaceflinger crash (on .rc script)
# 1) Read logcat for isHDRLayer
# 2) Find isHDRLayer offset
# 3) Find first "cbz" offset
# 4) Patch it to "cbnz" and save to /data/local/tmp/
# 5) Stop surfaceflinger
# 6) Patch lib (if system mounts as rw, lib patches directly but if not, patched lib bind mounts in every boot)
# 7) Start surfaceflinger

DUMPSURF="/data/local/tmp/dumpsurf.txt"

PATCH()
{
    local HDROFFSET=$1
    local LIBSURFACEFLINGER=$2
    local REPLACE=$3
    echo $HDROFFSET $LIBSURFACEFLINGER
    objdump -d "$LIBSURFACEFLINGER" | grep " $HDROFFSET:" -B 7 > $DUMPSURF

    if [ -z "$(cat $DUMPSURF | head -n 1 | grep cbz)" ]; then
        echo "Live Patch not supported on this lib"
        exit
    fi
    CBZ=$(cat $DUMPSURF | head -n 1 | awk '{ print "\\x"$2"\\x"$3"\\x"$4"\\xb4" }')
    CBNZ=$(cat $DUMPSURF | head -n 1 | awk '{ print "\\x"$2"\\x"$3"\\x"$4"\\xb5" }')
    BL=$(cat $DUMPSURF | head -n 2 | tail -n 1 | awk '{ print "\\x"$2"\\x"$3"\\x"$4"\\x"$5 }')
    stop surfaceflinger
    if [ $REPLACE == true ]; then
        gsed -i "s|$CBZ$BL|$CBNZ$BL|" "$LIBSURFACEFLINGER"
    else
        cp "$LIBSURFACEFLINGER" /data/local/tmp/libs.so
        gsed -i "s|$CBZ$BL|$CBNZ$BL|" /data/local/tmp/libs.so
        chmod 0644 /data/local/tmp/libs.so
        chcon u:object_r:system_file:s0 /data/local/tmp/libs.so
        sha1sum "$LIBSURFACEFLINGER" > /data/local/tmp/libsurfaceflinger.sha
        mount -o bind /data/local/tmp/libs.so "$LIBSURFACEFLINGER"
    fi
    start surfaceflinger
}

loop_times=60
i=0
while true; do
    HDRLINE=$(logcat -d | grep isHDRLayer | head -n 1)
    if [ -z "$HDRLINE" ]; then
        i=$(($i+1))
        if [ $i -gt $loop_times ]; then
            setprop isHDRLayer.patched 1
            exit
        fi
        sleep 1
        continue
    fi
    break
done

LIBSURFACEFLINGER=$(echo $HDRLINE | grep -o "/system/lib.*/libsurfaceflinger.so")
HDROFFSET=$(echo $HDRLINE | sed "s|/system/lib.*/libsurfaceflinger.so.*||" | sed $'s/./&\\\n/g' | sed -ne $'x;H;${x;s/\\n//g;p;}' | awk '{ print $1 }' | sed $'s/./&\\\n/g' | sed -ne $'x;H;${x;s/\\n//g;p;}' | sed 's/^0*//')

if mount -o remount,rw /system; then
    PATCH "$HDROFFSET" "$LIBSURFACEFLINGER" true
    mount -o remount,ro /system || true
else
    PATCH "$HDROFFSET" "$LIBSURFACEFLINGER" false
fi

setprop isHDRLayer.patched 1
