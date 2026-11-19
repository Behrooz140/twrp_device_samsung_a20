# TWRP device tree برای Samsung Galaxy A20 (SM-A205F / `a20`)

> 🇬🇧 English version: [README.md](README.md)

این مخزن حاوی **device tree مخصوص ساخت ریکاوری کاستوم TWRP** برای گوشی سامسونگ Galaxy A20 (مدل `SM-A205F`, کدنام `a20`, پلتفرم `Exynos 7884B`) است. درخت از روی ایمیج‌های استوک کاربر (`boot.img` / `recovery.img` / `dtbo.img`) استخراج و با مقادیر واقعی هدر/پارتیشن/پراپرتی‌های همان ایمیج‌ها ساخته شده است.

> ⚠️ هشدار: فلش ریکاوری کاستوم همیشه ریسک دارد. بوت‌لودر باز (unlocked)، از دست رفتن دیتا، یا بریک شدن دستگاه ممکن است. مسئولیت استفاده با خودتان است.

## مشخصات دستگاه (تأیید‌شده از ایمیج‌ها)

- **مدل:** `SM-A205F` (`samsung/a20dd/a20`)
- **SoC:** Samsung Exynos 7884B (`universal7884B`, Mali-G71)
- **CPU:** 2× Cortex-A73 + 6× Cortex-A53 (arm64-v8a)
- **بوت‌لودر:** `SRPSA16A011RU`
- **اندروید استوک:** 11 (SDK 30), فریمور/بیلد: `A205FXXSBCWC4`
- **فینگرپرینت:** `samsung/a20dd/a20:11/RP1A.200720.012/A205FXXSBCWC4:user/release-keys`
- **هدر بوت:** Android boot image header v1, pagesize `2048`, base `0x10000000`
  - kernel: `0x10008000` (offset `0x00008000`)
  - ramdisk: `0x11000000` (offset `0x01000000`)
  - tags: `0x10000100` (offset `0x00000100`)
- **DTBO ریکاوری:** داخل ایمیج ریکاوری در offset `44148736` (سایز واقعی dtbo: `295272` بایت) + مارکر `SEANDROIDENFORCE` بعد از بخش page-aligned dtbo (مطابق استوک)
- **پارتیشن‌ها (SM-A205F):**
  - boot: `37748736`
  - recovery: `55574528`
  - system: `4320133120`
  - vendor: `452984832`
  - cache: `157286400`
- **تاچ‌اسکرین:** Zinitix ZT7548 (طبق dtbo)
- **مسیر پارتیشن‌ها:** `/dev/block/platform/13500000.dwmmc0/by-name/*`

## محتوای درخت

مسیر درخت:

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
├── mkboot/
│   ├── bootimg.mk        # مارکر SEANDROIDENFORCE + فشردهسازی LZMA preset 9
│   └── mkbootimg.py      # اسکریپت mkbootimg قابلحمل/پچشده (Python 3)
├── prebuilt/
│   ├── Image             # کرنل hypersonic از ریکاوری سالم 3.7.x (غیر استوک)
│   └── dtbo.img          # dtbo متناظر همان ریکاوری سالم (291594 بایت)
├── system.prop           # پراپرتیها (رشتههای دارای فاصله فقط در اینجا امناند)
└── recovery/
    └── root/
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

- `prebuilt/Image` و `prebuilt/dtbo.img` از یک ریکاوری سالم TWRP 3.7.x برای a20 گرفته شدهاند؛ کرنل/dtbo استوک فریمور رابط TWRP را بالا نمیآورد، بنابراین فقط از این جفت استفاده کنید.
- `mkboot/bootimg.mk` مارکر `SEANDROIDENFORCE` را اضافه میکند و فشردهسازی رامدیسک را به `LZMA -9` تغییر میدهد.
- `mkboot/mkbootimg.py` نسخه AOSP است که برای اجرای صحیح در Python 3 پچ شده و از `--recovery_dtbo` پشتیبانی میکند.

## محدودیت‌ها / نکات مهم

### علت ریبوت در بیلدTWRP 12.1 قبلی (تشخیص دادهشده)

- رامدیسک فشردهشدهی قبلی ۲۰٫۲MB (gzip) بود. بوتلودر/کرنل 4.4 این دستگاه رامدیسکی بزرگتر از حدود ۱۶MB را رد میکند و گوشی روی لوگوی سامسونگ ریبوت میشود. رامدیسک ۱۶٫۲MB قدیمی و رامدیسک ۱۰٫۸MB LZMA ریکاوری سالم بالا میآیند؛ تست کنترل ۲۰٫۱MB (همان رامدیسک سالم + ۴MB فایل اضافی) دقیقاً ریبوت شد.
- با `BOARD_RAMDISK_USE_LZMA := true` و `lzma -9 -f -c` رامدیسک به حدود ۱۳MB میرسد و ایمیج بالا میآید (تست موفق `testF`).
- پراپرتی `ro.display.series=Samsung Galaxy A20` وقتی در `PRODUCT_PROPERTY_OVERRIDES` مینوشتهشده، در `prop.default` به سه خط «Samsung» / «Galaxy» / «A20» تبدیل میشد. اکنون در `system.prop` قرار دارد.
- کتابخانهی `libresetprop.so`، باینری `resetprop`، `ueventd.rc` و `/etc/recovery.fstab` قبلاً در رامدیسک نبودند؛ اکنون از طریق `recovery/root/` اضافه شدهاند.

