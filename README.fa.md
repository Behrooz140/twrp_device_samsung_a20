# TWRP برای Galaxy A20 (SM-A205F / `a20`)

> 🇬🇧 [English version](README.md)

درخت device مخصوص ریکاوری TWRP برای گلکسی A20 (Exynos 7884B، پایهٔ فریمور اندروید ۱۱). تست شده روی دستگاه: وارد TWRP 12.1 میشود.

⚠️ **فلش ریکاوری کاستوم میتواند دیتا را پاک کند یا دستگاه را بریک کند. قبل از آن بکاپ بگیرید.**

## بیلد

نیاز به سورس TWRP AOSP روی شاخهٔ `twrp-12.1` (اوبونتو ۲۲٫۰۴، حدود ۱۰۰GB فضای آزاد):

```bash
cd ~/twrp
git clone https://github.com/Behrooz140/twrp_device_samsung_a20.git device/samsung/a20
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
lunch twrp_a20-eng
mka recoveryimage
```

خروجی: `out/target/product/a20/recovery.img`

همچنین میتوانید از [GitHub Actions](https://github.com/Behrooz140/twrp_device_samsung_a20/actions/workflows/build-twrp.yml) استفاده کنید: **Run workflow** سپس دانلود artifact به نام `twrp-a20-twrp-12.1`.

## فلش

ایمیج `recovery.img` را روی پارتیشن **recovery** فلش کنید (Odin/Heimdall یا fastboot در صورت پشتیبانی)، سپس مستقیم وارد ریکاوری شوید. بوتلودر باید unlocked باشد.

## نکات مهم

- **LZMA باید فعال بماند.** رامدیسک gzip قبلی ۲۰MB بود و بوتلودر آنرا رد میکرد (ریبوت روی لوگوی سامسونگ). با `BOARD_RAMDISK_USE_LZMA := true` و `lzma -9` حجم به حدود ۱۳MB میرسد.
- **کرنل و dtbo همراه نگه دارید.** `prebuilt/Image` و `prebuilt/dtbo.img` از یک ریکاوری سالم TWRP 3.7.x گرفته شدهاند؛ جفت استوک فریمور نمایشگر را بالا نمیآورد.
- **پراپرتیها را تکرار نکنید.** رشتههای دارای فاصله در `system.prop` قرار میگیرند؛ `ro.product.board` و `ro.board.platform` از `BoardConfig.mk` ساخته میشوند و نباید دوباره نوشته شوند.
- **رمزدایی `/data` کار نمیکند (FBE).** فرمت شدن هست، ولی رمزگشایی دیتای استوک داخل TWRP ممکن نیست.
- **فقط مخصوص SM-A205F** (`a20`, `a20dd`, `SM-A205F`).

برگرفته از فریمور استوک `A205FXXSBCWC4` و یک ریکاوری سالم TWRP 3.7.x برای `a20`.
