#/bin/bash

url=$1
srctype=$2

mkdir downloads

wget $url -O downloads/temp.zip
./zip2img.sh downloads/temp.zip
mkdir system
mount cache/system.img system
./make.sh system $srctype AB
./make.sh system $srctype Aonly

ls -ln out/
