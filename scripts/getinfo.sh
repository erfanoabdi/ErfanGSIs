#!/bin/bash
SYSTEMDIR="$1"

flavor=$(grep -oP "(?<=^ro.build.flavor=).*" -hs "$SYSTEMDIR"/build*.prop)
[[ -z "${flavor}" ]] && flavor=$(grep -oP "(?<=^ro.system.build.flavor=).*" -hs "$SYSTEMDIR"/build*.prop)
[[ -z "${flavor}" ]] && flavor=$(grep -oP "(?<=^ro.build.type=).*" -hs "$SYSTEMDIR"/build*.prop)
release=$(grep -oP "(?<=^ro.build.version.release=).*" -hs "$SYSTEMDIR"/build*.prop)
[[ -z "${release}" ]] && release=$(grep -oP "(?<=^ro.system.build.version.release=).*" -hs "$SYSTEMDIR"/build*.prop)
id=$(grep -oP "(?<=^ro.build.id=).*" -hs "$SYSTEMDIR"/build*.prop)
[[ -z "${id}" ]] && id=$(grep -oP "(?<=^ro.system.build.id=).*" -hs "$SYSTEMDIR"/build*.prop)
incremental=$(grep -oP "(?<=^ro.build.version.incremental=).*" -hs "$SYSTEMDIR"/build*.prop)
[[ -z "${incremental}" ]] && incremental=$(grep -oP "(?<=^ro.system.build.version.incremental=).*" -hs "$SYSTEMDIR"/build*.prop)
tags=$(grep -oP "(?<=^ro.build.tags=).*" -hs "$SYSTEMDIR"/build*.prop)
[[ -z "${tags}" ]] && tags=$(grep -oP "(?<=^ro.system.build.tags=).*" -hs "$SYSTEMDIR"/build*.prop)
fingerprint=$(grep -oP "(?<=^ro.build.fingerprint=).*" -hs "$SYSTEMDIR"/build*.prop)
[[ -z "${fingerprint}" ]] && fingerprint=$(grep -oP "(?<=^ro.system.build.fingerprint=).*" -hs "$SYSTEMDIR"/build*.prop)
brand=$(grep -oP "(?<=^ro.product.brand=).*" -hs "$SYSTEMDIR"/build*.prop | head -1)
[[ -z "${brand}" ]] && brand=$(grep -oP "(?<=^ro.product.system.brand=).*" -hs "$SYSTEMDIR"/build*.prop | head -1)
[[ -z "${brand}" ]] && brand=$(echo $fingerprint | cut -d / -f1 )
model=$(grep -oP "(?<=^ro.product.model=).*" -hs "$SYSTEMDIR"/build*.prop | head -1)
[[ -z "${model}" ]] && model=$(grep -oP "(?<=^ro.product.system.model=).*" -hs "$SYSTEMDIR"/build*.prop | head -1)
codename=$(grep -oP "(?<=^ro.product.device=).*" -hs "$SYSTEMDIR"/build*.prop | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.product.system.device=).*" -hs "$SYSTEMDIR"/build*.prop | head -1)
[[ -z "${codename}" ]] && codename=$(echo $fingerprint | cut -d / -f3 | cut -d : -f1 )
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.build.fota.version=).*" -hs "$SYSTEMDIR"/build*.prop | cut -d - -f1 | head -1)
spl=$(grep -oP "(?<=^ro.build.version.security_patch=).*" -hs "$SYSTEMDIR"/build*.prop | head -1)
description=$(grep -oP "(?<=^ro.build.description=).*" -hs "$SYSTEMDIR"/build*.prop)
[[ -z "${description}" ]] && description=$(grep -oP "(?<=^ro.system.build.description=).*" -hs "$SYSTEMDIR"/build*.prop)
[[ -z "${description}" ]] && description="$flavor $release $id $incremental $tags"

printf "Android Version: $release
Brand: $brand
Model: $model
Codename: $codename
Build Type: $flavor
Build Number: $id
Incremental: $incremental
Tags: $tags
Security Patch: $spl
Fingerprint: $fingerprint
Description: $description
"
