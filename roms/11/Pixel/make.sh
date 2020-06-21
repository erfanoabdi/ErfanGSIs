#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
cp -fpr $thispath/overlay/* $1/product/overlay/

# Append file_context
echo "ro.boot.vendor.overlay.theme=com.google.android.theme.pixel" >> $1/etc/prop.default
echo "ro.config.ringtone=The_big_adventure.ogg" >> $1/etc/prop.default
echo "ro.config.notification_sound=Popcorn.ogg" >> $1/etc/prop.default
echo "ro.config.alarm_alert=Bright_morning.ogg" >> $1/etc/prop.default
echo "persist.sys.overlay.pixelrecents=true" >> $1/etc/prop.default
echo "qemu.hw.mainkeys=0" >> $1/etc/prop.default

sed -i "/dataservice_app/d" $1/product/etc/selinux/product_seapp_contexts
sed -i "/dataservice_app/d" $1/system_ext/etc/selinux/system_ext_seapp_contexts
