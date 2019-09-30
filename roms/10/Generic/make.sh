#!/bin/bash
systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Saw that some roms do not have permission to write internal storage > build.prop
echo "ro.build.system_root_image=true" >> $1/build.prop
