#!/bin/bash

# booooo
systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

#Data read only fix > build.prop
echo "ro.build.system_root_image=true" >> $1/build.prop
