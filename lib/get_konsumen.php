<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_connection.php';

$sql = "SELECT id, username, tanggal_registrasi FROM konsumen";
$result = $conn->query($sql);

$konsumen = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $konsumen[] = $row;
    }
}

echo json_encode($konsumen);

$conn->close();
?>
