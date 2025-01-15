<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Hardcode admin credentials
$adminUsername = "admin";
$adminPassword = "admin123";

// Tambahkan ini untuk menampilkan kesalahan
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    if ($username === $adminUsername && $password === $adminPassword) {
        echo json_encode(array("status" => "success", "role" => "admin"));
    } else {
        echo json_encode(array("status" => "error", "message" => "Invalid username or password"));
    }
} else {
    echo json_encode(array("status" => "error", "message" => "Invalid request method"));
}
?>
