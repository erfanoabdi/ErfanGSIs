mount -o bind /system/bin/android.hardware.wifi@1.0-service /vendor/bin/hw/android.hardware.wifi@1.0-service || true
mount -o bind /system/bin/hostapd /vendor/bin/hw/hostapd || true
mount -o bind /system/bin/wpa_supplicant /vendor/bin/hw/wpa_supplicant || true
mount -o bind /system/bin/vendor.qti.gnss@2.0-service /vendor/bin/hw/vendor.qti.gnss@2.0-service || true
mount -o bind /system/bin/vendor.qti.gnss@2.0-service /vendor/bin/hw/vendor.qti.gnss@1.0-service || true
mount -o bind /system/erfan/libgnss.so /vendor/lib64/libgnss.so || true
mount -o bind /system/bin/rild /vendor/bin/hw/rild || true
mount -o bind /system/erfan/libril.so /vendor/lib64/libril.so || true
