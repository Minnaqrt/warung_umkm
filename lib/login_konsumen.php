<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_connection.php';

// Tambahkan ini untuk menampilkan kesalahan
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    // Cek username dan password dari database untuk user biasa
    $stmt = $conn->prepare("SELECT password FROM konsumen WHERE username = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        $stmt->bind_result($hashed_password);
        $stmt->fetch();

        if (password_verify($password, $hashed_password)) {
            echo json_encode(array("status" => "success", "role" => "user"));
        } else {
            echo json_encode(array("status" => "error", "message" => "Password salah"));
        }
    } else {
        echo json_encode(array("status" => "error", "message" => "Username tidak ditemukan"));
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(array("status" => "error", "message" => "Invalid request method"));
}
?>
