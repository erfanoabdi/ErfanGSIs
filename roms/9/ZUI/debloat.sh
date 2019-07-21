#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

rm -rf $1/preinstall
rm -rf $1/priv-app/ZuiXlog
rm -rf $1/priv-app/ZuiCamera
