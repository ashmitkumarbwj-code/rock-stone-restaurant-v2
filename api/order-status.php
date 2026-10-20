<?php
/**
 * ROCK & STONE RESTAURANT 2.0 — ORDER STATUS TRANSITION CONTROLLER
 */

require_once __DIR__ . '/config.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Valid Order Transitions Graph
$VALID_TRANSITIONS = [
    'PENDING'   => ['ACCEPTED', 'REJECTED', 'CANCELLED'],
    'ACCEPTED'  => ['PREPARING', 'CANCELLED'],
    'PREPARING' => ['READY', 'CANCELLED'],
    'READY'     => ['ON_THE_WAY', 'COMPLETED'],
    'ON_THE_WAY'=> ['COMPLETED'],
    'COMPLETED' => [], // Terminal state
    'REJECTED'  => [], // Terminal state
    'CANCELLED' => []  // Terminal state
];

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $orderNumber = trim($input['order_number'] ?? '');
    $currentStatus = strtoupper(trim($input['current_status'] ?? ''));
    $targetStatus = strtoupper(trim($input['target_status'] ?? ''));
    $actorRole = trim($input['actor_role'] ?? 'kitchen_staff');

    if (empty($orderNumber) || empty($targetStatus)) {
        sendJsonResponse(false, [], 'Order number and target status are required.');
    }

    if (!isset($VALID_TRANSITIONS[$currentStatus])) {
        sendJsonResponse(false, [], "Current status [$currentStatus] is invalid.");
    }

    if (!in_array($targetStatus, $VALID_TRANSITIONS[$currentStatus])) {
        sendJsonResponse(false, [], "Illegal transition: Cannot change status from [$currentStatus] to [$targetStatus].");
    }

    // In a live database, execute update in transaction & write to order_status_history
    $historyRecord = [
        'order_number' => $orderNumber,
        'old_status' => $currentStatus,
        'new_status' => $targetStatus,
        'changed_by_role' => $actorRole,
        'changed_at' => date('c')
    ];

    sendJsonResponse(true, $historyRecord, "Order status transitioned successfully to [$targetStatus].");
} else {
    // GET status check
    $orderNumber = trim($_GET['order_number'] ?? '');
    if (empty($orderNumber)) {
        sendJsonResponse(false, [], 'Order number is required.');
    }
    // Return sample lookup
    sendJsonResponse(true, ['order_number' => $orderNumber, 'status' => 'PREPARING'], 'Order lookup successful.');
}
