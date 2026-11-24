# TWRP for Galaxy A20 (SM-A205F / `a20`)

Recovery-only TWRP device tree for the Galaxy A20 (Exynos 7884B, Android 11 firmware base). Tested on device: boots into TWRP 12.1.

⚠️ **Flashing a custom recovery can wipe data or brick the device. Back up first.**

## Build

Needs TWRP AOSP sources on branch `twrp-12.1` (Ubuntu 22.04, ~100 GB free disk).

```bash
cd ~/twrp
git clone https://github.com/Behrooz140/twrp_device_samsung_a20.git device/samsung/a20
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
lunch twrp_a20-eng
mka recoveryimage
```

Output: `out/target/product/a20/recovery.img`

Alternatively use [GitHub Actions](https://github.com/Behrooz140/twrp_device_samsung_a20/actions/workflows/build-twrp.yml) → **Run workflow**, then download the `twrp-a20-twrp-12.1` artifact.

## Flash

Flash `recovery.img` to the **recovery** partition (Odin/Heimdall, or fastboot if supported), then boot straight into recovery. OEM unlock is required.

## Important notes

- **Keep LZMA enabled.** The old gzip ramdisk was 20 MB and the bootloader rejected it (reboot at Samsung logo). `BOARD_RAMDISK_USE_LZMA := true` + `lzma -9` keeps it ~13 MB.
- **Keep the bundled kernel/DTBO.** `prebuilt/Image` and `prebuilt/dtbo.img` come from a known-good TWRP 3.7.x recovery; the stock firmware pair does not bring up the display.
- **Do not duplicate properties.** Values with spaces belong in `system.prop`; `ro.product.board` / `ro.board.platform` are generated from `BoardConfig.mk` and must not be added there.
- **No `/data` decryption (FBE).** Formatting works; decrypting stock `/data` in TWRP does not.
- **Only SM-A205F** (`a20`, `a20dd`, `SM-A205F`).

Based on stock firmware `A205FXXSBCWC4` and a known-good TWRP 3.7.x recovery for `a20`.
