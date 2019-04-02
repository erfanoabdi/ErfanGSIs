#/bin/bash

# Project OEM-GSI Porter by Erfan Abdi <erfangplus@gmail.com>

usage()
{
echo "Usage: $0 <Path to GSI system> <Firmware type> <Output type> [Output Dir]"
    echo -e "\tPath to GSI system: Mount GSI and set mount point"
    echo -e "\tFirmware type: Firmware mode"
    echo -e "\tOutput type: AB or A-Only"
    echo -e "\tOutput Dir: set output dir"
}

if [ "$3" == "" ]; then
    echo "ERROR: Enter all needed parameters"
    usage
    exit 1
fi

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
sourcepath=$1
romtype=$2
outputtype=$3

flag=false
roms=("$LOCALDIR"/roms/*/*)
for dir in "${roms[@]}"
do
    rom=`echo "$dir" | rev | cut -d "/" -f 1 | rev`
    if [ "$rom" == "$romtype" ]; then
        flag=true
    fi
done
if [ "$flag" == "false" ]; then
    echo "$romtype is not supported rom, supported roms:"
    for dir in "${roms[@]}"
    do
        ver=`echo "$dir" | rev | cut -d "/" -f 2 | rev`
        rom=`echo "$dir" | rev | cut -d "/" -f 1 | rev`
        echo "$rom for Android $ver"
    done
    exit 1
fi
flag=false
case "$outputtype" in
    *"AB"*) flag=true7z ;;
    *"Aonly"*) flag=true7z ;;
esac
if [ "$flag" == "false" ]; then
    echo "$outputtype is not supported type, supported types:"
    echo "AB"
    echo "Aonly"
    exit 1
fi

# Detect Source type, AB or not
sourcetype="Aonly"
if [[ -e "$sourcepath/init.rc" ]]; then
    sourcetype="AB"
fi

tempdirname="tmp"
tempdir="$LOCALDIR/$tempdirname"
systemdir="$tempdir/system"
toolsdir="$LOCALDIR/tools"
romsdir="$LOCALDIR/roms"
prebuiltdir="$LOCALDIR/prebuilt"
scriptsdir="$LOCALDIR/scripts"

echo "Create Temp dir"
mkdir -p "$systemdir"

if [ "$sourcetype" == "Aonly" ]; then
    echo "Warning: Aonly source detected, using P AOSP rootdir"
    cd "$systemdir"
    tar xf "$prebuiltdir/ABrootDir.tar"
    cd "$LOCALDIR"
    echo "Making copy of source rom to temp"
    ( cd "$sourcepath" ; sudo tar cf - . ) | ( cd "$systemdir/system" ; sudo tar xf - )
    cd "$LOCALDIR"
else
    echo "Making copy of source rom to temp"
    ( cd "$sourcepath" ; sudo tar cf - . ) | ( cd "$systemdir" ; sudo tar xf - )
    cd "$LOCALDIR"
fi

# Detect is the src treble ro.treble.enabled=true
istreble=`cat $systemdir/system/build.prop | grep ro.treble.enabled | cut -d "=" -f 2`
if [[ ! "$istreble" == "true" ]]; then
    echo "The source is not treble supported"
    exit 1
fi

# Detect Source API level
sourcever=`cat $systemdir/system/build.prop | grep ro.build.version.release | cut -d "=" -f 2`
flag=false
case "$sourcever" in
    *"9"*) flag=true7z ;;
    *"Q"*) flag=true7z ;;
esac
if [ "$flag" == "false" ]; then
    echo "$sourcever is not supported"
    exit 1
fi

# Detect rom folder again
if [[ ! -d "$romsdir/$sourcever/$romtype" ]]; then
    echo "$romtype is not supported rom for android $sourcever"
    exit 1
fi

# Detect arch
if [[ ! -d "$systemdir/system/lib64" ]]; then
    echo "32bit source detected, weird flex but ok!"
    # do something here?
fi

# Start patching
echo "Patching started..."
$scriptsdir/fixsymlinks.sh "$systemdir/system"
$scriptsdir/nukeABstuffs.sh "$systemdir/system"
$prebuiltdir/common/make.sh "$systemdir/system"
$prebuiltdir/$sourcever/make.sh "$systemdir/system"
$prebuiltdir/$sourcever/makeroot.sh "$systemdir"
$prebuiltdir/vendor_vndk/make$sourcever.sh "$systemdir/system"
$romsdir/$sourcever/$romtype/make.sh "$systemdir/system"
$romsdir/$sourcever/$romtype/debloat.sh "$systemdir/system"
$romsdir/$sourcever/$romtype/makeroot.sh "$systemdir"
if [ "$outputtype" == "Aonly" ]; then
    $prebuiltdir/$sourcever/makeA.sh "$systemdir/system"
    $romsdir/$sourcever/$romtype/makeA.sh "$systemdir/system"
fi

if [[ $(grep "ro.build.display.id" $systemdir/system/build.prop) ]]; then
    displayid="ro.build.display.id"
elif [[ $(grep "ro.build.id" $systemdir/system/build.prop) ]]; then
    displayid="ro.build.id"
fi
displayid2=$(echo "$displayid" | sed 's/\./\\./g')
bdisplay=$(grep "$displayid" $systemdir/system/build.prop | sed 's/\./\\./g; s:/:\\/:g; s/\,/\\,/g; s/\ /\\ /g')
sed -i "s/$bdisplay/$displayid2=Built\.with\.ErfanGSI\.Tools/" $systemdir/system/build.prop

if [ "$5" == "" ]; then
    echo "Create out dir"
    outdirname="out"
    outdir="$LOCALDIR/$outdirname"
    mkdir -p "$outdir"
else
    outdir=$5
fi

# Getting system size and add approximately 5% on it just for free space
systemsize=`du -sk $systemdir | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`

date=`date +%Y%m%d`
outputname="$romtype-$outputtype-$sourcever-$date-ErfanGSI.img"
output="$outdir/$outputname"

echo "Creating Image: $outputname"
$scriptsdir/mkimage.sh $systemdir $outputtype $systemsize $output

echo "Remove Temp dir"
rm -rf "$tempdir"
