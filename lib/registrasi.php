<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Koneksi ke database
include 'db_connection.php';

// Tambahkan ini untuk menampilkan kesalahan
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Masukkan data konsumen baru ke dalam database
    $stmt = $conn->prepare("INSERT INTO konsumen (username, password) VALUES (?, ?)");
    $stmt->bind_param("ss", $username, $hashed_password);

    if ($stmt->execute()) {
        echo json_encode(array("status" => "success", "message" => "Konsumen berhasil ditambahkan"));
    } else {
        echo json_encode(array("status" => "error", "message" => "Gagal menambahkan konsumen"));
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(array("status" => "error", "message" => "Invalid request method"));
}
?>
