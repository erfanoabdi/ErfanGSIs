#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy system files
rsync -ra $thispath/system/ $systempath

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts

#Soundsssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
echo "ro.config.mms_notification=free.ogg" >> $1/etc/prop.default
echo "ro.config.notification_sound=meet.ogg" >> $1/etc/prop.default
echo "ro.config.alarm_alert=spring.ogg" >> $1/etc/prop.default
echo "ro.config.ringtone=oneplus_tune.ogg" >> $1/etc/prop.default

# Fix rounded corner and long press options in OnePlus Launcher
echo "ro.boot.project_name=17801" >> $1/build.prop

# fix bt audio for op gsi
sed -i "/\/vendor\/etc\/audio /d" $1/bin/rw-system.sh

# drop dirac
rm -rf $1/app/NxpNfcNci

# fix op6t notch
sed -i "s/M-185,0 H183.34 c-9.77.44-19.57,0.08-29.28,1.24-20.33,1.14-41.18,5.17-58.62,16.24 C78.54,28.27,66,44.26,52,58.29 a72.73,72.73,0,0,1-38.29,19.58 c-16.53,2.51-34,1-49.09-6.62-9.85-4.62-17.88-12.24-25.21-20.18-10.46-11.27-20.9-22.75-33.53-31.66-11.49-8-24.9-12.78-38.53-15.42 C-149.92,0.81,-167.51.39,-185,0Z/00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk

# fix op6 notch
sed -i "s/M 0,0 L -183, 0 A 24.0, 24.0, 0, 0, 1, -159.0, 22.0 A 64.0, 64.0, 0, 0, 0, -95.0, 80.0 L 95.0, 80.0 A 64.0, 64.0, 0, 0, 0, 159.0, 22.0 A 24.0, 24.0, 0, 0, 1, 183.0, 0 Z/000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk
sed -i "s/M-184.95,0 C-168,0.12,-160.84,7.45,-158.7,24.11 c4,31.21,25.33,54.92,63.5,54.92 H95.2 c38.18,0,59.5-23.71,63.5-54.92 C160.84,7.45,168,.12,184.95,0 H-184.95Z/000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/" $1/framework/framework-res.apk

# Wifi fix
cp -fpr $thispath/bin/* $1/bin/
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

# Feature_list Tweaks
feature_list="
OP_FEATURE_AI_BOOST_PACKAGE
OP_FEATURE_APP_PRELOAD
OP_FEATURE_BUGREPORT
OP_FEATURE_OHPD
OP_FEATURE_OPDIAGNOSE
OP_FEATURE_PRELOAD_APP_TO_DATA
OP_FEATURE_SMART_BOOST
"
 for i in $feature_list ; do
   if [ "$(grep $i $1/etc/feature_list)" != "" ]; then
     sed -i -e "/$i/{n;d}" -e "$!N;/\n.*$i/!P;D" $1/etc/feature_list
     sed -i "/$i/d" $1/etc/feature_list
   fi
done
