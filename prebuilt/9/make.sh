#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Copy some stuffs
$thispath/overlays/make.sh "$systempath"
