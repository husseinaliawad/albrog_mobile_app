<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// التعامل مع OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    // الحصول على رابط الصورة من المعامل
    $imageUrl = $_GET['url'] ?? '';
    
    if (empty($imageUrl)) {
        throw new Exception('Image URL is required');
    }
    
    // التحقق من أن الرابط من نفس الدومين
    $allowedDomains = ['albrog.com', 'www.albrog.com'];
    $urlParts = parse_url($imageUrl);
    
    if (!in_array($urlParts['host'], $allowedDomains)) {
        throw new Exception('Domain not allowed');
    }
    
    // تحميل الصورة
    $imageData = file_get_contents($imageUrl);
    
    if ($imageData === false) {
        throw new Exception('Failed to load image');
    }
    
    // إرسال الصورة مع CORS headers
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_buffer($finfo, $imageData);
    finfo_close($finfo);
    
    header('Content-Type: ' . $mimeType);
    header('Content-Length: ' . strlen($imageData));
    header('Access-Control-Allow-Origin: *');
    
    echo $imageData;
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}
?> 