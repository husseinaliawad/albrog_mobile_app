<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

// ✅ ضبط المنطقة الزمنية العربية
date_default_timezone_set('Asia/Riyadh'); // أو 'Africa/Cairo'

// ✅ رؤوس CORS & JSON
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

header('Content-Type: application/json; charset=utf-8');

// ✅ الاتصال بقاعدة البيانات
require_once __DIR__ . '/config/database.php';

$database = new Database();
$pdo = $database->getConnection();

try {
    // ✅ الحصول على معاملات الطلب
    $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
    
    if ($user_id <= 0) {
        throw new Exception('معرف المستخدم مطلوب ويجب أن يكون أكبر من 0');
    }
    
    if ($limit <= 0 || $limit > 100) {
        $limit = 20; // حد افتراضي آمن
    }

    // ✅ جلب الأنشطة من قاعدة البيانات
    $sql = "
        SELECT 
            activity_id AS id,
            user_id,
            COALESCE(
                JSON_UNQUOTE(JSON_EXTRACT(meta, '$.title')),
                JSON_UNQUOTE(JSON_EXTRACT(meta, '$.name')),
                'نشاط جديد'
            ) AS title,
            COALESCE(
                JSON_UNQUOTE(JSON_EXTRACT(meta, '$.subtitle')),
                JSON_UNQUOTE(JSON_EXTRACT(meta, '$.message')),
                JSON_UNQUOTE(JSON_EXTRACT(meta, '$.phone')),
                ''
            ) AS details,
            COALESCE(
                JSON_UNQUOTE(JSON_EXTRACT(meta, '$.type')),
                'general'
            ) AS type,
            DATE_FORMAT(time, '%Y-%m-%d %H:%i:%s') AS created_at,
            meta AS raw_meta
        FROM wp_houzez_crm_activities
        WHERE user_id = :user_id
        ORDER BY time DESC
        LIMIT :limit
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();

    $activities = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // ✅ معالجة البيانات لتحسين العرض
    $processed_activities = [];
    foreach ($activities as $activity) {
        $processed_activity = [
            'id' => (int)$activity['id'],
            'user_id' => (int)$activity['user_id'],
            'title' => $activity['title'] ?: 'نشاط جديد',
            'details' => $activity['details'] ?: '',
            'type' => $activity['type'] ?: 'general',
            'created_at' => $activity['created_at'],
            'time' => $activity['created_at'], // للتوافق مع النموذج
        ];
        
        // إضافة أيقونة حسب النوع
        switch ($activity['type']) {
            case 'property_images_added':
                $processed_activity['icon_type'] = 'view';
                break;
            case 'property_update_for_investor':
            case 'investment_progress_update':
                $processed_activity['icon_type'] = 'favorite';
                break;
            case 'contact':
                $processed_activity['icon_type'] = 'contact';
                break;
            case 'inquiry':
                $processed_activity['icon_type'] = 'inquiry';
                break;
            default:
                $processed_activity['icon_type'] = 'view';
        }
        
        $processed_activities[] = $processed_activity;
    }

    // ✅ إحصائيات إضافية
    $count_sql = "SELECT COUNT(*) as total FROM wp_houzez_crm_activities WHERE user_id = :user_id";
    $count_stmt = $pdo->prepare($count_sql);
    $count_stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $count_stmt->execute();
    $total_count = $count_stmt->fetchColumn();

    echo json_encode([
        'success' => true,
        'data' => $processed_activities,
        'count' => count($processed_activities),
        'total_count' => (int)$total_count,
        'user_id' => $user_id,
        'limit' => $limit,
        'message' => 'تم جلب الأنشطة بنجاح',
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