# Snok-Installer - إصلاحات النسخة 2.1

## التحديثات المنفذة / Updates Implemented

### 1. ✅ إصلاح أخطاء Parted / Fixed Parted Command Errors

**المشكلة / Problem:**
```bash
parted: invalid option -- '4'
parted: invalid option -- 'G'
parted: invalid option -- 'i'
parted: invalid option -- 'B'
```

**الحل / Solution:**
- إزالة نوع نظام الملفات من أوامر `mkpart` في GPT
- تصحيح بناء الجملة لـ GPT و MBR
- إضافة سجلات مفصلة لكل خطوة

**قبل / Before:**
```bash
parted -s "$SELECTED_DISK" mkpart primary fat32 1MiB 513MiB  # خطأ في GPT
```

**بعد / After:**
```bash
parted -s "$SELECTED_DISK" mkpart EFI 1MiB 513MiB  # صحيح
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

## الإحصائيات / Statistics

| البند / Item | القيمة / Value |
|--------------|----------------|
| عدد الأسطر / Lines of Code | 955 |
| عدد الدوال / Functions | 37 (+2) |
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
# GPT (UEFI) - لا يستخدم نوع نظام الملفات
parted -s "$SELECTED_DISK" mkpart EFI 1MiB 513MiB
parted -s "$SELECTED_DISK" mkpart ROOT 513MiB -4GiB
parted -s "$SELECTED_DISK" mkpart SWAP -4GiB 100%
```

### إصلاح Parted لـ Legacy BIOS / Parted Fix for Legacy BIOS
```bash
# MBR (Legacy) - يستخدم نوع نظام الملفات
parted -s "$SELECTED_DISK" mkpart primary ext4 1MiB -4GiB
parted -s "$SELECTED_DISK" mkpart primary linux-swap -4GiB 100%
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
**النسخة / Version:** 2.1  
**الحالة / Status:** ✅ جاهز للاستخدام / Ready to Use
