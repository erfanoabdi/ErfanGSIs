mount -o bind /mnt/phh/empty_dir /vendor/overlay/DisplayCutoutEmulationTall || true
mount -o bind /mnt/phh/empty_dir /vendor/overlay/DisplayCutoutEmulationDouble || true
mount -o bind /mnt/phh/empty_dir /vendor/overlay/DisplayCutoutEmulationCorner || true

if [ "$vndk" -ge 28 ]; then
    mount -o bind /system/bin/wpa_supplicant /vendor/bin/hw/wpa_supplicant || true
fi
