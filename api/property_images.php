<?php
// Property Images API - Enhanced image handling
require_once 'config/database.php';

setCorsHeaders();

// Initialize database connection
$database = new Database();
$db = $database->getConnection();

// Get property ID
$property_id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

if ($property_id <= 0) {
    sendResponse(false, null, "معرف العقار مطلوب", 400);
    exit();
}

try {
    $images = array();
    $thumbnail = null;
    
    // 1. Get Featured Image (WordPress thumbnail)
    $thumbnail_query = "SELECT pm.meta_value as attachment_id 
                       FROM wp_postmeta pm 
                       WHERE pm.post_id = ? AND pm.meta_key = '_thumbnail_id'";
    $thumbnail_stmt = $db->prepare($thumbnail_query);
    $thumbnail_stmt->execute([$property_id]);
    $thumbnail_result = $thumbnail_stmt->fetch();
    
    if ($thumbnail_result && $thumbnail_result['attachment_id']) {
        $img_meta_query = "SELECT 
            p.guid as url,
            pm.meta_value as sizes_data
        FROM wp_posts p
        LEFT JOIN wp_postmeta pm ON p.ID = pm.post_id AND pm.meta_key = '_wp_attachment_metadata'
        WHERE p.ID = ? AND p.post_type = 'attachment'";
        
        $img_stmt = $db->prepare($img_meta_query);
        $img_stmt->execute([$thumbnail_result['attachment_id']]);
        $img_result = $img_stmt->fetch();
        
        if ($img_result) {
            $image_data = array(
                'id' => $thumbnail_result['attachment_id'],
                'url' => $img_result['url'],
                'is_thumbnail' => true,
                'type' => 'featured'
            );
            
            // Add different sizes if available
            if ($img_result['sizes_data']) {
                $metadata = unserialize($img_result['sizes_data']);
                if (is_array($metadata) && isset($metadata['sizes'])) {
                    $image_data['sizes'] = array();
                    $base_url = dirname($img_result['url']) . '/';
                    
                    foreach ($metadata['sizes'] as $size_name => $size_data) {
                        $image_data['sizes'][$size_name] = $base_url . $size_data['file'];
                    }
                }
            }
            
            $images[] = $image_data;
            $thumbnail = $image_data['url'];
        }
    }
    
    // 2. Get Property Gallery Images (Houzez specific)
    $meta_query = "SELECT meta_value FROM wp_postmeta WHERE post_id = ? AND meta_key = 'fave_property_images'";
    $meta_stmt = $db->prepare($meta_query);
    $meta_stmt->execute([$property_id]);
    $meta_result = $meta_stmt->fetch();
    
    if ($meta_result && $meta_result['meta_value']) {
        $image_ids = unserialize($meta_result['meta_value']);
        if (is_array($image_ids)) {
            foreach ($image_ids as $img_data) {
                if (isset($img_data['fave_property_image_id'])) {
                    $img_id = $img_data['fave_property_image_id'];
                    
                    $img_query = "SELECT 
                        p.guid as url,
                        p.post_title as title,
                        p.post_excerpt as caption,
                        pm.meta_value as sizes_data
                    FROM wp_posts p
                    LEFT JOIN wp_postmeta pm ON p.ID = pm.post_id AND pm.meta_key = '_wp_attachment_metadata'
                    WHERE p.ID = ? AND p.post_type = 'attachment'";
                    
                    $img_stmt = $db->prepare($img_query);
                    $img_stmt->execute([$img_id]);
                    $img_result = $img_stmt->fetch();
                    
                    if ($img_result) {
                        // Skip if already added as thumbnail
                        $already_exists = false;
                        foreach ($images as $existing_img) {
                            if ($existing_img['id'] == $img_id) {
                                $already_exists = true;
                                break;
                            }
                        }
                        
                        if (!$already_exists) {
                            $image_data = array(
                                'id' => $img_id,
                                'url' => $img_result['url'],
                                'title' => $img_result['title'],
                                'caption' => $img_result['caption'],
                                'is_thumbnail' => false,
                                'type' => 'gallery'
                            );
                            
                            // Add different sizes if available
                            if ($img_result['sizes_data']) {
                                $metadata = unserialize($img_result['sizes_data']);
                                if (is_array($metadata) && isset($metadata['sizes'])) {
                                    $image_data['sizes'] = array();
                                    $base_url = dirname($img_result['url']) . '/';
                                    
                                    foreach ($metadata['sizes'] as $size_name => $size_data) {
                                        $image_data['sizes'][$size_name] = $base_url . $size_data['file'];
                                    }
                                }
                            }
                            
                            $images[] = $image_data;
                            
                            // Set as thumbnail if we don't have one yet
                            if (!$thumbnail) {
                                $thumbnail = $image_data['url'];
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 3. Get any other attached images
    if (count($images) < 5) {
        $attached_query = "SELECT 
            p.ID,
            p.guid as url,
            p.post_title as title,
            p.post_excerpt as caption
        FROM wp_posts p
        WHERE p.post_parent = ? 
        AND p.post_type = 'attachment' 
        AND p.post_mime_type LIKE 'image%'
        ORDER BY p.menu_order ASC, p.ID ASC 
        LIMIT 10";
        
        $attached_stmt = $db->prepare($attached_query);
        $attached_stmt->execute([$property_id]);
        
        while ($attached_result = $attached_stmt->fetch()) {
            // Skip if already added
            $already_exists = false;
            foreach ($images as $existing_img) {
                if ($existing_img['id'] == $attached_result['ID']) {
                    $already_exists = true;
                    break;
                }
            }
            
            if (!$already_exists) {
                $images[] = array(
                    'id' => $attached_result['ID'],
                    'url' => $attached_result['url'],
                    'title' => $attached_result['title'],
                    'caption' => $attached_result['caption'],
                    'is_thumbnail' => false,
                    'type' => 'attachment'
                );
                
                if (!$thumbnail) {
                    $thumbnail = $attached_result['url'];
                }
            }
        }
    }
    
    // 4. Add default image if no images found
    if (empty($images)) {
        $default_images = array(
            array(
                'id' => 'default_1',
                'url' => 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                'title' => 'صورة افتراضية للعقار',
                'caption' => '',
                'is_thumbnail' => true,
                'type' => 'default'
            ),
            array(
                'id' => 'default_2',
                'url' => 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                'title' => 'منظر داخلي للعقار',
                'caption' => '',
                'is_thumbnail' => false,
                'type' => 'default'
            )
        );
        
        $images = $default_images;
        $thumbnail = $default_images[0]['url'];
    }
    
    $response_data = array(
        'property_id' => $property_id,
        'thumbnail' => $thumbnail,
        'images' => $images,
        'total_images' => count($images)
    );
    
    sendResponse(true, $response_data, "تم جلب الصور بنجاح");
    
} catch(PDOException $exception) {
    error_log("Get property images error: " . $exception->getMessage());
    sendResponse(false, null, "خطأ في جلب صور العقار", 500);
}
?> 