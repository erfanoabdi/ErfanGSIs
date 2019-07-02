#/bin/bash

systempath=$1
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
scriptsdir=$LOCALDIR/../../../scripts
toolsdir=$LOCALDIR/../../../tools
TMPDIR=$LOCALDIR/../../../tmp/brightnessfix
echo "Create Temp dir"
mkdir -p "$TMPDIR"

BAKSMALIJAR="$toolsdir"/smali/baksmali.jar
SMALIJAR="$toolsdir"/smali/smali.jar

$scriptsdir/oat2dex.sh "$systempath/framework" "$systempath/framework/services.jar"
mkdir -p "$TMPDIR/original_dex"
7z e "$systempath/framework/services.jar" classes.dex -o"$TMPDIR/original_dex"
java -jar "$BAKSMALIJAR" disassemble "$TMPDIR/original_dex/classes.dex" -o "$TMPDIR/dexout"
#cp -fpr "$LOCALDIR"/com_android_server_lights/* "$TMPDIR"/dexout/com/android/server/lights/
LightImpl=$(grep  ".method private setLightLocked(IIIII)V" "$TMPDIR"/dexout/com/android/server/lights/ -ri | cut -d ":" -f 1)
if [[ $LightImpl == "" ]]; then
    echo "ERR: Check 2: Patching Light not supported for this rom"
    rm -rf "$TMPDIR"
    exit
fi
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
java -jar "$SMALIJAR" assemble "$TMPDIR/dexout" -o "$TMPDIR/classes.dex"
zip -gjq "$systempath/framework/services.jar" "$TMPDIR/classes.dex"
java -jar $toolsdir/apktool/apktool.jar d $systempath/framework/framework-res.apk -o $TMPDIR/framework-res
ROMMAXBRIGHTNESS=$(grep '<integer name="config_screenBrightnessSettingMaximum">' $TMPDIR/framework-res/res/values/integers.xml | sed 's/<integer name="config_screenBrightnessSettingMaximum">//g' | sed 's/<\/integer>//' | sed 's/^[[:space:]]*//g')
echo "persist.display.rom_max_brightness=$ROMMAXBRIGHTNESS" >> $systempath/build.prop
rm -rf "$TMPDIR"
