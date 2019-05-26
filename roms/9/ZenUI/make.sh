#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# build.prop
echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop
