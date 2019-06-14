#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
#cp -fpr $thispath/lib64/* $1/lib64/

# remove phh qtiaudio
rm -rf $1/priv-app/QtiAudio
rm -rf $1/app/NQNfcNci
