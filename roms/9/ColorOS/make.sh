#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Workaround for SetupWizard Problem
# Remove Oppo's SetupWizard and push GoogleSetupWizard
# Then disable SetupWizard with prop.
rm -rf $1/priv-app/OppoBootReg
cp -fpr $thispath/SetupWizard $1/priv-app/

sed -i "s/vendor.oppo.hardware.cryptoeng/vendor.fuck.hardware.cryptoeng/g" $1/etc/vintf/manifest.xml

# hack phoenix
sed -i "s|/proc/phoenix|/data/erf/phx|g" $1/framework/boot-framework.vdex
sed -i "s|/proc/phoenix|/data/erf/phx|g" $1/lib/libphoenix_native.so
sed -i "s|/proc/phoenix|/data/erf/phx|g" $1/lib64/libphoenix_native.so
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh
