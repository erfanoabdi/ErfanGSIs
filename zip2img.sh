#/bin/bash

# 1) Aonly OTA
# 2) AB OTA
# 3) chunk system
# 4) raw image
# more...

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
toolsdir="$LOCALDIR/tools"

echo "Create Cache dir"
cachedir="$LOCALDIR/cache"
mkdir -p "$cachedir"

romzip=$1

cd $LOCALDIR

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    simg2img="$toolsdir/linux/bin/simg2img"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    simg2img="$toolsdir/mac/bin/simg2img"
else
    echo "Not Supported OS for simg2img"
    exit 1
fi

if [[ ! $(7z l $romzip | grep ".*system.ext4.tar.*\|.*tar.md5\|.*chunk\|system\/build.prop\|system.new.dat\|system_new.img\|system.img\|payload.bin\|image.*.zip" | grep -v ".*chunk.*\.so$") ]]; then
	echo -e "sorry not this zip"
	echo ""
    exit 1
fi

if [[ $(7z l $romzip | grep system.new.dat) ]]; then
	echo "Aonly OTA"
	7z e $romzip system.new.dat* system.transfer.list
	ls | grep "\.new\.dat" | while read i; do
		line=$(echo "$i" | cut -d"." -f1)
		if [[ $(echo "$i" | grep "\.dat\.xz") ]]; then
            7z e "$i"
            rm -rf "$i"
		fi
		if [[ $(echo "$i" | grep "\.dat\.br") ]]; then
            echo "$bluet$t_extract_convert_br$normal"
            brotli -d "$i"
            rm -f "$i"
		fi
		echo "$bluet$t_extract_convert_sys $line.img ...$normal"
		python3 $toolsdir/sdat2img.py $line.transfer.list $line.new.dat $line.img
		rm -rf $line.transfer.list $line.new.dat
	done
	romzip=""
	romimg="system.img"
elif [[ $(7z l $romzip | grep "system_new.img\|system.img$") ]]; then
	echo "raw image"
	if [[ -f system.img ]]; then
		mv system.img system_old.img
	fi
	7z e $romzip system_new.img system.img
	if [[ -f system_new.img ]]; then
		mv system_new.img system.img
	fi
	if [[ -f vendor_new.img ]]; then
		mv vendor_new.img vendor.img
	fi
	romzip=""
	romimg="system.img"
elif [[ $(7z l $romzip | grep system.ext4.tar.a) ]]; then
	echo "tar system"
	7z e $romzip system.ext4.tar.a
	romzip=""
	mv system.ext4.tar.a system.ext4.tar
	romtar="system.ext4.tar"
elif [[ $(7z l $romzip | grep tar.md5) && ! $(7z l $romzip | grep tar.md5 | gawk '{ print $6 }' | grep ^AP_) ]]; then
	tarmd5=$(7z l $romzip | grep tar.md5 | gawk '{ print $6 }')
	echo "extracting tarmd5..."
	7z e $romzip $tarmd5
	echo "extract img"
	if [[ $(tar -tf $tarmd5 | grep system.img.ext4) ]]; then
		tar -xf $tarmd5 system.img.ext4 7z
		mv system.img.ext4 system.img
	elif [[ $(tar -tf $tarmd5 | grep system.img) ]]; then
		tar -xf $tarmd5 system.img 7z
	fi
	if [[ -f system.img ]]; then
		rm -rf $tarmd5
	else
		echo "sorry not this thing"
		echo ""
		exit 1
	fi
	romzip=""
	romimg="system.img"
elif [[ $(7z l $romzip | grep tar.md5 | gawk '{ print $6 }' | grep ^AP_) ]]; then
	mainmd5=$(7z l $romzip | grep tar.md5 | gawk '{ print $6 }' | grep ^AP_)
	cscmd5=$(7z l $romzip | grep tar.md5 | gawk '{ print $6 }' | grep ^CSC_)
	echo "extract_tar_md5"
	7z e $romzip $mainmd5 $cscmd5
	echo "extract_img"
	for i in "$mainmd5" "$cscmd5"; do
		tarulist=$(tar -tf $i | grep -e ".*system.*\.img.*\|.*system.*ext4")
		echo "$tarulist" | while read line; do
            tar -xf "$i" "$line" 7z
            if [[ $(echo "$line" | grep "\.lz4") ]]; then
	            "$lz4" "$line"
	            rm -f "$line"
	            line=$(echo "$line" | sed 's/\.lz4$//')
            fi
        if [[ $(echo "$line" | grep "\.ext4") ]]; then
	        mv "$line" "$(echo "$line" | cut -d'.' -f1).img"
        fi
		done
	done
	if [[ -f system.img ]]; then
		rm -rf $mainmd5
		rm -rf $cscmd5
	else
		echo "extract_fail"
		exit 1
	fi
	romzip=""
	romimg="system.img"
elif [[ $(7z l $romzip | grep chunk | grep -v ".*\.so$") ]]; then
	echo "extract_chunk"
	7z e $romzip *system*chunk* */*system*chunk*
	rm -f *system_b*
	romzip=""
	romchunk=$(ls | grep chunk | sort)
    if [[ $(echo "$romchunk" | grep "sparsechunk") ]]; then
        $simg2img $(echo "$romchunk" | tr '\n' ' ') system.img.raw
        rm -rf *chunk*
        echo "extract_fix_img"
        python3 $toolsdir/fixmoto.py system.img.raw system.img
        if [[ -f system.img ]]; then
            rm -rf system.img.raw
        else
            mv system.img.raw system.img
        fi
    else
        $simg2img *chunk* system.img
        rm -rf *chunk*
    fi
    mv "system.img" "$cachedir/system.img"
    romrawimg="$cachedir/system.img"
elif [[ $(7z l $romzip | grep payload.bin) ]]; then
    echo "extract_ABota"
    7z e $romzip payload.bin
    python $toolsdir/update_payload_extractor/extract.py payload.bin --partitions system --output_dir $cachedir
    if [[ -f "$cachedir/system" ]]; then
        mv "$cachedir/system" "$cachedir/system.img"
        rm payload.bin
    else
        echo "extract_fail"
        exit 1
    fi
    romrawimg="$cachedir/system.img"
elif [[ $(7z l $romzip | grep "image.*.zip") ]]; then
    thezip=$(7z l $romzip | grep "image.*.zip" | gawk '{ print $6 }')
    echo "image zip firmware"
    7z e $romzip $thezip
    thezipfile=`echo $thezip | rev | cut -d "/" -f 1 | rev`
    mv $thezipfile temp.zip
    $LOCALDIR/zip2img.sh temp.zip
    rm temp.zip
    exit 1
fi

$simg2img system.img system.img-2 >/dev/null
if [[ ! -s system.img-2 ]]; then
    rm -rf system.img-2
else
    mv system.img-2 system.img
fi

mv "system.img" "$cachedir/system.img"

echo "$cachedir/system.img"
