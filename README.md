# ErfanGSIs - Android GSI Porting Tool

A powerful toolset to convert Android firmware (stock ROMs) into Generic System Images (GSI) that can be flashed on any Treble-compatible device.

## 📱 Supported Android Versions

| Android Version | API Level | Status |
|----------------|-----------|--------|
| Android 9 (Pie) | 28 | ✅ Supported |
| Android 10 (Q) | 29 | ✅ Supported |
| Android 11 (R) | 30 | ✅ Supported |
| Android 12 (S) | 31 | ✅ Supported |
| **Android 13 (Tiramisu)** | **33** | **✅ Supported** |
| **Android 14 (UpsideDownCake)** | **34** | **✅ Supported** |
| **Android 15** | **35** | **✅ Supported** |

> **Note:** Android 16-18 detection is also included for future compatibility.

## 🔧 Supported ROM Types

### Android 9
- ColorOS, Flyme, Generic, MIUI, Moto, Nubia, OneUI, OxygenOS, Pixel, Xperia, ZUI, ZenUI

### Android 10
- Flyme, Generic, MIUI, OxygenOS, Pixel

### Android 11+
- Generic, Pixel

### Output Types
- **AB (A/B)**: For devices with seamless update partition scheme
- **Aonly (A-Only)**: For traditional single system partition devices

## 📋 Requirements

### System Requirements
- **OS**: Linux (recommended) or macOS
- **Architecture**: x64 (64-bit)

### Dependencies
The `setup.sh` script will automatically install:
- `unace`, `unrar`, `zip`, `unzip`, `p7zip-full`, `p7zip-rar`
- `sharutils`, `rar`, `uudeview`, `mpack`, `arj`, `cabextract`
- `device-tree-compiler`, `liblzma-dev`, `aria2`
- `python-pip`, `brotli`, `liblz4-tool`, `gawk`

### Python Packages
- `backports.lzma`, `protobuf`, `pycrypto`

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone --recurse-submodules https://github.com/bradarwhatisdis/ErfanGSIs.git
cd ErfanGSIs
```

### 2. Install Dependencies
```bash
bash setup.sh
```

### 3. Build GSI from Firmware URL

**Basic usage:**
```bash
./url2GSI.sh <firmware_url> <rom_type> [options]
```

**Examples:**
```bash
# Build OxygenOS GSI from URL
./url2GSI.sh https://oxygenos.oneplus.net/OnePlus7ProOxygen_21.O.07_OTA_007_all.zip OxygenOS

# Build Pixel GSI (Android 15)
./url2GSI.sh https://dl.google.com/developer/android-15/pixel/Pixel.zip Pixel

# Build A-only GSI only
./url2GSI.sh https://example.com/firmware.zip Generic --aonly

# Build AB GSI only
./url2GSI.sh https://example.com/firmware.zip Generic --ab

# Clean up downloaded firmware after build
./url2GSI.sh https://example.com/firmware.zip Generic --cleanup
```

### 4. Build GSI from Local Firmware
```bash
./url2GSI.sh /path/to/local/firmware.zip Generic
```

## 📖 Advanced Usage

### Using make.sh Directly
```bash
./make.sh <path_to_firmware> <firmware_type> <output_type> [output_dir]

# Example
./make.sh /path/to/mounted/system Generic AB ./output
```

### Options Reference
| Option | Description |
|--------|-------------|
| `--ab` or `-b` | Build only A/B GSI |
| `--aonly` or `-a` | Build only A-Only GSI |
| `--cleanup` or `-c` | Clean up downloaded firmware after build |
| `--mounted` or `-m` | Use already mounted firmware |
| `--help` or `-h` | Show help information |

## 🤖 Telegram Bot Setup

The Telegram bot allows remote GSI building via Telegram commands.

### 1. Install Node.js Dependencies
```bash
cd telegram_bot
npm install
```

### 2. Configure Bot Token

Create `config.js` from the example:
```bash
cd telegram_bot
cp config.ex.js config.js
```

Edit `config.js` and add your bot token:
```javascript
const botConfig = {
    token: 'YOUR_TELEGRAM_BOT_TOKEN',  // Get from @BotFather
    gsi_builders: []  // Add authorized user IDs
};

module.exports = botConfig;
```

### 3. Get Bot Token
1. Message [@BotFather](https://t.me/BotFather) on Telegram
2. Send `/newbot` and follow instructions
3. Copy the token and paste into `config.js`

### 4. Run the Bot
```bash
cd telegram_bot
node bot.js
```

### 5. Available Bot Commands
| Command | Description |
|---------|-------------|
| `/start` | Display commands menu |
| `/help` | Show help information |
| `/url2gsi` | Build GSI from firmware URL |

### 6. Using with Private Utilities

Create `private_utils.sh` in the root directory (use `SAMPLEprivate_utils.sh` as template):
```bash
cp SAMPLEprivate_utils.sh private_utils.sh
```

Edit `private_utils.sh` to configure upload settings for completed GSIs.

## 📂 Project Structure

```
ErfanGSIs/
├── make.sh                  # Main GSI creation script
├── url2GSI.sh              # Entry point: Download & convert
├── setup.sh                # Install dependencies
├── update.sh               # Update submodules
├── roms/                   # ROM-specific configurations
│   ├── 9/                 # Android 9 ROMs
│   ├── 10/                # Android 10 ROMs
│   ├── 11/                # Android 11 ROMs
│   ├── 12/                # Android 12 ROMs
│   ├── 13/                # Android 13 ROMs
│   ├── 14/                # Android 14 ROMs
│   └── 15/                # Android 15 ROMs
├── prebuilt/               # Prebuilt system files & patches
│   ├── common/            # Common patches
│   ├── 9/ - 15/          # Version-specific patches
│   └── vendor_vndk/      # VNDK files (submodule)
├── scripts/                # Utility scripts
│   ├── mkimage.sh         # Create ext4 image
│   ├── fixsymlinks.sh     # Fix framework symlinks
│   ├── nukeABstuffs.sh    # Remove A/B files for A-only
│   └── ...
├── tools/                  # Binary tools
│   ├── Firmware_extractor/ # Extract firmware (submodule)
│   ├── ROM_resigner/      # APK resigner (submodule)
│   └── ...
└── telegram_bot/          # Telegram bot for remote building
```

## 🔄 How It Works

1. **Extract**: Firmware extracted using `Firmware_extractor`
2. **Mount**: Partition images mounted for access
3. **Copy**: System files copied to temp directory
4. **Debloat**: ROM-specific bloatware removed
5. **Resign**: APKs signed with AOSP keys
6. **Patch**: Apply common & ROM-specific patches
7. **Image**: Create flashable ext4 GSI image

## 📱 Runtime: rw-system.sh

The `rw-system.sh` script is included in the GSI and runs at boot to handle:
- Device-specific fixes (Samsung, Xiaomi, OnePlus, etc.)
- Fingerprint sensor quirks
- Display brightness fixes
- Audio effects configuration
- NFC settings for various devices
- Automatic hardware adaptation

## 🔗 Resources & Links

- **Download GSIs**: https://mirrors.lolinet.com/firmware/gsi/
- **XDA Thread**: https://forum.xda-developers.com/project-treble/trebleenabled-device-development/pie-erfan-gsi-ports-t3906486
- **Telegram Group**: https://t.me/ErfanGSIs
- **Telegram Channel**: https://t.me/ErfanGSI
- **Original Project**: https://github.com/erfanoabdi/ErfanGSIs

## ⚠️ Notes

- Ensure your device supports Project Treble (`ro.treble.enabled=true`)
- GSIs are best used with unlocked bootloader
- Always backup your device before flashing GSI
- Some features may not work depending on vendor implementation
- VNDK APEX files for Android 13-15 should be placed in `prebuilt/vendor_vndk_scripts/13/`, `14/`, `15/`

## 📄 License

This project is licensed under the terms found in `LICENSE` and `NOTICE` files.

## 🙏 Credits

- **Erfan Abdi** - Original creator
- **phhusson** - Treble GSI reference implementations
- **Contributors** - See GitHub commit history

---

**Disclaimer**: This tool is for educational and development purposes. Always respect software licenses and trademarks.
