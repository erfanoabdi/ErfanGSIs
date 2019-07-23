#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
cp -fpr $thispath/lib/* $1/lib/
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/bin/* $1/bin/
cp -fpr $thispath/bin-hw/* $1/bin/hw/
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/priv-app/* $1/priv-app/
#cp -fpr $thispath/manifest.xml $1/etc/vintf/
cp -fpr $thispath/overlay/* $1/product/overlay/
cp -fpr $thispath/framework/* $1/framework/

python $thispath/../../../scripts/custom_manifest.py $thispath/../../../tmp/manifest.xml $thispath/manifest.xml $1/etc/vintf/manifest.xml
cp -fpr $thispath/../../../tmp/manifest.xml $1/etc/vintf/manifest.xml

# build.prop
#cp -fpr $thispath/build.prop $1/
echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop
# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/etc/prop.default
echo "ro.setupwizard.mode=DISABLED" >> $1/etc/prop.default

# Enable OnePlus Call Recording
chmod 0644 $1/etc/init/opstuffs.rc

# drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml

# fix bt audio for op gsi
sed -i "/\/vendor\/etc\/audio/d" $1/bin/rw-system.sh

# drop dirac
rm -rf $1/priv-app/DiracAudioControlService
rm -rf $1/app/DiracManager
rm -rf $1/app/NxpNfcNci

