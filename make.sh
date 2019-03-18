#/bin/bash

# Project OEM-GSI Porter by Erfan Abdi <erfangplus@gmail.com>

usage()
{
echo "Usage: $0 <Path to GSI system> <Firmware type> <Output type> <System Partition Size> [Output Dir]"
    echo -e "\tPath to GSI system: Mount GSI and set mount point"
    echo -e "\tFirmware type: Firmware mode"
    echo -e "\tOutput type: AB or A-Only"
    echo -e "\tSystem Partition Size: set system Partition Size"
    echo -e "\tOutput Dir: set output dir"
}

if [ "$4" == "" ]; then
    echo "ERROR: Enter all needed parameters"
    usage
    exit 1
fi

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
sourcepath=$1
romtype=$2
outputtype=$3
systemsize=$4

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
    *"AB"*) flag=true && continue ;;
    *"Aonly"*) flag=true && continue ;;
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

# Detect Source API level
sourcever=`cat $systemdir/system/build.prop | grep ro.build.version.release | cut -d "=" -f 2`
flag=false
case "$sourcever" in
    *"9"*) flag=true && continue ;;
    *"Q"*) flag=true && continue ;;
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
$prebuiltdir/google2phh/make.sh "$systemdir/system"
$prebuiltdir/$sourcever/make.sh "$systemdir/system"
$prebuiltdir/$sourcever/makeroot.sh "$systemdir"
if [ "$outputtype" == "Aonly" ]; then
    $prebuiltdir/$sourcever/makeA.sh "$systemdir/system"
fi
$prebuiltdir/vendor_vndk/make$sourcever.sh "$systemdir/system"

$romsdir/$sourcever/$romtype/make.sh "$systemdir/system"
$romsdir/$sourcever/$romtype/debloat.sh "$systemdir/system"
$romsdir/$sourcever/$romtype/makeroot.sh "$systemdir"
if [ "$outputtype" == "Aonly" ]; then
    $romsdir/$sourcever/$romtype/makeA.sh "$systemdir/system"
fi

if [ "$5" == "" ]; then
echo "Create out dir"
outdirname="out"
outdir="$LOCALDIR/$outdirname"
mkdir -p "$outdir"
else
outdir=$5
fi

date=`date +%Y%m%d`
outputname="$romtype-$outputtype-$sourcever-$date-ErfanGSI.img"
output="$outdir/$outputname"

echo "Creating Image: $outputname"
$scriptsdir/mkimage.sh $systemdir $outputtype $systemsize $output

echo "Remove Temp dir"
rm -rf "$tempdir"
