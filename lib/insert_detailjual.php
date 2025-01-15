<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $jual_id = $_POST['jual_id'] ?? '';
    $produk_id = $_POST['produk_id'] ?? '';
    $jumlah_produk = $_POST['jumlah_produk'] ?? '';
    $harga_produk = $_POST['harga_produk'] ?? '';
    $total_harga = $_POST['total_harga'] ?? '';
    $berat_paket = $_POST['berat_paket'] ?? '';
    $metode_pengiriman = $_POST['metode_pengiriman'] ?? '';
    $biaya_pengiriman = $_POST['biaya_pengiriman'] ?? '';
    $total_bayar = $_POST['total_bayar'] ?? '';
    $nama_produk = $_POST['nama_produk'] ?? '';

    // Debugging
    error_log("Received values - Jual ID: $jual_id, Produk ID: $produk_id, Jumlah Produk: $jumlah_produk, Harga Produk: $harga_produk, Total Harga: $total_harga, Berat Paket: $berat_paket, Metode Pengiriman: $metode_pengiriman, Biaya Pengiriman: $biaya_pengiriman, Total Bayar: $total_bayar, Nama Produk: $nama_produk");

    $stmt = $conn->prepare("INSERT INTO detailjual (jual_id, produk_id, jumlah_produk, harga_produk, total_harga, berat_paket, metode_pengiriman, biaya_pengiriman, total_bayar, nama_produk) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        error_log("Prepare statement failed: " . $conn->error);
        echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $conn->error]);
        exit;
    }

    $stmt->bind_param("iiiiiissis", $jual_id, $produk_id, $jumlah_produk, $harga_produk, $total_harga, $berat_paket, $metode_pengiriman, $biaya_pengiriman, $total_bayar, $nama_produk);

    if ($stmt->execute()) {
        error_log("Sale detail successfully added to database.");
        echo json_encode(['status' => 'success']);
    } else {
        error_log("Error adding sale detail: " . $stmt->error);
        echo json_encode(['status' => 'error', 'message' => 'Error: ' . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
}
?>
