import 'package:flutter/material.dart';
import 'halaman_kelola_produk.dart'; // Import halaman kelola produk
import 'halaman_kelola_konsumen.dart';
import 'laporan_global.dart';
import 'laporan_periodik.dart'; // Import halaman kelola konsumen
// import 'halaman_laporan_global.dart'; // Import halaman laporan penjualan global
// import 'halaman_laporan_periodik.dart'; // Import halaman laporan penjualan periodik

class HalamanAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Kelola Produk'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HalamanKelolaProduk()),
              );
            },
          ),
          ListTile(
            title: Text('Kelola Konsumen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HalamanKelolaKonsumen()),
              );
            },
          ),
          ListTile(
            title: Text('Laporan Penjualan Global'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LaporanGlobal()),
              );
            },
          ),
          ListTile(
            title: Text('Laporan Penjualan Periodik'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LaporanPeriodik()),
              );
            },
          ),
        ],
      ),
    );
  }
}
