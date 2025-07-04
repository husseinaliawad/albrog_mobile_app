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

// ✅ Include database configuration
require_once __DIR__ . '/config/database.php';

// ✅ Helper function to check if string is serialized PHP data
function is_serialized_php($data) {
    return (is_string($data) && preg_match('/^(a|o|s):[0-9]+:.*[;}]/s', $data));
}

// ✅ Helper function to send JSON response
function sendResponse($success, $data = null, $message = "", $code = 200) {
    http_response_code($code);
    echo json_encode([
        "success" => $success,
        "data" => $data,
        "message" => $message,
        "timestamp" => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

try {
    // ✅ Get user ID from request
    $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
    $offset = isset($_GET['offset']) ? intval($_GET['offset']) : 0;
    
    if ($user_id <= 0) {
        sendResponse(false, null, "❌ معرف المستخدم مطلوب", 400);
    }

    // ✅ Initialize database connection
    $database = new Database();
    $db = $database->getConnection();

    // ✅ Main query to get user's properties with all metadata
    $stmt = $db->prepare("
    SELECT
        p.ID AS property_id,
        p.post_title AS property_title,
        p.post_content AS property_description,
        p.post_date AS property_created_at,
        p.post_status AS property_status,

        -- Property Meta
        MAX(CASE WHEN pm_price.meta_key = 'fave_property_price' THEN pm_price.meta_value END) AS price,
        MAX(CASE WHEN pm_area.meta_key = 'fave_property_area' THEN pm_area.meta_value END) AS area,
        MAX(CASE WHEN pm_bedrooms.meta_key = 'fave_property_bedrooms' THEN pm_bedrooms.meta_value END) AS bedrooms,
        MAX(CASE WHEN pm_bathrooms.meta_key = 'fave_property_bathrooms' THEN pm_bathrooms.meta_value END) AS bathrooms,
        MAX(CASE WHEN pm_location_str.meta_key = 'fave_property_location' THEN pm_location_str.meta_value END) AS location,
        MAX(CASE WHEN pm_thumbnail.meta_key = '_thumbnail_id' THEN pm_thumbnail_url_post_data.guid END) AS thumbnail_url,
        MAX(CASE WHEN pm_images.meta_key = 'project_images' THEN pm_images.meta_value END) AS project_images,
        MAX(CASE WHEN pm_type.meta_key = 'fave_property_type' THEN pm_type.meta_value END) AS property_type,
        MAX(CASE WHEN pm_completion.meta_key = 'progress_bar' THEN pm_completion.meta_value END) AS completion,
        MAX(CASE WHEN pm_lat.meta_key = 'houzez_geolocation_lat' THEN pm_lat.meta_value END) AS latitude,
        MAX(CASE WHEN pm_long.meta_key = 'houzez_geolocation_long' THEN pm_long.meta_value END) AS longitude,
        MAX(CASE WHEN pm_is_featured.meta_key = 'fave_featured' THEN pm_is_featured.meta_value END) AS is_featured,
        MAX(CASE WHEN pm_delivery_date.meta_key = 'delivery_date' THEN pm_delivery_date.meta_value END) AS delivery_date,
        MAX(CASE WHEN pm_notes.meta_key = 'fave_property_notes' THEN pm_notes.meta_value END) AS notes,
        MAX(CASE WHEN pm_updates.meta_key = 'fave_property_updates' THEN pm_updates.meta_value END) AS updates,
        
        -- ✅ حقول الفيديو الصحيحة
        MAX(CASE WHEN pm_firstvideo.meta_key = 'firstvideo' THEN pm_firstvideo.meta_value END) AS firstvideo,
        MAX(CASE WHEN pm_secondvideo.meta_key = 'secondvideo' THEN pm_secondvideo.meta_value END) AS secondvideo,
        MAX(CASE WHEN pm_thirdvideo.meta_key = 'thirdvideo' THEN pm_thirdvideo.meta_value END) AS thirdvideo,
        MAX(CASE WHEN pm_fourthvideo.meta_key = 'fourthvideo' THEN pm_fourthvideo.meta_value END) AS fourthvideo,
        MAX(CASE WHEN pm_video_file.meta_key = 'video_file' THEN pm_video_file.meta_value END) AS video_file,
        MAX(CASE WHEN pm_video_url.meta_key = 'video_url' THEN pm_video_url.meta_value END) AS video_url,

        -- Agent Details
        pa.ID AS agent_id,
        pa.post_title AS agent_name,
        MAX(CASE WHEN pam_phone.meta_key = 'fave_agent_phone' THEN pam_phone.meta_value END) AS agent_phone,
        MAX(CASE WHEN pam_email.meta_key = 'fave_agent_email' THEN pam_email.meta_value END) AS agent_email,
        MAX(CASE WHEN pam_whatsapp.meta_key = 'fave_agent_whatsapp' THEN pam_whatsapp.meta_value END) AS agent_whatsapp,
        MAX(CASE WHEN pam_avatar.meta_key = 'fave_agent_avatar' THEN pam_avatar.meta_value END) AS agent_avatar
    FROM
        wp_posts p
    LEFT JOIN wp_postmeta pm_price ON p.ID = pm_price.post_id AND pm_price.meta_key = 'fave_property_price'
    LEFT JOIN wp_postmeta pm_area ON p.ID = pm_area.post_id AND pm_area.meta_key = 'fave_property_area'
    LEFT JOIN wp_postmeta pm_bedrooms ON p.ID = pm_bedrooms.post_id AND pm_bedrooms.meta_key = 'fave_property_bedrooms'
    LEFT JOIN wp_postmeta pm_bathrooms ON p.ID = pm_bathrooms.post_id AND pm_bathrooms.meta_key = 'fave_property_bathrooms'
    LEFT JOIN wp_postmeta pm_location_str ON p.ID = pm_location_str.post_id AND pm_location_str.meta_key = 'fave_property_location'
    LEFT JOIN wp_postmeta pm_thumbnail ON p.ID = pm_thumbnail.post_id AND pm_thumbnail.meta_key = '_thumbnail_id'
    LEFT JOIN wp_posts pm_thumbnail_url_post_data ON pm_thumbnail.meta_value = pm_thumbnail_url_post_data.ID AND pm_thumbnail_url_post_data.post_type = 'attachment'
    LEFT JOIN wp_postmeta pm_images ON p.ID = pm_images.post_id AND pm_images.meta_key = 'project_images'
    LEFT JOIN wp_postmeta pm_type ON p.ID = pm_type.post_id AND pm_type.meta_key = 'fave_property_type'
    LEFT JOIN wp_postmeta pm_completion ON p.ID = pm_completion.post_id AND pm_completion.meta_key = 'progress_bar'
    LEFT JOIN wp_postmeta pm_lat ON p.ID = pm_lat.post_id AND pm_lat.meta_key = 'houzez_geolocation_lat'
    LEFT JOIN wp_postmeta pm_long ON p.ID = pm_long.post_id AND pm_long.meta_key = 'houzez_geolocation_long'
    LEFT JOIN wp_postmeta pm_is_featured ON p.ID = pm_is_featured.post_id AND pm_is_featured.meta_key = 'fave_featured'
    LEFT JOIN wp_postmeta pm_delivery_date ON p.ID = pm_delivery_date.post_id AND pm_delivery_date.meta_key = 'delivery_date'
    LEFT JOIN wp_postmeta pm_notes ON p.ID = pm_notes.post_id AND pm_notes.meta_key = 'fave_property_notes'
    LEFT JOIN wp_postmeta pm_updates ON p.ID = pm_updates.post_id AND pm_updates.meta_key = 'fave_property_updates'
    
    -- ✅ LEFT JOIN للفيديوهات الصحيحة
    LEFT JOIN wp_postmeta pm_firstvideo ON p.ID = pm_firstvideo.post_id AND pm_firstvideo.meta_key = 'firstvideo'
    LEFT JOIN wp_postmeta pm_secondvideo ON p.ID = pm_secondvideo.post_id AND pm_secondvideo.meta_key = 'secondvideo'
    LEFT JOIN wp_postmeta pm_thirdvideo ON p.ID = pm_thirdvideo.post_id AND pm_thirdvideo.meta_key = 'thirdvideo'
    LEFT JOIN wp_postmeta pm_fourthvideo ON p.ID = pm_fourthvideo.post_id AND pm_fourthvideo.meta_key = 'fourthvideo'
    LEFT JOIN wp_postmeta pm_video_file ON p.ID = pm_video_file.post_id AND pm_video_file.meta_key = 'video_file'
    LEFT JOIN wp_postmeta pm_video_url ON p.ID = pm_video_url.post_id AND pm_video_url.meta_key = 'video_url'
    
    LEFT JOIN wp_postmeta pm_owner ON p.ID = pm_owner.post_id AND pm_owner.meta_key = 'property_owner'
    LEFT JOIN wp_posts pa ON pm_owner.meta_value = pa.ID AND pa.post_type = 'houzez_agent'
    LEFT JOIN wp_postmeta pam_phone ON pa.ID = pam_phone.post_id AND pam_phone.meta_key = 'fave_agent_phone'
    LEFT JOIN wp_postmeta pam_email ON pa.ID = pam_email.post_id AND pam_email.meta_key = 'fave_agent_email'
    LEFT JOIN wp_postmeta pam_whatsapp ON pa.ID = pam_whatsapp.post_id AND pam_whatsapp.meta_key = 'fave_agent_whatsapp'
    LEFT JOIN wp_postmeta pam_avatar ON pa.ID = pam_avatar.post_id AND pam_avatar.meta_key = 'fave_agent_avatar'
    WHERE
        p.post_type = 'property'
        AND p.post_status = 'publish'
        AND p.post_author = :user_id
    GROUP BY
        p.ID, pa.ID
    ORDER BY p.post_date DESC
    LIMIT :limit OFFSET :offset;
");

    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();

    $properties_raw = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $properties = [];
    $default_image_url = 'https://albrog.com/wp-content/uploads/2025/default-property.jpg';

    foreach ($properties_raw as $row) {
        // معالجة project_images
        $project_images_urls = [];
        if (!empty($row['project_images']) && is_serialized_php($row['project_images'])) {
            $image_ids_serialized = unserialize($row['project_images']);
            if (is_array($image_ids_serialized)) {
                foreach ($image_ids_serialized as $id) {
                    $url = get_attachment_url_from_guid($id, $db);
                    if ($url) {
                        $project_images_urls[] = $url;
                    }
                }
            }
        }

        // إضافة الصورة المصغرة (thumbnail) إلى قائمة الصور
        if (!empty($row['thumbnail_url']) && !in_array($row['thumbnail_url'], $project_images_urls)) {
            array_unshift($project_images_urls, $row['thumbnail_url']);
        }
        
        // إذا لم توجد أي صور، استخدم الصورة الافتراضية
        if (empty($project_images_urls)) {
            $project_images_urls[] = $default_image_url;
        }

        // ✅ معالجة الفيديوهات من جميع الحقول الممكنة
        $videos = [];
        $video_fields = ['firstvideo', 'secondvideo', 'thirdvideo', 'fourthvideo', 'video_file', 'video_url'];
        
        foreach ($video_fields as $field) {
            if (!empty($row[$field]) && filter_var($row[$field], FILTER_VALIDATE_URL)) {
                $videos[] = $row[$field];
            }
        }

        // معالجة is_featured كـ boolean
        $is_featured_bool = (isset($row['is_featured']) && $row['is_featured'] == '1');

        $properties[] = [
            "id" => (int)$row['property_id'],
            "title" => $row['property_title'],
            "description" => $row['property_description'] ?? '',
            "price" => isset($row['price']) ? floatval($row['price']) : null,
            "area" => isset($row['area']) ? floatval($row['area']) : 0.0,
            "bedrooms" => isset($row['bedrooms']) ? intval($row['bedrooms']) : 0,
            "bathrooms" => isset($row['bathrooms']) ? intval($row['bathrooms']) : 0,
            "location" => $row['location'] ?? '',
            "thumbnail" => $row['thumbnail_url'] ?? $default_image_url,
            "images" => $project_images_urls,
            "type" => $row['property_type'] ?? 'apartment',
            "status" => $row['property_status'] ?? 'for_sale',
            "is_featured" => $is_featured_bool,
            "created_at" => $row['property_created_at'],
            "latitude" => isset($row['latitude']) ? floatval($row['latitude']) : 0.0,
            "longitude" => isset($row['longitude']) ? floatval($row['longitude']) : 0.0,
            "completion" => isset($row['completion']) ? floatval($row['completion']) / 100 : 0.0, // تحويل إلى نسبة مئوية
            "delivery_date" => $row['delivery_date'] ?? null,
            "notes" => (!empty($row['notes']) && is_serialized_php($row['notes'])) ? unserialize($row['notes']) : [],
            "videos" => $videos, // ⭐ الفيديوهات ستظهر الآن!
            "updates" => (!empty($row['updates']) && is_serialized_php($row['updates'])) ? unserialize($row['updates']) : [],
            "agent" => [
                "id" => $row['agent_id'] ? (int)$row['agent_id'] : 0,
                "name" => $row['agent_name'] ?? 'غير معروف',
                "phone" => $row['agent_phone'] ?? '',
                "email" => $row['agent_email'] ?? '',
                "whatsapp" => $row['agent_whatsapp'] ?? '',
                "avatar" => $row['agent_avatar'] ?? null,
            ],
        ];
    }

    // ✅ Send response
    if (empty($properties)) {
        sendResponse(true, [], "لا توجد عقارات مرتبطة بحسابك حالياً");
    } else {
        sendResponse(true, $properties, "تم جلب عقاراتك بنجاح (" . count($properties) . " عقار)");
    }
    
} catch (PDOException $e) {
    error_log("My Properties Database Error: " . $e->getMessage());
    sendResponse(false, null, "❌ خطأ في قاعدة البيانات: " . $e->getMessage(), 500);
} catch (Exception $e) {
    error_log("My Properties Error: " . $e->getMessage());
    sendResponse(false, null, "❌ حدث خطأ غير متوقع: " . $e->getMessage(), 500);
}
?> 