#!/bin/bash

rootpath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

rm -rf $1/sbin/dashd
sed -i "/critical/d" $1/init.rc
