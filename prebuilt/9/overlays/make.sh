#/bin/bash

systempath=$1
romdir=$2
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy phh stuffs
cp -fpr $thispath/bin/* $1/bin/
cp -fpr $thispath/app/* $1/app/
cp -fpr $thispath/nondevice_overlay/* $1/product/overlay/

if [ -f $romdir/NODEVICEOVERLAY ]; then
    echo "Using device specific overlays is not supported in this rom. Skipping..."
else
    cp -fpr $thispath/overlay/* $1/product/overlay/
fi
