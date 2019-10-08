#!/bin/bash

systempath=$1
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
scriptsdir=$LOCALDIR/../../../scripts
toolsdir=$LOCALDIR/../../../tools
TMPDIR=$LOCALDIR/../../../tmp/initstylewifi
mkdir -p "$TMPDIR"

BAKSMALIJAR="$toolsdir"/smali/baksmali.jar
SMALIJAR="$toolsdir"/smali/smali.jar

$scriptsdir/oat2dex.sh "$systempath/framework" "$systempath/framework/wifi-service.jar" 2>/dev/null >> "$TMPDIR"/oat2dex.log
mkdir -p "$TMPDIR/original_dex"
7z e "$systempath/framework/wifi-service.jar" classes* -o"$TMPDIR/original_dex" 2>/dev/null >> "$TMPDIR"/zip.log
CLASSES=$(ls "$TMPDIR/original_dex/classes"*)
for CLASS in $CLASSES; do
    java -jar "$BAKSMALIJAR" disassemble "$CLASS" -o "$TMPDIR/dexout"
    SupplicantStaIfaceHal="$TMPDIR"/dexout/com/android/server/wifi/SupplicantStaIfaceHal.smali
    cp $SupplicantStaIfaceHal "$TMPDIR"/SupplicantStaIfaceHal.smali
    rm $SupplicantStaIfaceHal
    flag=true
    while IFS= read -r line;
    do
        $flag && echo "$line" >> $SupplicantStaIfaceHal
        if [[ "$line" == ".method public startDaemon()Z" ]]; then
            flag=false
            cat "$LOCALDIR"/com_android_server_wifi_SupplicantStaIfaceHal.patch >> $SupplicantStaIfaceHal
        fi
        if ! $flag && [[ "$line" == ".end method" ]]; then
            flag=true
            echo "$line" >> $SupplicantStaIfaceHal
        fi
    done  < "$TMPDIR"/SupplicantStaIfaceHal.smali
    NEWCLASS=$(echo "$CLASS" | rev | cut -d "/" -f 1 | rev)
    java -jar "$SMALIJAR" assemble "$TMPDIR/dexout" -o "$TMPDIR/$NEWCLASS"
    zip -gjq "$systempath/framework/wifi-service.jar" "$TMPDIR/$NEWCLASS"
    rm -rf "$TMPDIR"
    exit
    rm -rf "$TMPDIR/dexout"
done

# This should not happen
echo "ERR: Patching Light not supported for this rom"
rm -rf "$TMPDIR"
