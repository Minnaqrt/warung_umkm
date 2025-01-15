<?php
$servername = "5lm8k.h.filess.io";
$username = "warung_hourrecall";
$password = "663fe1047c284170a828277a1d579f8672980470";
$dbname = "warung_hourrecall";
$port = "3307";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname, $port);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Koneksi gagal: ' . $conn->connect_error]));
}

?>