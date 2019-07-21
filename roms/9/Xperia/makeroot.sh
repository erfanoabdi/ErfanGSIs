#!/bin/bash

rootpath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

cp -fpr $thispath/root/init $1/
