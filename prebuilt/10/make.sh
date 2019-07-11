#/bin/bash

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
rm -rf $1/apex/com.android.conscrypt.apex
rm -rf $1/apex/com.android.media.apex
rm -rf $1/apex/com.android.media.swcodec.apex
rm -rf $1/apex/com.android.resolv.apex
rm -rf $1/apex/com.android.runtime.*.apex
rm -rf $1/apex/com.android.tzdata.apex
cp -fpr $thispath/apex/* $1/apex/
