#!/bin/bash

flag=true
while IFS= read -r line;
do
    case "$line" in
        *"end build properties"*) flag=false && continue ;;
        *"ADDITIONAL_BUILD_PROPERTIES"*) flag=true && continue ;;
    esac
    $flag && echo "$line"
done  < "$1"
