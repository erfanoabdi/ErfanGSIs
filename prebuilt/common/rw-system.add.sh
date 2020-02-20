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

# drop qcom stuffs for non qcom devices
if ! getprop ro.hardware | grep -qiE -e qcom -e mata;then
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

if getprop ro.vendor.build.fingerprint | grep -qiE '^samsung/' ;then
    mount -o bind /mnt/phh/empty_dir "/vendor/overlay" || true
fi

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

# Drop aosp light from manifest if service not avaliable
if [ "$vndk" -lt 29 ]; then
if [ ! -f /vendor/bin/hw/android.hardware.light* ]; then
    for f in \
        /vendor/etc/vintf/manifest.xml \
        /vendor/manifest.xml; do # For O if i ever wanted to try
        [ ! -f "$f" ] && continue
        if grep -q "android.hardware.light" "$f"; then
            # shellcheck disable=SC2010
            ctxt="$(ls -lZ "$f" | grep -oE 'u:object_r:[^:]*:s0')"
            b="$(echo "$f" | tr / _)"
            cp -a "$f" "/mnt/phh/$b"
            sed -i "s|android.hardware.light|android.hardware.NOPElight|g" "/mnt/phh/$b"
            chcon "$ctxt" "/mnt/phh/$b"
            mount -o bind "/mnt/phh/$b" "$f"
        fi
    done
fi
fi

frp_node="$(getprop ro.frp.pst)"
chown -h system.system $frp_node
chmod 0660 $frp_node

# Drop samsung overlays
if getprop ro.vendor.build.fingerprint | grep -qiE '^samsung'; then
    mount -o bind /system/phh/empty /vendor/overlay
fi
