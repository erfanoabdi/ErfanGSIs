#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# build.prop
#cp -fpr $thispath/build.prop $1/
#echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop

# drop finddevice, needs to be done before copying system files
rm -rf $1/priv-app/FindDevice

# Copy system files
rsync -ra $thispath/system/ $systempath

# AOSP libs
cp -fpr $thispath/lib/* $1/lib/
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/overlay/* $1/product/overlay/

# drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml
# drop dirac
rm -rf $1/priv-app/DiracAudioControlService
# remove phh qtiaudio
rm -rf $1/priv-app/QtiAudio
# drop FingerprintExtensionService
rm -rf $1/app/FingerprintExtensionService
# drop nfc
rm -rf $1/app/NQNfcNci

cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

sed -i 's/<bool name="support_round_corner">true/<bool name="support_round_corner">false/' $1/etc/device_features/*

sed -i "/miui.notch/d" $1/build.prop
