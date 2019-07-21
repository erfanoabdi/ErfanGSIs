#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy phh stuffs
cp -fpr $thispath/bin/* $1/bin/
cp -fpr $thispath/ld/* $1/etc/
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/permissions/* $1/etc/permissions/

cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh
echo "persist.bluetooth.bluetooth_audio_hal.disabled=true" >> $1/build.prop

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts

# Deal with non-flattened apex
$thispath/../../scripts/apex_extractor.sh $1/apex

# Disable Codec2
sed -i "s/android.hardware.media.c2/android.hardware.erfan.c2/g" $1/etc/vintf/manifest.xml
rm -rf $1/etc/vintf/manifest/manifest_media_c2_software.xml
