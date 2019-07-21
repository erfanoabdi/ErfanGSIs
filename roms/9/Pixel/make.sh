#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
cp -fpr $thispath/overlay/* $1/product/overlay/

# pixel theme
echo "ro.boot.vendor.overlay.theme=com.google.android.theme.pixel" >> $1/etc/prop.default
# enable P hotness
echo "persist.sys.overlay.photness=true" >> $1/etc/prop.default
echo "persist.sys.overlay.pixelrecents=true" >> $1/etc/prop.default
echo "qemu.hw.mainkeys=0" >> $1/etc/prop.default
# fix marlin plat_service_contexts
sed -i "/qti.ims.connectionmanagerservice/d" $1/etc/selinux/plat_service_contexts

