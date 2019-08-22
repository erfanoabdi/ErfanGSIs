#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

#TODO build.prop
#cp -fpr $thispath/build.prop $1/
# drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/etc/prop.default
echo "ro.setupwizard.mode=DISABLED" >> $1/etc/prop.default

# remove phh qtiaudio
rm -rf $1/priv-app/QtiAudio

# remove annoying WarrantyTime
rm -rf $1/app/SemcWarrantyTime

# remove cacaoserver
rm -rf $1/bin/cacaoserver

# fix lid state
sed -i "s|sys/devices/virtual/switch/lid/state|system/erfan/this_is_only_zero_state|g" $1/framework/oat/arm64/services.vdex

# copy vendor stuffs
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/erfan $1/
cp -fpr $thispath/bin-hw/* $1/bin/hw/
cp -fpr $thispath/lib64/* $1/lib64/
#cp -fpr $thispath/manifest.xml $1/etc/vintf/
cp -fpr $thispath/app/* $1/app/
cp -fpr $thispath/framework/* $1/framework/

python $thispath/../../../scripts/custom_manifest.py $thispath/../../../tmp/manifest.xml $thispath/manifest.xml $1/etc/vintf/manifest.xml
cp -fpr $thispath/../../../tmp/manifest.xml $1/etc/vintf/manifest.xml

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts

# deodex system
$thispath/../../../scripts/oat2dex.sh $1/framework
