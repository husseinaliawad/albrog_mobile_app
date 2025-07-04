<?php
// Advanced Search API - Enhanced search with filters
require_once 'config/database.php';

setCorsHeaders();

// Initialize database connection
$database = new Database();
$db = $database->getConnection();

// Get parameters
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$offset = ($page - 1) * $limit;

// Search filters
$keyword = isset($_GET['keyword']) ? trim($_GET['keyword']) : '';
$type = isset($_GET['type']) ? $_GET['type'] : '';
$status = isset($_GET['status']) ? $_GET['status'] : '';
$min_price = isset($_GET['min_price']) ? (float)$_GET['min_price'] : 0;
$max_price = isset($_GET['max_price']) ? (float)$_GET['max_price'] : 0;
$min_bedrooms = isset($_GET['min_bedrooms']) ? (int)$_GET['min_bedrooms'] : 0;
$max_bedrooms = isset($_GET['max_bedrooms']) ? (int)$_GET['max_bedrooms'] : 0;
$min_bathrooms = isset($_GET['min_bathrooms']) ? (int)$_GET['min_bathrooms'] : 0;
$max_bathrooms = isset($_GET['max_bathrooms']) ? (int)$_GET['max_bathrooms'] : 0;
$min_area = isset($_GET['min_area']) ? (float)$_GET['min_area'] : 0;
$max_area = isset($_GET['max_area']) ? (float)$_GET['max_area'] : 0;
$city = isset($_GET['city']) ? $_GET['city'] : '';
$district = isset($_GET['district']) ? $_GET['district'] : '';
$furnished = isset($_GET['furnished']) ? $_GET['furnished'] : '';
$parking = isset($_GET['parking']) ? (int)$_GET['parking'] : 0;
$features = isset($_GET['features']) ? explode(',', $_GET['features']) : [];
$sort_by = isset($_GET['sort_by']) ? $_GET['sort_by'] : 'date_desc';

