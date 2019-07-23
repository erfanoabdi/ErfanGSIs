#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/overlay/* $1/product/overlay/

# build.prop
# echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop

# Replace duplicated props
# TODO: Fixme properly
# remove anything below
#line 1 "device/qcom/sepolicy/generic/private/property_contexts"
#line 1 "device/qcom/sepolicy/qva/private/property_contexts"
cp -fpr $thispath/selinux/* $1/etc/selinux/
sed -i "/typetransition location_app/d" $1/etc/selinux/plat_sepolicy.cil

# Enable OnePlus Call Recording
sed -i "s/op_voice_recording_supported_by_mcc/op_voice_recording_supt_by_xxx/g" $1/priv-app/TeleService/TeleService.apk

# drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml

# fix bt audio for op gsi
sed -i "/\/vendor\/etc\/audio/d" $1/bin/rw-system.sh

# drop dirac
rm -rf $1/priv-app/DiracAudioControlService
rm -rf $1/app/DiracManager
rm -rf $1/app/NxpNfcNci
