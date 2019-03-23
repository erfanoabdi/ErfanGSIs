#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
cp -fpr $thispath/lib/* $1/lib/
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/init/* $1/etc/init/

# Copy phh stuffs
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

# Media Fix
cp -fpr $thispath/ataberk $1/

# Workaround for SetupWizard Problem
# Remove Oppo's SetupWizard and push GoogleSetupWizard
# Then disable SetupWizard with prop.
rm -rf $1/priv-app/OppoBootReg
cp -fpr $thispath/SetupWizard $1/priv-app/
echo "ro.setupwizard.mode=DISABLED" >> $1/build.prop

# Fix packageinstaller
echo "ro.build.version.sdk=28" >> $1/build.prop

# Fix Selinux - Fastboot kick
cp -fpr $thispath/selinux/plat_sepolicy.cil $1/etc/selinux/plat_sepolicy.cil
cp -fpr $thispath/selinux/28.0.cil $1/etc/selinux/mapping/28.0.cil

# Bloatware clean-up - Fit to 3GB
rm -rf $1/app/BackupAndRestore
rm -rf $1/app/BTtestmode
rm -rf $1/app/FindMyPhoneClient
rm -rf $1/app/GameSpace
rm -rf $1/app/ModemTestMode
rm -rf $1/app/NewSoundRecorder
rm -rf $1/app/talkback
rm -rf $1/priv-app/GmsCore
rm -rf $1/priv-app/TestApp5G