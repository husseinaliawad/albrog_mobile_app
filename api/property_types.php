<?php
/**
 * Property Types API - Albrog Mobile App
 * Endpoint: /property_types.php
 * Purpose: Get property types with counts
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
    // Get limit parameter (default: 10)
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $limit = max(1, min($limit, 50)); // Between 1 and 50

    // Initialize response array
    $propertyTypes = [];
    
    // Try to get property types from WordPress database
    try {
        // Method 1: Get types from wp_posts meta or custom table
        $sql = "
            SELECT 
                meta_type.meta_value as type_name,
                COUNT(*) as property_count
            FROM wp_posts p
            LEFT JOIN wp_postmeta meta_type ON p.ID = meta_type.post_id AND meta_type.meta_key = 'fave_property_type'
            WHERE p.post_type = 'property' 
                AND p.post_status = 'publish'
                AND meta_type.meta_value IS NOT NULL 
                AND meta_type.meta_value != ''
            GROUP BY meta_type.meta_value
            ORDER BY property_count DESC, type_name ASC
            LIMIT ?
        ";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$limit]);
        $dbResults = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Process database results
        foreach ($dbResults as $row) {
            $typeName = trim($row['type_name'] ?? '');
            if (empty($typeName)) continue;
            
            $propertyCount = (int)($row['property_count'] ?? 0);
            
            // Generate additional data
            $typeData = getPropertyTypeData($typeName);
            
            $propertyTypes[] = [
                'id' => sanitizeId($typeName),
                'name' => $typeName,
                'name_en' => $typeData['name_en'],
                'count' => $propertyCount,
                'property_count' => $propertyCount,
                'icon' => $typeData['icon'],
                'image' => $typeData['image'],
                'color' => $typeData['color'],
                'description' => "نوع العقار: $typeName - يحتوي على $propertyCount عقار"
            ];
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Property types loaded successfully',
            'count' => count($propertyTypes),
            'data' => $propertyTypes
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        error_log("Database error in property_types.php: " . $e->getMessage());
        throw new Exception("Database connection failed");
    }

} catch (Exception $e) {
    error_log("Error in property_types.php: " . $e->getMessage());
    
    // Return sample data as fallback
    $sampleTypes = [
        [
            'id' => 'apartment',
            'name' => 'شقة',
            'name_en' => 'Apartment',
            'count' => 1234,
            'property_count' => 1234,
            'icon' => 'apartment',
            'image' => 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'color' => '#2196F3',
            'description' => 'شقق سكنية متنوعة'
        ],
        [
            'id' => 'villa',
            'name' => 'فيلا',
            'name_en' => 'Villa',
            'count' => 567,
            'property_count' => 567,
            'icon' => 'home',
            'image' => 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'color' => '#4CAF50',
            'description' => 'فلل فخمة ومتنوعة'
        ],
        [
            'id' => 'office',
            'name' => 'مكتب',
            'name_en' => 'Office',
            'count' => 890,
            'property_count' => 890,
            'icon' => 'business',
            'image' => 'https://images.unsplash.com/photo-1497366216548-37526070297c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'color' => '#FF9800',
            'description' => 'مكاتب تجارية وإدارية'
        ],
        [
            'id' => 'shop',
            'name' => 'محل',
            'name_en' => 'Shop',
            'count' => 345,
            'property_count' => 345,
            'icon' => 'store',
            'image' => 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'color' => '#9C27B0',
            'description' => 'محلات تجارية متنوعة'
        ],
        [
            'id' => 'land',
            'name' => 'أرض',
            'name_en' => 'Land',
            'count' => 678,
            'property_count' => 678,
            'icon' => 'landscape',
            'image' => 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'color' => '#795548',
            'description' => 'أراضي سكنية وتجارية'
        ],
        [
            'id' => 'warehouse',
            'name' => 'مستودع',
            'name_en' => 'Warehouse',
            'count' => 123,
            'property_count' => 123,
            'icon' => 'warehouse',
            'image' => 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'color' => '#607D8B',
            'description' => 'مستودعات ومخازن'
        ],
        [
            'id' => 'building',
            'name' => 'مبنى',
            'name_en' => 'Building',
            'count' => 22,
            'property_count' => 22,
            'icon' => 'business',
            'image' => 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'color' => '#F44336',
            'description' => 'مباني متعددة الاستخدامات'
        ]
    ];
    
    // Limit sample data
    $sampleTypes = array_slice($sampleTypes, 0, $limit);
    
    echo json_encode([
        'success' => true,
        'message' => 'Sample property types data (database unavailable)',
        'count' => count($sampleTypes),
        'data' => $sampleTypes
    ], JSON_UNESCAPED_UNICODE);
}

// Helper functions
function sanitizeId($name) {
    $id = preg_replace('/[^a-zA-Z0-9\u0600-\u06FF]/', '_', $name);
    return strtolower(trim($id, '_'));
}

function getPropertyTypeData($arabicName) {
    $typeMap = [
        'شقة' => [
            'name_en' => 'Apartment',
            'icon' => 'apartment',
            'color' => '#2196F3',
            'image' => 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
        'فيلا' => [
            'name_en' => 'Villa',
            'icon' => 'home',
            'color' => '#4CAF50',
            'image' => 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
        'مكتب' => [
            'name_en' => 'Office',
            'icon' => 'business',
            'color' => '#FF9800',
            'image' => 'https://images.unsplash.com/photo-1497366216548-37526070297c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
        'محل' => [
            'name_en' => 'Shop',
            'icon' => 'store',
            'color' => '#9C27B0',
            'image' => 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
        'أرض' => [
            'name_en' => 'Land',
            'icon' => 'landscape',
            'color' => '#795548',
            'image' => 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
        'مستودع' => [
            'name_en' => 'Warehouse',
            'icon' => 'warehouse',
            'color' => '#607D8B',
            'image' => 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ],
        'مبنى' => [
            'name_en' => 'Building',
            'icon' => 'business',
            'color' => '#F44336',
            'image' => 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ]
    ];
    
    return $typeMap[$arabicName] ?? [
        'name_en' => $arabicName,
        'icon' => 'home',
        'color' => '#2196F3',
        'image' => 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
    ];
}
?> 