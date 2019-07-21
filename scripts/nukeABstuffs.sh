#!/bin/bash

declare -a abfiles=(
etc/init/bufferhubd.rc
etc/init/cppreopts.rc
etc/init/otapreopt.rc
etc/init/performanced.rc
etc/init/recovery-persist.rc
etc/init/recovery-refresh.rc
etc/init/update_engine.rc
etc/init/update_verifier.rc
etc/init/virtual_touchpad.rc
bin/update_engine
bin/update_verifier
)


for abfile in "${abfiles[@]}"
do
    rm -rf "$1/$abfile"
done
