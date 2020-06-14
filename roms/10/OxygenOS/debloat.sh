#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

rm -rf $1/product/app/Drive
rm -rf $1/product/app/Duo
rm -rf $1/product/app/Maps
rm -rf $1/product/app/YouTube
rm -rf $1/product/app/talkback
#rm -rf $1/app/Chrome
rm -rf $1/product/app/CalendarGoogle
rm -rf $1/product/app/Photos
rm -rf $1/app/GooglePay
rm -rf $1/product/app/Music2
rm -rf $1/product/app/Gmail2
rm -rf $1/app/EngineeringMode
rm -rf $1/app/Netflix_Activation
rm -rf $1/app/Netflix_Stub
rm -rf $1/app/OPYellowpage
rm -rf $1/app/OPWallpaperResources
rm -rf $1/product/app/GoogleTTS
rm -rf $1/app/OEMLogKit
rm -rf $1/app/OPBackup
rm -rf $1/product/app/Videos
rm -rf $1/priv-app/OnePlusCamera
rm -rf $1/priv-app/OnePlusGallery
rm -rf $1/priv-app/Velvet
rm -rf $1/priv-app/OPFaceUnlock
rm -rf $1/reserve/OPNote
rm -rf $1/reserve/SoundRecorder
rm -rf $1/reserve/OPForum
rm -rf $1/reserve/OPBackupRestore
rm -rf $1/etc/GeoIP2-City.mmdb
rm -rf $1/app/QQBrowser
rm -rf $1/reserve/OPNote
rm -rf $1/reserve/OPCommunity
rm -rf $1/reserve/alipay
rm -rf $1/reserve/amap
rm -rf $1/reserve/ctrip
rm -rf $1/reserve/SinaWeibo
rm -rf $1/reserve/YoudaoDict
rm -rf $1/reserve/TencentNews
rm -rf $1/reserve/JD
rm -rf $1/reserve/Meituan
rm -rf $1/reserve/NeteaseCloudmusic
rm -rf $1/reserve/NeteaseMail

# RIL FIX
rm -rf $1/product/framework/op-telephony-common.jar

# Drop OnePlus useless services
rm -rf $1/app/LogKitSdService
rm -rf $1/app/OEMLogKit
rm -rf $1/app/OPBugReportLite
rm -rf $1/app/OPCommonLogTool
rm -rf $1/app/OPIntelliService
rm -rf $1/app/OPTelephonyDiagnoseManager
rm -rf $1/priv-app/Houston
rm -rf $1/priv-app/OPAppCategoryProvider
rm -rf $1/priv-app/OPDeviceManager
rm -rf $1/priv-app/OPDeviceManagerProvider
