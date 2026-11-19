#
# Samsung boot image packing
#
# The stock Galaxy A20 recovery image is a header v1 Android boot image that
#  1. contains the kernel (Image), the recovery ramdisk and the recovery DTBO,
#  2. is followed by the literal marker "SEANDROIDENFORCE".
#
# AOSP's mkbootimg does not append that marker, so this file replaces the
# default boot/recovery image rules with a call to the mkbootimg.py shipped in
# this tree (patched AOSP android-11 script) and appends the marker afterwards.
#
# The marker must be written directly after the page-aligned DTBO, which is
# exactly where the stock image has it (offset 0x2a63000 for the stock
# A205FXXSBCWC4 recovery.img).
#

MKBOOTIMG_PY := $(DEVICE_PATH)/mkboot/mkbootimg.py
SEANDROIDENFORCE_MARKER := SEANDROIDENFORCE

# BOARD_RAMDISK_USE_LZMA selects the "alone" LZMA stream format that the A20
# 4.4 kernel can decompress. Use preset 9 (64 MiB dictionary) exactly like the
# known-good TWRP 3.7.x recovery for this device; that keeps the compressed
# recovery ramdisk at ~13 MiB instead of ~20 MiB, which the bootloader rejects.
COMPRESSION_COMMAND := $(LZMA) -9 -f -c

# --- boot image (not used by "mka recoveryimage", kept for completeness) ----
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG_PY) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Target boot image: $@")
	$(hide) python3 $(MKBOOTIMG_PY) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) printf "$(SEANDROIDENFORCE_MARKER)" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE))
	@echo "Made boot image: $@"

# --- recovery image ---------------------------------------------------------
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG_PY) $(recovery_ramdisk) $(recovery_kernel) $(recoveryimage-deps)
	$(call pretty,"Target recovery image: $@")
	$(hide) python3 $(MKBOOTIMG_PY) $(INTERNAL_RECOVERYIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) printf "$(SEANDROIDENFORCE_MARKER)" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE))
	@echo "Made recovery image: $@"
