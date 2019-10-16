#!/bin/bash

#
# oat2dex:
#
# $1: extracted apk|jar (to check if deodex is required)
# $2: odexed apk|jar to deodex
# $3: source of the odexed apk|jar
#
# Convert apk|jar .odex in the corresposing classes.dex
#
# usage: oat2dex.sh <framework path> <target jar/apk>

LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
toolsdir=$LOCALDIR/../tools
TMPDIR=$LOCALDIR/../tmp/oat2dex
mkdir -p "$TMPDIR"

FRAMEWORKDIR="$1"
TARGETS="$2"
DEODEXALL=false

BAKSMALIJAR="$toolsdir"/smali/baksmali.jar
SMALIJAR="$toolsdir"/smali/smali.jar
HOST="$(uname)"
VDEXEXTRACTOR="$toolsdir/$HOST/bin/vdexExtractor"
CDEXCONVERTER="$toolsdir/$HOST/bin/compact_dex_converter"

function get_file() {
    if [ -e "$1" ]; then
        cp -fpr "$1" "$2" 2>/dev/null
        return 0
    else
        return 1
    fi
};

# Extract existing boot.oats to the temp folder
if [ -z "$ARCHES" ]; then
	echo "Checking if system is odexed and locating boot.oats..."
    #TODO: add more arch here "arm" "x86_64" "x86"
	for ARCH in "arm64"; do
		mkdir -p "$TMPDIR/system/framework/$ARCH"
		if get_file "$FRAMEWORKDIR/$ARCH" "$TMPDIR/system/framework/"; then
			ARCHES+="$ARCH "
		else
			rmdir "$TMPDIR/system/framework/$ARCH"
		fi
	done
fi

if [ -z "$ARCHES" ]; then
    echo "System is already fully deodexed"
    rm -rf "$TMPDIR"
	exit
fi

if [ -z "$TARGETS" ]; then
	TARGETS=$(ls "$FRAMEWORKDIR"/*.jar)
    DEODEXALL=true
fi

for TARGET in $TARGETS; do

if [ ! -f "$TARGET" ]; then
    continue
fi

if grep "classes.dex" "$TARGET" >/dev/null; then
	continue
fi

for ARCH in $ARCHES; do
	BOOTOAT="$TMPDIR/system/framework/$ARCH/boot.oat"

	OAT="$(dirname "$TARGET")/oat/$ARCH/$(basename "$TARGET" ."${TARGET##*.}").odex"
	VDEX="$(dirname "$TARGET")/oat/$ARCH/$(basename "$TARGET" ."${TARGET##*.}").vdex"

	if get_file "$OAT" "$TMPDIR"; then
		if get_file "$VDEX" "$TMPDIR"; then
			"$VDEXEXTRACTOR" -o "$TMPDIR/" -i "$TMPDIR/$(basename "$VDEX")" >/dev/null
            CLASSES=$(ls "$TMPDIR/$(basename "${TARGET%.*}")_classes"*)
            for CLASS in $CLASSES; do
                NEWCLASS=$(echo "$CLASS" | sed 's/.*_//;s/cdex/dex/')
			    # Check if we have to deal with CompactDex
                if [[ "$CLASS" == *.cdex ]]; then
				    "$CDEXCONVERTER" "$CLASS" &>/dev/null
				    mv "$CLASS.new" "$TMPDIR/$NEWCLASS"
			    else
				    mv "$CLASS" "$TMPDIR/$NEWCLASS"
			    fi
            done
		else
			java -jar "$BAKSMALIJAR" deodex -o "$TMPDIR/dexout" -b "$BOOTOAT" -d "$TMPDIR" "$TMPDIR/$(basename "$OAT")"
			java -jar "$SMALIJAR" assemble "$TMPDIR/dexout" -o "$TMPDIR/classes.dex"
		fi
	elif [[ "$TARGET" =~ .jar$ ]]; then
		JAROAT="$TMPDIR/system/framework/$ARCH/boot-$(basename ${TARGET%.*}).oat"
		JARVDEX="$FRAMEWORKDIR/boot-$(basename ${TARGET%.*}).vdex"
		if [ ! -f "$JAROAT" ]; then
			JAROAT=$BOOTOAT
		fi
		# try to extract classes.dex from boot.vdex for frameworks jars
		# fallback to boot.oat if vdex is not available
		if get_file "$JARVDEX" "$TMPDIR"; then
			"$VDEXEXTRACTOR" -o "$TMPDIR/" -i "$TMPDIR/$(basename "$JARVDEX")" >/dev/null
            CLASSES=$(ls "$TMPDIR/$(basename "${JARVDEX%.*}")_classes"*)
            for CLASS in $CLASSES; do
                NEWCLASS=$(echo "$CLASS" | sed 's/.*_//;s/cdex/dex/')
                # Check if we have to deal with CompactDex
                if [[ "$CLASS" == *.cdex ]]; then
                    "$CDEXCONVERTER" "$CLASS" &>/dev/null
                    mv "$CLASS.new" "$TMPDIR/$NEWCLASS"
                else
                    mv "$CLASS" "$TMPDIR/$NEWCLASS"
                fi
            done
		else
			java -jar "$BAKSMALIJAR" deodex -o "$TMPDIR/dexout" -b "$BOOTOAT" -d "$TMPDIR" "$JAROAT/$TARGET"
			java -jar "$SMALIJAR" assemble "$TMPDIR/dexout" -o "$TMPDIR/classes.dex"
		fi
	else
		continue
	fi

done

rm -rf "$TMPDIR/dexout"

if [ -f "$TMPDIR/classes.dex" ]; then
    zip -gjq "$TARGET" "$TMPDIR/classes"*
    rm "$TMPDIR/classes"*
    printf '    (updated %s from odex files)\n' "${TARGET}"
fi
done

if [ $DEODEXALL == true ]; then
    rm -rf "$FRAMEWORKDIR/arm" "$FRAMEWORKDIR/arm64" "$FRAMEWORKDIR/oat" "$FRAMEWORKDIR"/*.vdex "$FRAMEWORKDIR"/*.prof
fi
rm -rf "$TMPDIR"
