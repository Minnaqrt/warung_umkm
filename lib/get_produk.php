<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$connection = new mysqli("localhost", "root", "", "warung");

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

$sql = "SELECT id, nama_produk, deskripsi, harga, image FROM produk"; // Perubahan di sini
$result = $connection->query($sql);

$produk = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        // Tidak perlu konversi base64, hanya perlu nama file
        $produk[] = $row;
    }
} else {
    echo "No products found";
    error_log("No products found in the 'produk' table.");
}

echo json_encode($produk);
error_log(print_r($produk, true));

$connection->close();
?>
