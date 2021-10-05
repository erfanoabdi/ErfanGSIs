#!/bin/bash

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
APEXEXTRACT=$LOCALDIR/../tools/apex_tools/deapexer.py

TMPDIR=$LOCALDIR/../tmp/apex_ext
mkdir -p "$TMPDIR"

APEXDIR="$1"
APEXES=$(ls "$APEXDIR" | grep ".*apex")
for APEX in $APEXES; do
    APEXNAME=$(echo "$APEX" | sed 's/\.[^.]*$//')
    if [[ -d "$APEXDIR/$APEXNAME" ]]; then
        continue
    fi
    if [[ $APEX == *".capex" ]]; then
        7z e -y "$APEXDIR/$APEX" original_apex -o"$APEXDIR" 2>/dev/null >> "$TMPDIR"/zip.log
        mv -f "$APEXDIR/original_apex" "$APEXDIR/$APEXNAME.apex"
        rm -rf "$APEXDIR/$APEX"
    fi
    mkdir -p "$APEXDIR/$APEXNAME"
    7z e -y "$APEXDIR/$APEX" apex_pubkey -o"$APEXDIR/$APEXNAME" 2>/dev/null >> "$TMPDIR"/zip.log
    $APEXEXTRACT extract "$APEXDIR/$APEXNAME.apex" "$APEXDIR/$APEXNAME" 2>/dev/null
    rm "$APEXDIR/$APEXNAME/apex_payload.img"
    rm -rf "$APEXDIR/$APEXNAME/lost+found"
    rm "$APEXDIR/$APEXNAME.apex"
done

rm -rf "$TMPDIR"
