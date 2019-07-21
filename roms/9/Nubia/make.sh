#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/init/* $1/etc/init/
