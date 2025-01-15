<?php
include 'db_connection.php';

// Tes koneksi
if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}
echo "Koneksi berhasil";
?>
