## Requirements
    Linux or Mac

## Released GSIs
Download links: https://mirrors.lolinet.com/firmware/gsi/  
XDA thread: https://forum.xda-developers.com/project-treble/trebleenabled-device-development/pie-erfan-gsi-ports-t3906486  
Telegram group: https://t.me/ErfanGSIs  
Telegram channel: https://t.me/ErfanGSI  

## How to use

### Download tools
```
git clone --recurse-submodules https://github.com/erfanoabdi/ErfanGSIs.git
cd ErfanGSIs
```

### For setting up requirements
    bash setup.sh

### Generating GSI from stock firmware URL
Example: for making OxygenOS of oneplus 7 pro firmware, you can use this command
```
./url2GSI.sh https://hugeota.d.miui.com/20.8.20/miui_PYXIS_20.8.20_880b3b35af_10.0.zip MIUI
```
check url2GSI.sh for more info
