#/bin/bash

url=$1
srctype=$2

mkdir downlaods

wget $url -O downlaods/temp.zip
./zip2img.sh downlaods/temp.zip
mkdir system
mount cache/system.img system
./make.sh system $srctype AB
./make.sh system $srctype Aonly

ls -ln out/
