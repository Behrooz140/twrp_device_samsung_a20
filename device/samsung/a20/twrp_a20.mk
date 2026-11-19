#
# Copyright (C) 2024 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit common TWRP configuration.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from the a20 device.
$(call inherit-product, device/samsung/a20/device.mk)

PRODUCT_RELEASE_NAME := a20

PRODUCT_DEVICE := a20
PRODUCT_NAME := twrp_a20
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-A205F
PRODUCT_MANUFACTURER := samsung

PRODUCT_GMS_CLIENTID_BASE := android-samsung-ss

# Firmware the tree was generated from: A205FXXSBCWC4 (Android 11)
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="a20dd-user 11 RP1A.200720.012 A205FXXSBCWC4 release-keys"

BUILD_FINGERPRINT := samsung/a20dd/a20:11/RP1A.200720.012/A205FXXSBCWC4:user/release-keys

# Properties TWRP / recovery needs at runtime live in system.prop.
# Do NOT put values containing spaces in PRODUCT_PROPERTY_OVERRIDES: the build
# writes them into prop.default one word per line, which corrupts the property
# (this is exactly what happened to ro.display.series).
