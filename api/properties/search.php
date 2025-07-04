<?php
// Search Properties API Endpoint
require_once '../config/database.php';

setCorsHeaders();

// Initialize database connection
$database = new Database();
$db = $database->getConnection();

// Get parameters
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$offset = ($page - 1) * $limit;

// Search filters
$type = isset($_GET['type']) ? $_GET['type'] : '';
$status = isset($_GET['status']) ? $_GET['status'] : '';
$min_price = isset($_GET['min_price']) ? (float)$_GET['min_price'] : 0;
$max_price = isset($_GET['max_price']) ? (float)$_GET['max_price'] : 0;
$bedrooms = isset($_GET['bedrooms']) ? (int)$_GET['bedrooms'] : 0;
$bathrooms = isset($_GET['bathrooms']) ? (int)$_GET['bathrooms'] : 0;
$city = isset($_GET['city']) ? $_GET['city'] : '';
$keyword = isset($_GET['keyword']) ? $_GET['keyword'] : '';

try {
    // Base query for properties
    $where_conditions = array("p.post_type = 'property'", "p.post_status = 'publish'");
    $having_conditions = array();
    
    // Add keyword search
    if (!empty($keyword)) {
        $where_conditions[] = "(p.post_title LIKE '%$keyword%' OR p.post_content LIKE '%$keyword%')";
    }
    
    // Build the main query
    $query = "SELECT 
        p.ID,
        p.post_title,
        p.post_content,
        p.post_date,
        p.post_author,
        p.post_status
    FROM wp_posts p";
    
    // Add joins for meta filtering
    if (!empty($type) || !empty($status) || $min_price > 0 || $max_price > 0 || $bedrooms > 0 || $bathrooms > 0 || !empty($city)) {
        $query .= " INNER JOIN wp_postmeta pm ON p.ID = pm.post_id";
    }
    
    $query .= " WHERE " . implode(' AND ', $where_conditions);
    
    // Add meta filters
    if (!empty($type)) {
        $query .= " AND p.ID IN (SELECT post_id FROM wp_postmeta WHERE meta_key = 'fave_property_type' AND meta_value = '$type')";
    }
    
    if (!empty($status)) {
        $query .= " AND p.ID IN (SELECT post_id FROM wp_postmeta WHERE meta_key = 'fave_property_status' AND meta_value = '$status')";
    }
    
    if ($min_price > 0) {
        $query .= " AND p.ID IN (SELECT post_id FROM wp_postmeta WHERE meta_key = 'fave_property_price' AND CAST(meta_value AS DECIMAL) >= $min_price)";
    }
    
    if ($max_price > 0) {
        $query .= " AND p.ID IN (SELECT post_id FROM wp_postmeta WHERE meta_key = 'fave_property_price' AND CAST(meta_value AS DECIMAL) <= $max_price)";
    }
    
    if ($bedrooms > 0) {
        $query .= " AND p.ID IN (SELECT post_id FROM wp_postmeta WHERE meta_key = 'fave_property_bedrooms' AND CAST(meta_value AS SIGNED) >= $bedrooms)";
    }
    
    if ($bathrooms > 0) {
        $query .= " AND p.ID IN (SELECT post_id FROM wp_postmeta WHERE meta_key = 'fave_property_bathrooms' AND CAST(meta_value AS SIGNED) >= $bathrooms)";
    }
    
    if (!empty($city)) {
        $query .= " AND p.ID IN (SELECT post_id FROM wp_postmeta WHERE meta_key = 'fave_property_address' AND meta_value LIKE '%$city%')";
    }
    
    $query .= " GROUP BY p.ID ORDER BY p.post_date DESC LIMIT $limit OFFSET $offset";
    
    $stmt = $db->prepare($query);
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
        
        $property = array(
            "id" => $row['ID'],
            "title" => $row['post_title'],
            "description" => $row['post_content'],
            "price" => isset($meta_data['fave_property_price']) ? (float)$meta_data['fave_property_price'] : 0,
            "area" => isset($meta_data['fave_property_size']) ? (float)$meta_data['fave_property_size'] : 0,
            "bedrooms" => isset($meta_data['fave_property_bedrooms']) ? (int)$meta_data['fave_property_bedrooms'] : 0,
            "bathrooms" => isset($meta_data['fave_property_bathrooms']) ? (int)$meta_data['fave_property_bathrooms'] : 0,
            "location" => isset($meta_data['fave_property_address']) ? $meta_data['fave_property_address'] : '',
            "type" => isset($meta_data['fave_property_type']) ? $meta_data['fave_property_type'] : '',
            "status" => isset($meta_data['fave_property_status']) ? $meta_data['fave_property_status'] : 'for_sale',
            "is_featured" => isset($meta_data['fave_featured']) && $meta_data['fave_featured'] == '1',
            "created_at" => $row['post_date'],
            "latitude" => isset($meta_data['houzez_geolocation_lat']) ? (float)$meta_data['houzez_geolocation_lat'] : 0,
            "longitude" => isset($meta_data['houzez_geolocation_long']) ? (float)$meta_data['houzez_geolocation_long'] : 0,
            "year_built" => isset($meta_data['fave_property_year']) ? (int)$meta_data['fave_property_year'] : null,
            "furnished" => isset($meta_data['fave_property_garage']) ? (bool)$meta_data['fave_property_garage'] : null,
            "parking" => isset($meta_data['fave_property_garage']) ? (int)$meta_data['fave_property_garage'] : null,
            "views" => 0,
            "images" => $images,
            "features" => array(),
            "agent" => array(
                "id" => $author ? $author['ID'] : '',
                "name" => $author ? $author['display_name'] : '',
                "phone" => '',
                "email" => $author ? $author['user_email'] : '',
                "avatar" => null,
                "whatsapp" => null,
                "rating" => null,
                "reviews_count" => 0,
                "verified" => false,
                "company" => 'شركة البروج للتطوير العقاري'
            )
        );
        
        array_push($properties, $property);
    }
    
    // Get total count for pagination
    $count_query = "SELECT COUNT(DISTINCT p.ID) as total FROM wp_posts p WHERE p.post_type = 'property' AND p.post_status = 'publish'";
    $count_stmt = $db->prepare($count_query);
    $count_stmt->execute();
    $total_result = $count_stmt->fetch();
    $total_count = $total_result ? $total_result['total'] : 0;
    
    $response_data = array(
        "properties" => $properties,
        "pagination" => array(
            "current_page" => $page,
            "total_pages" => ceil($total_count / $limit),
            "total_count" => (int)$total_count,
            "per_page" => $limit
        )
    );
    
    sendResponse(true, $response_data, "تم البحث بنجاح");
    
} catch(PDOException $exception) {
    error_log("Search properties error: " . $exception->getMessage());
    sendResponse(false, null, "خطأ في البحث", 500);
}
?> 