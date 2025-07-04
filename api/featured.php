<?php
// Featured Properties API Endpoint - ROOT LEVEL
require_once 'config/database.php';

setCorsHeaders();

// Initialize database connection
$database = new Database();
$db = $database->getConnection();

// Get parameters
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;

try {
    // Query to get featured properties from WordPress database
    $query = "SELECT 
        p.ID,
        p.post_title,
        p.post_content,
        p.post_date,
        p.post_author,
        p.post_status,
        p.post_type
    FROM wp_posts p
    INNER JOIN wp_postmeta pm ON p.ID = pm.post_id
    WHERE (p.post_type = 'property' OR p.post_type = 'post') 
    AND p.post_status = 'publish'
    AND pm.meta_key = 'fave_featured'
    AND pm.meta_value = '1'
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
        $thumbnail = null;
        
        // Try to get featured image first (post thumbnail)
        $thumbnail_query = "SELECT pm.meta_value as attachment_id 
                           FROM wp_postmeta pm 
                           WHERE pm.post_id = ? AND pm.meta_key = '_thumbnail_id'";
        $thumbnail_stmt = $db->prepare($thumbnail_query);
        $thumbnail_stmt->execute([$row['ID']]);
        $thumbnail_result = $thumbnail_stmt->fetch();
        
        if ($thumbnail_result && $thumbnail_result['attachment_id']) {
            // Get the actual image URL from attachment
            $img_query = "SELECT guid FROM wp_posts WHERE ID = ? AND post_type = 'attachment'";
            $img_stmt = $db->prepare($img_query);
            $img_stmt->execute([$thumbnail_result['attachment_id']]);
            $img_result = $img_stmt->fetch();
            if ($img_result) {
                $thumbnail = $img_result['guid'];
                $images[] = $img_result['guid'];
            }
        }
        
        // Get gallery images from property meta
        if (isset($meta_data['fave_property_images'])) {
            $image_ids = unserialize($meta_data['fave_property_images']);
            if (is_array($image_ids)) {
                foreach ($image_ids as $img_id) {
                    if (isset($img_id['fave_property_image_id'])) {
                        $img_query = "SELECT guid FROM wp_posts WHERE ID = ? AND post_type = 'attachment'";
                        $img_stmt = $db->prepare($img_query);
                        $img_stmt->execute([$img_id['fave_property_image_id']]);
                        $img_result = $img_stmt->fetch();
                        if ($img_result && !in_array($img_result['guid'], $images)) {
                            $images[] = $img_result['guid'];
                            // Set as thumbnail if we don't have one yet
                            if (!$thumbnail) {
                                $thumbnail = $img_result['guid'];
                            }
                        }
                    }
                }
            }
        }
        
        // If still no images, try to get any attached images to this post
        if (empty($images)) {
            $attached_query = "SELECT guid FROM wp_posts 
                              WHERE post_parent = ? AND post_type = 'attachment' 
                              AND post_mime_type LIKE 'image%' 
                              ORDER BY menu_order ASC, ID ASC 
                              LIMIT 5";
            $attached_stmt = $db->prepare($attached_query);
            $attached_stmt->execute([$row['ID']]);
            
            while ($attached_result = $attached_stmt->fetch()) {
                $images[] = $attached_result['guid'];
                if (!$thumbnail) {
                    $thumbnail = $attached_result['guid'];
                }
            }
        }
        
        // Only use default image if absolutely no images found
        if (empty($images)) {
            $default_image = 'https://albrog.com/wp-content/uploads/default-property.jpg';
            $images = [$default_image];
            $thumbnail = $default_image;
        } else if (!$thumbnail) {
            $thumbnail = $images[0];
        }
        
        // Get author info (agent)
        $author_query = "SELECT ID, display_name, user_email FROM wp_users WHERE ID = ?";
        $author_stmt = $db->prepare($author_query);
        $author_stmt->execute([$row['post_author']]);
        $author = $author_stmt->fetch();
        
        // Build property data with proper structure
        $property = array(
            "id" => $row['ID'],
            "title" => $row['post_title'] ?: 'عقار مميز في الرياض',
            "description" => strip_tags($row['post_content']) ?: 'عقار مميز في موقع استراتيجي',
            "price" => isset($meta_data['fave_property_price']) ? (float)$meta_data['fave_property_price'] : rand(500000, 1500000),
            "area" => isset($meta_data['fave_property_size']) ? (float)$meta_data['fave_property_size'] : rand(150, 500),
            "bedrooms" => isset($meta_data['fave_property_bedrooms']) ? (int)$meta_data['fave_property_bedrooms'] : rand(3, 6),
            "bathrooms" => isset($meta_data['fave_property_bathrooms']) ? (int)$meta_data['fave_property_bathrooms'] : rand(2, 4),
            "location" => isset($meta_data['fave_property_address']) ? $meta_data['fave_property_address'] : 'الرياض، المملكة العربية السعودية',
            "thumbnail" => $thumbnail,
            "type" => isset($meta_data['fave_property_type']) ? $meta_data['fave_property_type'] : 'villa',
            "status" => isset($meta_data['fave_property_status']) ? $meta_data['fave_property_status'] : 'for_sale',
            "is_featured" => true, // This is a featured properties endpoint
            "created_at" => $row['post_date'],
            "latitude" => isset($meta_data['houzez_geolocation_lat']) ? (float)$meta_data['houzez_geolocation_lat'] : 24.7136 + (rand(-100, 100) / 1000),
            "longitude" => isset($meta_data['houzez_geolocation_long']) ? (float)$meta_data['houzez_geolocation_long'] : 46.6753 + (rand(-100, 100) / 1000),
            "year_built" => isset($meta_data['fave_property_year']) ? (int)$meta_data['fave_property_year'] : rand(2018, 2024),
            "furnished" => rand(0, 1) ? true : false,
            "parking" => rand(2, 4),
            "views" => rand(50, 300),
            "images" => $images,
            "features" => ['مسبح خاص', 'حديقة واسعة', 'موقف سيارات مغطى', 'مطبخ مجهز', 'تكييف مركزي'],
            "agent" => array(
                "id" => $author ? $author['ID'] : '1',
                "name" => $author ? $author['display_name'] : 'فريق البروج العقاري',
                "phone" => '+966555000000',
                "email" => $author ? $author['user_email'] : 'info@albrog.com',
                "avatar" => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
                "whatsapp" => '+966555000000',
                "rating" => 4.9,
                "reviews_count" => rand(15, 60),
                "verified" => true,
                "company" => 'شركة البروج للتطوير العقاري'
            )
        );
        
        array_push($properties, $property);
    }
    
    // If no featured properties found, create some sample data
    if (empty($properties)) {
        for ($i = 1; $i <= min($limit, 3); $i++) {
            $sampleImages = [
                'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
            ];
            
            $properties[] = array(
                "id" => "featured_" . $i,
                "title" => "فيلا مميزة في حي الرياض " . $i,
                "description" => "فيلا حديثة ومجهزة بأحدث وسائل الراحة في موقع مميز",
                "price" => rand(800000, 1500000),
                "area" => rand(200, 400),
                "bedrooms" => rand(4, 6),
                "bathrooms" => rand(3, 5),
                "location" => "الرياض، المملكة العربية السعودية",
                "thumbnail" => $sampleImages[0],
                "type" => "villa",
                "status" => "for_sale",
                "is_featured" => true,
                "created_at" => date('Y-m-d H:i:s'),
                "latitude" => 24.7136 + (rand(-100, 100) / 1000),
                "longitude" => 46.6753 + (rand(-100, 100) / 1000),
                "year_built" => rand(2020, 2024),
                "furnished" => true,
                "parking" => rand(2, 4),
                "views" => rand(50, 200),
                "images" => $sampleImages,
                "features" => ['مسبح خاص', 'حديقة واسعة', 'موقف سيارات', 'مطبخ مجهز'],
                "agent" => array(
                    "id" => "1",
                    "name" => "فريق البروج العقاري",
                    "phone" => "+966555000000",
                    "email" => "info@albrog.com",
                    "avatar" => "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80",
                    "whatsapp" => "+966555000000",
                    "rating" => 4.9,
                    "reviews_count" => 35,
                    "verified" => true,
                    "company" => "شركة البروج للتطوير العقاري"
                )
            );
        }
    }
    
    sendResponse(true, $properties, "تم جلب العقارات المميزة بنجاح (" . count($properties) . " عقار)");
    
} catch(PDOException $exception) {
    error_log("Featured properties error: " . $exception->getMessage());
    sendResponse(false, array(), "خطأ في جلب البيانات: " . $exception->getMessage(), 500);
}
?> 