# There is no need for us to reset data services status on every boot
# Sometimes it will make our data unable to use again :(
# Mount empty for flymedata fix rc before running it after the first boot
if [[ -d /data/system ]]; then
    mount -o bind /system/phh/empty /system/etc/init/flymedata.rc
fi