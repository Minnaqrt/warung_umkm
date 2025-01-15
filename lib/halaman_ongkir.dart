import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'raja_ongkir_service.dart';
import './model/model_kota.dart';
import 'halaman_dashboard.dart';
import 'histori_belanja.dart';
import 'histori_service.dart';
// import 'product.dart';
import 'product_detail.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

const API_URL = 'https://imgup.fly.dev/api/images';

class ImageFilePicker {
  Future<FilePickerResult?> pickImage() =>
      FilePicker.platform.pickFiles(type: FileType.image);
}

class PlatformService {
  bool isWebPlatform() {
    return kIsWeb;
  }
}

class APIResponse {
  final String? url;
  final int code;

  APIResponse({this.url, required this.code});
}

Future<APIResponse?> openImagePickerDialog(ImageFilePicker imageFilePicker,
    http.Client client, PlatformService platformService) async {
  FilePickerResult? result = await imageFilePicker.pickImage();
  MultipartRequest request = http.MultipartRequest('POST', Uri.parse(API_URL));

  if (result != null && result.files.isNotEmpty) {
    PlatformFile platformFile = result.files.first;

    if (platformService.isWebPlatform()) {
      final bytes = platformFile.bytes;
      if (bytes != null) {
        final httpImage = http.MultipartFile.fromBytes(
          'image',
          bytes,
          contentType: MediaType.parse(lookupMimeType('', headerBytes: bytes)!),
          filename: platformFile.name,
        );
        request.files.add(httpImage);
      }
    } else {
      File file = File(result.files.first.path!);
      final bytes = await file.readAsBytes();
      final httpImage = http.MultipartFile.fromBytes(
        'image',
        bytes,
        contentType: MediaType.parse(lookupMimeType(file.path)!),
        filename: platformFile.name,
      );
      request.files.add(httpImage);
    }

    final response = await client.send(request);
    Response responseStream = await http.Response.fromStream(response);
    final responseData = json.decode(responseStream.body);

    return APIResponse(url: responseData['url'], code: response.statusCode);
  } else {
    return null;
  }
}

class HalamanOngkir extends StatefulWidget {
  final List<ProductDetail> pesanan;
  final int totalHarga;
  final String currentUsername;
  final SharedPreferences spInstance;

  const HalamanOngkir({
    Key? key,
    required this.pesanan,
    required this.totalHarga,
    required this.currentUsername,
    required this.spInstance,
  }) : super(key: key);

  @override
  _HalamanOngkirState createState() => _HalamanOngkirState();
}

