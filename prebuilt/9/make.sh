#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    dexhackt="$toolsdir/linux/bin"
    if [ ! -f "$toolsdir/linux/bin/vdexExtractor" ];then
    unzip $toolsdir/linux/cdextools.zip -d bin
    chmod 0777 $toolsdir/linux/*
    fi
    lighthts=yes
elif [[ "$OSTYPE" == "darwin"* ]]; then
    dexhackt="$toolsdir/mac/bin"
    lighthts=yes
else
    echo "Not Supported OS for patching brightness tools"
    lighthts=no
fi

# Copy some stuffs
$thispath/overlays/make.sh "$systempath"

# Enable Brightness fix for Android P
# But some systems are using custom light services, don't apply this patch on those roms
if [ "$romtype" == "MIUI" ]; then
echo "MIUI detected - skip applying brightness patch"
lighthts=no
fi

# Only patch this if our system support tools
if [ "$lighthts" == "yes" ]; then
	echo "Start patching brightness patch for services"
	if [ ! -f "$systempath/framework/oat/arm64/services.vdex" ];then
	vdex=no
	else
	echo "Dex Pre-opt ROM detected"
	vdex=yes
	fi

	# Fix no permission to run
	chmod 0777 $dexhackt/*
	# Let us do this on a tmp dir
	mkdir $thisdir/tmp
	mkdir $thisdir/tmp/services_original
        if [ "$vdex" == "yes" ]; then
        echo "Converting vdex to cdex"
	cp $systempath/framework/services.jar $thisdir/tmp/services_original/
	# vdex -> cdex
	$dexhackt/vdexExtractor -i $thisdir/tmp/services_original/services.vdex
	rm -rf $thisdir/tmp/services_original/services.vdex
	mv $thisdir/tmp/services_original/services_classes.cdex $thisdir/tmp/services_original/services.cdex
	cd $thisdir/tmp/services_original
	$dexhackt/compact_dex_converters services.cdex
	rm -rf services.cdex
	mv services.cdex.new services.dex
	# Merge dex into jar so that we can use apktool
	zip -r services_original.jar *
	mv services_original.jar ../
	cd ..
	rm -rf services_original
	# ready to go
	java -jar $toolsdir/apktool/apktool.jar d services_original.jar
	cd services_original.jar.out
	# let us patch it
	cd original/smali_services/server/lights
	rm -rf *.*
	cp $thisdir/brightness/* ./
	# repack it
	echo "Start repacking"
	cd $thisdir/tmp
	java -jar $toolsdir/apktool/apktool.jar b services_original.jar.out
	# replace
	rm -rf $systempath/framework/oat/arm64/services.*
	rm -rf $systempath/framework/services.jar
	cp services_original.jar.out/dist/services_original.jar $systempath/framework/services.jar
	cd $thisdir
	# cleanup
	rm -rf tmp
	fi

	if [ "$vdex" == "no" ]; then
	# generic services jar
	cp $systempath/framework/services.jar $thisdir/tmp/services_original.jar
	cd $thisdir/tmp
	java -jar $toolsdir/apktool/apktool.jar d services_original.jar
	cd services_original.jar.out
	# let us patch it
	cd original/smali_services/server/lights
	rm -rf *.*
	cp $thisdir/brightness/* ./
	# repack it
	echo "Start repacking"
	cd $thisdir/tmp
	java -jar $toolsdir/apktool/apktool.jar b services_original.jar.out
	# replace
	rm -rf $systempath/framework/oat/arm64/services.*
	rm -rf $systempath/framework/services.jar
	cp services_original.jar.out/dist/services_original.jar $systempath/framework/services.jar
	cd $thisdir
	# cleanup
	rm -rf tmp
	fi

fi
