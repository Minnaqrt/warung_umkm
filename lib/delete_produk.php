<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id = $_POST['id'] ?? '';

    if (empty($id)) {
        echo json_encode(['status' => 'error', 'message' => 'ID is required']);
        exit;
    }

    // Log the incoming request for debugging
    error_log("Received ID for deletion: " . $id);

    // Check if the product exists
    $check_sql = "SELECT * FROM produk WHERE id='$id'";
    $check_result = $connection->query($check_sql);

    if ($check_result->num_rows == 0) {
        echo json_encode(['status' => 'error', 'message' => 'Product not found']);
        exit;
    }

    // Log the check result
    error_log("Product exists, proceeding to delete: " . $id);

    // Delete the product from the produk table
    $sql = "DELETE FROM produk WHERE id='$id'";

    if ($connection->query($sql) === TRUE) {
        echo json_encode(['status' => 'success', 'message' => 'Product deleted successfully']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error: ' . $connection->error]);
    }

    $connection->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
?>
