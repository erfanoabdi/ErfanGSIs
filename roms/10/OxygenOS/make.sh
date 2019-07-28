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
sed -i "/\/vendor\/etc\/audio /d" $1/bin/rw-system.sh

# drop dirac
rm -rf $1/priv-app/DiracAudioControlService
rm -rf $1/app/DiracManager
rm -rf $1/app/NxpNfcNci

# fix op6t notch
sed -i "s/M-185,0 H183.34 c-9.77.44-19.57,0.08-29.28,1.24-20.33,1.14-41.18,5.17-58.62,16.24 C78.54,28.27,66,44.26,52,58.29 a72.73,72.73,0,0,1-38.29,19.58 c-16.53,2.51-34,1-49.09-6.62-9.85-4.62-17.88-12.24-25.21-20.18-10.46-11.27-20.9-22.75-33.53-31.66-11.49-8-24.9-12.78-38.53-15.42 C-149.92,0.81,-167.51.39,-185,0Z/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk

# fix op6 notch
sed -i "s/M 0,0 L -183, 0 A 24.0, 24.0, 0, 0, 1, -159.0, 22.0 A 64.0, 64.0, 0, 0, 0, -95.0, 80.0 L 95.0, 80.0 A 64.0, 64.0, 0, 0, 0, 159.0, 22.0 A 24.0, 24.0, 0, 0, 1, 183.0, 0 Z/000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk
sed -i "s/M-184.95,0 C-168,0.12,-160.84,7.45,-158.7,24.11 c4,31.21,25.33,54.92,63.5,54.92 H95.2 c38.18,0,59.5-23.71,63.5-54.92 C160.84,7.45,168,.12,184.95,0 H-184.95Z/000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk

# Wifi fix
cp -fpr $thispath/bin/* $1/bin/
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh
