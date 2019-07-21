#!/bin/bash

rootpath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

sudo sed -i "s|/dev/uinput               0660   uhid       uhid|/dev/uinput               0660   system     bluetooth|" "$rootpath/ueventd.rc"
