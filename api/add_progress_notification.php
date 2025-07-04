<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

// ✅ ضبط المنطقة الزمنية العربية
date_default_timezone_set('Asia/Riyadh'); // أو 'Africa/Cairo'

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/config/database.php';

$database = new Database();
$pdo = $database->getConnection();

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $property_id = $input['property_id'] ?? 0;
    $old_progress = $input['old_progress'] ?? 0;
    $new_progress = $input['new_progress'] ?? 0;
    $update_notes = $input['notes'] ?? '';
    $updater_name = $input['updater_name'] ?? 'إدارة المشروع';
    
    if ($property_id <= 0) {
        throw new Exception('معرف العقار مطلوب');
    }
    
    if ($new_progress < 0 || $new_progress > 100) {
        throw new Exception('نسبة الإنجاز يجب أن تكون بين 0 و 100');
    }
    
    // جلب معلومات العقار
    $property_stmt = $pdo->prepare("
        SELECT 
            p.post_title,
            p.post_author,
            pm_assigned.meta_value as assigned_clients
        FROM wp_posts p
        LEFT JOIN wp_postmeta pm_assigned 
            ON p.ID = pm_assigned.post_id 
            AND pm_assigned.meta_key = 'assigned_client'
        WHERE p.ID = :property_id 
        AND p.post_type = 'property'
    ");
    
    $property_stmt->bindParam(':property_id', $property_id, PDO::PARAM_INT);
    $property_stmt->execute();
    $property = $property_stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$property) {
        throw new Exception('العقار غير موجود');
    }
    
    $property_title = $property['post_title'];
    $property_owner = $property['post_author'];
    $assigned_clients = $property['assigned_clients'];
    
    // تحديد نوع التحديث
    $progress_change = $new_progress - $old_progress;
    $update_type = '';
    $update_message = '';
    
    if ($progress_change > 0) {
        $update_type = 'progress_increased';
        $update_message = "تطور المشروع من {$old_progress}% إلى {$new_progress}%";
    } elseif ($progress_change < 0) {
        $update_type = 'progress_decreased';
        $update_message = "تم تعديل نسبة الإنجاز من {$old_progress}% إلى {$new_progress}%";
    } else {
        $update_type = 'progress_updated';
        $update_message = "تم تحديث المشروع عند {$new_progress}%";
    }
    
    // إضافة الملاحظات إذا وجدت
    if (!empty($update_notes)) {
        $update_message .= " - " . $update_notes;
    }
    
    $notifications_added = [];
    
    // إشعار لمالك العقار
    if ($property_owner) {
        $owner_meta = json_encode([
            'type' => 'project_progress_updated',
            'title' => 'تحديث نسبة الإنجاز',
            'subtitle' => $update_message,
            'message' => "المشروع: {$property_title}",
            'property_id' => $property_id,
            'property_title' => $property_title,
            'old_progress' => $old_progress,
            'new_progress' => $new_progress,
            'progress_change' => $progress_change,
            'update_type' => $update_type,
            'notes' => $update_notes,
            'updater' => $updater_name
        ], JSON_UNESCAPED_UNICODE);
        
        $stmt = $pdo->prepare("
            INSERT INTO wp_houzez_crm_activities 
            (user_id, meta, time) 
            VALUES (:user_id, :meta, NOW())
        ");
        
        $stmt->bindParam(':user_id', $property_owner, PDO::PARAM_INT);
        $stmt->bindParam(':meta', $owner_meta, PDO::PARAM_STR);
        $stmt->execute();
        
        $notifications_added[] = "مالك العقار (ID: {$property_owner})";
    }
    
    // إشعار للمساهمين/المستثمرين
    if ($assigned_clients) {
        $client_ids = [];
        
        // معالجة assigned_clients
        if (is_string($assigned_clients)) {
            if (strpos($assigned_clients, 'a:') === 0) {
                $unserialized = @unserialize($assigned_clients);
                if (is_array($unserialized)) {
                    $client_ids = $unserialized;
                }
            } else {
                $decoded = @json_decode($assigned_clients, true);
                if (is_array($decoded)) {
                    $client_ids = $decoded;
                } else {
                    $client_ids = explode(',', $assigned_clients);
                }
            }
        }
        
        foreach ($client_ids as $client_id) {
            $client_id = intval(trim($client_id));
            if ($client_id > 0 && $client_id != $property_owner) {
                
                $client_title = ($progress_change > 0) ? 
                    '🎉 تقدم في مشروعك!' : 
                    'تحديث في مشروعك';
                
                $client_meta = json_encode([
                    'type' => 'investment_progress_update',
                    'title' => $client_title,
                    'subtitle' => $update_message,
                    'message' => "مشروعك: {$property_title}",
                    'property_id' => $property_id,
                    'property_title' => $property_title,
                    'old_progress' => $old_progress,
                    'new_progress' => $new_progress,
                    'progress_change' => $progress_change,
                    'update_type' => $update_type,
                    'is_positive_update' => ($progress_change > 0),
                    'notes' => $update_notes
                ], JSON_UNESCAPED_UNICODE);
                
                $client_stmt = $pdo->prepare("
                    INSERT INTO wp_houzez_crm_activities 
                    (user_id, meta, time) 
                    VALUES (:user_id, :meta, NOW())
                ");
                
                $client_stmt->bindParam(':user_id', $client_id, PDO::PARAM_INT);
                $client_stmt->bindParam(':meta', $client_meta, PDO::PARAM_STR);
                $client_stmt->execute();
                
                $notifications_added[] = "المستثمر (ID: {$client_id})";
            }
        }
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'تم إضافة إشعارات تحديث النسبة بنجاح',
        'property_id' => $property_id,
        'property_title' => $property_title,
        'progress_update' => [
            'from' => $old_progress,
            'to' => $new_progress,
            'change' => $progress_change,
            'type' => $update_type
        ],
        'notifications_sent_to' => $notifications_added,
        'count' => count($notifications_added),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
} 