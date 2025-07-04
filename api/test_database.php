<?php
// Database connectivity test
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");

try {
    // Test basic API response
    $test_results = [
        'api_working' => true,
        'timestamp' => date('Y-m-d H:i:s'),
        'tests' => []
    ];

    // Test 1: File exists check
    $config_file = __DIR__ . '/config/database.php';
    $test_results['tests']['config_file_exists'] = file_exists($config_file);
    
    if (!file_exists($config_file)) {
        throw new Exception("Database config file not found");
    }

    // Test 2: Include database config
    require_once $config_file;
    $test_results['tests']['config_loaded'] = true;

    // Test 3: Database connection
    try {
        $database = new Database();
        $db = $database->getConnection();
        $test_results['tests']['database_connection'] = true;
        
        // Test 4: Query test
        $stmt = $db->prepare("SELECT COUNT(*) as count FROM wp_users LIMIT 1");
        $stmt->execute();
        $result = $stmt->fetch();
        $test_results['tests']['database_query'] = true;
        $test_results['user_count'] = $result['count'] ?? 0;
        
    } catch (Exception $e) {
        $test_results['tests']['database_connection'] = false;
        $test_results['database_error'] = $e->getMessage();
    }

    echo json_encode([
        'success' => true,
        'message' => 'Database test completed',
        'results' => $test_results
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Test failed: ' . $e->getMessage(),
        'error_details' => [
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ]
    ], JSON_UNESCAPED_UNICODE);
}
?> 