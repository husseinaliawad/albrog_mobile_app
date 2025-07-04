<?php
// Test file to check API and database connectivity
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=utf-8");

echo json_encode([
    'success' => true,
    'message' => 'API connection working!',
    'timestamp' => date('Y-m-d H:i:s'),
    'server_info' => [
        'PHP_VERSION' => PHP_VERSION,
        'SERVER_NAME' => $_SERVER['SERVER_NAME'] ?? 'Unknown',
        'REQUEST_METHOD' => $_SERVER['REQUEST_METHOD'] ?? 'Unknown'
    ]
]);
?> 