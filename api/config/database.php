<?php
// Database configuration for albrog.com
class Database {
    // Database credentials - Updated for production server
    private $host = "localhost"; // Database host  
    private $db_name = "u738639298_dZk8J"; // Database name from backup file
    private $username = "u738639298_EaRh3"; // Database username from wp-config.php
    private $password = "iIXeSTqe9q"; // Database password from wp-config.php
    private $charset = "utf8mb4";
    
    public $conn;
    
    // Get database connection
    public function getConnection() {
        $this->conn = null;
        
        try {
            $dsn = "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=" . $this->charset;
            $this->conn = new PDO($dsn, $this->username, $this->password);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
            
            // ✅ ضبط المنطقة الزمنية لقاعدة البيانات
            $this->conn->exec("SET time_zone = '+03:00'");
        } catch(PDOException $exception) {
            error_log("Connection error: " . $exception->getMessage());
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "خطأ في الاتصال بقاعدة البيانات"
            ));
            exit();
        }
        
        return $this->conn;
    }
}

// CORS headers for Flutter app
function setCorsHeaders() {
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
    
    // Handle preflight OPTIONS request
    if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}

// Common response function
function sendResponse($success, $data = null, $message = "", $code = 200) {
    http_response_code($code);
    echo json_encode(array(
        "success" => $success,
        "data" => $data,
        "message" => $message,
        "timestamp" => date('Y-m-d H:i:s')
    ));
    exit();
}
?> 