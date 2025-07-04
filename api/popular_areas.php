<?php
/**
 * Popular Areas API - Albrog Mobile App
 * Endpoint: /popular_areas.php
 * Purpose: Get popular areas with property counts
 */

// Enable CORS for all origins (تمكين CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include database configuration
require_once 'config/database.php';

try {
    // Get limit parameter (default: 6)
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 6;
    $limit = max(1, min($limit, 50)); // Between 1 and 50

    // Initialize response array
    $popularAreas = [];
    
        // Try to get popular areas from WordPress database
    try {
        // Method 1: Get areas from wp_posts meta or custom table
        $sql = "
            SELECT 
                meta_city.meta_value as city_name,
                COUNT(*) as property_count,
                AVG(CAST(meta_price.meta_value AS UNSIGNED)) as average_price
            FROM wp_posts p
            LEFT JOIN wp_postmeta meta_city ON p.ID = meta_city.post_id AND meta_city.meta_key = 'fave_property_city'
            LEFT JOIN wp_postmeta meta_price ON p.ID = meta_price.post_id AND meta_price.meta_key = 'fave_property_price'
            WHERE p.post_type = 'property' 
                AND p.post_status = 'publish'
                AND meta_city.meta_value IS NOT NULL 
                AND meta_city.meta_value != ''
                AND meta_city.meta_value NOT REGEXP '^[-+]?[0-9]*\.?[0-9]+,[-+]?[0-9]*\.?[0-9]+'
            GROUP BY meta_city.meta_value
            ORDER BY property_count DESC, city_name ASC
            LIMIT ?
        ";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$limit]);
        $dbResults = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        error_log("✅ Found " . count($dbResults) . " areas in database (excluding coordinates)");
        
        // Process database results
        foreach ($dbResults as $row) {
            $cityName = trim($row['city_name'] ?? '');
            if (empty($cityName)) continue;
            
            $propertyCount = (int)($row['property_count'] ?? 0);
            $averagePrice = $row['average_price'] ? (float)$row['average_price'] : null;
            
            // Generate image URL
            $imageUrl = getAreaImageUrl($cityName);
            
            $popularAreas[] = [
                'id' => sanitizeId($cityName),
                'name' => $cityName,
                'name_en' => translateToEnglish($cityName),
                'property_count' => $propertyCount,
                'average_price' => $averagePrice,
                'image' => $imageUrl,
                'description' => "منطقة $cityName - تحتوي على $propertyCount عقار"
            ];
        }

        echo json_encode([
            'success' => true,
            'message' => '✅ تم جلب المناطق الشائعة من الجذر',
            'count' => count($popularAreas),
            'data' => $popularAreas,
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        error_log("Database error in popular_areas.php: " . $e->getMessage());
        throw new Exception("Database connection failed");
    }

} catch (Exception $e) {
    error_log("Error in popular_areas.php: " . $e->getMessage());
    
    // Return sample data as fallback
    $sampleAreas = [
        [
            'id' => 'riyadh',
            'name' => 'الرياض',
            'name_en' => 'Riyadh',
            'property_count' => 2456,
            'average_price' => 850000,
            'image' => 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'description' => 'العاصمة - أكبر تجمع للعقارات'
        ],
        [
            'id' => 'jeddah',
            'name' => 'جدة',
            'name_en' => 'Jeddah',
            'property_count' => 1890,
            'average_price' => 720000,
            'image' => 'https://images.unsplash.com/photo-1518684079-3c830dcef090?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'description' => 'عروس البحر الأحمر'
        ],
        [
            'id' => 'dammam',
            'name' => 'الدمام',
            'name_en' => 'Dammam',
            'property_count' => 1234,
            'average_price' => 650000,
            'image' => 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'description' => 'عاصمة المنطقة الشرقية'
        ],
        [
            'id' => 'makkah',
            'name' => 'مكة المكرمة',
            'name_en' => 'Makkah',
            'property_count' => 987,
            'average_price' => 950000,
            'image' => 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'description' => 'أقدس الأماكن'
        ],
        [
            'id' => 'madinah',
            'name' => 'المدينة المنورة',
            'name_en' => 'Madinah',
            'property_count' => 567,
            'average_price' => 800000,
            'image' => 'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'description' => 'المدينة المنورة'
        ],
        [
            'id' => 'taif',
            'name' => 'الطائف',
            'name_en' => 'Taif',
            'property_count' => 445,
            'average_price' => 600000,
            'image' => 'https://images.unsplash.com/photo-1571766938606-ca13e5db5346?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'description' => 'مدينة الورود'
        ]
    ];
    
    // Limit sample data
    $sampleAreas = array_slice($sampleAreas, 0, $limit);
    
    echo json_encode([
        'success' => true,
        'message' => 'Sample popular areas data (database unavailable)',
        'count' => count($sampleAreas),
        'data' => $sampleAreas
    ], JSON_UNESCAPED_UNICODE);
}

// Helper functions
function sanitizeId($name) {
    $id = preg_replace('/[^a-zA-Z0-9\u0600-\u06FF]/', '_', $name);
    return strtolower(trim($id, '_'));
}

function translateToEnglish($arabicName) {
    $translations = [
        'الرياض' => 'Riyadh',
        'جدة' => 'Jeddah',
        'الدمام' => 'Dammam',
        'مكة المكرمة' => 'Makkah',
        'المدينة المنورة' => 'Madinah',
        'الطائف' => 'Taif',
        'أبها' => 'Abha',
        'الخبر' => 'Khobar',
        'القطيف' => 'Qatif',
        'حائل' => 'Hail'
    ];
    
    return $translations[$arabicName] ?? $arabicName;
}



function getAreaImageUrl($cityName) {
    $images = [
        'الرياض' => 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        'جدة' => 'https://images.unsplash.com/photo-1518684079-3c830dcef090?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        'الدمام' => 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        'مكة المكرمة' => 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        'المدينة المنورة' => 'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        'الطائف' => 'https://images.unsplash.com/photo-1571766938606-ca13e5db5346?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        'أبها' => 'https://images.unsplash.com/photo-1571766938606-ca13e5db5346?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        'تبوك' => 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
    ];
    
    return $images[$cityName] ?? 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80';
}
?> 