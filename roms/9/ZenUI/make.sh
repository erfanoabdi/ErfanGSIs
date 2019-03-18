#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# build.prop
#cp -fpr $thispath/build.prop $1/
$thispath/../../../scripts/propcleanner.sh $1/build.prop > $thispath/../../../tmp/build.prop
cp -fpr $thispath/../../../tmp/build.prop $1/
echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop

# drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/etc/prop.default
echo "ro.setupwizard.mode=DISABLED" >> $1/etc/prop.default
# remove phh qtiaudio
rm -rf $1/priv-app/QtiAudio
rm -rf $1/app/NQNfcNci
#rm -rf $1/app/Bluetooth

# remove notch
cp -fpr $thispath/framework-res.apk $1/framework/
