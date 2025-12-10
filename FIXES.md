# Snok-Installer - إصلاحات النسخة 2.3

## التحديثات المنفذة / Updates Implemented

### 1. ✅ إصلاح أخطاء Parted / Fixed Parted Command Errors

**المشكلة / Problem:**
```bash
parted: invalid option -- '4'
parted: invalid option -- 'G'
parted: invalid option -- 'i'
parted: invalid option -- 'B'
Usage: parted [-hlmsv] [-a<align>] [DEVICE [COMMAND [PARAMETERS]]...]
Error: Partition doesn't exist.
```

**السبب / Root Cause:**
- استخدام قيم سالبة مثل `-4GiB` في أوامر `parted`
- يفسر `parted` الإشارة السالبة `-` كخيار سطر أوامر وليس كحجم قسم
- Using negative values like `-4GiB` in `parted` commands
- `parted` interprets the `-` sign as a command-line option flag, not as a partition size

**الحل / Solution:**
- حساب حجم القرص الكلي أولاً
- حساب موضع بداية قسم SWAP بطرح 4096 ميجابايت من الحجم الكلي
- استخدام القيم المطلقة المحسوبة بدلاً من القيم السالبة
- Calculate total disk size first
- Calculate SWAP partition start position by subtracting 4096 MiB from total size
- Use calculated absolute values instead of negative values

**قبل / Before:**
```bash
parted -s "$SELECTED_DISK" mkpart ROOT 513MiB -4GiB  # ❌ خطأ - يفسر كخيار
parted -s "$SELECTED_DISK" mkpart SWAP -4GiB 100%    # ❌ خطأ - يفسر كخيار
```

**بعد / After:**
```bash
# حساب حجم القرص وموضع البداية
local disk_size=$(parted -s "$SELECTED_DISK" unit MiB print | grep "^Disk" | awk '{print $3}' | sed 's/MiB//')
local swap_start=$((disk_size - 4096))  # 4GiB = 4096MiB

# استخدام القيم المطلقة
parted -s "$SELECTED_DISK" mkpart ROOT 513MiB ${swap_start}MiB  # ✅ صحيح
parted -s "$SELECTED_DISK" mkpart SWAP ${swap_start}MiB 100%    # ✅ صحيح
```

---

### 2. ✅ تثبيت تلقائي للمكتبات / Automatic Dependency Installation

**الميزة الجديدة / New Feature:**
- اكتشاف تلقائي لمدير الحزم (APT, Pacman, DNF, Zypper)
- تثبيت تلقائي للمكتبات المفقودة
- دعم جميع التوزيعات الرئيسية

**المكتبات المطلوبة / Required Packages:**
- `dialog` - واجهة المستخدم
- `parted` - تقسيم الأقراص
- `dosfstools` - تنسيق FAT32
- `e2fsprogs` - تنسيق ext4
- `pciutils` - اكتشاف العتاد
- `cryptsetup` - التشفير
- `lvm2` - إدارة الأقراص المنطقية
- `wipefs` - مسح الأقراص

**مديرو الحزم المدعومون / Supported Package Managers:**
```bash
✓ APT (Debian/Ubuntu)
✓ Pacman (Arch/Manjaro)
✓ DNF (Fedora/RHEL)
✓ Zypper (openSUSE)
```

---

### 3. ✅ حقل كلمة المرور مع إظهار/إخفاء / Password Field with Show/Hide

**الميزات / Features:**
- ⭐ عرض كلمة المرور كنجوم (***) افتراضياً
- 👁️ زر "Show" لإظهار كلمة المرور
- 🔒 زر "Hide" لإخفاء كلمة المرور
- ✓ تأكيد كلمة المرور
- ⚠️ التحقق من تطابق كلمات المرور

**الاستخدام / Usage:**
1. أدخل كلمة المرور (تظهر كـ ***)
2. اضغط "Show" لرؤية كلمة المرور
3. اضغط "Hide" لإخفائها مرة أخرى
4. اضغط "Continue" للمتابعة
5. أكد كلمة المرور

**الأمان / Security:**
- كلمات المرور مخفية افتراضياً
- خيار إظهار اختياري للتحقق
- تأكيد مزدوج لمنع الأخطاء

---

### 4. ✅ إصلاح اكتشاف الأقسام / Fixed Partition Detection

**المشكلة / Problem:**
```bash
mkswap: cannot open /dev/sda3: No such file or directory
swapon: cannot open /dev/sda3: No such file or directory
```

