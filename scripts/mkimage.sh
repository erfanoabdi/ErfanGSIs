#!/bin/bash

# Project Capire le treble (CLT) by Erfan Abdi <erfangplus@gmail.com>

usage()
{
    echo "Usage: $0 <Path to GSI system> <System Partition Size> <Output File>"
    echo -e "\tPath to GSI system : Mount GSI and set mount point"
    echo -e "\tSystem Partition Size : set system Partition Size"
    echo -e "\tOutput File : set Output file path (system.img)"
}

if [ "$3" == "" ]; then
    echo "ERROR: Enter all needed parameters"
    usage
    exit 1
fi

systemdir=$1
outputtype=$2
syssize=$3
output=$4

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
tempdir="$LOCALDIR/../tmp"
toolsdir="$LOCALDIR/../tools"

echo "Prepare File Contexts"
p="/plat_file_contexts"
n="/nonplat_file_contexts"
for f in "$systemdir/system/etc/selinux" "$systemdir/system/vendor/etc/selinux"; do
    if [[ -f "$f$p" ]]; then
        sudo cat "$f$p" >> "$tempdir/file_contexts"
    fi
    if [[ -f "$f$n" ]]; then
        sudo cat "$f$n" >> "$tempdir/file_contexts"
    fi
done

if [[ -f "$tempdir/file_contexts" ]]; then
    echo "/firmware(/.*)?         u:object_r:firmware_file:s0" >> "$tempdir/file_contexts"
    echo "/bt_firmware(/.*)?      u:object_r:bt_firmware_file:s0" >> "$tempdir/file_contexts"
    echo "/persist(/.*)?          u:object_r:mnt_vendor_file:s0" >> "$tempdir/file_contexts"
    echo "/dsp                    u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/oem                    u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/op1                    u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/op2                    u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/charger_log            u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/audit_filter_table     u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/keydata                u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/keyrefuge              u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/omr                    u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/publiccert.pem         u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/sepolicy_version       u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/cust                   u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/donuts_key             u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/v_key                  u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/carrier                u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/dqmdbg                 u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    fcontexts="$tempdir/file_contexts"
fi
sudo rm -rf "$systemdir/persist"
sudo rm -rf "$systemdir/bt_firmware"
sudo rm -rf "$systemdir/firmware"
sudo rm -rf "$systemdir/dsp"
sudo mkdir -p "$systemdir/bt_firmware"
sudo mkdir -p "$systemdir/persist"
sudo mkdir -p "$systemdir/firmware"
sudo mkdir -p "$systemdir/dsp"

if [ "$outputtype" == "Aonly" ]; then
    sudo $toolsdir/mkuserimg_mke2fs.sh -s "$systemdir/system" "$output" ext4 system $syssize -T 0 -L system $fcontexts
else
    sudo $toolsdir/mkuserimg_mke2fs.sh -s "$systemdir/" "$output" ext4 / $syssize -T 0 -L / $fcontexts
fi
