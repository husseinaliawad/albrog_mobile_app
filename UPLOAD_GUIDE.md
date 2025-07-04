# 📤 دليل رفع ملفات API - البروج العقاري

## 🎯 المطلوب رفعه للخادم

يجب رفع **جميع** ملفات مجلد `api/` إلى خادم albrog.com:

### 📁 **هيكل الملفات المطلوب:**
```
public_html/api/
├── index.php                    ✅ (موجود)
├── .htaccess                    ❌ (مطلوب)
├── config/
│   └── database.php             ❌ (مطلوب)
└── properties/
    ├── featured.php             ❌ (مطلوب)
    ├── recent.php               ❌ (مطلوب)
    └── search.php               ❌ (مطلوب)
```

## 🚀 خطوات الرفع

### الطريقة 1: File Manager في Hostinger
1. **تسجيل دخول:** [hpanel.hostinger.com](https://hpanel.hostinger.com)
2. **اختيار الموقع:** albrog.com
3. **فتح File Manager**
4. **الانتقال لمجلد:** `public_html/api/`
5. **رفع الملفات:**

#### ملفات يجب رفعها:
- `config/database.php` → `public_html/api/config/database.php`
- `properties/featured.php` → `public_html/api/properties/featured.php`
- `properties/recent.php` → `public_html/api/properties/recent.php`
- `properties/search.php` → `public_html/api/properties/search.php`
- `.htaccess` → `public_html/api/.htaccess`

### الطريقة 2: FTP Client
```bash
# باستخدام FileZilla أو WinSCP
الخادم: ftp.albrog.com
المستخدم: [username من Hostinger]
كلمة السر: [password من Hostinger]

# ارفع إلى:
/public_html/api/
```

## ✅ **تحقق من النجاح**

بعد رفع الملفات، اختبر:

1. **العقارات المميزة:**
   ```
   https://albrog.com/api/properties/featured
   ```

2. **العقارات الحديثة:**
   ```
   https://albrog.com/api/properties/recent
   ```

3. **البحث:**
   ```
   https://albrog.com/api/properties/search?limit=5
   ```

## 🔧 **استكشاف الأخطاء**

### خطأ 404:
- تأكد من رفع الملفات في المسار الصحيح
- تأكد من وجود مجلد `properties/`

### خطأ 500:
- تحقق من ملف `config/database.php`
- تأكد من صحة بيانات قاعدة البيانات

### CORS Error:
- تأكد من رفع ملف `.htaccess`

## 📞 **الدعم**

إذا واجهت مشاكل:
1. تحقق من error logs في Hostinger
2. اختبر كل endpoint منفصلاً
3. تأكد من أذونات الملفات (755)

---

## 🎉 **بعد الرفع:**

سيعمل تطبيق Flutter بالبيانات الحقيقية من موقع البروج! 🏠✨ 

## الملفات المطلوب رفعها:

### 1. ملفات API الصور:
```
api/property_images.php        ← الملف الأساسي لجلب صور العقارات
api/property_images_simple.php ← النسخة المبسطة للاختبار
```

### 2. ملفات API أخرى (إضافية):
```
api/advanced_search.php        ← البحث المتقدم
api/config/database.php        ← إعدادات قاعدة البيانات
```

## خطوات الرفع:

### الطريقة الأولى: cPanel File Manager
1. ادخل على cPanel الخاص بالموقع
2. افتح File Manager
3. انتقل إلى المجلد الرئيسي للموقع (public_html)
4. أنشئ مجلد جديد اسمه `api` إذا لم يكن موجوداً
5. ارفع الملفات التالية:
   - `property_images.php`
   - `property_images_simple.php`  
   - `advanced_search.php`
6. أنشئ مجلد `config` داخل مجلد `api`
7. ارفع ملف `database.php` داخل مجلد `config`

### الطريقة الثانية: FTP Client
1. استخدم برنامج FileZilla أو WinSCP
2. اتصل بالخادم باستخدام بيانات FTP
3. انتقل إلى مجلد `public_html`
4. ارفع المجلد `api` بكامل محتواه

## اختبار بعد الرفع:
```bash
# اختبر API الصور المبسط
curl "https://albrog.com/property_images_simple.php?id=46810"

# اختبر API الصور الكامل
curl "https://albrog.com/property_images.php?id=46810"
```

## ملاحظات مهمة:
- تأكد من صحة إعدادات قاعدة البيانات في `config/database.php`
- تأكد من أن الملفات لها صلاحيات القراءة (644)
- تأكد من أن المجلدات لها صلاحيات التنفيذ (755) 