<?php
// Albrog Mobile App API
require_once 'config/database.php';

setCorsHeaders();

// API Documentation
$api_info = array(
    "name" => "Albrog Mobile App API",
    "version" => "1.0.0",
    "description" => "REST API for Albrog Real Estate Mobile Application",
    "base_url" => "https://albrog.com/api",
    "endpoints" => array(
        "properties" => array(
            "featured" => array(
                "url" => "/properties/featured",
                "method" => "GET",
                "description" => "Get featured properties",
                "parameters" => array(
                    "limit" => "Number of properties to return (default: 10)"
                )
            ),
            "recent" => array(
                "url" => "/properties/recent", 
                "method" => "GET",
                "description" => "Get recent properties",
                "parameters" => array(
                    "limit" => "Number of properties to return (default: 10)"
                )
            ),
            "search" => array(
                "url" => "/properties/search",
                "method" => "GET", 
                "description" => "Search properties with filters",
                "parameters" => array(
                    "limit" => "Number of properties to return (default: 20)",
                    "page" => "Page number for pagination (default: 1)",
                    "type" => "Property type filter",
                    "status" => "Property status filter", 
                    "min_price" => "Minimum price filter",
                    "max_price" => "Maximum price filter",
                    "bedrooms" => "Minimum bedrooms filter",
                    "bathrooms" => "Minimum bathrooms filter",
                    "city" => "City filter",
                    "keyword" => "Keyword search in title and description"
                )
            )
        )
    ),
    "response_format" => array(
        "success" => "boolean - Whether the request was successful",
        "data" => "object|array - The requested data",
        "message" => "string - Response message in Arabic",
        "timestamp" => "string - Response timestamp"
    ),
    "database_info" => array(
        "system" => "WordPress + Houzez Theme",
        "structure" => "Properties stored in wp_posts with meta data in wp_postmeta"
    )
);

// Test database connection
try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        $api_info["status"] = "API is running";
        $api_info["database_status"] = "Connected successfully";
        
        // Get some basic stats
        $stats_query = "SELECT 
            (SELECT COUNT(*) FROM wp_posts WHERE post_type = 'property' AND post_status = 'publish') as total_properties,
            (SELECT COUNT(*) FROM wp_posts WHERE post_type = 'property' AND post_status = 'publish' AND ID IN (SELECT post_id FROM wp_postmeta WHERE meta_key = 'fave_featured' AND meta_value = '1')) as featured_properties,
            (SELECT COUNT(*) FROM wp_users) as total_users";
        
        $stats_stmt = $db->prepare($stats_query);
        $stats_stmt->execute();
        $stats = $stats_stmt->fetch();
        
        if ($stats) {
            $api_info["statistics"] = array(
                "total_properties" => (int)$stats['total_properties'],
                "featured_properties" => (int)$stats['featured_properties'], 
                "total_users" => (int)$stats['total_users']
            );
        }
    }
} catch (Exception $e) {
    $api_info["status"] = "API Error";
    $api_info["database_status"] = "Connection failed";
    $api_info["error"] = $e->getMessage();
}

sendResponse(true, $api_info, "مرحباً بك في API تطبيق البروج العقاري");
?> 