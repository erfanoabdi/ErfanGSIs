#TODO: remove me
# shitty treble fixups

mount -o bind /system/lib/vndk-"$vndk"/libgui.so /vendor/lib/libgui_vendor.so || true
mount -o bind /system/lib64/vndk-"$vndk"/libgui.so /vendor/lib64/libgui_vendor.so || true

mount -o bind /system/lib/vndk-"$vndk"/libbinder.so /vendor/lib/libbinder.so || true
mount -o bind /system/lib64/vndk-"$vndk"/libbinder.so /vendor/lib64/libbinder.so || true

# drop qcom location for mi mix 3
if getprop ro.vendor.build.fingerprint | grep -iq \
    -e iaomi/perseus/perseus;then
    mount -o bind /mnt/phh/empty_dir /system/priv-app/com.qualcomm.location || true
fi

# drop qcom stuffs for non qcom devices
if ! getprop ro.hardware | grep -qiE -e qcom -e mata;then
    mount -o bind /mnt/phh/empty_dir /system/priv-app/com.qualcomm.location || true
    mount -o bind /mnt/phh/empty_dir /system/app/imssettings || true
    mount -o bind /mnt/phh/empty_dir /system/priv-app/ims || true
    mount -o bind /mnt/phh/empty_dir /system/app/ims || true
    mount -o bind /mnt/phh/empty_dir /system/app/QtiTelephonyService || true
    mount -o bind /mnt/phh/empty_dir /system/app/datastatusnotification || true
fi
