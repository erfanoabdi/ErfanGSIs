#!/bin/bash

declare -a partitions=(
boot-framework-oahl-backward-compatibility.vdex
)

for partition in "${partitions[@]}"
do
    if [[ $(ls "$1/framework/arm64/" | grep "$partition") ]]; then
        rm -rf "$1/framework/arm64/$partition"
        ln -s "/system/framework/$partition" "$1/framework/arm64/$partition"
    fi
    if [[ $(ls "$1/framework/arm/" | grep "$partition") ]]; then
        rm -rf "$1/framework/arm/$partition"
        ln -s "/system/framework/$partition" "$1/framework/arm/$partition"
    fi
done

