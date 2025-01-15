import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class HalamanEditProduk extends StatefulWidget {
  final int id;
  final String nama_produk;
  final String deskripsi;
  final int harga;
  final String image;
  final Function onProductEdited;

  HalamanEditProduk({
    required this.id,
    required this.nama_produk,
    required this.deskripsi,
    required this.harga,
    required this.image,
    required this.onProductEdited,
  });

  @override
  _HalamanEditProdukState createState() => _HalamanEditProdukState();
}

class _HalamanEditProdukState extends State<HalamanEditProduk> {
  late TextEditingController namaController;
  late TextEditingController deskripsiController;
  late TextEditingController hargaController;
  File? _selectedImage;
  String? _imageUrl; // Variabel sementara untuk URL gambar
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama_produk);
    deskripsiController = TextEditingController(text: widget.deskripsi);
    hargaController = TextEditingController(text: widget.harga.toString());
    _imageUrl = widget.image; // Inisialisasi dengan URL gambar lama
  }

  Future<void> editProduk() async {
    setState(() {
      isLoading = true;
    });

    var uri = Uri.parse('http://192.168.145.99/warung_umkm/lib/edit_produk.php');

    var request = http.MultipartRequest('POST', uri)
      ..fields['id'] = widget.id.toString()
      ..fields['nama_produk'] = namaController.text
      ..fields['deskripsi'] = deskripsiController.text
      ..fields['harga'] = hargaController.text;

    if (_selectedImage != null) {
      String mimeType = lookupMimeType(_selectedImage!.path) ?? 'application/octet-stream';
      request.files.add(await http.MultipartFile.fromPath(
        'gambar',
        _selectedImage!.path,
        contentType: MediaType.parse(mimeType),
      ));
    } else {
      // Tambahkan URL gambar lama jika tidak ada gambar baru yang diunggah
      request.fields['image'] = _imageUrl ?? '';
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    print(responseBody);

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      widget.onProductEdited();
      Navigator.pop(context);
      _showMessage('Product edited successfully!');
    } else {
      print('Failed to edit product: ${response.statusCode}');
      _showMessage('Failed to edit product');
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
        _imageUrl = null; // Setel _imageUrl ke null untuk menggunakan gambar baru
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
        title: Text('Edit Produk'),
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
              child: const Text('Upload Gambar Baru'),
            ),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && _selectedImage != null)
              Image.file(
                _selectedImage!,
                fit: BoxFit.fill,
                width: 100,
                height: 100,
              ),
            if (!isLoading && _selectedImage == null)
              Image.network(
                _imageUrl!,
                fit: BoxFit.fill,
                width: 100,
                height: 100,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: editProduk,
              child: const Text('Edit Produk'),
            ),
          ],
        ),
      ),
    );
  }
}
