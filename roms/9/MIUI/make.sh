#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# build.prop
#cp -fpr $thispath/build.prop $1/
$thispath/../../../scripts/propcleanner.sh $1/build.prop > $thispath/../../../tmp/build.prop
cp -fpr $thispath/../../../tmp/build.prop $1/
# AOSP libs
cp -fpr $thispath/lib/* $1/lib/
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/init/* $1/etc/init/
# drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml
# drop dirac
rm -rf $1/priv-app/DiracAudioControlService
# remove phh qtiaudio
rm -rf $1/priv-app/QtiAudio

rm -rf $1/app/cit
rm -rf $1/app/MiuiCompass
rm -rf $1/app/MiuiScreenRecorder
rm -rf $1/app/MiuiVideoGlobal
rm -rf $1/app/Notes
rm -rf $1/app/PaymentService
rm -rf $1/app/Calculator
rm -rf $1/priv-app/Backup
rm -rf $1/priv-app/Browser
rm -rf $1/priv-app/Calendar
rm -rf $1/priv-app/CleanMaster
rm -rf $1/priv-app/MiRecycle
rm -rf $1/priv-app/MiuiScanner
rm -rf $1/priv-app/MiWebView
rm -rf $1/priv-app/Updater
rm -rf $1/priv-app/Velvet
rm -rf $1/priv-app/Weather
rm -rf $1/priv-app/WeatherProvider

#rm -rf $1/fonts/NotoSansEgyptianHieroglyphs-Regular.ttf
#rm -rf $1/fonts/NotoSansTibetan-Bold.ttf
#rm -rf $1/fonts/NotoSansTibetan-Regular.ttf
#rm -rf $1/fonts/NotoSerifCJK-Regular.ttc
#rm -rf $1/fonts/NotoSansCJK-Regular.ttc
#rm -rf $1/fonts/NotoSansCuneiform-Regular.ttf
#rm -rf $1/media/theme/miui_mod_icons
