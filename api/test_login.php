<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

echo "<h2>🧪 اختبار API تسجيل الدخول</h2>";

// ✅ اختبار الاتصال بقاعدة البيانات
echo "<h3>1. اختبار قاعدة البيانات:</h3>";
try {
    require_once __DIR__ . '/config/database.php';
    $database = new Database();
    $db = $database->getConnection();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    // عدد المستخدمين
    $stmt = $db->query("SELECT COUNT(*) as count FROM wp_users");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "👥 عدد المستخدمين: " . $result['count'] . "<br>";
    
} catch (Exception $e) {
    echo "❌ خطأ في قاعدة البيانات: " . $e->getMessage() . "<br>";
}

// ✅ اختبار ملف class-phpass.php
echo "<h3>2. اختبار ملف كلمات المرور:</h3>";
$phpass_path = __DIR__ . '/wp-includes/class-phpass.php';
if (file_exists($phpass_path)) {
    echo "✅ ملف class-phpass.php موجود<br>";
    require_once $phpass_path;
    
    $wp_hasher = new PasswordHash(8, true);
    echo "✅ تم إنشاء PasswordHash بنجاح<br>";
    
    // اختبار كلمة مرور
    $test_password = "test123";
    $test_hash = $wp_hasher->HashPassword($test_password);
    $check_result = $wp_hasher->CheckPassword($test_password, $test_hash);
    
    echo "🔐 اختبار تشفير كلمة المرور: " . ($check_result ? "✅ نجح" : "❌ فشل") . "<br>";
    
} else {
    echo "❌ ملف class-phpass.php غير موجود في: $phpass_path<br>";
}

// ✅ اختبار بيانات مستخدم حقيقي
echo "<h3>3. اختبار بيانات المستخدمين:</h3>";
try {
    $stmt = $db->prepare("SELECT ID, user_login, user_email, LEFT(user_pass, 10) as hash_preview FROM wp_users LIMIT 3");
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<table border='1' style='border-collapse: collapse;'>";
    echo "<tr><th>ID</th><th>اسم المستخدم</th><th>البريد</th><th>كلمة المرور (أول 10 أحرف)</th></tr>";
    
    foreach ($users as $user) {
        echo "<tr>";
        echo "<td>" . $user['ID'] . "</td>";
        echo "<td>" . $user['user_login'] . "</td>";
        echo "<td>" . $user['user_email'] . "</td>";
        echo "<td>" . $user['hash_preview'] . "...</td>";
        echo "</tr>";
    }
    echo "</table>";
    
} catch (Exception $e) {
    echo "❌ خطأ في جلب بيانات المستخدمين: " . $e->getMessage() . "<br>";
}

// ✅ عرض معلومات PHP
echo "<h3>4. معلومات PHP:</h3>";
echo "📋 إصدار PHP: " . PHP_VERSION . "<br>";
echo "📋 crypt() متاح: " . (function_exists('crypt') ? "✅ نعم" : "❌ لا") . "<br>";
echo "📋 CRYPT_BLOWFISH: " . (defined('CRYPT_BLOWFISH') ? CRYPT_BLOWFISH : "غير محدد") . "<br>";

?>

<style>
body { font-family: Arial, sans-serif; margin: 20px; }
table { margin: 10px 0; }
th, td { padding: 8px; text-align: left; }
h2, h3 { color: #333; }
</style> 