#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# build.prop
echo "ro.bootprof.disable=1" >> $1/build.prop

# Custom files
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/erfan $1/
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/bin/* $1/bin/
cp -fpr $thispath/overlay/* $1/product/overlay/
cp -fpr $thispath/framework/* $1/framework/

# Append to phh script
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

# hack bootprof
sed -i "s|/sys/bootprof/bootprof|/system/erfan/bootprof|g" $1/lib/libsurfaceflinger.so
sed -i "s|/sys/bootprof/bootprof|/system/erfan/bootprof|g" $1/lib64/libsurfaceflinger.so

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts
