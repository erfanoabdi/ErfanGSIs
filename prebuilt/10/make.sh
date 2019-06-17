#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy phh stuffs
cp -fpr $thispath/bin/* $1/bin/
cp -fpr $thispath/ld/* $1/etc/
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/permissions/* $1/etc/permissions/
#cp -fpr $thispath/app/* $1/app/
cp -fpr $thispath/overlay $1/product/

cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh
echo "persist.bluetooth.bluetooth_audio_hal.disabled=true" >> $1/build.prop

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts
