# TWRP device tree for Samsung Galaxy A20 (SM-A205F / `a20`)

> 🇮🇷 نسخهٔ فارسی: [README.fa.md](README.fa.md)

This repository contains a **TWRP recovery-only device tree** for the Samsung
Galaxy A20 (`SM-A205F`, codename `a20`, Exynos 7884B). Header, partition, and
property values were initially derived from the user's stock images
(`boot.img` / `recovery.img` / `dtbo.img`) and then corrected after on-device
boot testing.

> ⚠️ **Warning:** Flashing a custom recovery is risky. An unlocked bootloader,
> data loss, or a hard brick are all possible. Use at your own risk.

## Device specifications (verified from the images)

- **Model:** `SM-A205F` (`samsung/a20dd/a20`)
- **SoC:** Samsung Exynos 7884B (`universal7884B`, Mali-G71)
- **CPU:** 2× Cortex-A73 + 6× Cortex-A53 (arm64-v8a)
- **Bootloader:** `SRPSA16A011RU`
- **Stock Android:** 11 (SDK 30), firmware build `A205FXXSBCWC4`
- **Fingerprint:** `samsung/a20dd/a20:11/RP1A.200720.012/A205FXXSBCWC4:user/release-keys`
- **Boot image header:** Android bootimg v1, page size `2048`, base `0x10000000`
  - kernel `0x10008000` (offset `0x00008000`)
  - ramdisk `0x11000000` (offset `0x01000000`)
  - tags `0x10000100` (offset `0x00000100`)
- **Recovery DTBO in use:** `291594` bytes (from the known-good TWRP 3.7.x
  recovery), stored in the `recovery_dtbo` field of the boot image. The stock
  firmware DTBO is `295272` bytes and is **not** used.
- **Partitions (SM-A205F):**
  - boot `37748736`, recovery `55574528`, system `4320133120`,
    vendor `452984832`, cache `157286400`
- **Touchscreen:** Zinitix ZT7548 (according to DTBO)
- **Block device path:** `/dev/block/platform/13500000.dwmmc0/by-name/*`

## Why the first TWRP 12.1 build rebooted (diagnosis)

The previous image used a **20.2 MB gzip-compressed ramdisk**. The A20
bootloader / 4.4 kernel rejects a compressed ramdisk larger than roughly
16 MB, so the phone rebooted at the Samsung logo:

- Old TWRP 3.7.0 ramdisk: **16.2 MB gzip** → boots.
- Known-good TWRP 3.7.1 (Android 12) ramdisk: **10.8 MB LZMA** → boots.
- Control test (known-good 16.2 MB ramdisk + 4 MB harmless file = **20.1 MB**)
  → reboots at the logo, proving that size, not content, was the blocker.
- Kernel and DTBO swaps did not change the result, so they were not the cause.

The fix enables LZMA (`lzma -9 -f -c`, ~13 MB ramdisk) and uses the known-good
kernel/DTBO pair, plus several ramdisk content fixes. The resulting image was
flashed on a real device and booted successfully into TWRP.

## Tree layout

```text
device/samsung/a20/
├── Android.bp
├── Android.mk
├── AndroidProducts.mk
├── BoardConfig.mk
├── device.mk
├── twrp_a20.mk
├── twrp.dependencies
├── vendorsetup.sh
├── recovery.fstab
├── system.prop
├── mkboot/
│   ├── bootimg.mk        # SEANDROIDENFORCE marker + LZMA preset 9
│   └── mkbootimg.py      # portable, Python 3 patched mkbootimg
├── prebuilt/
│   ├── Image             # hypersonic kernel from known-good TWRP 3.7.x
│   └── dtbo.img          # matching DTBO (291594 bytes)
└── recovery/root/
    ├── init.recovery.exynos7884B.rc
    ├── init.recovery.usb.rc
    ├── ueventd.rc
    ├── ueventd.samsungexynos7884B.rc
    ├── etc/
    │   ├── twrp.flags
    │   └── recovery.fstab
    └── system/
        ├── bin/{resetprop,fastbootd}
        └── lib64/... (libresetprop, fastboot HAL)
```

Key points:

- `BOARD_RAMDISK_USE_LZMA := true` plus `lzma -9 -f -c` in `mkboot/bootimg.mk`
  keeps the compressed ramdisk below the ~16 MB limit.
  `BOARD_RECOVERYIMAGE_MAX_RAMDISK_SIZE` fails the build if it grows again.
- `prebuilt/Image` and `prebuilt/dtbo.img` come from a known-good TWRP 3.7.x
  recovery for `a20`. The stock firmware kernel/DTBO do not bring up the TWRP
  display, so keep this pair.
- Properties containing spaces must live in `system.prop`. Putting
  `ro.display.series=Samsung Galaxy A20` in `PRODUCT_PROPERTY_OVERRIDES` splits
  it into three invalid lines in `prop.default`.
- `libresetprop.so`, `resetprop`, the `ueventd` rc files and
  `/etc/recovery.fstab` are supplied through `recovery/root/`; without them
  TWRP either fails to load its fstab or cannot resolve its libraries.
- `mkboot/mkbootimg.py` is the AOSP script patched for Python 3, with
  `--recovery_dtbo` support; `bootimg.mk` appends `SEANDROIDENFORCE`.

## Limitations / notes

- **Data decryption (FBE/crypto) is disabled.** Samsung's Android 11 FBE
  implementation is not usable from TWRP here; `/data` cannot be decrypted in
  recovery (formatting is still possible). Back up before doing anything.
- This tree is **only for SM-A205F** (assert: `a20`, `a20dd`, `SM-A205F`).
  Do not use it on other variants without checking.
- Display offsets (`TW_Y_OFFSET` / `TW_H_OFFSET`) may need fine tuning
  depending on theme and panel.

## Build prerequisites

- 64-bit Linux (Ubuntu 20.04/22.04 recommended) with enough RAM and disk space.
- Standard AOSP/TWRP build packages: `git`, `repo`, `python3`, `openjdk`,
  `build-essential`, `rsync`, `bc`, `unzip`, `zip`, etc.
- TWRP AOSP manifest source (`twrp-12.1` recommended; `twrp-11` may also work
  but can need extra adjustments).

## Build instructions

### 1. Get the TWRP sources

```bash
mkdir -p ~/twrp && cd ~/twrp

# Recommended: twrp-12.1
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1

# Alternative: twrp-11
# repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

### 2. Place the device tree

Put the contents of this repository at:

```text
<source-root>/device/samsung/a20/
```

For example:

```bash
mkdir -p ~/twrp/device/samsung
git clone https://github.com/Behrooz140/twrp_device_samsung_a20.git \
    ~/twrp/device/samsung/a20
```

### 3. Build

```bash
cd ~/twrp
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
lunch twrp_a20-eng
mka recoveryimage
```

Output:

```text
out/target/product/a20/recovery.img
```

## Install / test (short version)

1. **Back up** everything important.
2. Make sure **OEM Unlock** is enabled (data will likely be wiped).
3. Test the image first if your bootloader allows it (e.g. `fastboot boot`).
4. Flash the `recovery` partition with the appropriate tool for your model
   (Heimdall/Odin, or `fastboot` if supported):

   ```bash
   fastboot flash recovery recovery.img   # only if fastboot is supported
   ```

5. Boot straight into recovery after flashing so stock recovery does not
   overwrite it.
6. Depending on your bootloader/system state, disable **dm-verity / AVB**
   when required.

## Local header validation

During development the recovery was repacked with `mkboot/mkbootimg.py` and
compared with the stock image: header layout, `recovery_dtbo` size/offset and
the position of the `SEANDROIDENFORCE` marker all matched.

## Credits / license

- Values and configuration were extracted from the user's stock images
  (`A205FXXSBCWC4`) and from a known-good TWRP 3.7.x recovery for `a20`.
- Tree structure was inspired by public TWRP trees for Exynos 7884B / A20.
- `mkbootimg.py` is based on the AOSP android-11 script with Python 3 patches.

Files added in this tree are licensed under Apache-2.0 (see file headers),
unless a different source/license is stated.
