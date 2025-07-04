-- إضافة إشعار تجريبي للمستخدم 80
INSERT INTO wp_houzez_crm_activities (user_id, meta, time) VALUES (
    80,
    JSON_OBJECT(
        'type', 'property_images_added',
        'title', 'تم إضافة صور جديدة',
        'subtitle', 'تم إضافة 3 صور للعقار: فيلا العاصمة الجديدة',
        'message', 'رفع بواسطة: المهندس أحمد',
        'property_id', 25,
        'property_title', 'فيلا العاصمة الجديدة',
        'image_count', 3,
        'uploader', 'المهندس أحمد'
    ),
    NOW()
);

-- إضافة إشعار آخر للتأكد
INSERT INTO wp_houzez_crm_activities (user_id, meta, time) VALUES (
    80,
    JSON_OBJECT(
        'type', 'investment_progress_update',
        'title', 'تحديث في نسبة الإنجاز',
        'subtitle', 'تقدم المشروع من 60% إلى 75%',
        'message', 'المشروع: شقة بالتجمع الخامس',
        'property_id', 20,
        'property_title', 'شقة بالتجمع الخامس',
        'old_progress', 60,
        'new_progress', 75
    ),
    NOW()
);

-- التحقق من الإشعارات المضافة
SELECT 
    activity_id,
    user_id,
    JSON_UNQUOTE(JSON_EXTRACT(meta, '$.title')) as title,
    JSON_UNQUOTE(JSON_EXTRACT(meta, '$.subtitle')) as subtitle,
    time
FROM wp_houzez_crm_activities 
WHERE user_id = 80 
ORDER BY time DESC 
LIMIT 5; 