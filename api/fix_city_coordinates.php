<?php
/**
 * Fix City Coordinates Script
 * تحويل الإحداثيات في قاعدة البيانات إلى أسماء مدن حقيقية
 * يجب تشغيل هذا السكريبت مرة واحدة فقط
 */

header('Content-Type: application/json; charset=utf-8');
require_once 'config/database.php';

// التحقق من أن السكريبت يتم تشغيله من المتصفح
$confirmRun = isset($_GET['confirm']) && $_GET['confirm'] === 'yes';

if (!$confirmRun) {
    echo json_encode([
        'status' => 'waiting',
        'message' => 'هذا السكريبت سيقوم بتحديث قاعدة البيانات. لتشغيله أضف ?confirm=yes إلى الرابط',
        'warning' => 'تأكد من عمل backup لقاعدة البيانات قبل التشغيل!',
        'url_example' => 'fix_city_coordinates.php?confirm=yes'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $pdo = new PDO($dsn, $username, $password, $options);
    
    echo json_encode(['status' => 'starting', 'message' => '🚀 بدء تحديث قاعدة البيانات...'], JSON_UNESCAPED_UNICODE);
    echo "\n";
    flush();
    
    // 1️⃣ جلب جميع العقارات التي تحتوي على إحداثيات في حقل المدينة
    $selectSql = "
        SELECT p.ID, meta_city.meta_value as current_city, p.post_title
        FROM wp_posts p
        LEFT JOIN wp_postmeta meta_city ON p.ID = meta_city.post_id AND meta_city.meta_key = 'fave_property_city'
        WHERE p.post_type = 'property' 
            AND p.post_status = 'publish'
            AND meta_city.meta_value IS NOT NULL 
            AND meta_city.meta_value != ''
            AND meta_city.meta_value REGEXP '^[-+]?[0-9]*\.?[0-9]+,[-+]?[0-9]*\.?[0-9]+'
    ";
    
    $stmt = $pdo->prepare($selectSql);
    $stmt->execute();
    $coordinateProperties = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'status' => 'found', 
        'message' => "🔍 تم العثور على " . count($coordinateProperties) . " عقار يحتوي على إحداثيات",
        'count' => count($coordinateProperties)
    ], JSON_UNESCAPED_UNICODE);
    echo "\n";
    flush();
    
    $updatedCount = 0;
    $skippedCount = 0;
    $errorCount = 0;
    
    // 2️⃣ معالجة كل عقار
    foreach ($coordinateProperties as $property) {
        $propertyId = $property['ID'];
        $currentCity = $property['current_city'];
        $postTitle = $property['post_title'];
        
        try {
            // تحويل الإحداثيات إلى اسم مدينة
            $cityName = convertCoordinatesToCity($currentCity);
            
            if ($cityName && $cityName !== $currentCity) {
                // تحديث قاعدة البيانات
                $updateSql = "
                    UPDATE wp_postmeta 
                    SET meta_value = ? 
                    WHERE post_id = ? AND meta_key = 'fave_property_city'
                ";
                
                $updateStmt = $pdo->prepare($updateSql);
                $success = $updateStmt->execute([$cityName, $propertyId]);
                
                if ($success) {
                    $updatedCount++;
                    echo json_encode([
                        'status' => 'updated',
                        'property_id' => $propertyId,
                        'title' => $postTitle,
                        'old_value' => $currentCity,
                        'new_value' => $cityName
                    ], JSON_UNESCAPED_UNICODE);
                    echo "\n";
                    flush();
                } else {
                    $errorCount++;
                }
            } else {
                $skippedCount++;
            }
            
        } catch (Exception $e) {
            $errorCount++;
            echo json_encode([
                'status' => 'error',
                'property_id' => $propertyId,
                'error' => $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
            echo "\n";
            flush();
        }
    }
    
    // 3️⃣ التقرير النهائي
    echo json_encode([
        'status' => 'completed',
        'message' => '✅ تم الانتهاء من تحديث قاعدة البيانات',
        'summary' => [
            'total_found' => count($coordinateProperties),
            'updated' => $updatedCount,
            'skipped' => $skippedCount,
            'errors' => $errorCount
        ]
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    echo json_encode([
        'status' => 'fatal_error',
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

/**
 * تحويل الإحداثيات إلى اسم مدينة سعودية
 */
function convertCoordinatesToCity($coordinateString) {
    // التحقق من أن البيانات إحداثيات
    if (!preg_match('/^[-+]?[0-9]*\.?[0-9]+,[-+]?[0-9]*\.?[0-9]+/', $coordinateString)) {
        return null; // ليست إحداثيات
    }
    
    $coords = explode(',', $coordinateString);
    if (count($coords) < 2) return null;
    
    $lat = (float)$coords[0];
    $lng = (float)$coords[1];
    
    // خريطة دقيقة للمدن السعودية الرئيسية
    $cities = [
        'الرياض' => ['lat' => 24.7136, 'lng' => 46.6753, 'radius' => 50],
        'جدة' => ['lat' => 21.4858, 'lng' => 39.1925, 'radius' => 40],
        'مكة المكرمة' => ['lat' => 21.3891, 'lng' => 39.8579, 'radius' => 30],
        'المدينة المنورة' => ['lat' => 24.5247, 'lng' => 39.5692, 'radius' => 30],
        'الدمام' => ['lat' => 26.4207, 'lng' => 50.0888, 'radius' => 35],
        'الخبر' => ['lat' => 26.2172, 'lng' => 50.1971, 'radius' => 20],
        'الطائف' => ['lat' => 21.2703, 'lng' => 40.4158, 'radius' => 25],
        'أبها' => ['lat' => 18.2164, 'lng' => 42.5047, 'radius' => 25],
        'تبوك' => ['lat' => 28.3998, 'lng' => 36.5700, 'radius' => 30],
        'بريدة' => ['lat' => 26.3260, 'lng' => 43.9750, 'radius' => 25],
        'حائل' => ['lat' => 27.5114, 'lng' => 41.7208, 'radius' => 25],
        'خميس مشيط' => ['lat' => 18.3000, 'lng' => 42.7300, 'radius' => 20],
        'القطيف' => ['lat' => 26.5205, 'lng' => 49.9830, 'radius' => 15],
        'الهفوف' => ['lat' => 25.3605, 'lng' => 49.5861, 'radius' => 20],
        'ينبع' => ['lat' => 24.0896, 'lng' => 38.0618, 'radius' => 20],
        'جازان' => ['lat' => 16.8892, 'lng' => 42.5511, 'radius' => 25],
        'نجران' => ['lat' => 17.4924, 'lng' => 44.1277, 'radius' => 20],
        'الباحة' => ['lat' => 20.0129, 'lng' => 41.4687, 'radius' => 15],
        'عرعر' => ['lat' => 30.9665, 'lng' => 41.0364, 'radius' => 20],
        'سكاكا' => ['lat' => 29.9697, 'lng' => 40.2064, 'radius' => 15]
    ];
    
    $closestCity = null;
    $minDistance = PHP_FLOAT_MAX;
    
    foreach ($cities as $cityName => $cityData) {
        $distance = calculateDistance($lat, $lng, $cityData['lat'], $cityData['lng']);
        
        // إذا كانت المسافة ضمن نطاق المدينة
        if ($distance <= $cityData['radius'] && $distance < $minDistance) {
            $minDistance = $distance;
            $closestCity = $cityName;
        }
    }
    
    // إذا لم نجد مدينة قريبة، نحدد بناءً على المنطقة الجغرافية
    if (!$closestCity) {
        if ($lat >= 24 && $lat <= 26 && $lng >= 46 && $lng <= 48) {
            return 'الرياض'; // منطقة الرياض
        } elseif ($lat >= 21 && $lat <= 22 && $lng >= 39 && $lng <= 40.5) {
            return 'جدة'; // منطقة مكة المكرمة
        } elseif ($lat >= 26 && $lat <= 27 && $lng >= 49.5 && $lng <= 51) {
            return 'الدمام'; // المنطقة الشرقية
        } elseif ($lat >= 16 && $lat <= 32 && $lng >= 34 && $lng <= 56) {
            return 'منطقة أخرى'; // داخل السعودية لكن بعيدة
        } else {
            return null; // خارج السعودية، لا نغيرها
        }
    }
    
    return $closestCity;
}

/**
 * حساب المسافة بين نقطتين بالكيلومتر (Haversine formula)
 */
function calculateDistance($lat1, $lng1, $lat2, $lng2) {
    $earthRadius = 6371; // كيلومتر
    
    $latFrom = deg2rad($lat1);
    $lngFrom = deg2rad($lng1);
    $latTo = deg2rad($lat2);
    $lngTo = deg2rad($lng2);
    
    $latDelta = $latTo - $latFrom;
    $lngDelta = $lngTo - $lngFrom;
    
    $a = sin($latDelta / 2) * sin($latDelta / 2) +
         cos($latFrom) * cos($latTo) *
         sin($lngDelta / 2) * sin($lngDelta / 2);
    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    
    return $earthRadius * $c;
}
?> 