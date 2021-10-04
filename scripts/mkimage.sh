#!/bin/bash

# Project Capire le treble (CLT) by Erfan Abdi <erfangplus@gmail.com>

usage()
{
    echo "Usage: $0 <Path to GSI system> <Output Type> <System Partition Size> <Output File> [--old]"
    echo -e "\tPath to GSI system : Mount GSI and set mount point"
    echo -e "\tOutput type : AB or A-Only"
    echo -e "\tSystem Partition Size : set system Partition Size"
    echo -e "\tOutput File : set Output file path (system.img)"
    echo -e "\told : use ext4fs to make image"
}

if [ "$4" == "" ]; then
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
HOST="$(uname)"
make_ext4fs="$toolsdir/$HOST/bin/make_ext4fs"

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
    echo "/ADF                    u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/APD                    u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/asdf                   u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/batinfo                u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/voucher                u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/xrom                   u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/custom                 u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/cpefs                  u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/modem                  u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/module_hashes          u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/pds                    u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/tombstones             u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/factory                u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/oneplus(/.*)?          u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/addon.d                u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/op_odm                 u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    echo "/avb                    u:object_r:rootfs:s0" >> "$tempdir/file_contexts"
    fcontexts="$tempdir/file_contexts"
fi
sudo rm -rf "$systemdir/persist"
sudo rm -rf "$systemdir/bt_firmware"
sudo rm -rf "$systemdir/firmware"
sudo rm -rf "$systemdir/dsp"
sudo rm -rf "$systemdir/cache"
sudo mkdir -p "$systemdir/bt_firmware"
sudo mkdir -p "$systemdir/persist"
sudo mkdir -p "$systemdir/firmware"
sudo mkdir -p "$systemdir/dsp"
sudo mkdir -p "$systemdir/cache"

if [ "$5" == "--old" ]; then
    if [ "$outputtype" == "Aonly" ]; then
        sudo $make_ext4fs -T 0 -S $fcontexts -l $syssize -L system -a system -s "$output" "$systemdir/system"
    else
        sudo $make_ext4fs -T 0 -S $fcontexts -l $syssize -L / -a / -s "$output" "$systemdir/"
    fi
else
    if [ "$outputtype" == "Aonly" ]; then
        sudo $toolsdir/mkuserimg_mke2fs.py "$systemdir/system" "$output" ext4 "/system" $syssize $fcontexts -j "0" -T "1230768000" -L "system" -I "256" -M "/system" -m "0"
    else
        sudo $toolsdir/mkuserimg_mke2fs.py "$systemdir/" "$output" ext4 "/" $syssize $fcontexts -j "0" -T "1230768000" -L "/" -I "256" -M "/" -m "0"
    fi
fi
