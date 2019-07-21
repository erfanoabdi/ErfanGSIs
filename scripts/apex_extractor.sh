#!/bin/bash

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
TMPDIR=$LOCALDIR/../tmp/apex_ext
mkdir -p "$TMPDIR"

APEXDIR="$1"
APEXES=$(ls "$APEXDIR" | grep ".apex")
for APEX in $APEXES; do
    APEXNAME=$(echo "$APEX" | sed 's/.apex//')
    mkdir -p "$APEXDIR/$APEXNAME"
    7z e "$APEXDIR/$APEX" apex_payload.img apex_pubkey -o"$APEXDIR/$APEXNAME" 2>/dev/null >> "$TMPDIR"/zip.log
    7z x "$APEXDIR/$APEXNAME/apex_payload.img" -o"$APEXDIR/$APEXNAME" 2>/dev/null >> "$TMPDIR"/zip.log
    rm "$APEXDIR/$APEXNAME/apex_payload.img"
    rm -rf "$APEXDIR/$APEXNAME/lost+found"
    rm "$APEXDIR/$APEX"
done

rm -rf "$TMPDIR"
