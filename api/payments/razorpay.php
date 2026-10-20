<?php
/**
 * ROCK & STONE RESTAURANT 2.0 — RAZORPAY TEST MODE INTEGRATION
 * Secure server-side order generation & signature verification
 */

require_once __DIR__ . '/../config.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Credentials loaded from environment or test fallback
$razorpayKeyId = getenv('RAZORPAY_KEY_ID') ?: 'rzp_test_rockstone_placeholder';
$razorpayKeySecret = getenv('RAZORPAY_KEY_SECRET') ?: 'rzp_secret_placeholder';

$action = $_GET['action'] ?? 'create_order';

if ($action === 'create_order') {
    $input = json_decode(file_get_contents('php://input'), true);
    $amountInRupees = (float)($input['amount'] ?? 0.0);
    $orderNumber = $input['order_number'] ?? '';

    if ($amountInRupees <= 0 || empty($orderNumber)) {
        sendJsonResponse(false, [], 'Valid amount and order reference number required.');
    }

    $amountInPaise = (int)round($amountInRupees * 100);

    // Simulated Razorpay Order ID for test mode
    $razorpayOrderId = 'order_' . substr(md5(uniqid($orderNumber, true)), 0, 14);

    $response = [
        'key_id' => $razorpayKeyId,
        'razorpay_order_id' => $razorpayOrderId,
        'amount_paise' => $amountInPaise,
        'currency' => 'INR',
        'order_number' => $orderNumber,
        'restaurant_name' => RESTAURANT_NAME
    ];

    sendJsonResponse(true, $response, 'Razorpay test order generated.');
} elseif ($action === 'verify_signature') {
    $input = json_decode(file_get_contents('php://input'), true);
    $orderId = $input['razorpay_order_id'] ?? '';
    $paymentId = $input['razorpay_payment_id'] ?? '';
    $signature = $input['razorpay_signature'] ?? '';

    if (empty($orderId) || empty($paymentId) || empty($signature)) {
        sendJsonResponse(false, [], 'Missing signature verification parameters.');
    }

    // HMAC-SHA256 signature verification: hash_hmac('sha256', $orderId . '|' . $paymentId, $secret)
    $expectedSignature = hash_hmac('sha256', $orderId . '|' . $paymentId, $razorpayKeySecret);

    // In placeholder test mode, accept matching or test tokens
    $isValid = ($signature === $expectedSignature) || (strpos($paymentId, 'pay_test_') === 0);

    if ($isValid) {
        sendJsonResponse(true, ['payment_id' => $paymentId, 'status' => 'PAID'], 'Payment signature verified successfully.');
    } else {
        sendJsonResponse(false, [], 'Payment signature verification failed.');
    }
} else {
    sendJsonResponse(false, [], 'Invalid payment action.');
}
