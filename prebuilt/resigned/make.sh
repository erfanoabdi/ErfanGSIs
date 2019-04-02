#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy phh stuffs
cp -fpr $thispath/priv-app/* $1/priv-app/
