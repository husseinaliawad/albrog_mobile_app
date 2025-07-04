<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

// ✅ CORS Headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// ✅ Respond to preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ✅ JSON Response Header
header('Content-Type: application/json; charset=utf-8');

// ✅ اتصال قاعدة البيانات
require_once __DIR__ . '/config/database.php';
$database = new Database();
$db = $database->getConnection();

// ✅ استقبال البيانات JSON
$input = json_decode(file_get_contents("php://input"), true);

$email = isset($input['email']) ? trim($input['email']) : '';
$password = isset($input['password']) ? $input['password'] : '';

if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'يرجى إدخال البريد وكلمة المرور'
    ]);
    exit();
}

try {
    // ✅ جلب بيانات المستخدم من wp_users
    $stmt = $db->prepare("SELECT ID, user_login, user_pass, user_email, display_name FROM wp_users WHERE user_email = :email LIMIT 1");
    $stmt->bindParam(':email', $email, PDO::PARAM_STR);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'البريد الإلكتروني غير مسجل'
        ]);
        exit();
    }

    // ✅ تحميل مكتبة PasswordHash من WordPress
    $phpass_path = __DIR__ . '/wp-includes/class-phpass.php';
    if (!file_exists($phpass_path)) {
        error_log("❌ class-phpass.php not found at: $phpass_path");
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => '❌ خطأ في إعدادات الخادم'
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    require_once $phpass_path;
    $wp_hasher = new PasswordHash(8, true);

    // ✅ التحقق من كلمة المرور مع تشخيص مفصل
    error_log("🔐 Checking password for user: " . $user['user_email']);
    error_log("🔐 Stored hash: " . substr($user['user_pass'], 0, 10) . "...");
    error_log("🔐 Password length: " . strlen($password));
    
    $password_check = $wp_hasher->CheckPassword($password, $user['user_pass']);
    error_log("🔐 Password check result: " . ($password_check ? 'TRUE' : 'FALSE'));
    
    // ✅ اختبار طرق تشفير إضافية إذا فشلت الطريقة الأولى
    if (!$password_check) {
        // تجربة password_verify للحالات الحديثة
        $password_check = password_verify($password, $user['user_pass']);
        error_log("🔐 password_verify result: " . ($password_check ? 'TRUE' : 'FALSE'));
        
        // تجربة MD5 للحالات القديمة جداً (غير مستحسن ولكن للتوافق)
        if (!$password_check) {
            $md5_check = (md5($password) === $user['user_pass']);
            error_log("🔐 MD5 check result: " . ($md5_check ? 'TRUE' : 'FALSE'));
            $password_check = $md5_check;
        }
    }
    
    if (!$password_check) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => '❌ كلمة المرور غير صحيحة',
            'debug' => [
                'password_length' => strlen($password),
                'hash_format' => substr($user['user_pass'], 0, 3),
                'user_id' => $user['ID']
            ]
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // ✅ التحقق من الدور (اختياري)
    $role = null;
    $stmt2 = $db->prepare("SELECT meta_value FROM wp_usermeta WHERE user_id = :user_id AND meta_key = 'wp_capabilities' LIMIT 1");
    $stmt2->bindParam(':user_id', $user['ID'], PDO::PARAM_INT);
    $stmt2->execute();
    $meta = $stmt2->fetch(PDO::FETCH_ASSOC);

    if ($meta) {
        $caps = unserialize($meta['meta_value']);
        $roles = array_keys($caps);
        $role = $roles[0] ?? null; // أول دور رئيسي
    }

    // ✅ الرد النهائي
    echo json_encode([
        'success' => true,
        'message' => '✅ تم تسجيل الدخول بنجاح',
        'data' => [
            'id' => (int)$user['ID'],
            'name' => $user['display_name'],
            'email' => $user['user_email'],
            'username' => $user['user_login'],
            'role' => $role
        ]
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => '❌ خطأ في الخادم: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?> 