try {
    // Build the main query
    $query = "SELECT DISTINCT
        p.ID,
        p.post_title,
        p.post_content,
        p.post_date,
        p.post_author,
        p.post_status,
        
        -- Get price
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_property_price' LIMIT 1) as price,
        
        -- Get area
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_property_size' LIMIT 1) as area,
        
        -- Get bedrooms
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_property_bedrooms' LIMIT 1) as bedrooms,
        
        -- Get bathrooms
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_property_bathrooms' LIMIT 1) as bathrooms,
        
        -- Get location
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_property_address' LIMIT 1) as location,
        
        -- Get type
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_property_type' LIMIT 1) as type,
        
        -- Get status
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_property_status' LIMIT 1) as status,
        
        -- Get featured
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_featured' LIMIT 1) as is_featured,
        
        -- Get coordinates
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'houzez_geolocation_lat' LIMIT 1) as latitude,
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'houzez_geolocation_long' LIMIT 1) as longitude,
        
        -- Get year built
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_property_year' LIMIT 1) as year_built,
        
        -- Get parking
        (SELECT meta_value FROM wp_postmeta WHERE post_id = p.ID AND meta_key = 'fave_property_garage' LIMIT 1) as property_parking
        
    FROM wp_posts p
    WHERE p.post_type = 'property'
    AND p.post_status = 'publish'";
    
    $params = array();
    
    // Add keyword search
    if (!empty($keyword)) {
        $query .= " AND (p.post_title LIKE ? OR p.post_content LIKE ?)";
        $params[] = "%$keyword%";
        $params[] = "%$keyword%";
    }
    
    // Add filters using HAVING clause (since we're using subqueries)
    $having_conditions = array();
    
    if (!empty($type)) {
        $having_conditions[] = "type = ?";
        $params[] = $type;
    }
    
    if (!empty($status)) {
        $having_conditions[] = "status = ?";
        $params[] = $status;
    }
    
    if ($min_price > 0) {
        $having_conditions[] = "CAST(price AS DECIMAL) >= ?";
        $params[] = $min_price;
    }
    
    if ($max_price > 0) {
        $having_conditions[] = "CAST(price AS DECIMAL) <= ?";
        $params[] = $max_price;
    }
    
    if ($min_bedrooms > 0) {
        $having_conditions[] = "CAST(bedrooms AS SIGNED) >= ?";
        $params[] = $min_bedrooms;
    }
    
    if ($max_bedrooms > 0) {
        $having_conditions[] = "CAST(bedrooms AS SIGNED) <= ?";
        $params[] = $max_bedrooms;
    }
    
    if ($min_bathrooms > 0) {
        $having_conditions[] = "CAST(bathrooms AS SIGNED) >= ?";
        $params[] = $min_bathrooms;
    }
    
    if ($max_bathrooms > 0) {
        $having_conditions[] = "CAST(bathrooms AS SIGNED) <= ?";
        $params[] = $max_bathrooms;
    }
    
    if ($min_area > 0) {
        $having_conditions[] = "CAST(area AS DECIMAL) >= ?";
        $params[] = $min_area;
    }
    
    if ($max_area > 0) {
        $having_conditions[] = "CAST(area AS DECIMAL) <= ?";
        $params[] = $max_area;
    }
    
    if (!empty($city)) {
        $having_conditions[] = "location LIKE ?";
        $params[] = "%$city%";
    }
    
    if (!empty($district)) {
        $having_conditions[] = "location LIKE ?";
        $params[] = "%$district%";
    }
    
    if (!empty($furnished)) {
        $having_conditions[] = "property_parking IS NOT NULL";
    }
    
    if ($parking > 0) {
        $having_conditions[] = "CAST(property_parking AS SIGNED) >= ?";
        $params[] = $parking;
    }
    
    // Add HAVING clause if we have conditions
    if (!empty($having_conditions)) {
        $query .= " HAVING " . implode(' AND ', $having_conditions);
    }
    
    // Add sorting
    switch ($sort_by) {
        case 'price_asc':
            $query .= " ORDER BY CAST(price AS DECIMAL) ASC";
            break;
        case 'price_desc':
            $query .= " ORDER BY CAST(price AS DECIMAL) DESC";
            break;
        case 'area_asc':
            $query .= " ORDER BY CAST(area AS DECIMAL) ASC";
            break;
        case 'area_desc':
            $query .= " ORDER BY CAST(area AS DECIMAL) DESC";
            break;
        case 'date_asc':
            $query .= " ORDER BY p.post_date ASC";
            break;
        case 'featured':
            $query .= " ORDER BY is_featured DESC, p.post_date DESC";
            break;
        case 'alphabetical':
            $query .= " ORDER BY p.post_title ASC";
            break;
        default: // date_desc
            $query .= " ORDER BY p.post_date DESC";
            break;
    }
    
    $query .= " LIMIT ? OFFSET ?";
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $db->prepare($query);
    $stmt->execute($params);
    
    $properties = array();
    
    while ($row = $stmt->fetch()) {
        // Get thumbnail image
        $thumbnail = null;
        $images = array();
        
        // Get featured image
        $thumbnail_query = "SELECT pm.meta_value as attachment_id 
                           FROM wp_postmeta pm 
                           WHERE pm.post_id = ? AND pm.meta_key = '_thumbnail_id'";
        $thumbnail_stmt = $db->prepare($thumbnail_query);
        $thumbnail_stmt->execute([$row['ID']]);
        $thumbnail_result = $thumbnail_stmt->fetch();
        
        if ($thumbnail_result && $thumbnail_result['attachment_id']) {
            $img_query = "SELECT guid FROM wp_posts WHERE ID = ? AND post_type = 'attachment'";
            $img_stmt = $db->prepare($img_query);
            $img_stmt->execute([$thumbnail_result['attachment_id']]);
            $img_result = $img_stmt->fetch();
            if ($img_result) {
                $thumbnail = $img_result['guid'];
                $images[] = $img_result['guid'];
            }
        }
        
        // Get gallery images
        $gallery_query = "SELECT meta_value FROM wp_postmeta WHERE post_id = ? AND meta_key = 'fave_property_images'";
        $gallery_stmt = $db->prepare($gallery_query);
        $gallery_stmt->execute([$row['ID']]);
        $gallery_result = $gallery_stmt->fetch();
        
        if ($gallery_result && $gallery_result['meta_value']) {
            $image_ids = unserialize($gallery_result['meta_value']);
            if (is_array($image_ids)) {
                foreach ($image_ids as $img_id) {
                    if (isset($img_id['fave_property_image_id'])) {
                        $img_query = "SELECT guid FROM wp_posts WHERE ID = ? AND post_type = 'attachment'";
                        $img_stmt = $db->prepare($img_query);
                        $img_stmt->execute([$img_id['fave_property_image_id']]);
                        $img_result = $img_stmt->fetch();
                        if ($img_result && !in_array($img_result['guid'], $images)) {
                            $images[] = $img_result['guid'];
                            if (!$thumbnail) {
                                $thumbnail = $img_result['guid'];
                            }
                        }
                    }
                }
            }
        }
        
        // Default image if none found
        if (!$thumbnail) {
            $thumbnail = 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
            $images = [$thumbnail];
        }
        
        // Get author info
        $author_query = "SELECT ID, display_name, user_email FROM wp_users WHERE ID = ?";
        $author_stmt = $db->prepare($author_query);
        $author_stmt->execute([$row['post_author']]);
        $author = $author_stmt->fetch();
        
        // Get property features
        $features_array = array();
        $features_query = "SELECT meta_value FROM wp_postmeta WHERE post_id = ? AND meta_key = 'fave_property_features'";
        $features_stmt = $db->prepare($features_query);
        $features_stmt->execute([$row['ID']]);
        $features_result = $features_stmt->fetch();
        
        if ($features_result && $features_result['meta_value']) {
            $features_data = unserialize($features_result['meta_value']);
            if (is_array($features_data)) {
                $features_array = $features_data;
            }
        }
        
        $property = array(
            "id" => $row['ID'],
            "title" => $row['post_title'] ?: 'عقار مميز',
            "description" => strip_tags($row['post_content']) ?: 'عقار مميز في موقع استراتيجي',
            "price" => $row['price'] ? (float)$row['price'] : 0,
            "area" => $row['area'] ? (float)$row['area'] : 0,
            "bedrooms" => $row['bedrooms'] ? (int)$row['bedrooms'] : 0,
            "bathrooms" => $row['bathrooms'] ? (int)$row['bathrooms'] : 0,
            "location" => $row['location'] ?: 'المملكة العربية السعودية',
            "thumbnail" => $thumbnail,
            "images" => $images,
            "type" => $row['type'] ?: 'apartment',
            "status" => $row['status'] ?: 'for_sale',
            "is_featured" => $row['is_featured'] == '1',
            "created_at" => $row['post_date'],
            "latitude" => $row['latitude'] ? (float)$row['latitude'] : 0,
            "longitude" => $row['longitude'] ? (float)$row['longitude'] : 0,
            "year_built" => $row['year_built'] ? (int)$row['year_built'] : null,
            "furnished" => $row['property_parking'] ? true : false,
            "parking" => $row['property_parking'] ? (int)$row['property_parking'] : 0,
            "views" => rand(50, 300),
            "features" => $features_array,
            "amenities" => array(),
            "agent" => array(
                "id" => $author ? $author['ID'] : '1',
                "name" => $author ? $author['display_name'] : 'فريق شركة البروج',
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
        
        $properties[] = $property;
    }
    
    // Get total count for pagination (using the same query but without LIMIT)
    $count_query = str_replace("SELECT DISTINCT", "SELECT COUNT(DISTINCT", $query);
    $count_query = preg_replace('/ORDER BY.*/', '', $count_query);
    $count_query = preg_replace('/LIMIT.*/', '', $count_query);
    $count_query = str_replace("COUNT(DISTINCT\n        p.ID,", "COUNT(DISTINCT p.ID)", $count_query);
    $count_query = preg_replace('/,\s*--[^,]*/', '', $count_query); // Remove comments
    
    // Simplify count query
    $count_query = "SELECT COUNT(DISTINCT p.ID) as total
                   FROM wp_posts p
                   WHERE p.post_type = 'property'
                   AND p.post_status = 'publish'";
    
    $count_params = array();
    
    if (!empty($keyword)) {
        $count_query .= " AND (p.post_title LIKE ? OR p.post_content LIKE ?)";
        $count_params[] = "%$keyword%";
        $count_params[] = "%$keyword%";
    }
    
    $count_stmt = $db->prepare($count_query);
    $count_stmt->execute($count_params);
    $total_result = $count_stmt->fetch();
    $total_count = $total_result ? $total_result['total'] : count($properties);
    
    $response_data = array(
        "properties" => $properties,
        "pagination" => array(
            "current_page" => $page,
            "total_pages" => ceil($total_count / $limit),
            "total_count" => (int)$total_count,
            "per_page" => $limit
        ),
        "search_info" => array(
            "keyword" => $keyword,
            "filters_applied" => array(
                "type" => $type,
                "status" => $status,
                "price_range" => $min_price > 0 || $max_price > 0 ? array("min" => $min_price, "max" => $max_price) : null,
                "bedrooms_range" => $min_bedrooms > 0 || $max_bedrooms > 0 ? array("min" => $min_bedrooms, "max" => $max_bedrooms) : null,
                "bathrooms_range" => $min_bathrooms > 0 || $max_bathrooms > 0 ? array("min" => $min_bathrooms, "max" => $max_bathrooms) : null,
                "area_range" => $min_area > 0 || $max_area > 0 ? array("min" => $min_area, "max" => $max_area) : null,
                "location" => array("city" => $city, "district" => $district),
                "features" => $features
            ),
            "sort_by" => $sort_by
        )
    );
    
    sendResponse(true, $response_data, "تم البحث بنجاح - وجد $total_count عقار");
    
} catch(PDOException $exception) {
    error_log("Advanced search error: " . $exception->getMessage());
    sendResponse(false, null, "خطأ في البحث المتقدم", 500);
}
?> 