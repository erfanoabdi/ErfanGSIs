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
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

python $thispath/../../../scripts/custom_manifest.py $thispath/../../../tmp/manifest.xml $thispath/manifest.xml $1/etc/vintf/manifest.xml
cp -fpr $thispath/../../../tmp/manifest.xml $1/etc/vintf/manifest.xml

# build.prop
#cp -fpr $thispath/build.prop $1/
#echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop
# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/etc/prop.default
echo "ro.setupwizard.mode=DISABLED" >> $1/etc/prop.default

# Enable OnePlus Call Recording
chmod 0644 $1/etc/init/opstuffs.rc

# drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml

# fix bt audio for op gsi
sed -i "/\/vendor\/etc\/audio /d" $1/bin/rw-system.sh

# drop dirac
rm -rf $1/priv-app/DiracAudioControlService
rm -rf $1/app/DiracManager
rm -rf $1/app/NxpNfcNci

# fix dash state
cp -fpr $thispath/erfan $1/
sed -i "s|/sys/class/power_supply/battery/chg_protect_status|/system/erfan///////////////////////////zero_state|g" $1/framework/oat/arm64/services.vdex
sed -i "s|/sys/class/power_supply/battery/fastchg_status_is_ok|/system/erfan/////////////////////////////zero_state|g" $1/framework/oat/arm64/services.vdex
sed -i "s|/sys/class/power_supply/battery/short_c_hw_status|/system/erfan//////////////////////////zero_state|g" $1/framework/oat/arm64/services.vdex
sed -i "s|/sys/class/power_supply/battery/short_ic_otp_status|/system/erfan////////////////////////////zero_state|g" $1/framework/oat/arm64/services.vdex
sed -i "s|/sys/class/power_supply/battery/fastchg_status|/system/erfan///////////////////////zero_state|g" $1/framework/oat/arm64/services.vdex

# fix op6t notch
sed -i "s/M-185,0 H183.34 c-9.77.44-19.57,0.08-29.28,1.24-20.33,1.14-41.18,5.17-58.62,16.24 C78.54,28.27,66,44.26,52,58.29 a72.73,72.73,0,0,1-38.29,19.58 c-16.53,2.51-34,1-49.09-6.62-9.85-4.62-17.88-12.24-25.21-20.18-10.46-11.27-20.9-22.75-33.53-31.66-11.49-8-24.9-12.78-38.53-15.42 C-149.92,0.81,-167.51.39,-185,0Z/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk

# fix op6 notch
sed -i "s/M 0,0 L -183, 0 A 24.0, 24.0, 0, 0, 1, -159.0, 22.0 A 64.0, 64.0, 0, 0, 0, -95.0, 80.0 L 95.0, 80.0 A 64.0, 64.0, 0, 0, 0, 159.0, 22.0 A 24.0, 24.0, 0, 0, 1, 183.0, 0 Z/000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk
sed -i "s/M-184.95,0 C-168,0.12,-160.84,7.45,-158.7,24.11 c4,31.21,25.33,54.92,63.5,54.92 H95.2 c38.18,0,59.5-23.71,63.5-54.92 C160.84,7.45,168,.12,184.95,0 H-184.95Z/000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk
