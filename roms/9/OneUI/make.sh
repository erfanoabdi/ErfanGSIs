#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

rm -rf $1/lib/vndk-27
rm -rf $1/lib64/vndk-27
rm -rf $1/lib/vndk-26
rm -rf $1/lib64/vndk-26
rm -rf $1/lib/vndk-sp-27
rm -rf $1/lib64/vndk-sp-27
rm -rf $1/lib/vndk-sp-26
rm -rf $1/lib64/vndk-sp-26

# drop this shit
rm -rf $1/bin/sdp_cryptod

# AOSP libs
cp -fpr $thispath/lib/* $1/lib/
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/lib64-hw/* $1/lib64/hw/
cp -fpr $thispath/lib-hw/* $1/lib/hw/
cp -fpr $thispath/vndk-28-arm32/* $1/lib/vndk-28/
cp -fpr $thispath/vndk-28-arm64/* $1/lib64/vndk-28/

# Copy phh stuffs
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts

cp -fpr $thispath/bin/* $1/bin/
cp -fpr $thispath/bin-hw/* $1/bin/hw/
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/erfan $1/

#cp -fpr $thispath/manifest.xml $1/etc/vintf/
python $thispath/../../../scripts/custom_manifest.py $thispath/../../../tmp/manifest.xml $thispath/manifest.xml $1/etc/vintf/manifest.xml
cp -fpr $thispath/../../../tmp/manifest.xml $1/etc/vintf/manifest.xml

$thispath/debloat.sh "$systempath"
