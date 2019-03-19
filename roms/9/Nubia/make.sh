#/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
cp -fpr $thispath/lib64/* $1/lib64/
cp -fpr $thispath/init/* $1/etc/init/

# Bloatware clean-up
rm -rf $1/preset_apps/aimeituan_nubiya4_signed_aligned_20180712202003
rm -rf $1/preset_apps/amap_8_2_2_L016_Nubiya_C01110001123
rm -rf $1/preset_apps/app_K17_17Knubia_6_1_6_build976_3
rm -rf $1/preset_apps/baidusearch_Android_10_5_0_155_1008614g
rm -rf $1/preset_apps/com_chaozh_iReaderNubia_publish_754_116699_formal_signed_2018_08_31_17_04
rm -rf $1/preset_apps/Ctrip_android_7_14_2_1170_55554059_4781968
rm -rf $1/preset_apps/moffice_9_5_3_1033_cn00668_multidex_245717
rm -rf $1/preset_apps/NewsArticle_nubia_yz1_v6_4_8_f1b4d47_2018_04_03_18_37_51
rm -rf $1/preset_apps/pptv_aphone_v6_4_1_2365_2018_03_19_88d38bd
rm -rf $1/preset_apps/QQBrowser7_8_0_38_zipaligned_x5_20180202_1100101423_180202125910a
rm -rf $1/preset_apps/QYVideoClient_Nubiya_9_5_1_20180828_101536
rm -rf $1/preset_apps/redtea_app
rm -rf $1/preset_apps/suning_nubia_11000_5_7_2_2_20180720_1303
rm -rf $1/preset_apps/UCBrowser_V12_0_0_980_android_pf145_zh_cn_prerelease_Build180928162242_36262
rm -rf $1/preset_apps/V6_6_0_54928_1522316489_T2_oem_heisha
rm -rf $1/preset_apps/vipshop_nubia6_8_6_21_8_1_git_c1a6b215365_20180930
rm -rf $1/preset_apps/nubiabbs_v2_0_4_20181120_release
rm -rf $1/preset_apps/nubia_neoShare
rm -rf $1/preset_apps/Weibo_8_5_3_nubia_9170_90009_3635_0910
