<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nama_produk = $_POST['nama_produk'] ?? '';
    $deskripsi = $_POST['deskripsi'] ?? '';
    $harga = $_POST['harga'] ?? '';

    if (!isset($_FILES["gambar"])) {
        error_log("No image file uploaded");
        echo json_encode(['status' => 'error', 'message' => 'No image file uploaded']);
        exit;
    }

    $check = getimagesize($_FILES["gambar"]["tmp_name"]);
    if ($check === false) {
        error_log("File is not an image.");
        echo json_encode(['status' => 'error', 'message' => 'File is not an image.']);
        exit;
    }

    if ($_FILES["gambar"]["size"] > 5000000) {
        error_log("File is too large.");
        echo json_encode(['status' => 'error', 'message' => 'Sorry, your file is too large.']);
        exit;
    }

    $imageFileName = $_FILES["gambar"]["name"];
    $imageURL = 'http://192.168.145.99/warung_umkm/lib/images/' . $imageFileName;

    // Gunakan path absolut ke folder images
    $targetDirectory = "C:/xampp/htdocs/warung_umkm/lib/images/";
    $targetFile = $targetDirectory . basename($imageFileName);

    if (!is_writable($targetDirectory)) {
        error_log("Folder images tidak dapat ditulisi.");
        echo json_encode(['status' => 'error', 'message' => 'Sorry, there was an error uploading your file.']);
        exit;
    }

    if (!move_uploaded_file($_FILES["gambar"]["tmp_name"], $targetFile)) {
        error_log("move_uploaded_file gagal. Source: " . $_FILES["gambar"]["tmp_name"] . ", Target: $targetFile, Error: " . $_FILES["gambar"]["error"]);
        echo json_encode(['status' => 'error', 'message' => 'Sorry, there was an error uploading your file.']);
        exit;
    } else {
        error_log("move_uploaded_file berhasil. File berada di: $targetFile");
    }

    $stmt = $conn->prepare("INSERT INTO produk (nama_produk, deskripsi, harga, image) VALUES (?, ?, ?, ?)");
    if (!$stmt) {
        error_log("Prepare statement gagal: " . $conn->error);
        echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $conn->error]);
        exit;
    }

    $stmt->bind_param("ssss", $nama_produk, $deskripsi, $harga, $imageURL);

    if ($stmt->execute()) {
        error_log("Produk berhasil ditambahkan ke database.");
        echo json_encode([
            'status' => 'success', 
            'message' => 'New product added successfully',
            'image_url' => $imageURL
        ]);
    } else {
        error_log("Kesalahan saat menambahkan produk: " . $stmt->error);
        echo json_encode(['status' => 'error', 'message' => 'Error: ' . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
}
?>