**السبب / Root Cause:**
- السكريبت يحاول الوصول إلى القسم 3 (SWAP) حتى عندما لا يتم إنشاؤه
- عند اختيار "No SWAP" يتم إنشاء قسمين فقط، لكن الكود يحاول استخدام القسم الثالث
- Script tries to access partition 3 (SWAP) even when it's not created
- When selecting "No SWAP", only 2 partitions are created, but code tries to use partition 3

**الحل / Solution:**
- تعريف متغير `swap_part` فقط داخل الشرط `if [ "$SELECTED_SWAP_TYPE" = "swap" ]`
- تجنب الوصول إلى أقسام غير موجودة
- Define `swap_part` variable only inside the `if [ "$SELECTED_SWAP_TYPE" = "swap" ]` condition
- Avoid accessing non-existent partitions

**قبل / Before:**
```bash
local swap_part="${SELECTED_DISK}3"
# ...
if [ "$SELECTED_SWAP_TYPE" = "swap" ]; then
    mkswap "$swap_part"  # ❌ خطأ - القسم قد لا يكون موجوداً
fi
```

**بعد / After:**
```bash
if [ "$SELECTED_SWAP_TYPE" = "swap" ]; then
    local swap_part="${SELECTED_DISK}3"
    if [[ "$SELECTED_DISK" =~ "nvme" ]] || [[ "$SELECTED_DISK" =~ "mmcblk" ]]; then
        swap_part="${SELECTED_DISK}p3"
    fi
    mkswap "$swap_part"  # ✅ صحيح - القسم موجود
fi
```

---

### 5. ✅ إزالة حقل اسم الجهاز / Removed Hostname Field

**التغيير / Change:**
- إزالة مربع حوار إدخال اسم الجهاز
- تعيين اسم افتراضي تلقائياً: `snok-linux`
- تبسيط عملية الإعداد
- Removed hostname input dialog
- Automatically set default hostname: `snok-linux`
- Simplified setup process

**قبل / Before:**
```bash
HOSTNAME=$(dialog --inputbox "Enter hostname:" 10 60)
if [ -z "$HOSTNAME" ]; then
    HOSTNAME="snok-linux"
fi
```

**بعد / After:**
```bash
# Set default hostname automatically
HOSTNAME="snok-linux"
```

---

### 6. ✅ تحسين مربع حوار التشفير / Improved Encryption Dialog

**التحسينات / Improvements:**
- إضافة معلومات مفصلة عن فوائد وعيوب التشفير
- شرح واضح لـ LUKS2
- مساعدة المستخدم على اتخاذ قرار مستنير
- Added detailed information about encryption benefits and drawbacks
- Clear explanation of LUKS2
- Help user make informed decision

**الميزات الجديدة / New Features:**
```
Benefits:
  ✓ Protects data if disk is stolen
  ✓ Uses LUKS2 encryption standard
  ✓ Military-grade security

Drawbacks:
  ✗ Requires password on every boot
  ✗ Slight performance impact (~5%)
  ✗ Cannot recover data if password is lost
```

---

### 7. ✅ تبسيط مربع حوار كلمة المرور / Simplified Password Dialog

**التحسينات / Improvements:**
- إزالة التبديل المعقد بين إظهار/إخفاء
- واجهة أبسط وأسهل في الاستخدام
- زر واحد "Show Password" لإظهار كلمة المرور عند الحاجة
- Removed complex show/hide toggle
- Simpler and easier to use interface
- Single "Show Password" button to reveal when needed

**الاستخدام / Usage:**
1. أدخل كلمة المرور (مخفية كـ ***)
2. اضغط "Show Password" إذا أردت رؤيتها
3. اضغط "Continue" للمتابعة

---

## الإحصائيات / Statistics

| البند / Item | القيمة / Value |
|--------------|----------------|
| عدد الأسطر / Lines of Code | 956 |
| عدد الدوال / Functions | 37 |
| الإصلاحات / Fixes | 7 |
| اللغات المدعومة / Languages | 4 |
| مديرو الحزم / Package Managers | 4 |

---

## الاختبار / Testing

### ✅ اختبار بناء الجملة / Syntax Test
```bash
bash -n snok-installer.sh
# النتيجة: لا توجد أخطاء / Result: No errors
```

### ✅ اختبار المكتبات / Dependencies Test
```bash
./test-installer.sh
# النتيجة: جميع الاختبارات نجحت / Result: All tests passed
```

