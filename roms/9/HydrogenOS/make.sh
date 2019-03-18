#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
cp -fpr $thispath/lib/* $1/lib/
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/bin/* $1/bin/
cp -fpr $thispath/bin-hw/* $1/bin/hw/
cp -fpr $thispath/init/* $1/etc/init/
#cp -fpr $thispath/manifest.xml $1/etc/vintf/
cp -fpr $thispath/vndk-27-arm32/* $1/lib/vndk-27/
cp -fpr $thispath/vndk-27-arm64/* $1/lib64/vndk-27/

python $thispath/../../../scripts/custom_manifest.py $thispath/../../../tmp/manifest.xml $thispath/manifest.xml $1/etc/vintf/manifest.xml
cp -fpr $thispath/../../../tmp/manifest.xml $1/etc/vintf/manifest.xml

# build.prop
#cp -fpr $thispath/build.prop $1/
$thispath/../../../scripts/propcleanner.sh $1/build.prop > $thispath/../../../tmp/build.prop
cp -fpr $thispath/../../../tmp/build.prop $1/
echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop
# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/etc/prop.default
echo "ro.setupwizard.mode=DISABLED" >> $1/etc/prop.default

# drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml

# drop dirac
rm -rf $1/priv-app/DiracAudioControlService
rm -rf $1/app/DiracManager
rm -rf $1/app/NxpNfcNci
