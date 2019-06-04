#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

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
