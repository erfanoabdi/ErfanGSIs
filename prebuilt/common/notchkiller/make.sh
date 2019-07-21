#!/bin/bash

systempath=$1
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
scriptsdir=$LOCALDIR/../../../scripts
toolsdir=$LOCALDIR/../../../tools
TMPDIR=$LOCALDIR/../../../tmp/notchkiller
mkdir -p "$TMPDIR"

APKTOOL="$toolsdir"/apktool/apktool.jar

# Notch
sed -i 's/config_mainBuiltInDisplayCutout/config_xxxxBuiltInDisplayxxxxxx/g' $systempath/framework/*framework-res*.apk

# OnePlus Rounded Corner
sed -i 's/config_has_rounded_corner/config_has_rounded_xxxxxx/g' $systempath/priv-app/*framework-res*/*.apk

rm -rf "$TMPDIR"
