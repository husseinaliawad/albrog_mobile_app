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

// ✅ الاتصال بقاعدة البيانات بنفس المسار الثابت
require_once __DIR__ . '/config/database.php';
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
    
    // Verify user exists
    $user_query = "SELECT ID, display_name, user_email FROM wp_users WHERE ID = ? AND user_status = 0";
    $user_stmt = $db->prepare($user_query);
    $user_stmt->execute([$user_id]);
    $user = $user_stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        http_response_code(404);
        echo json_encode([
            "success" => false,
            "message" => "❌ المستخدم غير موجود",
            "timestamp" => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }
    
    // Get user's investment projects
    $projects_query = "SELECT 
        p.ID as project_id,
        p.post_title as project_name,
        p.post_content as project_description,
        p.post_date as start_date,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'project_location' LIMIT 1) as location,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'project_type' LIMIT 1) as project_type,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'project_units' LIMIT 1) as total_units,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'project_available_units' LIMIT 1) as available_units,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'project_progress' LIMIT 1) as progress_percentage,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'project_expected_delivery' LIMIT 1) as expected_delivery,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'project_developer' LIMIT 1) as developer,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'project_featured_image' LIMIT 1) as featured_image,
        -- Investment specific data
        i.investment_amount,
        i.paid_amount,
        i.remaining_amount,
        i.expected_return,
        i.expected_roi,
        i.investment_date,
        i.status as investment_status
    FROM wp_posts p
    INNER JOIN wp_user_investments i ON p.ID = i.project_id
    WHERE p.post_type = 'investment_project' 
    AND p.post_status = 'publish'
    AND i.user_id = ?
    ORDER BY i.investment_date DESC";
    
    $projects_stmt = $db->prepare($projects_query);
    $projects_stmt->execute([$user_id]);
    $projects_raw = $projects_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $total_investment = 0;
    $total_expected_return = 0;
    $total_paid = 0;
    $projects = [];
    
    foreach ($projects_raw as $project) {
        // Calculate totals
        $investment_amount = floatval($project['investment_amount'] ?? 0);
        $expected_return = floatval($project['expected_return'] ?? 0);
        $paid_amount = floatval($project['paid_amount'] ?? 0);
        
        $total_investment += $investment_amount;
        $total_expected_return += $expected_return;
        $total_paid += $paid_amount;
        
        // Get project updates/timeline
        $updates_query = "SELECT 
            update_title,
            update_description,
            update_date,
            update_type,
            update_images
        FROM wp_project_updates 
        WHERE project_id = ? 
        ORDER BY update_date DESC 
        LIMIT 5";
        
        $updates_stmt = $db->prepare($updates_query);
        $updates_stmt->execute([$project['project_id']]);
        $updates = $updates_stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Format updates
        $formatted_updates = [];
        foreach ($updates as $update) {
            $formatted_updates[] = [
                'date' => $update['update_date'],
                'title' => $update['update_title'],
                'description' => $update['update_description'],
                'type' => $update['update_type'] ?? 'progress',
                'images' => $update['update_images'] ? json_decode($update['update_images'], true) : []
            ];
        }
        
        // Get project timeline
        $timeline_query = "SELECT 
            phase_name,
            phase_date,
            phase_status,
            phase_description
        FROM wp_project_timeline 
        WHERE project_id = ? 
        ORDER BY phase_order ASC";
        
        $timeline_stmt = $db->prepare($timeline_query);
        $timeline_stmt->execute([$project['project_id']]);
        $timeline = $timeline_stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Format timeline
        $formatted_timeline = [];
        foreach ($timeline as $phase) {
            $formatted_timeline[] = [
                'phase' => $phase['phase_name'],
                'date' => $phase['phase_date'],
                'status' => $phase['phase_status'], // completed, in_progress, pending
                'description' => $phase['phase_description']
            ];
        }
        
        // Build project data
        $projects[] = [
            'id' => intval($project['project_id']),
            'name' => $project['project_name'],
            'description' => $project['project_description'],
            'location' => $project['location'] ?? '',
            'type' => $project['project_type'] ?? 'سكني',
            'progress' => intval($project['progress_percentage'] ?? 0),
            'expectedDelivery' => $project['expected_delivery'],
            'developer' => $project['developer'] ?? '',
            'startDate' => $project['start_date'],
            'totalUnits' => intval($project['total_units'] ?? 0),
            'availableUnits' => intval($project['available_units'] ?? 0),
            'image' => $project['featured_image'] ?? 'https://albrog.com/wp-content/uploads/2024/01/default-project.jpg',
            'financialSummary' => [
                'totalInvestment' => $investment_amount,
                'paidAmount' => $paid_amount,
                'remainingAmount' => floatval($project['remaining_amount'] ?? 0),
                'expectedReturn' => $expected_return,
                'expectedROI' => floatval($project['expected_roi'] ?? 0)
            ],
            'investmentAmount' => $investment_amount,
            'investmentDate' => $project['investment_date'],
            'status' => $project['investment_status'] ?? 'active',
            'updates' => $formatted_updates,
            'timeline' => $formatted_timeline
        ];
    }
    
    // Calculate average ROI
    $average_roi = 0;
    if (count($projects) > 0) {
        $total_roi = 0;
        foreach ($projects as $project) {
            $total_roi += $project['financialSummary']['expectedROI'];
        }
        $average_roi = $total_roi / count($projects);
    }
    
    // Get recent investment activities
    $activities_query = "SELECT 
        'investment' as activity_type,
        p.post_title as project_name,
        ia.activity_type as type,
        ia.activity_description as description,
        ia.activity_date as date,
        ia.amount
    FROM wp_investment_activities ia
    JOIN wp_posts p ON ia.project_id = p.ID
    WHERE ia.user_id = ?
    ORDER BY ia.activity_date DESC
    LIMIT 10";
    
    $activities_stmt = $db->prepare($activities_query);
    $activities_stmt->execute([$user_id]);
    $activities = $activities_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format activities
    $formatted_activities = [];
    foreach ($activities as $activity) {
        $formatted_activities[] = [
            'type' => $activity['type'],
            'projectName' => $activity['project_name'],
            'description' => $activity['description'],
            'date' => $activity['date'],
            'amount' => floatval($activity['amount'] ?? 0)
        ];
    }
    
    // Prepare dashboard data
    $dashboard_data = [
        'user' => [
            'id' => $user['ID'],
            'name' => $user['display_name'],
            'email' => $user['user_email']
        ],
        'portfolio' => [
            'totalInvestment' => $total_investment,
            'totalExpectedReturn' => $total_expected_return,
            'totalPaid' => $total_paid,
            'averageROI' => $average_roi,
            'projectsCount' => count($projects),
            'growthPercentage' => 12.5 // This could be calculated based on historical data
        ],
        'projects' => $projects,
        'recentActivities' => $formatted_activities
    ];
    
    echo json_encode([
        "success" => true,
        "message" => "✅ تم جلب بيانات لوحة الاستثمار بنجاح",
        "data" => $dashboard_data,
        "timestamp" => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    
} catch (PDOException $e) {
    error_log("Investment Dashboard Database Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "❌ خطأ في قاعدة البيانات: " . $e->getMessage(),
        "timestamp" => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
} catch (Exception $e) {
    error_log("Investment Dashboard Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "❌ حدث خطأ غير متوقع: " . $e->getMessage(),
        "timestamp" => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}
?> 