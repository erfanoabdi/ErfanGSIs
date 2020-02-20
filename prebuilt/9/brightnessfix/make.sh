#!/bin/bash

systempath=$1
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
scriptsdir=$LOCALDIR/../../../scripts
toolsdir=$LOCALDIR/../../../tools
TMPDIR=$LOCALDIR/../../../tmp/brightnessfix
mkdir -p "$TMPDIR"

BAKSMALIJAR="$toolsdir"/smali/baksmali.jar
SMALIJAR="$toolsdir"/smali/smali.jar
APKTOOL="$toolsdir"/apktool/apktool.jar

$scriptsdir/oat2dex.sh "$systempath/framework" "$systempath/framework/services.jar" 2>/dev/null >> "$TMPDIR"/oat2dex.log
mkdir -p "$TMPDIR/original_dex"
7z e "$systempath/framework/services.jar" classes* -o"$TMPDIR/original_dex" 2>/dev/null >> "$TMPDIR"/zip.log
CLASSES=$(ls "$TMPDIR/original_dex/classes"*)
for CLASS in $CLASSES; do
    java -jar "$BAKSMALIJAR" disassemble "$CLASS" -o "$TMPDIR/dexout"
    LightImpl=$(grep  ".method private setLightLocked(IIIII)V" "$TMPDIR"/dexout/com/android/server/lights/ -ri | cut -d ":" -f 1)
    if [[ ! $LightImpl == "" ]]; then
        cp $LightImpl "$TMPDIR"/LightImpl.smali
        rm $LightImpl
        flag=true
        while IFS= read -r line;
        do
            $flag && echo "$line" >> $LightImpl
            if [[ "$line" == ".method public setBrightness(II)V" ]]; then
                flag=false
                cat "$LOCALDIR"/LightsService_LightImpl.patch >> $LightImpl
            fi
            if ! $flag && [[ "$line" == ".end method" ]]; then
                flag=true
                echo "$line" >> $LightImpl
            fi
        done  < "$TMPDIR"/LightImpl.smali
        NEWCLASS=$(echo "$CLASS" | rev | cut -d "/" -f 1 | rev)
        java -jar "$SMALIJAR" assemble "$TMPDIR/dexout" -o "$TMPDIR/$NEWCLASS"
        zip -gjq "$systempath/framework/services.jar" "$TMPDIR/$NEWCLASS"
        java -jar "$APKTOOL" d $systempath/framework/framework-res.apk -o $TMPDIR/framework-res 2>/dev/null >> "$TMPDIR"/apktoolunpack.log
        ROMMAXBRIGHTNESS=$(grep '<integer name="config_screenBrightnessSettingMaximum">' $TMPDIR/framework-res/res/values/integers.xml | sed 's/<integer name="config_screenBrightnessSettingMaximum">//g' | sed 's/<\/integer>//' | sed 's/^[[:space:]]*//g')
        echo "persist.display.rom_max_brightness=$ROMMAXBRIGHTNESS" >> $systempath/build.prop
        rm -rf "$TMPDIR"
        exit
    fi
    rm -rf "$TMPDIR/dexout"
done

# This should not happen
echo "ERR: Patching Light not supported for this rom"
rm -rf "$TMPDIR"
