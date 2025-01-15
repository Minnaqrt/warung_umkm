<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
  $username = $_POST['username'];
  $password = $_POST['password'];

  // Hash the password before storing it
  $hashed_password = password_hash($password, PASSWORD_DEFAULT);

  // Insert the new customer into the konsumen table
  $sql = "INSERT INTO konsumen (username, password) VALUES ('$username', '$hashed_password')";

  if ($conn->query($sql) === TRUE) {
    echo json_encode(array("status" => "success", "message" => "New customer added successfully"));
  } else {
    echo json_encode(array("status" => "error", "message" => "Error: " . $sql . "<br>" . $conn->error));
  }

  $conn->close();
}
?>
