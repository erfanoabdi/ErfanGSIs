#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy phh stuffs
cp -fpr $thispath/app/* $1/app/
cp -fpr $thispath/overlay/* $1/product/overlay/
