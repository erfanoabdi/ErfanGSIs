#TODO: remove me
# shitty treble fixups

mount -o bind /system/lib/vndk-"$vndk"/libgui.so /vendor/lib/libgui_vendor.so || true
mount -o bind /system/lib64/vndk-"$vndk"/libgui.so /vendor/lib64/libgui_vendor.so || true

mount -o bind /system/lib/vndk-"$vndk"/libbinder.so /vendor/lib/libbinder.so || true
mount -o bind /system/lib64/vndk-"$vndk"/libbinder.so /vendor/lib64/libbinder.so || true

mount -o bind /system/lib/vndk-"$vndk"/libbinder.so /vendor/lib/vndk/libbinder.so || true
mount -o bind /system/lib64/vndk-"$vndk"/libbinder.so /vendor/lib64/vndk/libbinder.so || true

mount -o bind /system/lib/vndk-sp-"$vndk"/libcutils.so /vendor/lib/libcutils.so || true
mount -o bind /system/lib64/vndk-sp-"$vndk"/libcutils.so /vendor/lib64/libcutils.so || true

mount -o bind /system/lib/vndk-sp-"$vndk"/libcutils.so /vendor/lib/vndk-sp/libcutils.so || true
mount -o bind /system/lib64/vndk-sp-"$vndk"/libcutils.so /vendor/lib64/vndk-sp/libcutils.so || true

mount -o bind /system/lib/libpdx_default_transport.so /vendor/lib/libpdx_default_transport.so || true
mount -o bind /system/lib64/libpdx_default_transport.so /vendor/lib64/libpdx_default_transport.so || true

mount -o bind /system/lib/libpdx_default_transport.so /vendor/lib/vndk/libpdx_default_transport.so || true
mount -o bind /system/lib64/libpdx_default_transport.so /vendor/lib64/vndk/libpdx_default_transport.so || true

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

vendor_overlays=$(ls /vendor/overlay)

for overlay in $vendor_overlays; do
    if [[ ! $overlay == *"utout"* ]] && [[ ! $overlay == *"DarkTheme"* ]] && [[ ! $overlay == *"framework"* ]]; then
        if [ -f "/vendor/overlay/$overlay" ]; then
            mount -o bind /system/phh/empty "/vendor/overlay/$overlay" || true
        fi
        if [ -d "/vendor/overlay/$overlay" ]; then
             mount -o bind /mnt/phh/empty_dir "/vendor/overlay/$overlay" || true
        fi
    fi
done

# Fix no Earpiece in audio_policy
for f in \
    /odm/etc/audio_policy_configuration.xml \
    /vendor/etc/audio_policy_configuration.xml; do
    [ ! -f "$f" ] && continue
    if ! grep -q "<item>Earpiece</item>" "$f"; then
        # shellcheck disable=SC2010
        ctxt="$(ls -lZ "$f" | grep -oE 'u:object_r:[^:]*:s0')"
        b="$(echo "$f" | tr / _)"
        cp -a "$f" "/mnt/phh/$b"
        sed -i "s|<attachedDevices>|<attachedDevices><item>Earpiece</item>|g" "/mnt/phh/$b"
        chcon "$ctxt" "/mnt/phh/$b"
        mount -o bind "/mnt/phh/$b" "$f"
    fi
done
