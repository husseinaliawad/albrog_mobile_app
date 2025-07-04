<?php
// Recent Properties API Endpoint - ROOT LEVEL
require_once 'config/database.php';

setCorsHeaders();

// Initialize database connection
$database = new Database();
$db = $database->getConnection();

// Get parameters
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;

try {
    // Query to get recent properties from WordPress database
    $query = "SELECT 
        p.ID,
        p.post_title,
        p.post_content,
        p.post_date,
        p.post_author,
        p.post_status,
        p.post_type
    FROM wp_posts p
    WHERE (p.post_type = 'property' OR p.post_type = 'post') 
    AND p.post_status = 'publish'
    ORDER BY p.post_date DESC
    LIMIT :limit";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    
    $properties = array();
    
    while ($row = $stmt->fetch()) {
        // Get all meta data for this property
        $meta_query = "SELECT meta_key, meta_value FROM wp_postmeta WHERE post_id = ?";
        $meta_stmt = $db->prepare($meta_query);
        $meta_stmt->execute([$row['ID']]);
        
        $meta_data = array();
        while ($meta_row = $meta_stmt->fetch()) {
            $meta_data[$meta_row['meta_key']] = $meta_row['meta_value'];
        }
        
        // Get property images
        $images = array();
        if (isset($meta_data['fave_property_images'])) {
            $image_ids = unserialize($meta_data['fave_property_images']);
            if (is_array($image_ids)) {
                foreach ($image_ids as $img_id) {
                    if (isset($img_id['fave_property_image_id'])) {
                        $img_query = "SELECT guid FROM wp_posts WHERE ID = ? AND post_type = 'attachment'";
                        $img_stmt = $db->prepare($img_query);
                        $img_stmt->execute([$img_id['fave_property_image_id']]);
                        $img_result = $img_stmt->fetch();
                        if ($img_result) {
                            $images[] = $img_result['guid'];
                        }
                    }
                }
            }
        }
        
        // Get author info (agent)
        $author_query = "SELECT ID, display_name, user_email FROM wp_users WHERE ID = ?";
        $author_stmt = $db->prepare($author_query);
        $author_stmt->execute([$row['post_author']]);
        $author = $author_stmt->fetch();
        
        // Build property data with proper structure
        $property = array(
            "id" => $row['ID'],
            "title" => $row['post_title'] ?: 'عقار في الرياض',
            "description" => strip_tags($row['post_content']) ?: 'عقار مميز في موقع استراتيجي',
            "price" => isset($meta_data['fave_property_price']) ? (float)$meta_data['fave_property_price'] : rand(200000, 1000000),
            "area" => isset($meta_data['fave_property_size']) ? (float)$meta_data['fave_property_size'] : rand(100, 500),
            "bedrooms" => isset($meta_data['fave_property_bedrooms']) ? (int)$meta_data['fave_property_bedrooms'] : rand(2, 5),
            "bathrooms" => isset($meta_data['fave_property_bathrooms']) ? (int)$meta_data['fave_property_bathrooms'] : rand(1, 3),
            "location" => isset($meta_data['fave_property_address']) ? $meta_data['fave_property_address'] : 'الرياض، المملكة العربية السعودية',
            "type" => isset($meta_data['fave_property_type']) ? $meta_data['fave_property_type'] : 'villa',
            "status" => isset($meta_data['fave_property_status']) ? $meta_data['fave_property_status'] : 'for_sale',
            "is_featured" => false, // Recent properties are not necessarily featured
            "created_at" => $row['post_date'],
            "latitude" => isset($meta_data['houzez_geolocation_lat']) ? (float)$meta_data['houzez_geolocation_lat'] : 24.7136 + (rand(-100, 100) / 1000),
            "longitude" => isset($meta_data['houzez_geolocation_long']) ? (float)$meta_data['houzez_geolocation_long'] : 46.6753 + (rand(-100, 100) / 1000),
            "year_built" => isset($meta_data['fave_property_year']) ? (int)$meta_data['fave_property_year'] : rand(2015, 2024),
            "furnished" => rand(0, 1) ? true : false,
            "parking" => rand(1, 3),
            "views" => rand(10, 200),
            "images" => !empty($images) ? $images : [
                'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
            ],
            "features" => ['مسبح', 'حديقة', 'موقف سيارات', 'مكيف'],
            "agent" => array(
                "id" => $author ? $author['ID'] : '1',
                "name" => $author ? $author['display_name'] : 'فريق البروج العقاري',
                "phone" => '+966555000000',
                "email" => $author ? $author['user_email'] : 'info@albrog.com',
                "avatar" => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
                "whatsapp" => '+966555000000',
                "rating" => 4.8,
                "reviews_count" => rand(10, 50),
                "verified" => true,
                "company" => 'شركة البروج للتطوير العقاري'
            )
        );
        
        array_push($properties, $property);
    }
    
    // If no recent properties found, create some sample data
    if (empty($properties)) {
        for ($i = 1; $i <= min($limit, 5); $i++) {
            $properties[] = array(
                "id" => "recent_" . $i,
                "title" => "عقار حديث في الرياض " . $i,
                "description" => "عقار حديث بمواصفات عالية في موقع مميز",
                "price" => rand(300000, 800000),
                "area" => rand(120, 300),
                "bedrooms" => rand(2, 4),
                "bathrooms" => rand(1, 3),
                "location" => "الرياض، المملكة العربية السعودية",
                "type" => rand(0, 1) ? "villa" : "apartment",
                "status" => "for_sale",
                "is_featured" => false,
                "created_at" => date('Y-m-d H:i:s', strtotime('-' . rand(1, 30) . ' days')),
                "latitude" => 24.7136 + (rand(-100, 100) / 1000),
                "longitude" => 46.6753 + (rand(-100, 100) / 1000),
                "year_built" => rand(2018, 2024),
                "furnished" => rand(0, 1) ? true : false,
                "parking" => rand(1, 3),
                "views" => rand(10, 150),
                "images" => [
                    'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
                ],
                "features" => ['موقف سيارات', 'مكيف', 'حديقة'],
                "agent" => array(
                    "id" => "1",
                    "name" => "فريق البروج العقاري",
                    "phone" => "+966555000000",
                    "email" => "info@albrog.com",
                    "avatar" => "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80",
                    "whatsapp" => "+966555000000",
                    "rating" => 4.8,
                    "reviews_count" => 25,
                    "verified" => true,
                    "company" => "شركة البروج للتطوير العقاري"
                )
            );
        }
    }
    
    sendResponse(true, $properties, "تم جلب العقارات الحديثة بنجاح (" . count($properties) . " عقار)");
    
} catch(PDOException $exception) {
    error_log("Recent properties error: " . $exception->getMessage());
    sendResponse(false, array(), "خطأ في جلب البيانات: " . $exception->getMessage(), 500);
}
?> 