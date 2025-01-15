<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

$connection = new mysqli("localhost", "root", "", "warung");

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

// Ambil parameter pagination
$page = isset($_GET['page']) ? intval($_GET['page']) : 1;
$items_per_page = isset($_GET['items_per_page']) ? intval($_GET['items_per_page']) : 10;
$offset = ($page - 1) * $items_per_page;

$response = array();

// Hitung total data
$sql_total = "SELECT COUNT(*) as total_count FROM jual";
$result_total = $connection->query($sql_total);
$total_count = $result_total->fetch_assoc()['total_count'];
$total_pages = ceil($total_count / $items_per_page);

// Ambil data dengan pagination
$sql_jual = "SELECT id, tanggal_penjualan, total_harga, biaya_pengiriman, total_bayar, username_pembeli, jumlah_produk 
             FROM jual LIMIT $offset, $items_per_page";
$result_jual = $connection->query($sql_jual);

$sales = array();

if ($result_jual->num_rows > 0) {
    while ($row = $result_jual->fetch_assoc()) {
        if (!isset($row['jumlah_produk']) || $row['jumlah_produk'] === null) {
            $row['jumlah_produk'] = 0;
        }
        $sales[] = $row;
    }
} else {
    $response['jual_error'] = "No sales data found";
    error_log("No sales data found in the 'jual' table.");
}

// Tambahkan data sales dan total halaman ke response
$response['sales'] = $sales;
$response['total_pages'] = $total_pages;

$connection->close();

// Kembalikan response dalam format JSON
echo json_encode($response);
?>
