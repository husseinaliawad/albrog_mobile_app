<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// التعامل مع OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'config/database.php';

try {
    // الحصول على المعاملات
    $action = $_GET['action'] ?? 'check_new_videos';
    $user_id = $_GET['user_id'] ?? null;
    $hours_back = $_GET['hours_back'] ?? 24; // البحث في آخر 24 ساعة افتراضياً
    
    switch ($action) {
        case 'check_new_videos':
            $result = checkNewVideoProperties($pdo, $hours_back);
            break;
            
        case 'get_user_notifications':
            if (!$user_id) {
                throw new Exception('User ID is required');
            }
            $result = getUserNotifications($pdo, $user_id);
            break;
            
        case 'mark_as_read':
            if (!$user_id) {
                throw new Exception('User ID is required');
            }
            $notification_id = $_POST['notification_id'] ?? $_GET['notification_id'];
            $result = markNotificationAsRead($pdo, $notification_id, $user_id);
            break;
            
        default:
            throw new Exception('Invalid action');
    }
    
    echo json_encode([
        'success' => true,
        'data' => $result,
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}

/**
 * البحث عن المشاريع الجديدة التي تحتوي على فيديوهات يوتيوب
 */
function checkNewVideoProperties($pdo, $hours_back = 24) {
    // 🎯 الاستعلام الذكي اللي طلبته
    $sql = "
        SELECT DISTINCT
            p.ID AS post_id,
            p.post_title,
            p.post_modified,
            p.post_date,
            GROUP_CONCAT(DISTINCT m.meta_value SEPARATOR '|||') AS youtube_videos,
            COUNT(DISTINCT m.meta_id) AS video_count
        FROM 
            wp_posts p
        JOIN 
            wp_postmeta m ON p.ID = m.post_id
        WHERE 
            p.post_status = 'publish'
            AND p.post_type = 'post'
            AND (
                m.meta_key LIKE '%video%' 
                OR m.meta_key LIKE '%youtube%'
                OR m.meta_key LIKE '%_video_file%'
            )
            AND (
                m.meta_value LIKE '%youtube.com%' 
                OR m.meta_value LIKE '%youtu.be%'
            )
            AND p.post_modified >= DATE_SUB(NOW(), INTERVAL ? HOUR)
        GROUP BY p.ID, p.post_title, p.post_modified, p.post_date
        ORDER BY 
            p.post_modified DESC
        LIMIT 50
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$hours_back]);
    $properties = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $new_notifications = [];
    
    foreach ($properties as $property) {
        // تنظيف روابط اليوتيوب
        $videos = explode('|||', $property['youtube_videos']);
        $clean_videos = [];
        
        foreach ($videos as $video) {
            if (strpos($video, 'youtube') !== false || strpos($video, 'youtu.be') !== false) {
                $clean_videos[] = extractYouTubeID($video);
            }
        }
        
        if (!empty($clean_videos)) {
            // إنشاء إشعار جديد
            $notification = [
                'property_id' => $property['post_id'],
                'title' => $property['post_title'],
                'message' => "تم إضافة " . count($clean_videos) . " فيديو جديد للمشروع",
                'type' => 'new_video',
                'video_count' => count($clean_videos),
                'youtube_ids' => $clean_videos,
                'created_at' => $property['post_modified'],
                'is_new' => true
            ];
            
            $new_notifications[] = $notification;
            
            // حفظ الإشعار في قاعدة البيانات
            saveNotificationToDB($pdo, $notification);
        }
    }
    
    return [
        'found_properties' => count($properties),
        'new_notifications' => count($new_notifications),
        'notifications' => $new_notifications,
        'search_period_hours' => $hours_back
    ];
}

/**
 * استخراج معرف اليوتيوب من الرابط - محدث لدعم YouTube Shorts
 */
function extractYouTubeID($url) {
    $video_id = '';
    
    // تنظيف الرابط من الـ backslashes
    $url = str_replace('\\/', '/', $url);
    
    // YouTube Watch URLs
    if (preg_match('/youtube\.com\/watch\?v=([^\&\?\/]+)/', $url, $id)) {
        $video_id = $id[1];
    }
    // YouTube Embed URLs
    elseif (preg_match('/youtube\.com\/embed\/([^\&\?\/]+)/', $url, $id)) {
        $video_id = $id[1];
    }
    // YouTube Shorts URLs - الأهم!
    elseif (preg_match('/youtube\.com\/shorts\/([^\&\?\/]+)/', $url, $id)) {
        $video_id = $id[1];
    }
    // Short youtu.be URLs
    elseif (preg_match('/youtu\.be\/([^\&\?\/]+)/', $url, $id)) {
        $video_id = $id[1];
    }
    
    return [
        'original_url' => $url,
        'video_id' => $video_id,
        'thumbnail' => "https://img.youtube.com/vi/{$video_id}/maxresdefault.jpg",
        'watch_url' => "https://www.youtube.com/watch?v={$video_id}"
    ];
}

/**
 * حفظ الإشعار في قاعدة البيانات
 */
function saveNotificationToDB($pdo, $notification) {
    // إنشاء جدول الإشعارات إذا لم يكن موجوداً
    createNotificationsTableIfNotExists($pdo);
    
    $sql = "
        INSERT INTO albrog_notifications 
        (property_id, title, message, type, data, created_at) 
        VALUES (?, ?, ?, ?, ?, NOW())
    ";
    
    $data = json_encode([
        'video_count' => $notification['video_count'],
        'youtube_ids' => $notification['youtube_ids']
    ]);
    
    $stmt = $pdo->prepare($sql);
    return $stmt->execute([
        $notification['property_id'],
        $notification['title'],
        $notification['message'],
        $notification['type'],
        $data
    ]);
}

/**
 * جلب إشعارات المستخدم
 */
function getUserNotifications($pdo, $user_id, $limit = 50) {
    $sql = "
        SELECT 
            id,
            property_id,
            title,
            message,
            type,
            data,
            is_read,
            created_at
        FROM albrog_notifications 
        WHERE user_id IS NULL OR user_id = ?
        ORDER BY created_at DESC 
        LIMIT ?
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$user_id, $limit]);
    $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // تحويل البيانات JSON
    foreach ($notifications as &$notification) {
        $notification['data'] = json_decode($notification['data'], true);
        $notification['is_read'] = (bool)$notification['is_read'];
    }
    
    return $notifications;
}

/**
 * تحديد الإشعار كمقروء
 */
function markNotificationAsRead($pdo, $notification_id, $user_id) {
    $sql = "UPDATE albrog_notifications SET is_read = 1 WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    return $stmt->execute([$notification_id]);
}

/**
 * إنشاء جدول الإشعارات
 */
function createNotificationsTableIfNotExists($pdo) {
    $sql = "
        CREATE TABLE IF NOT EXISTS albrog_notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NULL,
            property_id INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            message TEXT NOT NULL,
            type VARCHAR(50) NOT NULL DEFAULT 'general',
            data JSON NULL,
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_user_id (user_id),
            INDEX idx_property_id (property_id),
            INDEX idx_created_at (created_at),
            INDEX idx_is_read (is_read)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ";
    
    $pdo->exec($sql);
}
?> 