class _HalamanOngkirState extends State<HalamanOngkir> {
  final RajaOngkirService rajaOngkirService = RajaOngkirService();
  List<ModelKota> cities = [];
  String? selectedCity;
  String? selectedOriginCity;
  String? selectedCourier;
  String? strBerat;
  int shippingCost = 0;
  String? imageURL;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCities();
    loadPreferences();
  }

  void fetchCities() async {
    try {
      final data = await rajaOngkirService.getAllCities();
      setState(() {
        cities = data;
      });
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  void calculateShippingCost() async {
  if (selectedOriginCity != null &&
      selectedCity != null &&
      selectedCourier != null &&
      strBerat != null) {
    try {
      final weight = int.tryParse(strBerat!) ?? 0;
      final cost = await rajaOngkirService.calculateShippingCost(
        originCityId: selectedOriginCity!, // Using String type
        destinationCityId: int.parse(selectedCity!), // Parsing to int
        weight: weight,
        courier: selectedCourier!,
      );
      setState(() {
        shippingCost = cost;
      });
    } catch (e) {
      print('Error calculating shipping cost: $e');
    }
  } else {
    print("Please fill all fields.");
  }
}

  Future<int> insertJual(int totalHarga, int biayaPengiriman, int totalBayar, String usernamePembeli, int jumlahProduk) async {
  final response = await http.post(
    Uri.parse('http://warung-umkm.vercel.app/warung_umkm/lib/insert_jual.php'),
    body: {
      'tanggal_penjualan': DateTime.now().toString(),
      'total_harga': totalHarga.toString(),
      'biaya_pengiriman': biayaPengiriman.toString(),
      'total_bayar': totalBayar.toString(),
      'username_pembeli': usernamePembeli,
      'jumlah_produk': jumlahProduk.toString(), // Menambahkan jumlah produk
    },
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    return responseData['id']; // Assuming the API returns the ID of the inserted jual record
  } else {
    throw Exception('Failed to insert jual record');
  }
}



Future<void> insertDetailJual(
    int jualId, int produkId, int jumlah, int hargaProduk, int totalHarga, int beratPaket, String metodePengiriman, int biayaPengiriman, int totalBayar, String namaProduk) async {
  final response = await http.post(
    Uri.parse('http://warung-umkm.vercel.app/warung_umkm/lib/insert_detailjual.php'),
    body: {
      'jual_id': jualId.toString(),
      'produk_id': produkId.toString(),
      'jumlah_produk': jumlah.toString(),
      'harga_produk': hargaProduk.toString(),
      'total_harga': totalHarga.toString(),
      'berat_paket': beratPaket.toString(),
      'metode_pengiriman': metodePengiriman,
      'biaya_pengiriman': biayaPengiriman.toString(),
      'total_bayar': totalBayar.toString(),
      'nama_produk': namaProduk,
    },
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      print('Insert successful: ${data['id']}');
    } else {
      print('Insert failed: ${data['message']}');
    }
  } else {
    throw Exception('Failed to insert detailjual record');
  }
}



  Future<void> _onImagePressed() async {
    setState(() {
      isLoading = true;
    });

    APIResponse? response = await openImagePickerDialog(
        ImageFilePicker(), http.Client(), PlatformService());

    if (response == null) {
      setState(() {
        isLoading = false;
      });
    } else if (response.code != 200) {
      setState(() {
        imageURL = null;
        isLoading = false;
      });
    } else {
      setState(() {
        imageURL = response.url;
        isLoading = false;
      });
    }
  }

  void resetPurchase() {
    setState(() {
      selectedCity = null;
      selectedOriginCity = null;
      selectedCourier = null;
      strBerat = null;
      shippingCost = 0;
      imageURL = null;
      isLoading = false;
    });
  }

  void savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', selectedCity ?? '');
    await prefs.setString('selectedOriginCity', selectedOriginCity ?? '');
    await prefs.setString('selectedCourier', selectedCourier ?? '');
    await prefs.setString('strBerat', strBerat ?? '');
  }

  void loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCity = prefs.getString('selectedCity');
      selectedOriginCity = prefs.getString('selectedOriginCity');
      selectedCourier = prefs.getString('selectedCourier');
      strBerat = prefs.getString('strBerat');
    });

    if (selectedCity != null &&
        selectedOriginCity != null &&
        selectedCourier != null &&
        strBerat != null) {
      calculateShippingCost();
    }
  }