---

## كيفية الاستخدام / How to Use

### 1. تشغيل البرنامج / Run the Installer
```bash
cd /home/snokpc/Desktop/Snok-Installer_V2
sudo ./snok-installer.sh
```

### 2. سيقوم البرنامج تلقائياً بـ / The Installer Will Automatically:
- ✓ التحقق من المكتبات المطلوبة
- ✓ تثبيت المكتبات المفقودة
- ✓ اكتشاف العتاد (NVIDIA, UEFI/Legacy)
- ✓ توجيهك خلال عملية التثبيت

### 3. حقول كلمة المرور / Password Fields:
- أدخل كلمة المرور (ستظهر كـ ***)
- استخدم زر "Show" لرؤية ما كتبته
- استخدم زر "Hide" لإخفائها
- أكد كلمة المرور

---

## الإصلاحات التفصيلية / Detailed Fixes

### إصلاح Parted لـ UEFI / Parted Fix for UEFI
```bash
# حساب حجم القرص / Calculate disk size
local disk_size=$(parted -s "$SELECTED_DISK" unit MiB print | grep "^Disk" | awk '{print $3}' | sed 's/MiB//')
local swap_start=$((disk_size - 4096))  # 4GiB = 4096MiB

# GPT (UEFI) - لا يستخدم نوع نظام الملفات
parted -s "$SELECTED_DISK" mkpart EFI 1MiB 513MiB
parted -s "$SELECTED_DISK" mkpart ROOT 513MiB ${swap_start}MiB
parted -s "$SELECTED_DISK" mkpart SWAP ${swap_start}MiB 100%
```

### إصلاح Parted لـ Legacy BIOS / Parted Fix for Legacy BIOS
```bash
# حساب حجم القرص / Calculate disk size
local disk_size=$(parted -s "$SELECTED_DISK" unit MiB print | grep "^Disk" | awk '{print $3}' | sed 's/MiB//')
local swap_start=$((disk_size - 4096))  # 4GiB = 4096MiB

# MBR (Legacy) - يستخدم نوع نظام الملفات
parted -s "$SELECTED_DISK" mkpart primary ext4 1MiB ${swap_start}MiB
parted -s "$SELECTED_DISK" mkpart primary linux-swap ${swap_start}MiB 100%
```

### دالة تثبيت المكتبات / Dependency Installation Function
```bash
install_dependencies() {
    # اكتشاف مدير الحزم
    if command -v apt-get &> /dev/null; then
        apt-get update -qq
        apt-get install -y dialog parted dosfstools e2fsprogs pciutils cryptsetup lvm2
    elif command -v pacman &> /dev/null; then
        pacman -Sy --noconfirm dialog parted dosfstools e2fsprogs pciutils cryptsetup lvm2
    # ... إلخ
    fi
}
```

### دالة كلمة المرور / Password Function
```bash
password_input_with_toggle() {
    local show_password=false
    
    while true; do
        if [ "$show_password" = true ]; then
            # إظهار كلمة المرور
            password=$(dialog --inputbox "..." --extra-button --extra-label "Hide" ...)
        else
            # إخفاء كلمة المرور (نجوم)
            password=$(dialog --insecure --passwordbox "..." --extra-button --extra-label "Show" ...)
        fi
    done
}
```

---

## الملفات المعدلة / Modified Files

- ✏️ [snok-installer.sh](file:///home/snokpc/Desktop/Snok-Installer_V2/snok-installer.sh) - الملف الرئيسي

---

## الخطوات التالية / Next Steps

1. ✅ اختبار في بيئة افتراضية / Test in VM
2. ✅ التحقق من جميع الميزات / Verify all features
3. ✅ اختبار على توزيعات مختلفة / Test on different distros

---

## الملاحظات الهامة / Important Notes

> [!WARNING]
> **تحذير / Warning**
> - سيتم مسح جميع البيانات على القرص المحدد!
> - All data on selected disk will be erased!
> - اختبر في بيئة افتراضية أولاً / Test in VM first!

> [!TIP]
> **نصيحة / Tip**
> - استخدم زر "Show" للتحقق من كلمة المرور
> - Use "Show" button to verify password
> - البرنامج سيثبت المكتبات تلقائياً
> - Installer will install dependencies automatically

---

**تم التحديث / Updated:** 10 ديسمبر 2025  
**النسخة / Version:** 2.3  
**الحالة / Status:** ✅ جاهز للاستخدام / Ready to Use
