#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

rm -rf $1/app/Drive
rm -rf $1/app/Duo
rm -rf $1/app/Maps
rm -rf $1/app/YouTube
rm -rf $1/app/talkback
rm -rf $1/app/CalendarGoogle
rm -rf $1/app/Photos
rm -rf $1/app/GooglePay
rm -rf $1/app/Music2
rm -rf $1/app/Gmail2
rm -rf $1/app/GoogleTTS
rm -rf $1/priv-app/Velvet
rm -rf $1/app/AsusFMRadio
rm -rf $1/app/AsusFMService
rm -rf $1/app/Facebook
rm -rf $1/app/FacebookAppManager
rm -rf $1/app/FacebookMessenger
rm -rf $1/app/Instagram
rm -rf $1/app/mangaDeals
rm -rf $1/priv-app/YandexApp
rm -rf $1/priv-app/YandexBrowser
rm -rf $1/priv-app/FacebookInstaller
rm -rf $1/priv-app/FacebookNotificationServices
rm -rf $1/priv-app/AsusDataTransfer
rm -rf $1/priv-app/GameBroadcaster
