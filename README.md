## Requirements
- protobuf
- LZMA
- 7z
- lz4
### Linux
```
apt install liblzma-dev python-pip openjdk-8-jre-headless brotli lz4
pip install backports.lzma protobuf
```
### Mac
```
brew install protobuf liblzma-dev brotli lz4
pip install backports.lzma protobuf
```

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

### Generating GSI from stock firmware URL
Example: for making OxygenOS of oneplus 7 pro firmware, you can use this command
```
./url2GSI.sh https://oxygenos.oneplus.net/OnePlus7ProOxygen_21.O.07_OTA_007_all_1905120542_fc480574576b4843.zip OxygenOS
```
check url2GSI.sh for more info
