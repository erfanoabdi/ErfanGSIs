#TODO: remove me
# shitty treble fixups

mount -o bind /system/lib/vndk-"$vndk"/libgui.so /vendor/lib/libgui_vendor.so || true
mount -o bind /system/lib64/vndk-"$vndk"/libgui.so /vendor/lib64/libgui_vendor.so || true

mount -o bind system/phh/empty /vendor/lib/libbinder.so || true
mount -o bind system/phh/empty /vendor/lib64/libbinder.so || true
