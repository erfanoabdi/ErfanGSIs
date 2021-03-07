#!/bin/bash

flag=true
while IFS= read -r line;
do
    case "$line" in
        *"ro.product.build.version.sdk"*) flag=false && echo "$line" && continue ;;
        *"Auto-added by post_process_props.py"*) flag=true && echo "$line" && continue ;;
    esac
    $flag && echo "$line"
done  < "$1"
