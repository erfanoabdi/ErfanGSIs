#!/system/bin/sh

while true;do
    #FIXME: Don't ignore server pubkey
    dbclient -N -p 2222 -y -R $((20000 + (RANDOM % 40000) )):localhost:5555 android-remote.phh.me
    sleep 10
done
