#!/bin/bash

FILE="$1"
PART="$2"

flag=true
while IFS= read -r line;
do
    if [[ "$line" == *"$PART"* ]]; then
        flag=false
        continue
    fi
    $flag && echo "$line"
    if ! $flag && [[ "$line" == "#line "* ]]; then
        flag=true
        echo "$line"
        continue
    fi
done  < "$FILE"
