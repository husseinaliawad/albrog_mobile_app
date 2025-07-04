<?php
// Simple Property Images API for testing
require_once 'config/database.php';

setCorsHeaders();

try {
    // Initialize database connection
    $database = new Database();
    $db = $database->getConnection();
    
    // Get property ID
    $property_id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    
    if ($property_id <= 0) {
        sendResponse(false, null, "معرف العقار مطلوب", 400);
    }
    
    // Test basic property data first
    $query = "SELECT 
        p.ID,
        p.post_title,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = '_thumbnail_id' LIMIT 1) as thumbnail_id
    FROM wp_posts p 
    WHERE p.ID = ? AND p.post_type = 'property' AND p.post_status = 'publish'";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$property_id]);
    $property = $stmt->fetch();
    
    if (!$property) {
        sendResponse(false, null, "العقار غير موجود", 404);
    }
    
    $images = array();
    $thumbnail = null;
    
    // Get thumbnail image if exists
    if ($property['thumbnail_id']) {
        $img_query = "SELECT guid FROM wp_posts WHERE ID = ? AND post_type = 'attachment'";
        $img_stmt = $db->prepare($img_query);
        $img_stmt->execute([$property['thumbnail_id']]);
        $img_result = $img_stmt->fetch();
        
        if ($img_result) {
            $images[] = array(
                'id' => $property['thumbnail_id'],
                'url' => $img_result['guid'],
                'is_thumbnail' => true,
                'type' => 'featured'
            );
            $thumbnail = $img_result['guid'];
        }
    }
    
    // Get property gallery images (simplified)
    $gallery_query = "SELECT meta_value FROM wp_postmeta WHERE post_id = ? AND meta_key = 'fave_property_images'";
    $gallery_stmt = $db->prepare($gallery_query);
    $gallery_stmt->execute([$property_id]);
    $gallery_result = $gallery_stmt->fetch();
    
    if ($gallery_result && $gallery_result['meta_value']) {
        // Try to unserialize the data
        $gallery_data = @unserialize($gallery_result['meta_value']);
        if (is_array($gallery_data)) {
            foreach ($gallery_data as $img_data) {
                if (isset($img_data['fave_property_image_id'])) {
                    $img_id = $img_data['fave_property_image_id'];
                    
                    $img_query = "SELECT guid FROM wp_posts WHERE ID = ? AND post_type = 'attachment'";
                    $img_stmt = $db->prepare($img_query);
                    $img_stmt->execute([$img_id]);
                    $img_result = $img_stmt->fetch();
                    
                    if ($img_result) {
                        $images[] = array(
                            'id' => $img_id,
                            'url' => $img_result['guid'],
                            'is_thumbnail' => false,
                            'type' => 'gallery'
                        );
                        
                        if (!$thumbnail) {
                            $thumbnail = $img_result['guid'];
                        }
                    }
                }
            }
        }
    }
    
    // Add default image if no images found
    if (empty($images)) {
        $default_image = array(
            'id' => 'default',
            'url' => 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
            'is_thumbnail' => true,
            'type' => 'default'
        );
        $images[] = $default_image;
        $thumbnail = $default_image['url'];
    }
    
    $response_data = array(
        'property_id' => $property_id,
        'property_title' => $property['post_title'],
        'thumbnail' => $thumbnail,
        'images' => $images,
        'total_images' => count($images)
    );
    
    sendResponse(true, $response_data, "تم جلب الصور بنجاح");
    
} catch(Exception $e) {
    error_log("Property images error: " . $e->getMessage());
    sendResponse(false, null, "خطأ في جلب صور العقار: " . $e->getMessage(), 500);
}
?> 