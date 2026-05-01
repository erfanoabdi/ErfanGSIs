#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Make VNDK symlinks for Android 13 (API 33)
rm -rf $systempath/lib/vndk-31 $systempath/lib/vndk-sp-31
rm -rf $systempath/lib/vndk-30 $systempath/lib/vndk-sp-30
rm -rf $systempath/lib/vndk-29 $systempath/lib/vndk-sp-29
rm -rf $systempath/lib/vndk-28 $systempath/lib/vndk-sp-28

rm -rf $systempath/lib64/vndk-31 $systempath/lib64/vndk-sp-31
rm -rf $systempath/lib64/vndk-30 $systempath/lib64/vndk-sp-30
rm -rf $systempath/lib64/vndk-29 $systempath/lib64/vndk-sp-29
rm -rf $systempath/lib64/vndk-28 $systempath/lib64/vndk-sp-28

# Symlinks for VNDK 31-33
ln -s  /apex/com.android.vndk.v31/lib $systempath/lib/vndk-31 2>/dev/null
ln -s  /apex/com.android.vndk.v30/lib $systempath/lib/vndk-30 2>/dev/null
ln -s  /apex/com.android.vndk.v29/lib $systempath/lib/vndk-29 2>/dev/null
ln -s  /apex/com.android.vndk.v28/lib $systempath/lib/vndk-28 2>/dev/null

ln -s  /apex/com.android.vndk.v31/lib $systempath/lib/vndk-sp-31 2>/dev/null
ln -s  /apex/com.android.vndk.v30/lib $systempath/lib/vndk-sp-30 2>/dev/null
ln -s  /apex/com.android.vndk.v29/lib $systempath/lib/vndk-sp-29 2>/dev/null
ln -s  /apex/com.android.vndk.v28/lib $systempath/lib/vndk-sp-28 2>/dev/null

ln -s  /apex/com.android.vndk.v31/lib64 $systempath/lib64/vndk-31 2>/dev/null
ln -s  /apex/com.android.vndk.v30/lib64 $systempath/lib64/vndk-30 2>/dev/null
ln -s  /apex/com.android.vndk.v29/lib64 $systempath/lib64/vndk-29 2>/dev/null
ln -s  /apex/com.android.vndk.v28/lib64 $systempath/lib64/vndk-28 2>/dev/null

ln -s  /apex/com.android.vndk.v31/lib64 $systempath/lib64/vndk-sp-31 2>/dev/null
ln -s  /apex/com.android.vndk.v30/lib64 $systempath/lib64/vndk-sp-30 2>/dev/null
ln -s  /apex/com.android.vndk.v29/lib64 $systempath/lib64/vndk-sp-29 2>/dev/null
ln -s  /apex/com.android.vndk.v28/lib64 $systempath/lib64/vndk-sp-28 2>/dev/null

# Extract VNDK apex to system (if available)
7z x -y $thispath/13/com.android.vndk.v31.apex.7z -o$systempath/apex/ 2>/dev/null
7z x -y $thispath/13/com.android.vndk.v30.apex.7z -o$systempath/apex/ 2>/dev/null
7z x -y $thispath/13/com.android.vndk.v29.apex.7z -o$systempath/apex/ 2>/dev/null
rm -rf $systempath/zip.log 2>/dev/null
