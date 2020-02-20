#!/bin/bash

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
EXT4EXTRACT=$LOCALDIR/../tools/ext4extract/ext4extract.py

TMPDIR=$LOCALDIR/../tmp/apex_ext
mkdir -p "$TMPDIR"

APEXDIR="$1"
APEXES=$(ls "$APEXDIR" | grep ".apex")
for APEX in $APEXES; do
    APEXNAME=$(echo "$APEX" | sed 's/.apex//')
    if [[ -d "$APEXDIR/$APEXNAME" ]]; then
        continue
    fi
    mkdir -p "$APEXDIR/$APEXNAME"
    7z e "$APEXDIR/$APEX" apex_payload.img apex_pubkey -o"$APEXDIR/$APEXNAME" 2>/dev/null >> "$TMPDIR"/zip.log
    $EXT4EXTRACT "$APEXDIR/$APEXNAME/apex_payload.img" -D "$APEXDIR/$APEXNAME" 2>/dev/null
    rm "$APEXDIR/$APEXNAME/apex_payload.img"
    rm -rf "$APEXDIR/$APEXNAME/lost+found"
done

rm -rf "$TMPDIR"
