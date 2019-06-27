#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
toolsdir=$thispath/../../tools

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    dexhackt="$toolsdir/linux/bin"
    if [ ! -f "$toolsdir/linux/bin/compact_dex_converters" ];then
    unzip $toolsdir/linux/cdextools.zip -d $toolsdir/linux/bin/
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
if [ -f $romsdir/$sourcever/$romtype/DONTPATCHLIGHT ]; then
	echo "Patching lights on $romtype isn't working. Skipping..."
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
	mkdir $thispath/tmp
	mkdir $thispath/tmp/services_original
        if [ "$vdex" == "yes" ]; then
        echo "Converting vdex to cdex"
	cp $systempath/framework/services.jar $thispath/tmp/services_original/
        cp $systempath/framework/oat/arm64/services.vdex $thispath/tmp/services_original/
	# vdex -> cdex
	$dexhackt/vdexExtractor -i $thispath/tmp/services_original/services.vdex
	rm -rf $thispath/tmp/services_original/services.vdex
	mv $thispath/tmp/services_original/services_classes.cdex $thispath/tmp/services_original/services.cdex
	cd $thispath/tmp/services_original
	$dexhackt/compact_dex_converters services.cdex
	rm -rf services.cdex
	mv services.cdex.new services.dex
        unzip services.jar
        rm -rf services.jar
	# Merge dex into jar so that we can use apktool
	zip -r services_original.jar *
	mv services_original.jar ../
	cd ..
	rm -rf services_original
	# ready to go
	java -jar $toolsdir/apktool/apktool.jar d services_original.jar
	cd services_original.jar.out
	# let us patch it
	cd smali_services/com/android/server/lights
	rm -rf *.*
	cp $thispath/brightness/* ./
	# repack it
	echo "Start repacking"
	cd $thispath/tmp
        # For unknown reason apktool didn't pack META-INF
        # So we had to repack it ourselves
	java -jar $toolsdir/apktool/apktool.jar b services_original.jar.out
        mkdir services_new
        unzip services_original.jar.out/dist/services_original.jar -d $thispath/tmp/new/
	cp -r services_original.jar.out/original/* $thispath/tmp/new/
	cd $thispath/tmp/new
	zip -r ../services_new.jar *
	# replace
	rm -rf $systempath/framework/oat/arm64/services.*
	rm -rf $systempath/framework/services.jar
	cp ../services_new.jar $systempath/framework/services.jar
	cd $thispath
	# cleanup
	rm -rf tmp
	fi

	if [ "$vdex" == "no" ]; then
	# generic services jar
	cp $systempath/framework/services.jar $thispath/tmp/services_original.jar
	cd $thispath/tmp
	java -jar $toolsdir/apktool/apktool.jar d services_original.jar
	cd services_original.jar.out
	# let us patch it
	cd smali_services/com/android/server/lights
	rm -rf *.*
	cp $thispath/brightness/* ./
	# repack it
	echo "Start repacking"
	cd $thispath/tmp
        # For unknown reason apktool didn't pack META-INF
        # So we had to repack it ourselves
	java -jar $toolsdir/apktool/apktool.jar b services_original.jar.out
        mkdir services_new
        unzip services_original.jar.out/dist/services_original.jar -d $thispath/tmp/new/
	cp -r services_original.jar.out/original/* $thispath/tmp/new/
	cd $thispath/tmp/new
	zip -r ../services_new.jar *
	# replace
	rm -rf $systempath/framework/services.jar
	cp ../services_new.jar $systempath/framework/services.jar
	cd $thispath
	# cleanup
	rm -rf tmp
	fi
fi
