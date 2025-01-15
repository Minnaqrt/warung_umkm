import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class HalamanTambahProduk extends StatefulWidget {
  final Function onProductAdded;

  const HalamanTambahProduk({required this.onProductAdded});

  @override
  _HalamanTambahProdukState createState() => _HalamanTambahProdukState();
}

class _HalamanTambahProdukState extends State<HalamanTambahProduk> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  File? _selectedImage;
  bool isLoading = false;

  Future<void> tambahProduk() async {
    if (_selectedImage == null) {
      _showMessage('No image selected for upload.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var uri = Uri.parse('http://192.168.145.99/warung_umkm/lib/add_produk.php');
      String mimeType = lookupMimeType(_selectedImage!.path) ?? 'application/octet-stream';

      var request = http.MultipartRequest('POST', uri)
        ..fields['nama_produk'] = namaController.text
        ..fields['deskripsi'] = deskripsiController.text
        ..fields['harga'] = hargaController.text
        ..files.add(await http.MultipartFile.fromPath(
          'gambar',
          _selectedImage!.path,
          contentType: MediaType.parse(mimeType),
        ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print(responseBody);

      if (response.statusCode == 200) {
        widget.onProductAdded();
        Navigator.pop(context);
        _showMessage('Product added successfully!');
      } else {
        print('Failed to add product: ${response.statusCode}');
        _showMessage('Failed to add product');
      }
    } catch (e) {
      print('Exception: $e');
      _showMessage('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
        print('Selected Image Path: ${_selectedImage!.path}');
      });
    } else {
      print('No image selected.');
      _showMessage('No image selected.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: deskripsiController,
              decoration: InputDecoration(labelText: 'Deskripsi'),
            ),
            TextField(
              controller: hargaController,
              decoration: InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Gambar'),
            ),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && _selectedImage != null)
              Image.file(
                _selectedImage!,
                fit: BoxFit.fill,
                width: 100,
                height: 100,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: tambahProduk,
              child: const Text('Tambah Produk'),
            ),
          ],
        ),
      ),
    );
  }
}
