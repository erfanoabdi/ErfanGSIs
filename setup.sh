#!/bin/bash

grep -E "^NAME=" /etc/os-release | grep Fedora &>/dev/null
if [ $? = 0 ]; then
    sudo dnf install unace unrar zip unzip p7zip sharutils uudeview arj cabextract file-roller dtc xz python-pip brotli lz4 gawk \*mpack* aria2 xz-lzma*
    pip install backports.lzma protobuf pycrypto
    exit
fi
grep -E "^NAME=" /etc/os-release | grep CentOS &>/dev/null
if [ $? = 0 ]; then
    sudo dnf install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    sudo dnf install --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm 
    sudo dnf install --nogpgcheck https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
    sudo dnf config-manager --enable PowerTools
    sudo dnf groupupdate core
    sudo dnf install rpmfusion-free-release-tainted
    sudo dnf install rpmfusion-nonfree-release-tainted
    sudo dnf install unrar zip unzip p7zip sharutils arj innoextract file-roller dtc xz python2 python2-pip brotli lz4 gawk aria2 lzma \*mpack* gcc libffi-devel python2-devel openssl-devel xz-devel --skip-broken 
    sudo rm -f /usr/bin/pip
    sudo rm -f /usr/bin/python
    sudo ln -s /usr/bin/pip2.7 /usr/bin/pip
    sudo ln -s /usr/bin/python2 /usr/bin/python
    pip install backports.lzma protobuf pycrypto --user
    exit
fi
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    distro=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
    if [[ "$distro" == "arch" ]]; then
       echo "Arch Linux Detected"
       sudo pacman -S unace unrar zip unzip p7zip sharutils uudeview arj cabextract file-roller dtc xz python-pip brotli lz4 gawk libmpack aria2
       #aur=rar
    else
       sudo apt install unace unrar zip unzip p7zip-full p7zip-rar sharutils rar uudeview mpack arj cabextract file-roller device-tree-compiler liblzma-dev python-pip brotli liblz4-tool gawk aria2
    fi
    pip install backports.lzma protobuf pycrypto
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install protobuf xz brotli lz4 aria2
    pip install backports.lzma protobuf pycrypto
fi
