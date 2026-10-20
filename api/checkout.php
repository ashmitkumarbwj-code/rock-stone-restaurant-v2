<?php
/**
 * ROCK & STONE RESTAURANT 2.0 — AUTHORITATIVE SERVER CHECKOUT
 * Strictly 100% Pure Vegetarian Restaurant
 */

require_once __DIR__ . '/config.php';

// Allow CORS for preview URL
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Idempotency-Key');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(false, [], 'Only POST requests allowed.');
}

// Read raw JSON input
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    sendJsonResponse(false, [], 'Invalid JSON payload.');
}

// 1. Validate Customer Info
$customerName = trim($input['customer_name'] ?? '');
$customerPhone = trim($input['customer_phone'] ?? '');
$orderType = strtoupper(trim($input['order_type'] ?? 'DINE_IN'));
$paymentMethod = strtoupper(trim($input['payment_method'] ?? 'CASH'));
$tableNumber = trim($input['table_number'] ?? '');
$deliveryAddress = trim($input['delivery_address'] ?? '');
$specialInstructions = trim($input['special_instructions'] ?? '');
$idempotencyKey = trim($input['idempotency_key'] ?? '');
$rawItems = $input['items'] ?? [];

if (empty($customerName) || empty($customerPhone)) {
    sendJsonResponse(false, [], 'Customer name and valid phone number are required.');
}

if (!in_array($orderType, ['DINE_IN', 'TAKEAWAY', 'DELIVERY'])) {
    sendJsonResponse(false, [], 'Invalid order type specified.');
}

if ($orderType === 'DELIVERY' && empty($deliveryAddress)) {
    sendJsonResponse(false, [], 'Delivery address is mandatory for delivery orders.');
}

if (empty($rawItems) || !is_array($rawItems)) {
    sendJsonResponse(false, [], 'Order cart cannot be empty.');
}

// 2. Authoritative Price Recalculation (Never trust browser prices)
$validatedItems = [];
$authoritativeSubtotal = 0.0;

foreach ($rawItems as $item) {
    $dishId = $item['id'] ?? $item['menu_item_id'] ?? '';
    $qty = (int)($item['quantity'] ?? 1);

    if ($qty <= 0) continue;

    if (!isset($AUTHORITATIVE_DISHES[$dishId])) {
        sendJsonResponse(false, [], "Menu item [$dishId] is not found or not approved.");
    }

    $dishMeta = $AUTHORITATIVE_DISHES[$dishId];
    if (empty($dishMeta['is_pure_veg'])) {
        sendJsonResponse(false, [], "Dishes must strictly be 100% Pure Vegetarian.");
    }

    $unitPrice = (float)$dishMeta['price'];
    $lineTotal = round($unitPrice * $qty, 2);
    $authoritativeSubtotal += $lineTotal;

    $validatedItems[] = [
        'menu_item_id' => $dishId,
        'item_name_snapshot' => $dishMeta['name'],
        'unit_price_snapshot' => $unitPrice,
        'quantity' => $qty,
        'line_total' => $lineTotal
    ];
}

if (empty($validatedItems)) {
    sendJsonResponse(false, [], 'No valid items found in order.');
}

// 3. Compute Charges & Total
$taxAmount = round($authoritativeSubtotal * (GST_PERCENT / 100.0), 2);
$packagingFee = ($orderType === 'TAKEAWAY' || $orderType === 'DELIVERY') ? PACKAGING_FEE : 0.0;
$deliveryFee = ($orderType === 'DELIVERY') ? DELIVERY_FEE : 0.0;
$totalAmount = round($authoritativeSubtotal + $taxAmount + $packagingFee + $deliveryFee, 2);

// 4. Generate Unique Order Number
$datePart = date('Ymd');
$randomSuffix = rand(1000, 9999);
$orderNumber = "RS-{$datePart}-{$randomSuffix}";

$utrNumber = trim($input['utr_number'] ?? '');

$orderPayload = [
    'order_number' => $orderNumber,
    'idempotency_key' => $idempotencyKey ?: uniqid('idem_', true),
    'order_type' => $orderType,
    'order_status' => 'PENDING',
    'payment_status' => 'PENDING', // STRICTLY PENDING until manual or bank verification
    'payment_method' => $paymentMethod === 'SBI_UPI_QR' ? 'SBI_UPI_QR' : 'CASH',
    'utr_number' => $utrNumber ?: null,
    'merchant_name' => 'ROCK AND STONE RESTRAUNT',
    'sbi_tid' => 'SB797564',
    'sbi_mid' => '022211900799141',
    'subtotal' => $authoritativeSubtotal,
    'tax_amount' => $taxAmount,
    'packaging_fee' => $packagingFee,
    'delivery_fee' => $deliveryFee,
    'total_amount' => $totalAmount,
    'customer_name' => $customerName,
    'customer_phone' => $customerPhone,
    'table_number' => $tableNumber,
    'delivery_address' => $deliveryAddress,
    'special_instructions' => $specialInstructions,
    'items' => $validatedItems,
    'created_at' => date('c')
];

// Return verified authoritative response
sendJsonResponse(true, $orderPayload, 'Order calculated and verified authoritatively.');
