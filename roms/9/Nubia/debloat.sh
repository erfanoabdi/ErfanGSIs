#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Bloatware clean-up
rm -rf $1/preset_apps/aimeituan*
rm -rf $1/preset_apps/amap*
rm -rf $1/preset_apps/*Knubia*
rm -rf $1/preset_apps/baidusearch*
rm -rf $1/preset_apps/*iReaderNubia*
rm -rf $1/preset_apps/Ctrip*
rm -rf $1/preset_apps/moffice*
rm -rf $1/preset_apps/NewsArticle*
rm -rf $1/preset_apps/pptv*
rm -rf $1/preset_apps/QQBrowser*
rm -rf $1/preset_apps/QYVideoClient*
rm -rf $1/preset_apps/redtea*
rm -rf $1/preset_apps/suning*
rm -rf $1/preset_apps/UCBrowser*
rm -rf $1/preset_apps/*heisha
rm -rf $1/preset_apps/vipshop*
rm -rf $1/preset_apps/nubiabbs*
rm -rf $1/preset_apps/*neoShare*
rm -rf $1/preset_apps/Weibo*
rm -rf $1/media/videosample
rm -rf $1/ultrasonic
rm -rf $1/priv-app/Camera
