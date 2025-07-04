# Albrog Mobile App API Setup

## خطوات التنصيب والربط

### 1. رفع الملفات للخادم
قم برفع مجلد `api` إلى موقعك على Hostinger:
```
public_html/
├── api/
│   ├── config/
│   │   └── database.php
│   ├── properties/
│   │   ├── featured.php
│   │   ├── recent.php
│   │   └── search.php
│   ├── .htaccess
│   ├── index.php
│   └── README.md
```

### 2. تحديث كلمة مرور قاعدة البيانات
في ملف `api/config/database.php`، غير السطر:
```php
private $password = "YOUR_DB_PASSWORD_HERE";
```
إلى كلمة المرور الصحيحة لقاعدة البيانات.

### 3. اختبار الاتصال
زر هذا الرابط لاختبار API:
```
https://albrog.com/api
```
يجب أن تظهر معلومات API وحالة الاتصال بقاعدة البيانات.

### 4. اختبار نقاط النهاية (Endpoints)
```
https://albrog.com/api/properties/featured
https://albrog.com/api/properties/recent  
https://albrog.com/api/properties/search
```

### 5. تحديث تطبيق Flutter
في التطبيق، تأكد من أن `baseUrl` في `lib/services/api_service.dart` يشير إلى:
```dart
static const String baseUrl = 'https://albrog.com/api';
```

## معلومات قاعدة البيانات
- **نوع النظام**: WordPress + Houzez Theme
- **جدول العقارات**: `wp_posts` (post_type = 'property')
- **تفاصيل العقارات**: `wp_postmeta` (meta fields)
- **الصور**: `wp_posts` (post_type = 'attachment')
- **المستخدمين**: `wp_users`

## نقاط النهاية المتاحة

### العقارات المميزة
- **URL**: `/properties/featured`
- **Method**: GET
- **Parameters**: `limit` (default: 10)

### العقارات الحديثة  
- **URL**: `/properties/recent`
- **Method**: GET
- **Parameters**: `limit` (default: 10)

### البحث في العقارات
- **URL**: `/properties/search`
- **Method**: GET
- **Parameters**: 
  - `limit`, `page`
  - `type`, `status`
  - `min_price`, `max_price`
  - `bedrooms`, `bathrooms`
  - `city`, `keyword`

## التطوير المستقبلي
يمكن إضافة المزيد من نقاط النهاية:
- تفاصيل عقار واحد
- إضافة عقارات جديدة
- إدارة المفضلة
- نظام المراجعات والتقييمات
- إدارة الوكلاء 