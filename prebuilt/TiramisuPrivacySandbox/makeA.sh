#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy phh stuffs
cp -fpr $thispath/init_A/* $1/etc/init/

# copy apex stuffs
rm -rf $1/bin/linker
rm -rf $1/bin/linker64
rm -rf $1/bin/linker_asan
rm -rf $1/bin/linker_asan64
rm -rf $1/lib/libc.so
rm -rf $1/lib/libdl.so
rm -rf $1/lib/libm.so
rm -rf $1/lib64/libc.so
rm -rf $1/lib64/libdl.so
rm -rf $1/lib64/libm.so
cp -fpr $1/lib/bootstrap/* $1/lib/
cp -fpr $1/lib64/bootstrap/* $1/lib64/
cp -fpr $1/bin/bootstrap/* $1/bin/

mv $1/product_services/app/* $1/app/
mv $1/product_services/priv-app/* $1/priv-app/
mv $1/product_services/etc/permissions/* $1/etc/permissions/
