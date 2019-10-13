#!/bin/bash

# Project OEM-GSI Porter by Erfan Abdi <erfangplus@gmail.com>

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

TOKEN=xxxxxxxxxx
CHAT_ID=xxxxxxxx
BOTURL="https://api.telegram.org/bot$TOKEN/sendMessage"

urlencode() {
    echo "$*" | sed 's:%:%25:g;s: :%20:g;s:<:%3C:g;s:>:%3E:g;s:#:%23:g;s:{:%7B:g;s:}:%7D:g;s:|:%7C:g;s:\\:%5C:g;s:\^:%5E:g;s:~:%7E:g;s:\[:%5B:g;s:\]:%5D:g;s:`:%60:g;s:;:%3B:g;s:/:%2F:g;s:?:%3F:g;s^:^%3A^g;s:@:%40:g;s:=:%3D:g;s:&:%26:g;s:\$:%24:g;s:\!:%21:g;s:\*:%2A:g'
}

function tg_send() {
    TEXT="$1"
    until [ $(echo -n "$TEXT" | wc -m) -eq 0 ]; do
    res=$(curl -s "$BOTURL" -d "chat_id=$CHAT_ID" -d "text=$(urlencode "${TEXT:0:4096}")" -d "parse_mode=markdown" -d "disable_web_page_preview=true")
    TEXT="${TEXT:4096}"
    done
}

UPLOAD()
{
    OUTPUTDIR="$1"
    SRCTYPENAME=$2
    AB=$3
    AONLY=$4
    URL="$5"

    DATE=`date +%Y%m%d`
    TIME=`date +%H%M`

    IMAGEABNAME="${SRCTYPENAME}-AB-*-${DATE}-*.img"
    INFOABNAME="${SRCTYPENAME}-AB-*-${DATE}-*.txt"
    IMAGEABPATH="${OUTPUTDIR}/${IMAGEABNAME}"
    INFOABPATH="${OUTPUTDIR}/${INFOABNAME}"

    IMAGEAONAME="${SRCTYPENAME}-Aonly-*-${DATE}-*.img"
    INFOAONAME="${SRCTYPENAME}-Aonly-*-${DATE}-*.txt"
    IMAGEAOPATH="${OUTPUTDIR}/${IMAGEAONAME}"
    INFOAOPATH="${OUTPUTDIR}/${INFOAONAME}"

    if [ $AB == true ]; then
        IMAGEABPATH="$(ls $IMAGEABPATH)"
        INFOABPATH="$(ls $INFOABPATH)"
        IMAGEABNAME=$(echo "$IMAGEABPATH" | rev | cut -d "/" -f 1 | rev)
        INFOABNAME=$(echo "$INFOABPATH" | rev | cut -d "/" -f 1 | rev)
        INFONAME=$INFOABNAME
        INFOPATH=$INFOABPATH
        if [[ -f "$IMAGEABPATH" ]]; then
            echo "Compressing $IMAGEABPATH-${TIME}.7z"
            7z a "$IMAGEABPATH-${TIME}.7z" "$IMAGEABPATH" 2>/dev/null >> "$OUTPUTDIR/zip.log"
            mv "$IMAGEABPATH-${TIME}.7z" /data/web/gsis/
        fi
    fi

    if [ $AONLY == true ]; then
        IMAGEAOPATH="$(ls $IMAGEAOPATH)"
        INFOAOPATH="$(ls $INFOAOPATH)"
        IMAGEAONAME=$(echo "$IMAGEAOPATH" | rev | cut -d "/" -f 1 | rev)
        INFOAONAME=$(echo "$INFOAOPATH" | rev | cut -d "/" -f 1 | rev)
        INFONAME=$INFOAONAME
        INFOPATH=$INFOAOPATH
        if [[ -f "$IMAGEAOPATH" ]]; then
            echo "Compressing $IMAGEAOPATH-${TIME}.7z"
            7z a "$IMAGEAOPATH-${TIME}.7z" "$IMAGEAOPATH" 2>/dev/null >> "$OUTPUTDIR/zip.log"
            mv "$IMAGEAOPATH-${TIME}.7z" /data/web/gsis/
        fi
    fi

    rm -rf "$IMAGEABPATH" "$IMAGEAOPATH"

    if [ $AB == true ] && [ $AONLY == true ]; then DEVICE_TEXT="A/AB Devices"; fi
    if [ $AB == true ] && [ $AONLY == false ]; then DEVICE_TEXT="AB Devices"; fi
    if [ $AB == false ] && [ $AONLY == true ]; then DEVICE_TEXT="A-Only Devices"; fi

    MSGTEXT="*$SRCTYPENAME GSI For $DEVICE_TEXT*  \n  \n"
    if [[ "$URL" == "http"* ]]; then
        # URL detected
        MSGTEXT="${MSGTEXT}*Base Firmware Link:* [Click]($URL)  \n  \n"
    fi
    if [[ -f "$INFOPATH" ]]; then
        MSGTEXT="${MSGTEXT}*Information:*\`\`\`"
        MSGTEXT="${MSGTEXT}$(cat $INFOPATH)\`\`\`  \n"
    fi
    AUTHORS=$(git log --all --format='%aN' | sort -u | nc termbin.com 9999)
    if [ ! -z "$AUTHORS" ]; then
        MSGTEXT="${MSGTEXT}*Thanks to:*  \n"
        MSGTEXT="${MSGTEXT}[Contributors List]($AUTHORS)  \n  \n"
    fi
    MSGTEXT="${MSGTEXT}*Download Links*  \n"
    if [ $AB == true ]; then
        MSGTEXT="${MSGTEXT}*AB Devices:*  \n"
        MSGTEXT="${MSGTEXT}[$IMAGEABNAME-${TIME}.7z](https://myserver.com/gsis/$IMAGEABNAME-${TIME}.7z)  \n  \n"
    fi
    if [ $AONLY == true ]; then
        MSGTEXT="${MSGTEXT}*A-Only Devices:*  \n"
        MSGTEXT="${MSGTEXT}[$IMAGEAONAME-${TIME}.7z](https://myserver.com/gsis/$IMAGEAONAME-${TIME}.7z)  \n  \n"
    fi

    printf "${MSGTEXT}" > "$OUTPUTDIR/tg.md"
    tg_send "$(cat $OUTPUTDIR/tg.md)"
}
