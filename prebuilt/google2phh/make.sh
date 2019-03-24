#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy phh stuffs
cp -fpr $thispath/phh $1/
cp -fpr $thispath/ph $1/
cp -fpr $thispath/etc/* $1/etc/
cp -fpr $thispath/usr_idc/* $1/usr/idc/
cp -fpr $thispath/bin/* $1/bin/
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/ld/* $1/etc/
#cp -fpr $thispath/priv-app/* $1/priv-app/
#cp -fpr $thispath/app/* $1/app/
#cp -fpr $thispath/overlay $1/product/

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts

# Append props
cat $thispath/build.prop >> $1/build.prop

# Disable Actionable props
sed -i "/ro.actionable_compatible_property.enabled/d" $1/etc/prop.default

# enable logcat
sed -i "s/u:object_r:logcat_exec:s0/u:object_r:logd_exec:s0/g" $1/etc/selinux/plat_file_contexts

# disable any setupwizard mode
sed -i "/ro.setupwizard.mode/d" $1/etc/prop.default
sed -i "/ro.setupwizard.mode/d" $1/build.prop

# disable RescureParty
echo "persist.sys.disable_rescue=true" >> $1/etc/prop.default
# fix vndk26 vold
sed -i "/reserved_disk/d" $1/etc/init/vold.rc

# drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml
rm -rf $1/etc/permissions/com.qti.dpmframework.xml

sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/etc/prop.default
rm -rf $1/priv-app/DiracAudioControlService
rm -rf $1/app/DiracManager
echo "ro.setupwizard.mode=DISABLED" >> $1/etc/prop.default

# cleanup build prop
$thispath/../../scripts/propcleanner.sh $1/build.prop > $thispath/../../tmp/build.prop
cp -fpr $thispath/../../tmp/build.prop $1/

cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

# cleanup props
plat_property=$1/etc/selinux/plat_property_contexts
sed -i "/ro.opengles.version/d" $plat_property
sed -i "/sys.usb.configfs/d" $plat_property
sed -i "/sys.usb.controller/d" $plat_property
sed -i "/sys.usb.config/d" $plat_property
sed -i "/ro.build.fingerprint/d" $plat_property
