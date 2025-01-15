import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPenjualan extends StatelessWidget {
  final int jualId;

  DetailPenjualan({required this.jualId});

  Future<List<Map<String, dynamic>>> fetchDataDetail() async {
    final response = await http.get(
        Uri.parse('http://warung-umkm.vercel.app/warung_umkm/lib/get_detailjual.php?jual_id=$jualId'));
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> data = json.decode(response.body);
        print('Data received: $data');
        return data['details'].cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }
    } else {
      throw Exception('Failed to load detail data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Penjualan'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDataDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final detailData = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Nama Produk')),
                  DataColumn(label: Text('Jumlah Produk')),
                  DataColumn(label: Text('Harga Produk')),
                  DataColumn(label: Text('Total Harga')),
                  DataColumn(label: Text('Berat Paket')),
                  DataColumn(label: Text('Metode Pengiriman')),
                  DataColumn(label: Text('Biaya Pengiriman')),
                  DataColumn(label: Text('Total Bayar')),
                ],
                rows: detailData.map((detailRow) {
                  return DataRow(cells: [
                    DataCell(Text(detailRow['id'].toString())),
                    DataCell(Text(detailRow['nama_produk'])),
                    DataCell(Text(detailRow['jumlah_produk'].toString())),
                    DataCell(Text(detailRow['harga_produk'].toString())),
                    DataCell(Text(detailRow['total_harga'].toString())),
                    DataCell(Text(detailRow['berat_paket'].toString())),
                    DataCell(Text(detailRow['metode_pengiriman'])),
                    DataCell(Text(detailRow['biaya_pengiriman'].toString())),
                    DataCell(Text(detailRow['total_bayar'].toString())),
                  ]);
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
