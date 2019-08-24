#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy init
cp -fpr $thispath/init_A/* $1/etc/init/
