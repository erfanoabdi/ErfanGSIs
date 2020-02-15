#!/bin/bash

# Supported Firmwares:
# Aonly OTA
# Raw image
# tarmd5
# chunk image
# QFIL
# AB OTA
# Image zip
# ozip
# Sony ftf
# ZTE update.zip
# KDDI .bin

usage() {
    echo "Usage: $0 <Path to firmware> [Output Dir]"
    echo -e "\tPath to firmware: the zip!"
    echo -e "\tOutput Dir: the output dir!"
}

if [ "$1" == "" ]; then
    echo "BRUH: Enter all needed parameters"
    usage
    exit 1
fi

LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
HOST="$(uname)"
toolsdir="$LOCALDIR/tools"
simg2img="$toolsdir/$HOST/bin/simg2img"
packsparseimg="$toolsdir/$HOST/bin/packsparseimg"
unsin="$toolsdir/$HOST/bin/unsin"
payload_extractor="$toolsdir/update_payload_extractor/extract.py"
sdat2img="$toolsdir/sdat2img.py"
ozipdecrypt="$toolsdir/oppo_ozip_decrypt/ozipdecrypt.py"
brotli_exec="$toolsdir/$HOST/bin/brotli"

romzip="$(realpath $1)"
PARTITIONS="system"
EXT4PARTITIONS="system"
OTHERPARTITIONS=""

echo "Create Temp and out dir"
outdir="$LOCALDIR/cache"
if [ ! "$2" == "" ]; then
    outdir="$(realpath $2)"
fi
tmpdir="$outdir/tmp"
mkdir -p "$tmpdir"
mkdir -p "$outdir"
cd $tmpdir

MAGIC=$(head -c12 $romzip | tr -d '\0')
if [[ $MAGIC == "OPPOENCRYPT!" ]]; then
    echo "ozip detected"
    cp $romzip "$tmpdir/temp.ozip"
    python $ozipdecrypt "$tmpdir/temp.ozip"
    "$LOCALDIR/zip2img.sh" "$tmpdir/temp.zip" "$outdir"
    exit
fi

if [[ ! $(7z l -ba $romzip | grep ".*system.ext4.tar.*\|.*.tar\|.*chunk\|system\/build.prop\|system.new.dat\|system_new.img\|system.img\|payload.bin\|image.*.zip\|update.zip\|.*rawprogram*\|system.sin\|system-p" | grep -v ".*chunk.*\.so$") ]]; then
    echo "BRUH: This type of firmwares not supported"
    cd "$LOCALDIR"
    rm -rf "$tmpdir" "$outdir"
    exit 1
fi

echo "Extracting firmware on: $outdir"

for otherpartition in $OTHERPARTITIONS; do
    filename=$(echo $otherpartition | cut -f 1 -d ":")
    outname=$(echo $otherpartition | cut -f 2 -d ":")
    if [[ $(7z l -ba $romzip | grep $filename) ]]; then
        echo "$filename detected for $outname"
        foundfiles=$(7z l -ba $romzip | rev | gawk '{ print $1 }' | rev | grep $filename)
        7z e -y $romzip $foundfiles 2>/dev/null >> $tmpdir/zip.log
        outputs=$(ls *"$filename"*)
        for output in $outputs; do
            [[ ! -e "$outname".img ]] && mv $output "$outname".img
            $simg2img "$outname".img "$outdir/$outname".img 2>/dev/null
            if [[ ! -s "$outdir/$outname".img ]] && [ -f "$outname".img ]; then
                mv "$outname".img "$outdir/$outname".img
            fi
        done
    fi
done

if [[ $(7z l -ba $romzip | grep system.new.dat) ]]; then
    echo "Aonly OTA detected"
    for partition in $PARTITIONS; do
        7z e -y $romzip $partition.new.dat* $partition.transfer.list $partition.img 2>/dev/null >> $tmpdir/zip.log
        if [[ -f $partition.new.dat.1 ]]; then
            cat $partition.new.dat.{0..999} 2>/dev/null >> $partition.new.dat
            rm -rf $partition.new.dat.{0..999}
        fi
        ls | grep "\.new\.dat" | while read i; do
            line=$(echo "$i" | cut -d"." -f1)
            if [[ $(echo "$i" | grep "\.dat\.xz") ]]; then
                7z e -y "$i" 2>/dev/null >> $tmpdir/zip.log
                rm -rf "$i"
            fi
            if [[ $(echo "$i" | grep "\.dat\.br") ]]; then
                echo "Converting brotli $partition dat to normal"
                $brotli_exec -d "$i"
                rm -f "$i"
            fi
            echo "Extracting $partition"
            python3 $sdat2img $line.transfer.list $line.new.dat "$outdir"/$line.img > $tmpdir/extract.log
            rm -rf $line.transfer.list $line.new.dat
        done
    done
