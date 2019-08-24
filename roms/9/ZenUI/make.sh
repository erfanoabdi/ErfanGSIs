#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# build.prop
#echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop

# Custom files
cp -fpr $thispath/lib64/* $1/lib64/

# Fix audio
model=$(sed -n 's/^ro.build.product=[[:space:]]*//p' "$1/build.prop")
size=${#model}
for n in $(seq $size);
do
    new=$new'\x00'
done
sed -i "s/audio_policy_configuration_$model.xml/audio_policy_configuration.xml\x00$new/" "$1/lib/libaudiopolicymanagerdefault.so"
sed -i "s/audio_policy_configuration_$model.xml/audio_policy_configuration.xml\x00$new/" "$1/lib64/libaudiopolicymanagerdefault.so"
