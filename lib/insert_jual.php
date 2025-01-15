<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $tanggal_penjualan = $_POST['tanggal_penjualan'] ?? '';
    $total_harga = $_POST['total_harga'] ?? '';
    $biaya_pengiriman = $_POST['biaya_pengiriman'] ?? '';
    $total_bayar = $_POST['total_bayar'] ?? '';
    $username_pembeli = $_POST['username_pembeli'] ?? '';
    $jumlah_produk = $_POST['jumlah_produk'] ?? '';

    $stmt = $conn->prepare("INSERT INTO jual (tanggal_penjualan, total_harga, biaya_pengiriman, total_bayar, username_pembeli, jumlah_produk) VALUES (?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        error_log("Prepare statement failed: " . $conn->error);
        echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $conn->error]);
        exit;
    }

    $stmt->bind_param("ssssss", $tanggal_penjualan, $total_harga, $biaya_pengiriman, $total_bayar, $username_pembeli, $jumlah_produk);

    if ($stmt->execute()) {
        $id = $stmt->insert_id; // Get the last inserted ID
        error_log("Sale successfully added to database with ID: $id");
        echo json_encode(['status' => 'success', 'id' => $id]);
    } else {
        error_log("Error adding sale: " . $stmt->error);
        echo json_encode(['status' => 'error', 'message' => 'Error: ' . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
}
?>