elif [[ $(7z l -ba $romzip | grep chunk | grep -v ".*\.so$") ]]; then
    echo "chunk detected"
    for partition in $PARTITIONS; do
        foundpartitions=$(7z l -ba $romzip | rev | gawk '{ print $1 }' | rev | grep $partition.img)
        7z e -y $romzip *$partition*chunk* */*$partition*chunk* $foundpartitions dummypartition 2>/dev/null >> $tmpdir/zip.log
        rm -f *"$partition"_b*
        rm -f *"$partition"_other*
        romchunk=$(ls | grep chunk | grep $partition | sort)
        if [[ $(echo "$romchunk" | grep "sparsechunk") ]]; then
            $simg2img $(echo "$romchunk" | tr '\n' ' ') $partition.img.raw 2>/dev/null
            rm -rf *$partition*chunk*
            if [[ -f $partition.img ]]; then
                rm -rf $partition.img.raw
            else
                mv $partition.img.raw $partition.img
            fi
        fi
    done
elif [[ $(7z l -ba $romzip | grep "system.sin") ]]; then
    echo "sin detected"
    cd $tmpdir
    for partition in $PARTITIONS; do
        7z e -y $romzip $partition.sin 2>/dev/null >> $tmpdir/zip.log
    done
    $unsin -d $tmpdir
    rm -rf $tmpdir/*.sin
    ext4_list=`find $tmpdir/ -type f -printf '%P\n' | sort`
    for file in $ext4_list; do
        mv $tmpdir/$file $(echo "$outdir/$file" | sed -r 's|ext4|img|g')
    done
elif [[ $(7z l -ba $romzip | grep "system-p") ]]; then
    echo "P suffix images detected"
    for partition in $PARTITIONS; do
        foundpartitions=$(7z l -ba $romzip | rev | gawk '{ print $1 }' | rev | grep $partition-p)
        7z e -y $romzip $foundpartitions dummypartition 2>/dev/null >> $tmpdir/zip.log
        if [ ! -z "$foundpartitions" ]; then
            mv $(ls $partition-p*) "$partition.img"
        fi
    done
elif [[ $(7z l -ba $romzip | grep "system_new.img\|system.img") ]]; then
    echo "Image detected"
    for partition in $PARTITIONS; do
        foundpartitions=$(7z l -ba $romzip | rev | gawk '{ print $1 }' | rev | grep $partition.img)
        7z e -y $romzip $foundpartitions dummypartition 2>/dev/null >> $tmpdir/zip.log
        if [[ -f $partition_new.img ]]; then
            mv $partition_new.img $partition.img
        fi
        if [[ -f $partition.img.ext4 ]]; then
            mv $partition.img.ext4 $partition.img
        fi
    done
    romzip=""
elif [[ $(7z l -ba $romzip | grep .tar) && ! $(7z l -ba $romzip | grep tar.md5 | rev | gawk '{ print $1 }' | rev | grep AP_) ]]; then
    tar=$(7z l -ba $romzip | grep .tar | rev | gawk '{ print $1 }' | rev)
    echo "non AP tar detected"
    7z e -y $romzip $tar 2>/dev/null >> $tmpdir/zip.log
    "$LOCALDIR/zip2img.sh" $tar "$outdir"
    exit
elif [[ $(7z l -ba $romzip | grep tar.md5 | rev | gawk '{ print $1 }' | rev | grep AP_) ]]; then
    echo "AP tarmd5 detected"
    mainmd5=$(7z l -ba $romzip | grep tar.md5 | rev | gawk '{ print $1 }' | rev | grep AP_)
    cscmd5=$(7z l -ba $romzip | grep tar.md5 | rev | gawk '{ print $1 }' | rev | grep CSC_)
    echo "Extracting tarmd5"
    7z e -y $romzip $mainmd5 $cscmd5 2>/dev/null >> $tmpdir/zip.log
    mainmd5=$(7z l -ba $romzip | grep tar.md5 | rev | gawk '{ print $1 }' | rev | grep AP_ | rev | cut -d "/" -f 1 | rev)
    cscmd5=$(7z l -ba $romzip | grep tar.md5 | rev | gawk '{ print $1 }' | rev | grep CSC_ | rev | cut -d "/" -f 1 | rev)
    echo "Extracting images..."
    for i in "$mainmd5" "$cscmd5"; do
        for partition in $PARTITIONS; do
            tarulist=$(tar -tf $i | grep -e ".*$partition.*\.img.*\|.*$partition.*ext4")
            echo "$tarulist" | while read line; do
                tar -xf "$i" "$line"
                if [[ $(echo "$line" | grep "\.lz4") ]]; then
                    lz4 "$line"
                    rm -f "$line"
                    line=$(echo "$line" | sed 's/\.lz4$//')
                fi
                if [[ $(echo "$line" | grep "\.ext4") ]]; then
                    mv "$line" "$(echo "$line" | cut -d'.' -f1).img"
                fi
            done
        done
    done
    if [[ -f system.img ]]; then
        rm -rf $mainmd5
        rm -rf $cscmd5
    else
        echo "Extract failed"
        rm -rf "$tmpdir"
        exit 1
    fi
    romzip=""
elif [[ $(7z l -ba $romzip | grep rawprogram) ]]; then
    echo "QFIL detected"
    rawprograms=$(7z l -ba $romzip | rev | gawk '{ print $1 }' | rev | grep rawprogram)
    7z e -y $romzip $rawprograms 2>/dev/null >> $tmpdir/zip.log
    for partition in $PARTITIONS; do
        partitionsonzip=$(7z l -ba $romzip | rev | gawk '{ print $1 }' | rev | grep $partition)
        if [[ ! $partitionsonzip == "" ]]; then
            7z e -y $romzip $partitionsonzip 2>/dev/null >> $tmpdir/zip.log
            if [[ ! -f "$partition.img" ]]; then
                if [[ -f "$partition.raw.img" ]]; then
                    mv "$partition.raw.img" "$partition.img"
                else
                    rawprogramsfile=$(grep -rlw $partition rawprogram*)
                    $packsparseimg -t $partition -x $rawprogramsfile > $tmpdir/extract.log
                    mv "$partition.raw" "$partition.img"
                fi
            fi
        fi
    done
elif [[ $(7z l -ba $romzip | grep payload.bin) ]]; then
    echo "AB OTA detected"
    7z e -y $romzip payload.bin 2>/dev/null >> $tmpdir/zip.log
    for partition in $PARTITIONS; do
        python $payload_extractor payload.bin --partitions $partition --output_dir $tmpdir > $tmpdir/extract.log
        if [[ -f "$tmpdir/$partition" ]]; then
            mv "$tmpdir/$partition" "$outdir/$partition.img"
        fi
    done
    rm payload.bin
    rm -rf "$tmpdir"
    exit
elif [[ $(7z l -ba $romzip | grep "image.*.zip\|update.zip") ]]; then
    echo "Image zip firmware detected"
    thezip=$(7z l -ba $romzip | grep "image.*.zip\|update.zip" | rev | gawk '{ print $1 }' | rev)
    7z e -y $romzip $thezip 2>/dev/null >> $tmpdir/zip.log
    thezipfile=$(echo $thezip | rev | cut -d "/" -f 1 | rev)
    mv $thezipfile temp.zip
    "$LOCALDIR/zip2img.sh" temp.zip "$outdir"
    exit
fi

for partition in $PARTITIONS; do
    if [ -f $partition.img ]; then
        $simg2img $partition.img "$outdir"/$partition.img 2>/dev/null
    fi
    if [[ ! -s "$outdir"/$partition.img ]] && [ -f $partition.img ]; then
        mv $partition.img "$outdir"/$partition.img
    fi

    if [[ $EXT4PARTITIONS =~ (^|[[:space:]])"$partition"($|[[:space:]]) ]] && [ -f "$outdir"/$partition.img ]; then
        MAGIC=$(head -c12 "$outdir"/$partition.img | tr -d '\0')
        offset=$(LANG=C grep -aobP -m1 '\x53\xEF' "$outdir"/$partition.img | head -1 | gawk '{print $1 - 1080}')
        if [[ $(echo "$MAGIC" | grep "MOTO") ]]; then
            if [[ "$offset" == 128055 ]]; then
                offset=131072
            fi
            echo "MOTO header detected on $partition in $offset"
        elif [[ $(echo "$MAGIC" | grep "ASUS") ]]; then
            echo "ASUS header detected on $partition in $offset"
        else
            offset=0
        fi
        if [ ! $offset == "0" ]; then
            dd if="$outdir"/$partition.img of="$outdir"/$partition.img-2 ibs=$offset skip=1 2>/dev/null
            mv "$outdir"/$partition.img-2 "$outdir"/$partition.img
        fi
    fi

    if [ ! -s "$outdir"/$partition.img ] && [ -f "$outdir"/$partition.img ]; then
        rm "$outdir"/$partition.img
    fi
done

cd "$LOCALDIR"
rm -rf "$tmpdir"
