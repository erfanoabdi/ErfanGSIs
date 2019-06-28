#/bin/bash

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
echo "Create Temp dir"
mkdir -p "$TMPDIR"

FRAMEWORKDIR="$1"
TARGET="$2"

BAKSMALIJAR="$toolsdir"/smali/baksmali.jar
SMALIJAR="$toolsdir"/smali/smali.jar
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    VDEXEXTRACTOR="$toolsdir/linux/bin/vdexExtractor"
    CDEXCONVERTER="$toolsdir/linux/bin/compact_dex_converter"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    VDEXEXTRACTOR="$toolsdir/mac/bin/vdexExtractor"
    CDEXCONVERTER="$toolsdir/mac/bin/compact_dex_converter"
else
    echo "Not Supported OS for oat2dex"
fi

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
	FULLY_DEODEXED=1 && exit 0 # system is fully deodexed, return
fi

if [ ! -f "$TARGET" ]; then
	exit
fi

if grep "classes.dex" "$TARGET" >/dev/null; then
	exit 0 # target apk|jar is already odexed, return
fi

for ARCH in $ARCHES; do
	BOOTOAT="$TMPDIR/system/framework/$ARCH/boot.oat"

	OAT="$(dirname "$TARGET")/oat/$ARCH/$(basename "$TARGET" ."${TARGET##*.}").odex"
	VDEX="$(dirname "$TARGET")/oat/$ARCH/$(basename "$TARGET" ."${TARGET##*.}").vdex"

	if get_file "$OAT" "$TMPDIR"; then
		if get_file "$VDEX" "$TMPDIR"; then
			"$VDEXEXTRACTOR" -o "$TMPDIR/" -i "$TMPDIR/$(basename "$VDEX")" >/dev/null
			# Check if we have to deal with CompactDex
			if [ -f "$TMPDIR/$(basename "${TARGET%.*}")_classes.cdex" ]; then
				"$CDEXCONVERTER" "$TMPDIR/$(basename "${TARGET%.*}")_classes.cdex" &>/dev/null
				mv "$TMPDIR/$(basename "${TARGET%.*}")_classes.cdex.new" "$TMPDIR/classes.dex"
			else
				mv "$TMPDIR/$(basename "${TARGET%.*}")_classes.dex" "$TMPDIR/classes.dex"
			fi
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
			# Check if we have to deal with CompactDex
			if [ -f "$TMPDIR/$(basename "${JARVDEX%.*}")_classes.cdex" ]; then
				"$CDEXCONVERTER" "$TMPDIR/$(basename "${JARVDEX%.*}")_classes.cdex" &>/dev/null
				mv "$TMPDIR/$(basename "${JARVDEX%.*}")_classes.cdex.new" "$TMPDIR/classes.dex"
			else
				mv "$TMPDIR/$(basename "${JARVDEX%.*}")_classes.dex" "$TMPDIR/classes.dex"
			fi
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
    zip -gjq "$TARGET" "$TMPDIR/classes.dex"
    rm "$TMPDIR/classes.dex"
    printf '    (updated %s from odex files)\n' "${TARGET}"
fi

rm -rf "$TMPDIR"
