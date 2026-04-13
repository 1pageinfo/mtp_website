<?php
/**
 * Enquiry form mailer — Metal Tubular Products
 * Handles POST from: contact-us.html main form + modal "Get A Quote" on all pages
 * Sends to: sales@metaltubular.com
 */

header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');

// Only allow POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed.']);
    exit;
}

// Sanitize all inputs
function sanitize($val) {
    return htmlspecialchars(strip_tags(trim($val ?? '')), ENT_QUOTES, 'UTF-8');
}

$name    = sanitize($_POST['name']    ?? '');
$email   = sanitize($_POST['email']   ?? '');
$company = sanitize($_POST['company'] ?? '');
$phone   = sanitize($_POST['phone']   ?? '');
$address = sanitize($_POST['address'] ?? '');
$message = sanitize($_POST['message'] ?? '');
$source  = sanitize($_POST['page_source'] ?? 'Website');

// Validate required fields
if ($name === '' || $email === '' || $message === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Name, email, and message are required.']);
    exit;
}

// Validate email
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Please enter a valid email address.']);
    exit;
}

// Compose email
$to      = 'sales@metaltubular.com';
$subject = 'New Enquiry from ' . $name . ' — Metal Tubular Products';

$body  = "New enquiry received from the website.\n";
$body .= str_repeat('-', 50) . "\n";
$body .= "Name    : " . $name    . "\n";
$body .= "Email   : " . $email   . "\n";
if ($company !== '') $body .= "Company : " . $company . "\n";
if ($phone   !== '') $body .= "Phone   : " . $phone   . "\n";
if ($address !== '') $body .= "Address : " . $address . "\n";
$body .= "Source  : " . $source  . "\n";
$body .= str_repeat('-', 50) . "\n";
$body .= "Message :\n" . $message . "\n";

$headers  = "From: Metal Tubular Products <no-reply@metaltubulars.com>\r\n";
$headers .= "Reply-To: " . $name . " <" . $email . ">\r\n";
$headers .= "MIME-Version: 1.0\r\n";
$headers .= "Content-Type: text/plain; charset=UTF-8\r\n";
$headers .= "X-Mailer: PHP/" . PHP_VERSION;

$sent = mail($to, $subject, $body, $headers);

if ($sent) {
    echo json_encode([
        'success' => true,
        'message' => 'Your enquiry has been sent successfully! We will get back to you shortly.'
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to send your message. Please try again or contact us at sales@metaltubular.com.'
    ]);
}
