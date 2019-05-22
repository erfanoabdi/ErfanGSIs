#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

rm -rf $1/app/Drive
rm -rf $1/app/Duo
rm -rf $1/app/Maps
rm -rf $1/app/YouTube
rm -rf $1/app/talkback
#rm -rf $1/app/Chrome
rm -rf $1/app/CalendarGoogle
rm -rf $1/app/Photos
rm -rf $1/app/GooglePay
rm -rf $1/app/Music2
rm -rf $1/app/Gmail2
rm -rf $1/app/GoogleTTS
rm -rf $1/app/OEMLogKit
rm -rf $1/app/OPBackup
rm -rf $1/priv-app/OnePlusCamera
rm -rf $1/priv-app/OnePlusGallery
rm -rf $1/priv-app/Velvet
rm -rf $1/priv-app/Videos
rm -rf $1/OPFaceUnlock
rm -rf $1/reserve/OPNote
rm -rf $1/reserve/SoundRecorder
rm -rf $1/reserve/OPForum
rm -rf $1/reserve/OPBackupRestore
