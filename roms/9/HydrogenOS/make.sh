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

# fix op6t notch
sed -i "s/M-185,0 H183.34 c-9.77.44-19.57,0.08-29.28,1.24-20.33,1.14-41.18,5.17-58.62,16.24 C78.54,28.27,66,44.26,52,58.29 a72.73,72.73,0,0,1-38.29,19.58 c-16.53,2.51-34,1-49.09-6.62-9.85-4.62-17.88-12.24-25.21-20.18-10.46-11.27-20.9-22.75-33.53-31.66-11.49-8-24.9-12.78-38.53-15.42 C-149.92,0.81,-167.51.39,-185,0Z/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk
