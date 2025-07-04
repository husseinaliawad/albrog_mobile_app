<?php
// Test APIs - Quick Testing File
require_once 'config/database.php';

// Test database connection
try {
    $database = new Database();
    $db = $database->getConnection();
    echo "✅ Database connection successful\n\n";
} catch (Exception $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n\n";
    exit();
}

// Test if tables exist
$tables_to_check = ['wp_posts', 'wp_postmeta', 'wp_users'];
foreach ($tables_to_check as $table) {
    try {
        $stmt = $db->query("SELECT COUNT(*) FROM $table LIMIT 1");
        echo "✅ Table $table exists\n";
    } catch (Exception $e) {
        echo "❌ Table $table not found: " . $e->getMessage() . "\n";
    }
}

echo "\n";

// Test property data
try {
    $query = "SELECT COUNT(*) as count FROM wp_posts WHERE post_type = 'property' AND post_status = 'publish'";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->fetch();
    
    if ($result && $result['count'] > 0) {
        echo "✅ Found {$result['count']} properties in database\n";
    } else {
        echo "⚠️  No properties found in database\n";
    }
} catch (Exception $e) {
    echo "❌ Error checking properties: " . $e->getMessage() . "\n";
}

// Test first property with meta
try {
    $query = "SELECT ID, post_title FROM wp_posts WHERE post_type = 'property' AND post_status = 'publish' LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $property = $stmt->fetch();
    
    if ($property) {
        echo "✅ Sample property: {$property['post_title']} (ID: {$property['ID']})\n";
        
        // Check meta data
        $meta_query = "SELECT COUNT(*) as count FROM wp_postmeta WHERE post_id = ?";
        $meta_stmt = $db->prepare($meta_query);
        $meta_stmt->execute([$property['ID']]);
        $meta_result = $meta_stmt->fetch();
        
        echo "✅ Property has {$meta_result['count']} meta fields\n";
        
        // Check specific meta fields
        $important_meta = [
            'fave_property_price' => 'Price',
            'fave_property_size' => 'Size',
            'fave_property_bedrooms' => 'Bedrooms',
            'fave_property_bathrooms' => 'Bathrooms',
            'fave_property_address' => 'Address',
            'fave_property_type' => 'Type'
        ];
        
        foreach ($important_meta as $meta_key => $description) {
            $check_query = "SELECT meta_value FROM wp_postmeta WHERE post_id = ? AND meta_key = ?";
            $check_stmt = $db->prepare($check_query);
            $check_stmt->execute([$property['ID'], $meta_key]);
            $check_result = $check_stmt->fetch();
            
            if ($check_result) {
                echo "  ✅ $description: {$check_result['meta_value']}\n";
            } else {
                echo "  ⚠️  $description: Not found\n";
            }
        }
    }
} catch (Exception $e) {
    echo "❌ Error testing property data: " . $e->getMessage() . "\n";
}

echo "\n";

// Test APIs (if running via web server)
if (isset($_SERVER['HTTP_HOST'])) {
    echo "<h2>API Tests (Web Mode)</h2>\n";
    echo "<p>✅ APIs ready for testing:</p>\n";
    echo "<ul>\n";
    echo "<li><a href='featured.php?limit=5'>Featured Properties API</a></li>\n";
    echo "<li><a href='recent.php?limit=5'>Recent Properties API</a></li>\n";
    echo "<li><a href='advanced_search.php?keyword=villa&limit=5'>Advanced Search API</a></li>\n";
    echo "<li><a href='property_images.php?id=1'>Property Images API</a></li>\n";
    echo "<li><a href='popular_areas.php'>Popular Areas API</a></li>\n";
    echo "<li><a href='property_types.php'>Property Types API</a></li>\n";
    echo "</ul>\n";
} else {
    echo "💡 To test APIs via web browser, access this file through a web server.\n";
    echo "Example: http://your-domain.com/api/test_apis.php\n";
}

echo "\n🎯 All tests completed!\n";
?> 