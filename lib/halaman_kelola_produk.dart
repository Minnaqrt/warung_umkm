import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'halaman_edit_produk.dart';
import 'halaman_tambah_produk.dart';
import 'product.dart'; // Import the Product model

class HalamanKelolaProduk extends StatefulWidget {
  @override
  _HalamanKelolaProdukState createState() => _HalamanKelolaProdukState();
}

class _HalamanKelolaProdukState extends State<HalamanKelolaProduk> {
  List<Product> produk = [];

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    final response = await http
        .get(Uri.parse('http://warung-umkm.vercel.app/warung_umkm/lib/get_produk.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print('Fetched products: $jsonResponse'); // Debugging line
      setState(() {
        produk = jsonResponse.map((prod) => Product.fromJson(prod)).toList();
        print('Parsed products: $produk'); // Debugging line
      });
    } else {
      print('Failed to load products: ${response.body}');
      throw Exception('Failed to load products');
    }
  }

  Future<void> hapusProduk(int id) async {
    try {
      print('Sending request to delete product with ID: $id'); // Debugging line
      final response = await http.post(
        Uri.parse('http://warung-umkm.vercel.app/warung_umkm/lib/delete_produk.php'),
        body: {'id': id.toString()},
      );

      if (response.statusCode == 200) {
        print('Product deleted successfully');
        setState(() {
          produk.removeWhere((prod) => prod.id == id); // Update state after deletion
        });
        await fetchProduk(); // Refetch the product list
        _showMessage('Product deleted successfully');
      } else {
        print('Failed to delete product: ${response.body}');
        _showMessage('Failed to delete product');
      }
    } catch (e) {
      print('Error: $e');
      _showMessage('Error deleting product');
    }
  }

  Future<void> updateProduk() async {
    await fetchProduk(); // Refetch the product list
    setState(() {}); // Update the state to reflect changes
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildImage(String image) {
    print('Image URL: $image'); // Debugging line
    return Image.network(
      image,
      fit: BoxFit.cover,
      width: 50,
      height: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Produk'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HalamanTambahProduk(onProductAdded: updateProduk)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: produk.length,
              itemBuilder: (context, index) {
                final product = produk[index];
                return ListTile(
                  leading: _buildImage(product.image),
                  title: Text(product.name),
                  subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          print('Editing product: ${product.id}'); // Debugging line
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HalamanEditProduk(
                                  id: product.id,
                                  nama_produk: product.name,
                                  deskripsi: product.description,
                                  harga: product.price,
                                  image: product.image,
                                  onProductEdited: updateProduk,
                                ),
                              ),
                            );
                          } catch (e) {
                            print('Error navigating to edit produk: $e');
                            _showMessage('Error navigating to edit produk');
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          hapusProduk(product.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
