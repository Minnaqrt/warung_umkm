import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'detail_penjualan.dart'; // Import halaman detail

class LaporanGlobal extends StatefulWidget {
  @override
  _LaporanGlobalState createState() => _LaporanGlobalState();
}

class _LaporanGlobalState extends State<LaporanGlobal> {
  int currentPage = 1;
  int totalPages = 1;
  final int itemsPerPage = 10;

  Future<Map<String, dynamic>> fetchData(int page) async {
    final queryParameters = {
      'page': page.toString(),
      'items_per_page': itemsPerPage.toString()
    };
    final uri = Uri.http('192.168.145.99', '/warung_umkm/lib/get_jual.php', queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return {
        'sales': data['sales'].cast<Map<String, dynamic>>(),
        'total_pages': data['total_pages']
      };
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchDataDetail(int jualId) async {
    final response = await http.get(
        Uri.parse('http://192.168.145.99/warung_umkm/lib/get_detailjual.php?jual_id=$jualId'));
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> data = json.decode(response.body);
        return data['details'].cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to decode JSON');
      }
    } else {
      throw Exception('Failed to load detail data');
    }
  }

  Future<void> exportToExcel(List<Map<String, dynamic>> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Append data rows
    for (var row in data) {
      sheetObject.appendRow([
        row['id'],
        row['tanggal_penjualan'],
        row['total_harga'],
        row['biaya_pengiriman'],
        row['total_bayar'],
        row['username_pembeli'],
        row['jumlah_produk']
      ]);
    }

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/Laporan_Global.xlsx';
    File(path).writeAsBytesSync(excel.encode()!);
    OpenFile.open(path);
  }

  Future<void> exportToPDF(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.TableHelper.fromTextArray(
          headers: [
            'ID', 'Tanggal Penjualan', 'Total Harga', 'Biaya Pengiriman', 'Total Bayar', 'Username Pembeli', 'Jumlah Produk'
          ],
          data: data.map((row) => [
            row['id'],
            row['tanggal_penjualan'],
            row['total_harga'],
            row['biaya_pengiriman'],
            row['total_bayar'],
            row['username_pembeli'],
            row['jumlah_produk']
          ]).toList(),
        );
      },
    ));

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/Laporan_Global.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(path);
  }

  void _changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Penjualan Global'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) async {
              final data = await fetchData(currentPage);
              final salesData = data['sales'];
              if (result == 'excel') {
                await exportToExcel(salesData);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Global sales report exported to Excel'),
                ));
              } else if (result == 'pdf') {
                await exportToPDF(salesData);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Global sales report exported to PDF'),
                ));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'excel',
                child: Text('Export to Excel'),
              ),
              const PopupMenuItem<String>(
                value: 'pdf',
                child: Text('Export to PDF'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(currentPage),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['sales'].isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final salesData = snapshot.data!['sales'];
            totalPages = snapshot.data!['total_pages'] ?? 1;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Container()), // Tidak ada label di sini
                            DataColumn(label: Text('Tanggal Penjualan')),
                            DataColumn(label: Text('Total Harga')),
                            DataColumn(label: Text('Biaya Pengiriman')),
                            DataColumn(label: Text('Total Bayar')),
                            DataColumn(label: Text('Username Pembeli')),
                            DataColumn(label: Text('Jumlah Produk')),
                            DataColumn(label: Text('Detail')),
                          ],
                          rows: salesData.map<DataRow>((row) {
                            return DataRow(cells: [
                              DataCell(Text(row['id'].toString())), // Menampilkan ID di dalam baris data
                              DataCell(Text(row['tanggal_penjualan'])),
                              DataCell(Text(row['total_harga'].toString())),
                              DataCell(Text(row['biaya_pengiriman'].toString())),
                              DataCell(Text(row['total_bayar'].toString())),
                              DataCell(Text(row['username_pembeli'])),
                              DataCell(Text(row['jumlah_produk'].toString())),
                              DataCell(IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPenjualan(jualId: int.parse(row['id'])),
                                    ),
                                  );
                                },
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (currentPage > 1)
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => _changePage(currentPage - 1),
                        ),
                      Text('Page $currentPage of $totalPages'),
                      if (currentPage < totalPages)
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () => _changePage(currentPage + 1),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
