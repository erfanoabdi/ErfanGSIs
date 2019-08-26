#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# moto wifi hal files (also vold and vdc)
cp -fpr $thispath/bin/* $1/bin/
cp -fpr $thispath/lib64/* $1/lib64/
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

# add moto wifi hal to manifest
python $thispath/../../../scripts/custom_manifest.py $thispath/../../../tmp/manifest.xml $thispath/manifest.xml $1/etc/vintf/manifest.xml
cp -fpr $thispath/../../../tmp/manifest.xml $1/etc/vintf/manifest.xml

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts

# set fake fingerprint
"ro.build.fingerprint=motorola/nash/nash:8.0.0/OPXS27.109-34-10/5:user/release-keys" >> $1/build.prop

# libaudioclient
cp -fpr $thispath/vndk-28-arm32/* $1/lib/vndk-28/

# Hotspot overlay
cp -fpr $thispath/overlay/* $1/product/overlay/

# Disable frp prop
echo "ro.frp.pst=" >> $1/etc/prop.default
