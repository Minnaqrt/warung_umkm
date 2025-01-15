<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

$connection = new mysqli("localhost", "root", "", "warung");

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

$response = array();

$jual_id = isset($_GET['jual_id']) ? $_GET['jual_id'] : 0;
error_log("Received jual_id: " . $jual_id);

if ($jual_id > 0) {
    // Fetch records from the 'detailjual' table for the specified jual_id
    $sql_detailjual = "SELECT id, jual_id, produk_id, nama_produk, jumlah_produk, harga_produk, total_harga, berat_paket, metode_pengiriman, biaya_pengiriman, total_bayar FROM detailjual WHERE jual_id = ?";
    $stmt = $connection->prepare($sql_detailjual);
    $stmt->bind_param("i", $jual_id);
    if ($stmt->execute()) {
        $result_detailjual = $stmt->get_result();

        $details = array();

        if ($result_detailjual->num_rows > 0) {
            while ($row = $result_detailjual->fetch_assoc()) {
                $details[] = $row;
            }
        } else {
            $response['detailjual_error'] = "No sales details data found";
            error_log("No sales details data found in the 'detailjual' table.");
        }

        // Adding details data to the response
        $response['details'] = $details;
    } else {
        $response['detailjual_error'] = "Failed to execute query";
        error_log("Failed to execute query: " . $stmt->error);
    }
} else {
    $response['detailjual_error'] = "Invalid jual_id provided";
    error_log("Invalid jual_id provided");
}

$connection->close();

// Return the response in JSON format
echo json_encode($response);
?>