- **رمزگشایی دیتا (FBE/crypto) در TWRP فعال نیست.** پیاده‌سازی FBE سامسونگ روی Android 11 با TWRP پیچیده/ناسازگار است؛ بنابراین `/data` قابل decrypt شدن در ریکاوری نیست (فرمت دیتا ممکن است). قبل از هر کاری بکاپ بگیرید.
- این درخت **مخصوص SM-A205F** ساخته شده است (assert: `a20`, `a20dd`, `SM-A205F`). برای مدل‌های دیگر (مثلاً A205FN/… یا ریویژن‌های متفاوت) بدون بررسی استفاده نکنید.
- تنظیمات نمایش/آفست (`TW_Y_OFFSET`/`TW_H_OFFSET`) ممکن است بسته به تم/پنل نیاز به تنظیم ظریف داشته باشند.

## پیش‌نیازهای ساخت

- سیستم لینوکس 64 بیتی (ترجیحاً Ubuntu 20.04/22.04) با RAM و دیسک کافی
- پکیج‌های استاندارد build برای AOSP/TWRP (git, repo, python3, openjdk, build-essential, rsync, bc, unzip, zip, …)
- سورس TWRP AOSP manifest (شاخه `twrp-12.1` توصیه می‌شود؛ `twrp-11` نیز قابل استفاده است اما نکات پایین را ببینید)

## نحوه‌ی ساخت

### 1) دریافت سورس TWRP

```bash
mkdir -p ~/twrp && cd ~/twrp

# توصیه‌شده: twrp-12.1
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1

# (جایگزین: twrp-11 — بسته به زمان sync ممکن است نیازمند تنظیمات/اکستراهای اضافه باشد)
# repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

### 2) قرار دادن device tree

محتویات این مخزن را به مسیر زیر در سورس کپی/کلون کنید:

```text
<source-root>/device/samsung/a20/
```

مثال:

```bash
mkdir -p ~/twrp/device/samsung
cp -a /path/to/this/tree/device/samsung/a20 ~/twrp/device/samsung/a20
# یا کلون مستقیم در مسیر بالا
```

### 3) بیلد

```bash
cd ~/twrp
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
lunch twrp_a20-eng
mka recoveryimage
```

خروجی معمولاً در مسیر زیر خواهد بود:

```text
out/target/product/a20/recovery.img
```

## نصب / تست (مختصر)

1. **بکاپ کامل** از دیتاهای مهم بگیرید.
2. **باز کردن بوت‌لودر (OEM Unlock)** انجام شده باشد (پاک‌شدن دیتا محتمل است).
3. پیشنهاد می‌شود قبل از فلش دائمی، ابتدا ایمیج را تست کنید (در صورت امکان با fastboot boot / Odin به روش مناسب مدل؛ روش دقیق بسته به بوت‌لودر دستگاه متفاوت است).
4. فلش پارتیشن `recovery` با ابزار مناسب (مثلاً Heimdall/Odin یا fastboot در صورت پشتیبانی دستگاه/بوت‌لودر):

   ```bash
   # نمونه (اگر fastboot در دسترس/پشتیبانی‌شده باشد) — قبل از اجرا مطمئن شوید
   fastboot flash recovery recovery.img
   ```

5. بلافاصله پس از فلش، مستقیم وارد ریکاوری شوید تا ریکاوری استوک آن را بازنویسی نکند.
6. برای جلوگیری از آسیب/بازنویسی، توصیه می‌شود **dm-verity / AVB verification** را غیرفعال کنید (مثلاً فلش vbmeta غیرفعال یا استفاده از zip/patch مناسب TWRP/Magisk) — بسته به وضعیت بوت‌لودر/سیستم شما.

## اعتبارسنجی محلی (repack هدر/مارکر)

در طول ساخت این درخت، بازپک کردن ریکاوری با `mkboot/mkbootimg.py` و کرنل/رم‌دیسک استوک + dtbo کاربر تست شد؛ ساختار هدر، اندازه/آفست `recovery_dtbo` و محل مارکر `SEANDROIDENFORCE` با ایمیج استوک مطابقت داده شد (کرنل/رم‌دیسک/dtbo یکسان).

## منابع

- مقادیر و کانفیگ بر اساس ایمیج‌های استوک ارسالی کاربر (A205FXXSBCWC4) استخراج شده‌اند.
- ساختار درخت با الهام از درخت‌های عمومی TWRP برای سری Exynos 7884B/A20 تنظیم شده است.
- `mkbootimg.py` بر پایه اسکریپت AOSP/android-11 (با پچ سازگاری Python 3).

## مجوز

بخش‌های اضافه‌شده در این درخت تحت مجوز Apache-2.0 (مطابق هدر فایل‌ها) منتشر شده‌اند، مگر در مواردی که منبع/مجوز متفاوتی ذکر شده باشد.
