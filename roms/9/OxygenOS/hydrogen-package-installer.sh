#/bin/bash

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
apppath=$1

rm -rf $1/priv-app/PackageInstaller
cp -r $LOCALDIR/priv-app/PackageInstaller $1/priv-app/
