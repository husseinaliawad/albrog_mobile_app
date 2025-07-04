<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

// ✅ ضبط المنطقة الزمنية العربية
date_default_timezone_set('Asia/Riyadh'); // أو 'Africa/Cairo'

// ✅ رؤوس CORS & JSON
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ✅ الاتصال بقاعدة البيانات
require_once __DIR__ . '/config/database.php';

$database = new Database();
$pdo = $database->getConnection();

try {
    // احصل على user_id من الطلب
    $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 80;
    
    // ✅ إضافة إشعار تصوير العقار
    $stmt1 = $pdo->prepare("
        INSERT INTO wp_houzez_crm_activities (user_id, meta, time) VALUES (
            :user_id,
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
        )
    ");
    $stmt1->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $result1 = $stmt1->execute();
    
    // ✅ إضافة إشعار تقدم المشروع
    $stmt2 = $pdo->prepare("
        INSERT INTO wp_houzez_crm_activities (user_id, meta, time) VALUES (
            :user_id,
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
        )
    ");
    $stmt2->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $result2 = $stmt2->execute();
    
    // ✅ إضافة إشعار استفسار جديد
    $stmt3 = $pdo->prepare("
        INSERT INTO wp_houzez_crm_activities (user_id, meta, time) VALUES (
            :user_id,
            JSON_OBJECT(
                'type', 'contact',
                'title', 'استفسار جديد',
                'subtitle', 'استفسار حول شقة في مدينة نصر',
                'message', 'من: أحمد محمد - رقم: 01234567890',
                'property_id', 15,
                'contact_name', 'أحمد محمد',
                'contact_phone', '01234567890'
            ),
            NOW()
        )
    ");
    $stmt3->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $result3 = $stmt3->execute();
    
    // ✅ التحقق من الإشعارات المضافة
    $check_stmt = $pdo->prepare("
        SELECT 
            activity_id,
            user_id,
            JSON_UNQUOTE(JSON_EXTRACT(meta, '$.title')) as title,
            JSON_UNQUOTE(JSON_EXTRACT(meta, '$.subtitle')) as subtitle,
            DATE_FORMAT(time, '%Y-%m-%d %H:%i:%s') as created_at
        FROM wp_houzez_crm_activities 
        WHERE user_id = :user_id 
        ORDER BY time DESC 
        LIMIT 5
    ");
    $check_stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $check_stmt->execute();
    $notifications = $check_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'تم إضافة الإشعارات التجريبية بنجاح',
        'user_id' => $user_id,
        'notifications_added' => 3,
        'recent_notifications' => $notifications,
        'results' => [
            'image_notification' => $result1,
            'progress_notification' => $result2,
            'contact_notification' => $result3
        ],
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'user_id' => $user_id ?? 0,
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
        'user_id' => $user_id ?? 0,
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
}
?> 