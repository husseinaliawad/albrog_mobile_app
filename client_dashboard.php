<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

// ✅ CORS Headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

header('Content-Type: application/json; charset=utf-8');

// ✅ الاتصال بقاعدة البيانات - تصحيح المسار للملف في المجلد الجذر
require_once __DIR__ . '/api/config/database.php';
$database = new Database();
$db = $database->getConnection();

try {
    // Get user ID from request
    $user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
    
    if ($user_id <= 0) {
        http_response_code(400);
        echo json_encode([
            "success" => false,
            "message" => "❌ معرف المستخدم مطلوب",
            "timestamp" => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }
    
    // Get user profile information
    $profile_query = "SELECT 
        ID as user_id,
        display_name as user_name,
        user_email,
        user_registered,
        (SELECT meta_value FROM wp_usermeta WHERE user_id = u.ID AND meta_key = 'first_name' LIMIT 1) as first_name,
        (SELECT meta_value FROM wp_usermeta WHERE user_id = u.ID AND meta_key = 'last_name' LIMIT 1) as last_name,
        (SELECT meta_value FROM wp_usermeta WHERE user_id = u.ID AND meta_key = 'phone' LIMIT 1) as phone,
        (SELECT meta_value FROM wp_usermeta WHERE user_id = u.ID AND meta_key = 'profile_image' LIMIT 1) as profile_image
    FROM wp_users u 
    WHERE u.ID = ? AND u.user_status = 0";
    
    $profile_stmt = $db->prepare($profile_query);
    $profile_stmt->execute([$user_id]);
    $profile = $profile_stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$profile) {
        http_response_code(404);
        echo json_encode([
            "success" => false,
            "message" => "❌ المستخدم غير موجود",
            "timestamp" => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }
    
    // Count favorites (using wp_usermeta for user favorites)
    $favorites_query = "SELECT COUNT(*) as count FROM wp_usermeta 
                       WHERE user_id = ? AND meta_key LIKE 'fave_property_favorite_%'";
    $favorites_stmt = $db->prepare($favorites_query);
    $favorites_stmt->execute([$user_id]);
    $favorites_count = $favorites_stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Count saved searches (using wp_posts for saved searches)
    $searches_query = "SELECT COUNT(*) as count FROM wp_posts 
                      WHERE post_author = ? AND post_type = 'saved_search' AND post_status = 'publish'";
    $searches_stmt = $db->prepare($searches_query);
    $searches_stmt->execute([$user_id]);
    $searches_count = $searches_stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Count property visits (using wp_postmeta for property views)
    $visits_query = "SELECT COUNT(DISTINCT post_id) as count FROM wp_postmeta pm
                    JOIN wp_posts p ON pm.post_id = p.ID
                    WHERE pm.meta_key = 'property_views' 
                    AND pm.meta_value LIKE '%user_$user_id%'
                    AND p.post_type = 'property'";
    $visits_stmt = $db->prepare($visits_query);
    $visits_stmt->execute();
    $visits_count = $visits_stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Count reviews (using wp_comments for reviews)
    $reviews_query = "SELECT COUNT(*) as count FROM wp_comments 
                     WHERE user_id = ? AND comment_approved = '1'";
    $reviews_stmt = $db->prepare($reviews_query);
    $reviews_stmt->execute([$user_id]);
    $reviews_count = $reviews_stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Count requests/inquiries (using wp_posts for inquiries)
    $requests_query = "SELECT COUNT(*) as count FROM wp_posts 
                      WHERE post_author = ? AND post_type = 'houzez_inquiry' AND post_status = 'publish'";
    $requests_stmt = $db->prepare($requests_query);
    $requests_stmt->execute([$user_id]);
    $requests_count = $requests_stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Count notifications (using wp_usermeta for unread notifications)
    $notifications_query = "SELECT COUNT(*) as count FROM wp_usermeta 
                           WHERE user_id = ? AND meta_key = 'unread_notifications'";
    $notifications_stmt = $db->prepare($notifications_query);
    $notifications_stmt->execute([$user_id]);
    $notifications_count = $notifications_stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Get recent activities
    $activities = [];
    
    // Recent favorites
    $recent_favorites_query = "SELECT 
        'favorite' as type,
        'أضفت عقار للمفضلة' as title,
        p.post_title as subtitle,
        um.umeta_id as activity_id,
        NOW() as activity_time
    FROM wp_usermeta um
    JOIN wp_posts p ON p.ID = SUBSTRING_INDEX(SUBSTRING_INDEX(um.meta_key, '_', -1), '_', 1)
    WHERE um.user_id = ? 
    AND um.meta_key LIKE 'fave_property_favorite_%'
    AND p.post_type = 'property'
    ORDER BY um.umeta_id DESC
    LIMIT 2";
    
    $recent_favorites_stmt = $db->prepare($recent_favorites_query);
    $recent_favorites_stmt->execute([$user_id]);
    $recent_favorites = $recent_favorites_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($recent_favorites as $activity) {
        $activities[] = [
            'icon' => 'favorite',
            'title' => $activity['title'],
            'subtitle' => $activity['subtitle'],
            'time' => 'منذ ساعتين', // You can calculate actual time
            'color' => 'red'
        ];
    }
    
    // Recent comments/reviews
    $recent_reviews_query = "SELECT 
        'review' as type,
        'قيمت عقار' as title,
        p.post_title as subtitle,
        c.comment_ID as activity_id,
        c.comment_date as activity_time
    FROM wp_comments c
    JOIN wp_posts p ON c.comment_post_ID = p.ID
    WHERE c.user_id = ? 
    AND c.comment_approved = '1'
    AND p.post_type = 'property'
    ORDER BY c.comment_date DESC
    LIMIT 2";
    
    $recent_reviews_stmt = $db->prepare($recent_reviews_query);
    $recent_reviews_stmt->execute([$user_id]);
    $recent_reviews = $recent_reviews_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($recent_reviews as $activity) {
        $activities[] = [
            'icon' => 'star',
            'title' => $activity['title'],
            'subtitle' => $activity['subtitle'],
            'time' => 'منذ يوم',
            'color' => 'orange'
        ];
    }
    
    // Add default activities if none found
    if (empty($activities)) {
        $activities = [
            [
                'icon' => 'home_work',
                'title' => 'مرحباً بك في البروج العقاري',
                'subtitle' => 'ابدأ باستكشاف العقارات المتاحة',
                'time' => 'اليوم',
                'color' => 'blue'
            ],
            [
                'icon' => 'search',
                'title' => 'جرب البحث المتقدم',
                'subtitle' => 'اعثر على العقار المثالي بسهولة',
                'time' => 'اليوم',
                'color' => 'green'
            ]
        ];
    }
    
    // Prepare profile data with statistics
    $profile_data = [
        'user_id' => $profile['user_id'],
        'user_name' => $profile['user_name'] ?: ($profile['first_name'] . ' ' . $profile['last_name']),
        'user_email' => $profile['user_email'],
        'phone' => $profile['phone'] ?: '',
        'profile_image' => $profile['profile_image'] ?: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
        'user_registered' => $profile['user_registered'],
        'favorites_count' => (int)$favorites_count,
        'saved_searches_count' => (int)$searches_count,
        'visits_count' => (int)$visits_count,
        'reviews_count' => (int)$reviews_count,
        'requests_count' => (int)$requests_count,
        'notifications_count' => (int)$notifications_count
    ];
    
    $dashboard_data = [
        'profile' => $profile_data,
        'recent_activities' => $activities
    ];
    
    echo json_encode([
        "success" => true,
        "message" => "✅ تم جلب بيانات لوحة التحكم بنجاح",
        "data" => $dashboard_data,
        "timestamp" => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    
} catch (PDOException $e) {
    error_log("Dashboard Database Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "❌ خطأ في قاعدة البيانات: " . $e->getMessage(),
        "timestamp" => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
} catch (Exception $e) {
    error_log("Dashboard Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "❌ حدث خطأ غير متوقع: " . $e->getMessage(),
        "timestamp" => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}
?> 