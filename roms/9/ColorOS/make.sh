#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Workaround for SetupWizard Problem
# Remove Oppo's SetupWizard and push GoogleSetupWizard
# Then disable SetupWizard with prop.
rm -rf $1/priv-app/OppoBootReg
cp -fpr $thispath/SetupWizard $1/priv-app/

# Custom files
cp -fpr $thispath/init/* $1/etc/init/
cp -fpr $thispath/bin/* $1/bin/

# drop QVRservice
rm -rf $1/bin/qvrservice

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts

# Fix packageinstaller
echo "ro.build.version.sdk=28" >> $1/build.prop

# oppo boot stage hacks
sed -i "s|/proc/phoenix|/data/erf/phx|g" $1/framework/boot-framework.vdex
sed -i "s|/proc/phoenix|/data/erf/phx|g" $1/lib/libphoenix_native.so
sed -i "s|/proc/phoenix|/data/erf/phx|g" $1/lib64/libphoenix_native.so

sed -i "s|/proc/opbootfrom|/data/erf/botfrm|g" $1/framework/oat/arm64/services.vdex

cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh
