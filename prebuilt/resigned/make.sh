#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy system stuffs
rsync -ra $thispath/system/ $systempath

python $thispath/../../scripts/custom_manifest.py $1/../../manifest.xml $thispath/manifest.xml $1/etc/vintf/manifest.xml
cp -fpr $1/../../manifest.xml $1/etc/vintf/manifest.xml
