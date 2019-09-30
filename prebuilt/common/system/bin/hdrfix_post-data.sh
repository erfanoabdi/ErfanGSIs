#!/system/bin/sh

# Project OEM-GSI Porter by Erfan Abdi <erfangplus@gmail.com>

# Patch surfaceflinger on boot if already patched before
if mount -o remount,rw /system; then
    # Just checking remount ability
    mount -o remount,ro /system || true
else
    if [ -f /data/local/tmp/libs.so ]; then
        LIBSURFACEFLINGER="$(cat /data/local/tmp/libsurfaceflinger.sha | awk '{ print $2 }')"
        if [ "$(cat /data/local/tmp/libsurfaceflinger.sha)" == "$(sha1sum $LIBSURFACEFLINGER)" ]; then
            stop surfaceflinger
            mount -o bind /data/local/tmp/libs.so $LIBSURFACEFLINGER
            start surfaceflinger
            setprop isHDRLayer.patched 1
        fi
    fi
fi
