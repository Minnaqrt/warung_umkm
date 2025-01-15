import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'halaman_ongkir.dart'; // Import halaman ongkir
import 'product.dart';
import 'product_detail.dart'; // Import product detail

class HalamanPembayaran extends StatelessWidget {
  final List<Map<String, dynamic>> pesanan;
  final int totalHarga;
  final String currentUsername;
  final SharedPreferences spInstance;

  HalamanPembayaran({
    required this.pesanan,
    required this.totalHarga,
    required this.currentUsername,
    required this.spInstance,
  });

  @override
  Widget build(BuildContext context) {
    // Group items by 'name'
    final Map<String, Map<String, dynamic>> groupedItems = {};
    for (var item in pesanan) {
      final itemName = item['product'].name;
      if (groupedItems.containsKey(itemName)) {
        groupedItems[itemName]!['jumlah'] += item['jumlah'];
        groupedItems[itemName]!['totalHarga'] += item['jumlah'] * item['product'].price;
      } else {
        groupedItems[itemName] = {
          'product': item['product'],
          'jumlah': item['jumlah'],
          'totalHarga': item['jumlah'] * item['product'].price,
        };
      }
    }

    // Transform groupedItems to List<ProductDetail>
    final List<ProductDetail> products = groupedItems.entries.map((entry) {
      final product = entry.value['product'] as Product;
      final jumlah = entry.value['jumlah'] as int;
      final totalHargaItem = entry.value['totalHarga'] as int;
      return ProductDetail(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        image: product.image,
        quantity: jumlah,
        totalPrice: totalHargaItem,
      );
    }).toList(); // <-- This section ensures products are correctly grouped and transformed

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pembayaran")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Pemesanan"),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: groupedItems.length,
              itemBuilder: (context, index) {
                final itemName = groupedItems.keys.elementAt(index);
                final itemDetails = groupedItems[itemName]!;
                final product = itemDetails['product'] as Product;
                final jumlah = itemDetails['jumlah'] as int;
                final totalHargaItem = itemDetails['totalHarga'] as int;

                return ListTile(
                  leading: Image.network(
                    product.image, // Use the image URL
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.name),
                  subtitle: Text("${product.price} x $jumlah = Rp $totalHargaItem"),
                );
              },
            ),
            const SizedBox(height: 10),
            const Text("Total Bayar:"),
            Text("Rp $totalHarga"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalamanOngkir(
                      pesanan: products, // <-- Pass the transformed list
                      totalHarga: totalHarga,
                      currentUsername: currentUsername,
                      spInstance: spInstance,
                    ),
                  ),
                );
              },
              child: const Text("Bayar Sekarang"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Kembali ke Menu"),
            ),
          ],
        ),
      ),
    );
  }
}
