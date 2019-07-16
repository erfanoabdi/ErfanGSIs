model="$(sed -n 's/^ro.build.product=[[:space:]]*//p' /system/build.prop)"
mount -o bind /vendor/etc/audio_policy_configuration.xml /vendor/etc/audio_policy_configuration_"$model".xml || true
