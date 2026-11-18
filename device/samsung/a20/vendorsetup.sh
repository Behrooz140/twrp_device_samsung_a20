#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# add_lunch_combo is deprecated/removed in newer Android build environments.
# COMMON_LUNCH_CHOICES in AndroidProducts.mk is the preferred mechanism.
if command -v add_lunch_combo >/dev/null 2>&1; then
  add_lunch_combo twrp_a20-eng
  add_lunch_combo twrp_a20-userdebug
  add_lunch_combo twrp_a20-user
fi