void printNota() async {
  try {
    print("Masuk ke printNota");
    String receiptNumber = "REC-${DateTime.now().millisecondsSinceEpoch}";

    // Debug: Print all items in widget.pesanan
    print("Isi widget.pesanan:");
    for (var item in widget.pesanan) {
      print("${item.name} dengan harga Rp ${item.price} sebanyak ${item.quantity} buah");
    }

    // Create and display shopping history item
    ShoppingHistoryItem newItem = ShoppingHistoryItem(
      itemName: 'Pesanan ${DateTime.now()}',
      quantity: widget.pesanan.fold(0, (sum, item) => sum + item.quantity),
      price: widget.totalHarga.toDouble(),
      date: DateTime.now(),
      shippingCost: shippingCost.toDouble(),
      totalPrice: (widget.totalHarga + shippingCost).toDouble(),
    );

    // Save to shopping history
    List<ShoppingHistoryItem> history = await loadShoppingHistory();
    history.add(newItem);
    await saveShoppingHistory(history);

    // Insert into the jual table and get the jual ID
    int totalBayar = widget.totalHarga + shippingCost;
    int jumlahProduk = widget.pesanan.fold(0, (sum, item) => sum + item.quantity);
    int jualId = await insertJual(widget.totalHarga, shippingCost, totalBayar, widget.currentUsername, jumlahProduk);

    // Insert into the detailjual table for each item
    for (var item in widget.pesanan) {
      // Sample values for berat_paket, metode_pengiriman, biaya_pengiriman
      int beratPaket = int.parse(strBerat ?? "0"); // Berat paket dari input
      String metodePengiriman = selectedCourier ?? ""; // Kurir dari input
      int biayaPengiriman = shippingCost; // Ongkos kirim
      int totalHarga = item.quantity * item.price;
      int totalBayar = totalHarga + biayaPengiriman;

      print('Metode Pengiriman: $metodePengiriman');

      await insertDetailJual(
        jualId,
        item.id,
        item.quantity,
        item.price,
        totalHarga,
        beratPaket,
        metodePengiriman,
        biayaPengiriman,
        totalBayar,
        item.name, // Nama produk
      );
    }

    // Generate PDF
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Nota Pembayaran", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text("Receipt Number: $receiptNumber"),
              pw.Text("Date: ${DateTime.now()}"),
              pw.Text("Customer: ${widget.currentUsername}"),
              pw.Divider(),
              pw.Text("Order Details:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...widget.pesanan.map((item) {
                return pw.Text("${item.name} x ${item.quantity} @ Rp ${item.price} = Rp ${item.totalPrice}");
              }).toList(),
              pw.Divider(),
              pw.Text("Total Quantity: ${widget.pesanan.fold(0, (sum, item) => sum + item.quantity)}"),
              pw.Text("Total Harga: Rp ${widget.totalHarga}"),
              pw.Text("Ongkos Kirim: Rp $shippingCost"),
              pw.Text("Total Bayar: Rp ${widget.totalHarga + shippingCost}"),
            ],
          );
        },
      ),
    );

    // Save PDF file
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());
    print("PDF berhasil disimpan: ${file.path}");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nota Pembayaran"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("-------------------------------------"),
                Text("Receipt Number: $receiptNumber"),
                const SizedBox(height: 10),
                Text("Date: ${DateTime.now()}"),
                const SizedBox(height: 10),
                Text("Customer: ${widget.currentUsername}"),
                const SizedBox(height: 10),
                Text("-------------------------------------"),
                Text("Order Details:", style: TextStyle(fontWeight: FontWeight.bold)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: widget.pesanan.map<Widget>((item) {
                  return Text("${item.name} x ${item.quantity} @ Rp ${item.price} = Rp ${item.totalPrice}");
                }).toList()),
                const SizedBox(height: 10),
                Text("-------------------------------------"),
                Text("Total Quantity: ${widget.pesanan.fold(0, (sum, item) => sum + item.quantity)}"),
                Text("Total Harga: Rp ${widget.totalHarga}"),
                Text("Ongkos Kirim: Rp $shippingCost"),
                const SizedBox(height: 10),
                Text("Total Bayar: Rp ${widget.totalHarga + shippingCost}"),
                Text("-------------------------------------"),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    OpenFile.open(file.path); // Code to open or share the PDF file
                  },
                  child: const Text("Cetak Nota"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HalamanDashboard(
                          widget.spInstance,
                          widget.currentUsername,
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                    resetPurchase(); // Reset purchase to initial state (0)
                  },
                  child: const Text("Kembali ke menu"),
                ),
              ],
            ),
          ],
        );
      },
    );

  } catch (e) {
    print("Error: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Ongkir")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DropdownSearch<ModelKota>(
              items: cities,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Kota Tujuan",
                  hintText: "Pilih Kota Tujuan",
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedCity = value?.cityId;
                });
                calculateShippingCost();
                savePreferences();
              },
              popupProps: PopupProps.menu(
                showSearchBox: true,
                emptyBuilder: (context, searchEntry) {
                  if (cities.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Center(child: Text("No data found"));
                  }
                },
                itemBuilder: (context, item, isSelected) {
                  return ListTile(
                    title: Text(item.cityName ?? ''),
                  );
                },
              ),
            ),
            DropdownSearch<ModelKota>(
              items: cities,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Kota Asal",
                  hintText: "Pilih Kota Asal",
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedOriginCity = value?.cityId;
                });
                calculateShippingCost();
                savePreferences();
              },
              popupProps: PopupProps.menu(
                showSearchBox: true,
                emptyBuilder: (context, searchEntry) {
                  if (cities.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Center(child: Text("No data found"));
                  }
                },
                itemBuilder: (context, item, isSelected) {
                  return ListTile(
                    title: Text(item.cityName ?? ''),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Berat Paket (gram)",
                hintText: "Input Berat Paket",
              ),
              onChanged: (text) {
                setState(() {
                  strBerat = text;
                });
                calculateShippingCost();
                savePreferences();
              },
            ),
            DropdownSearch<String>(
              items: const ["JNE", "TIKI", "POS"],
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Kurir",
                  hintText: "Pilih Kurir",
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedCourier = value;
                });
                calculateShippingCost();
                savePreferences();
              },
              popupProps: PopupProps.menu(
                showSearchBox: true,
                emptyBuilder: (context, searchEntry) {
                  return Center(child: Text("No data found"));
                },
                itemBuilder: (context, item, isSelected) {
                  return ListTile(
                    title: Text(item),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text("Ongkos Kirim: Rp $shippingCost"),
            const SizedBox(height: 10),
            Text("Total Bayar: Rp ${widget.totalHarga + shippingCost}"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onImagePressed,
              child: const Text("Upload Bukti Pembayaran"),
            ),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && imageURL != null)
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse(imageURL!);
                  await launchUrl(url);
                },
                child: Image.network(
                  imageURL!,
                  fit: BoxFit.fill,
                  width: 100,
                  height: 100,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                printNota();
              },
              child: const Text("Selesaikan Pembayaran"),
            ),
          ],
        ),
      ),
    );
  }
}
