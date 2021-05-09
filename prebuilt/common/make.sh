#!/bin/bash

systempath=$1
romdir=$2
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

## System edits
# Copy system files
rsync -ra $thispath/system/ $systempath
# Remove libdolphin.so
rm -rf $1/lib64/libdolphin.so
# Drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml
rm -rf $1/etc/permissions/com.qti.dpmframework.xml
# We no Dirac here
rm -rf $1/priv-app/DiracAudioControlService
rm -rf $1/app/DiracManager
# Drop qcom location
rm -rf $1/priv-app/com.qualcomm.location

## SELinux
# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts
# enable logcat
sed -i "s/u:object_r:logcat_exec:s0/u:object_r:logd_exec:s0/g" $1/etc/selinux/plat_file_contexts
# cleanup plat_property
plat_property=$1/etc/selinux/plat_property_contexts
sed -i "/ro.opengles.version/d" $plat_property
sed -i "/sys.usb.configfs/d" $plat_property
sed -i "/sys.usb.controller/d" $plat_property
sed -i "/sys.usb.config/d" $plat_property
sed -i "/ro.build.fingerprint/d" $plat_property


## Props
# Append props
cat $thispath/build.prop >> $1/build.prop
# Disable Actionable props
sed -i "/ro.actionable_compatible_property.enabled/d" $1/etc/prop.default
sed -i "/ro.actionable_compatible_property.enabled/d" $1/build.prop
# disable any setupwizard mode
sed -i "/ro.setupwizard.mode/d" $1/etc/prop.default
sed -i "/ro.setupwizard.mode/d" $1/build.prop
sed -i "/ro.setupwizard.mode/d" $1/product/build.prop
sed -i "/ro.setupwizard.mode/d" $1/product/etc/build.prop
if [[ -f $1/product/etc/build.prop ]]; then
    echo "ro.setupwizard.mode=DISABLED" >> $1/product/etc/build.prop
else
    echo "ro.setupwizard.mode=DISABLED" >> $1/etc/prop.default
    echo "ro.setupwizard.mode=DISABLED" >> $1/product/build.prop
fi
# Disable vndk lite
if [[ -f $1/product/etc/build.prop ]]; then
    echo "ro.vndk.lite=false" >> $1/product/etc/build.prop
else
    echo "ro.vndk.lite=false" >> $1/etc/prop.default
    echo "ro.vndk.lite=false" >> $1/product/build.prop
fi
# disable RescureParty
if [[ -f $1/product/etc/build.prop ]]; then
    echo "persist.sys.disable_rescue=true" >> $1/product/etc/build.prop
else
    echo "persist.sys.disable_rescue=true" >> $1/etc/prop.default
fi
# disable privapp_permissions checking
if [[ -f $1/product/etc/build.prop ]]; then
    echo "ro.control_privapp_permissions=disable" >> $1/product/etc/build.prop
else
    echo "ro.control_privapp_permissions=disable" >> $1/etc/prop.default
    echo "ro.control_privapp_permissions=disable" >> $1/product/build.prop
fi
# fix vndk26 vold
sed -i "/reserved_disk/d" $1/etc/init/vold.rc
# Adb prop
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/etc/prop.default
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/build.prop
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/product/etc/build.prop
# Use qti Bluetooth lib if avaliable
if [ -f $1/lib64/libbluetooth_qti.so ]; then
    echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop
fi
# Disable adb secure
sed -i "s/ro.adb.secure=1/ro.adb.secure=0/g" $1/etc/prop.default
sed -i "s/ro.adb.secure=1/ro.adb.secure=0/g" $1/build.prop
# cleanup build prop
if grep -q ADDITIONAL_BUILD_PROPERTIES $1/build.prop; then
    $thispath/../../scripts/propcleanner.sh $1/build.prop > $1/../../build.prop
    cp -fpr $1/../../build.prop $1/
fi
if grep -q post_process_props $1/product/etc/build.prop; then
    $thispath/../../scripts/propcleannerS.sh $1/product/etc/build.prop > $1/../../build.prop
    cp -fpr $1/../../build.prop $1/product/etc/
fi


## Append to phh script
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh
