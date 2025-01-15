<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_connection.php';

$start_date = isset($_GET['start_date']) ? $_GET['start_date'] : '';
$end_date = isset($_GET['end_date']) ? $_GET['end_date'] : '';
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$items_per_page = isset($_GET['items_per_page']) ? (int)$_GET['items_per_page'] : 10;
$offset = ($page - 1) * $items_per_page;

$sql = "SELECT * FROM jual WHERE 1=1";

if ($start_date != '') {
    $sql .= " AND tanggal_penjualan >= '$start_date'";
}

if ($end_date != '') {
    $sql .= " AND tanggal_penjualan <= '$end_date'";
}

// Count total records
$count_sql = "SELECT COUNT(*) as total FROM ($sql) as total_records";
$count_result = $conn->query($count_sql);
$total_records = $count_result->fetch_assoc()['total'];
$total_pages = ceil($total_records / $items_per_page);

// Add LIMIT clause for pagination
$sql .= " LIMIT $items_per_page OFFSET $offset";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $sales = [];

    while ($row = $result->fetch_assoc()) {
        $sales[] = $row;
    }

    echo json_encode(['sales' => $sales, 'total_pages' => $total_pages]);
} else {
    echo json_encode(['sales' => [], 'total_pages' => 1]);
}

$conn->close();
?>
