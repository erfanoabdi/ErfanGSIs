#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    distro=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
    if [[ "$distro" == "arch" ]]; then
       echo "Arch Linux Detected"
       sudo pacman -Sy --needed unace unrar zip unzip p7zip sharutils uudeview arj cabextract file-roller dtc xz python-pip python2-pip brotli lz4 gawk libmpack aria2
       #aur=rar
    else
       sudo apt install unace unrar zip unzip p7zip-full p7zip-rar sharutils rar uudeview mpack arj cabextract file-roller device-tree-compiler liblzma-dev python-pip brotli liblz4-tool gawk aria2
    fi
    python2 -m pip install backports.lzma protobuf pycrypto
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install protobuf xz brotli lz4 aria2
    python2 -m pip install backports.lzma protobuf pycrypto
fi

python --version 2 >&1|grep -E '^Python 2' >/dev/null
if [ $? = 1 ]; then
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        mkdir -p ~/.tempbin/erfangsi
        ln -s /usr/bin/python2 .tempbin/python
        ln -s /usr/bin/pip2 .tempbin/pip
        export PATH=.tempbin/erfangsi:$PATH
    fi
fi
