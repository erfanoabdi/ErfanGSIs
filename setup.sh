#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    sudo apt install unace unrar zip unzip p7zip-full p7zip-rar sharutils rar uudeview mpack arj cabextract file-roller device-tree-compiler liblzma-dev python-pip brotli liblz4-tool
    pip install backports.lzma protobuf pycrypto
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install protobuf xz brotli lz4
    pip install backports.lzma protobuf pycrypto
fi
