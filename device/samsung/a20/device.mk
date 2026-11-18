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

LOCAL_PATH := device/samsung/a20

# Nothing device-specific is required on top of vendor/twrp/config/common.mk:
# recovery, minadbd, toybox, busybox, the TWRP app hooks, etc. are all
# pulled in there.
#
# This device uses a Samsung configfs USB init
# (recovery/root/init.recovery.usb.rc) that provides adb/MTP; fastbootd
# is not enabled. If you add fastbootd support, enable it in BoardConfig.mk
# and add the corresponding packages here.
