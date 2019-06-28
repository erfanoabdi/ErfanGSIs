#/bin/bash

systempath=$1
romdir=$2
thispath=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Apply overlay patches
$thispath/overlays/make.sh "$systempath"

# Brightness fix for Android P
# But some systems are using custom light services, don't apply this patch on those roms
if [ -f $romdir/DONTPATCHLIGHT ]; then
	echo "Patching lights on $romtype isn't working. Skipping..."
else
    $thispath/brightnessfix/make.sh "$systempath"
fi
