import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'halaman_pembayaran.dart';
import 'halaman_splash_screen.dart';
import 'halaman_edit_profile.dart';
import 'histori_belanja.dart';
import 'histori_service.dart';
import 'hlm_login_admin.dart';
import 'product.dart';
import 'tampilan_histori.dart';

class HalamanDashboard extends StatefulWidget {
  final SharedPreferences spInstance;
  final String currentUsername;

  const HalamanDashboard(this.spInstance, this.currentUsername, {super.key});

  @override
  _HalamanDashboardState createState() => _HalamanDashboardState();
}

class _HalamanDashboardState extends State<HalamanDashboard> {
  int totalHarga = 0;
  List<Map<String, dynamic>> pesanan = [];
  late String currentUsername;
  List<Product> products = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    currentUsername = widget.currentUsername;
    if (currentUsername.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HalamanSplashScreen()),
        );
      });
    } else {
      loadData();
      fetchProducts();
      _startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchProducts();
    });
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
          Uri.parse('http://warung-umkm.vercel.app/warung_umkm/lib/get_produk.php'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          products = jsonResponse
              .map((product) => Product.fromJson(product))
              .toList();
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void loadData() {
    final userData = widget.spInstance.getString("user");
    if (userData != null) {
      final userMap = json.decode(userData) as Map<String, dynamic>;
      if (userMap.isNotEmpty) {
        setState(() {
          currentUsername = userMap.keys.first;
        });
      }
    }
  }

  void tambahHarga(Product product) {
    setState(() {
      totalHarga += product.price;
      final existingItem = pesanan.firstWhere(
        (pesan) => (pesan['product'] == product),
        orElse: () => {'product': null, 'jumlah': 0},
      );

      if (existingItem['product'] != null) {
        existingItem['jumlah'] += 1;
      } else {
        pesanan.add({'product': product, 'jumlah': 1});
      }
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Dashboard"),
      actions: [
        Row(
          children: [
            Text(currentUsername),
            const SizedBox(width: 8),
            const Icon(Icons.person),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: _onMenuSelected,
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(value: 'call_center', child: Text('Call Center')),
                  const PopupMenuItem<String>(value: 'sms_center', child: Text('SMS Center')),
                  const PopupMenuItem<String>(value: 'lokasi', child: Text('Lokasi/Maps')),
                  const PopupMenuItem<String>(value: 'update_user', child: Text('Update User & Password')),
                  const PopupMenuItem<String>(value: 'histori_belanja', child: Text('Histori Belanja')),
                  const PopupMenuItem<String>(value: 'admin_login', child: Text('Admin Login')),
                  const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
                ];
              },
            ),
          ],
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: products.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : GridView.count(
                          mainAxisSpacing: 7,
                          crossAxisSpacing: 7,
                          crossAxisCount: 3,
                          children: products.map((product) {
                            return buildProductItem(product);
                          }).toList(),
                        ),
                ),
              ),
            ),
          ),
          // Bottom bar with total price
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: GestureDetector(
              onTap: () {
                if (totalHarga > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HalamanPembayaran(
                        totalHarga: totalHarga,
                        pesanan: pesanan,
                        currentUsername: currentUsername,
                        spInstance: widget.spInstance,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tambahkan item terlebih dahulu')),
                  );
                }
              },
              child: Text(
                "Total: Rp. ${totalHarga.toStringAsFixed(0)}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget buildProductItem(Product product) {
    return Padding(
      key: ValueKey(product.id),
      padding: const EdgeInsets.all(7),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                tambahHarga(product);
              },
              child: _buildImage(product),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            product.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Rp ${product.price.toStringAsFixed(0)}',
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Product product) {
    print(
        'Product image URL: ${product.image}'); // Debugging: Print the full image URL
    return Image.network(
      product.image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
    );
  }

  void _onMenuSelected(String value) async {
    switch (value) {
      case 'call_center':
        _openWhatsApp();
        break;
      case 'sms_center':
        _openWhatsApp();
        break;
      case 'lokasi':
        openLocation();
        break;
      case 'update_user':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HalamanEditProfile(widget.spInstance, currentUsername)),
        ).then((updated) {
          if (updated == true) {
            loadData();
          }
        });
        break;
      case 'histori_belanja':
        List<ShoppingHistoryItem> history = await loadShoppingHistory();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShoppingHistoryScreen(history: history),
          ),
        );
        break;
      case 'admin_login':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HalamanLoginAdmin()),
        );
        break;
      case 'logout':
        await widget.spInstance.setBool("isLoggedIn", false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HalamanSplashScreen()),
          (route) => false,
        );
        break;
      default:
        break;
    }
  }

  Future<void> _openWhatsApp() async {
    const url = 'https://wa.me/6282265214946';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka WhatsApp';
    }
  }

  Future<void> openLocation() async {
    const url =
        'https://www.google.com/maps/search/?api=1&query=-6.982083,110.409333';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka Google Maps';
    }
  }
}
