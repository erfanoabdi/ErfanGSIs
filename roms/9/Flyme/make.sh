#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# build.prop
echo "ro.bootprof.disable=1" >> $1/build.prop

# Custom files
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/erfan $1/

# hack bootprof
sed -i "s|/sys/bootprof/bootprof|/system/erfan/bootprof|g" $1/lib/libsurfaceflinger.so
sed -i "s|/sys/bootprof/bootprof|/system/erfan/bootprof|g" $1/lib64/libsurfaceflinger.so
