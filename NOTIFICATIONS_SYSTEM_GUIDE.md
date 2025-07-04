# 🔔 دليل نظام الإشعارات الشامل

## 📊 **النظام الحالي:**

### ✅ **الإشعارات الموجودة حالياً:**
```sql
-- من جدول: wp_houzez_crm_activities
├── استفسارات العملاء (customer inquiries)
├── طلبات الاتصال (contact requests)  
├── مشاهدات العقارات (property views)
└── إشعارات الفيديوهات (YouTube videos)
```

---

## 🚀 **الإشعارات الجديدة المضافة:**

### 1. **إشعار إضافة صور للعقار** 📸
**الاستخدام:**
```dart
// في Flutter
final apiService = Get.find<ApiService>();

await apiService.addPropertyImageNotification(
  propertyId: 123,
  imageCount: 5,
  uploaderName: 'أحمد المطور',
);
```

**يرسل إشعار لـ:**
- ✅ **مالك العقار** - "تم إضافة 5 صور للعقار"
- ✅ **المساهمين** - "تم إضافة صور جديدة للمشروع"

### 2. **إشعار تحديث نسبة الإنجاز** 📊
**الاستخدام:**
```dart
// عند تحديث نسبة الإنجاز
await apiService.addProgressUpdateNotification(
  propertyId: 123,
  oldProgress: 65,
  newProgress: 75,
  notes: 'تم الانتهاء من أعمال الواجهة الخارجية',
  updaterName: 'مهندس المشروع',
);
```

**يرسل إشعار لـ:**
- ✅ **مالك العقار** - "تحديث نسبة الإنجاز"
- ✅ **المستثمرين** - "🎉 تقدم في مشروعك!"

---

## 🏗️ **كيفية إضافة إشعارات جديدة:**

### خطوة 1: إنشاء API Endpoint
```php
// مثال: api/add_custom_notification.php
$meta = json_encode([
    'type' => 'custom_notification_type',
    'title' => 'عنوان الإشعار',
    'subtitle' => 'تفاصيل الإشعار',
    'message' => 'رسالة إضافية',
    'property_id' => $property_id,
    // بيانات إضافية...
], JSON_UNESCAPED_UNICODE);

$stmt = $pdo->prepare("
    INSERT INTO wp_houzez_crm_activities 
    (user_id, meta, time) 
    VALUES (:user_id, :meta, NOW())
");
```

### خطوة 2: إضافة الوظيفة في Flutter
```dart
// في lib/services/api_service.dart
Future<bool> addCustomNotification({
  required int userId,
  required String title,
  required String message,
}) async {
  // كود الاستدعاء...
}
```

---

## 🎯 **أمثلة عملية للاستخدام:**

### مثال 1: عند رفع صور جديدة
```php
// عند رفع صور في WordPress Admin
if (files_uploaded_successfully) {
    $curl = curl_init();
    curl_setopt_array($curl, [
        CURLOPT_URL => 'https://albrog.com/add_property_image_notification.php',
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => json_encode([
            'property_id' => $property_id,
            'image_count' => count($uploaded_files),
            'uploader_name' => $current_user->display_name
        ]),
        CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
    ]);
    curl_exec($curl);
}
```

### مثال 2: عند تحديث تقدم المشروع
```dart
// في صفحة تحديث العقار
void updateProgress(int newProgress) async {
  final oldProgress = property.completion ?? 0;
  
  // تحديث النسبة في قاعدة البيانات أولاً
  await updatePropertyProgress(property.id, newProgress);
  
  // إرسال إشعارات
  await apiService.addProgressUpdateNotification(
    propertyId: int.parse(property.id),
    oldProgress: oldProgress,
    newProgress: newProgress,
    notes: 'تحديث تلقائي من التطبيق',
  );
  
  // تحديث الواجهة
  setState(() {
    property = property.copyWith(completion: newProgress);
  });
}
```

---

## 📋 **أنواع الإشعارات المقترحة للمستقبل:**

### إشعارات إضافية يمكن تطويرها:
1. **تحديث السعر** 💰
   - عند تغيير سعر العقار
   - إشعار للمهتمين والمساهمين

2. **موعد التسليم** 📅
   - عند اقتراب موعد التسليم
   - تحديث موعد التسليم

3. **دفعات مالية** 💳
   - استحقاق دفعة قادمة
   - تأكيد وصول دفعة

4. **تحديثات قانونية** 📜
   - الحصول على تراخيص
   - تحديث الوثائق القانونية

5. **نشاط السوق** 📈
   - ارتفاع أسعار المنطقة
   - عقارات مشابهة في السوق

---

## 🔧 **كيفية التخصيص:**

### تخصيص رسائل الإشعارات:
```php
// في ملف API
$notification_templates = [
    'ar' => [
        'image_added' => 'تم إضافة {count} صورة للعقار {property}',
        'progress_update' => 'تطور المشروع إلى {progress}%',
    ],
    'en' => [
        'image_added' => '{count} images added to {property}',
        'progress_update' => 'Project progress updated to {progress}%',
    ]
];
```

### إضافة إعدادات الإشعارات للمستخدم:
```dart
class NotificationSettings {
  bool imageUpdates = true;
  bool progressUpdates = true;
  bool priceChanges = true;
  bool deliveryReminders = true;
}
```

---

## 🎯 **الخلاصة:**

✅ **تم إنجازه:**
- نظام إشعارات للصور
- نظام إشعارات لتحديث النسبة
- APIs جاهزة ومتصلة بـ Flutter

🔄 **التطوير التالي:**
- إضافة Push Notifications (اختياري)
- واجهة إدارة الإشعارات للمستخدم
- إشعارات مجدولة (cron jobs)

🎉 **النتيجة:**
المساهمون الآن سيحصلون على إشعارات فورية عند أي تحديث في مشاريعهم! 