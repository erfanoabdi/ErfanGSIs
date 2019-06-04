#!/system/bin/sh

# Copyright (C) 2019 Erfan Abdi (erfangplus@gmail.com)

mkdir -p /data/erf
chmod 0775 /data/erf
chown system:system /data/erf
echo "SET_BOOTSTAGE@NATIVE_INIT_TRIGGER_POST_FS_DATA" > /data/erf/phx
chmod 0640 /data/erf/phx
chown system:system /data/erf/phx
touch /data/erf/botfrm
chmod 0640 /data/erf/botfrm
chown system:system /data/erf/botfrm
