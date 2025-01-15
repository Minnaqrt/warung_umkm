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

    // Check if the customer exists
    $check_sql = "SELECT * FROM konsumen WHERE id='$id'";
    $check_result = $conn->query($check_sql);

    if ($check_result->num_rows == 0) {
        echo json_encode(['status' => 'error', 'message' => 'Customer not found']);
        exit;
    }

    // Delete the customer from the konsumen table
    $sql = "DELETE FROM konsumen WHERE id='$id'";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(['status' => 'success', 'message' => 'Customer deleted successfully']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error: ' . $conn->error]);
    }

    $conn->close();
}
?>