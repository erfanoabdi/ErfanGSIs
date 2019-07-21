#!/bin/bash

# usage: apkedit.sh app.apk patch.sh platform

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
apppath=$1
patch=$2
sign=$3

apktool=$LOCALDIR/../tools/apktool/apktool.jar
tmp=$LOCALDIR/../tools/apktool/tmp
appname=`echo "$apppath" | rev | cut -d "/" -f 1 | rev`
appnamenoapk=`echo "$appname" | cut -d "." -f 1`
appdirtmp=$tmp/$appname
mkdir -p $appdirtmp

cp $apppath $appdirtmp/
cd $appdirtmp
java -jar $apktool d $appname

$patch $appdirtmp/$appnamenoapk

cd $appdirtmp/$appnamenoapk

java -jar $apktool b

notsigned=$appdirtmp/$appnamenoapk/dist/$appname

rm -rf $apppath

java -jar $LOCALDIR/../tools/ROM_resigner/signapk.jar $LOCALDIR/../tools/ROM_resigner/AOSP_security/$sign.x509.pem $LOCALDIR/../tools/ROM_resigner/AOSP_security/$sign.pk8 $notsigned $apppath

cd $LOCALDIR
rm -rf $tmp

