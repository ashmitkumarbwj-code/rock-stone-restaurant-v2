<?php
/**
 * ROCK & STONE RESTAURANT 2.0 — BACKEND CONFIGURATION
 * 100% Pure Vegetarian Restaurant
 * Location: V.P.O. Tatal, Nurpur, Kangra, HP 176205
 */

header('Content-Type: application/json; charset=utf-8');

// Verified Restaurant Master Credentials
define('RESTAURANT_NAME', 'Rock & Stone Restaurant');
define('RESTAURANT_PHONE', '+91 76781 29577');
define('RESTAURANT_EMAIL', 'ashmitkumarbwj@gmail.com');
define('RESTAURANT_FSSAI', '10925004000220');
define('RESTAURANT_GSTIN', '02DKLPP2797H1ZR');
define('RESTAURANT_ADDRESS', 'V.P.O. Tatal, Near Indian Oil Petrol Pump, P/O Khel, Tehsil Nurpur, Kangra, HP 176205');

// Authoritative Pricing Rules
define('GST_PERCENT', 5.0);
define('PACKAGING_FEE', 25.0);
define('DELIVERY_FEE', 40.0);
define('MIN_DELIVERY_ORDER', 200.0);

// Authoritative Pure Vegetarian Master Dish Prices (Never trust browser submitted price)
$AUTHORITATIVE_DISHES = [
    'veg-01' => ['name' => 'Kangra Madra (Himachali Speciality)', 'price' => 280.00, 'is_pure_veg' => true],
    'veg-02' => ['name' => 'Clay Tandoor Paneer Tikka', 'price' => 320.00, 'is_pure_veg' => true],
    'veg-03' => ['name' => 'Dal Dhauladhar (Signature Dal Makhani)', 'price' => 260.00, 'is_pure_veg' => true],
    'veg-04' => ['name' => 'Sepu Vadi in Spinach Gravy', 'price' => 290.00, 'is_pure_veg' => true],
    'veg-05' => ['name' => 'Paneer Butter Masala', 'price' => 310.00, 'is_pure_veg' => true],
    'veg-06' => ['name' => 'Kashmiri Dum Aloo', 'price' => 240.00, 'is_pure_veg' => true],
    'veg-07' => ['name' => 'Butter Naan / Tandoori Roti Basket', 'price' => 140.00, 'is_pure_veg' => true],
    'veg-08' => ['name' => 'Himalayan Herbal Masala Chai', 'price' => 60.00, 'is_pure_veg' => true]
];

// Database Connection Helper (Supports Supabase PostgreSQL PDO or Local SQLite/MariaDB fallback)
function getDbConnection() {
    static $pdo = null;
    if ($pdo !== null) return $pdo;

    $host = getenv('SUPABASE_DB_HOST') ?: '127.0.0.1';
    $port = getenv('SUPABASE_DB_PORT') ?: '5432';
    $dbname = getenv('SUPABASE_DB_NAME') ?: 'postgres';
    $user = getenv('SUPABASE_DB_USER') ?: 'postgres';
    $pass = getenv('SUPABASE_DB_PASS') ?: '';

    try {
        $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]);
        return $pdo;
    } catch (PDOException $e) {
        // Fallback to local storage or file data when live Supabase credentials are not yet injected
        return null;
    }
}

function sendJsonResponse($status, $data = [], $message = '') {
    echo json_encode([
        'success' => $status,
        'message' => $message,
        'data' => $data,
        'timestamp' => date('c')
    ]);
    exit;
}
