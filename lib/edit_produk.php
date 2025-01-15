<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id = $_POST['id'];
    $nama_produk = $_POST['nama_produk'];
    $deskripsi = $_POST['deskripsi'];
    $harga = $_POST['harga'];
    $image = $_POST['image']; // URL gambar lama jika tidak ada gambar baru

    // Debugging statements
    error_log("ID: $id");
    error_log("Nama Produk: $nama_produk");
    error_log("Deskripsi: $deskripsi");
    error_log("Harga: $harga");
    error_log("Image: $image");

    if (isset($_FILES["gambar"]) && $_FILES["gambar"]["error"] == UPLOAD_ERR_OK) {
        $check = getimagesize($_FILES["gambar"]["tmp_name"]);
        if ($check === false) {
            echo json_encode(['status' => 'error', 'message' => 'File is not an image.']);
            exit;
        }

        if ($_FILES["gambar"]["size"] > 5000000) {
            echo json_encode(['status' => 'error', 'message' => 'Sorry, your file is too large.']);
            exit;
        }

        // Simpan nama file gambar baru
        $imageFileName = basename($_FILES["gambar"]["name"]);
        $targetDirectory = "C:/xampp/htdocs/warung_umkm/lib/images/";
        $targetFile = $targetDirectory . $imageFileName;
        if (!move_uploaded_file($_FILES["gambar"]["tmp_name"], $targetFile)) {
            echo json_encode(['status' => 'error', 'message' => 'Sorry, there was an error uploading your file.']);
            exit;
        }

        // Update image URL
        $image = 'http://warung-umkm.vercel.app/warung_umkm/lib/images/' . $imageFileName; // Gambar baru
    }

    // Update product in the database
    $sql = "UPDATE produk SET nama_produk='$nama_produk', deskripsi='$deskripsi', harga='$harga', image='$image' WHERE id=$id";
    $result = mysqli_query($connection, $sql);

    if ($result) {
        echo json_encode(['message' => 'Record updated successfully']);
    } else {
        echo json_encode(['message' => 'Error: Data failed to update']);
        error_log("Database Error: " . mysqli_error($connection));
    }

    $connection->close();
} else {
    echo json_encode(['message' => 'Invalid request method']);
}
?>
