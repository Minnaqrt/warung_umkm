// import 'package:http/http.dart' as http;
// import 'data.dart';

// Future<void> insertProduct(ItemMenu product) async {
//   final uri = Uri.parse('http://192.168.145.99/warung_umkm/lib/add_produk.php');
//   final request = http.MultipartRequest('POST', uri)
//     ..fields['nama_produk'] = product.nama
//     ..fields['deskripsi'] = product.deskripsi
//     ..fields['harga'] = product.harga.toString()
//     ..files.add(await http.MultipartFile.fromPath('gambar', product.imageFile.path));

//   final response = await request.send();

//   if (response.statusCode == 200) {
//     print('Product added successfully');
//     print(await response.stream.bytesToString()); // Tambahkan untuk melihat pesan sukses dari server
//   } else {
//     print('Failed to add product');
//     print(await response.stream.bytesToString()); // Tambahkan untuk melihat pesan error dari server
//   }
// }

// Future<void> insertAllProducts() async {
//   for (var product in menuImitasi) {
//     await insertProduct(product);
//   }
// }

// void main() async {
//   await insertAllProducts(); // Pastikan dipanggil dengan await
// }
