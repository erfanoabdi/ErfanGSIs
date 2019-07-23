#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Enable OnePlus Call Recording
cp -fpr $thispath/init/* $1/etc/init/

# Some overlays
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

# fix bt audio for op gsi
sed -i "/\/vendor\/etc\/audio/d" $1/bin/rw-system.sh

# drop dirac
rm -rf $1/priv-app/DiracAudioControlService
rm -rf $1/app/DiracManager
rm -rf $1/app/NxpNfcNci
