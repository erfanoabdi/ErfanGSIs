#!/system/bin/sh

# Copyright (C) 2019 Erfan Abdi (erfangplus@gmail.com)

fingerprint="$(getprop ro.build.fingerprint)"
sdkVersion"$(getprop ro.build.version.sdk)"

if [[ ! -d /data/system ]]; then
    mkdir -p /data/system
    chmod 0775 /data/system
    chown system:system /data/system
fi

if [[ ! -e /data/system/packages.list ]]; then
    touch /data/system/packages.list
    chmod 0640 /data/system/packages.list
    chown system:system /data/system/packages.list
fi

if [[ ! -e /data/system/packages.xml ]]; then
    echo "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>" > /data/system/packages.xml
    echo "<packages>" >> /data/system/packages.xml
    echo '<version sdkVersion="'$sdkVersion'" databaseVersion="3" fingerprint="'$fingerprint'" />' >> /data/system/packages.xml
    echo "</packages>" >> /data/system/packages.xml
    chmod 0640 /data/system/packages.xml
    chown system:system /data/system/packages.xml
fi
