import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HalamanKelolaKonsumen extends StatefulWidget {
  @override
  _HalamanKelolaKonsumenState createState() => _HalamanKelolaKonsumenState();
}

class _HalamanKelolaKonsumenState extends State<HalamanKelolaKonsumen> {
  List<Map<String, dynamic>> konsumen = [];

  @override
  void initState() {
    super.initState();
    fetchKonsumen();
  }

  Future<void> fetchKonsumen() async {
    final response = await http.get(Uri.parse('http://192.168.145.99/warung_umkm/lib/get_konsumen.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        konsumen = jsonResponse.map((cons) => {
          'id': cons['id'],
          'username': cons['username'],
          'tanggal_registrasi': cons['tanggal_registrasi'],
        }).toList();
      });
    } else {
      print('Failed to load customers: ${response.body}');
      throw Exception('Failed to load customers');
    }
  }

  Future<void> tambahKonsumen(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.145.99/warung_umkm/lib/add_konsumen.php'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      await fetchKonsumen(); // Refetch the customer list
      _showMessage('Customer added successfully');
    } else {
      print('Failed to add customer: ${response.body}');
      _showMessage('Failed to add customer');
      throw Exception('Failed to add customer');
    }
  }

  Future<void> hapusKonsumen(int id) async {
    try {
      print('Sending request to delete customer with ID: $id'); // Debugging line
      final response = await http.post(
        Uri.parse('http://192.168.145.99/warung_umkm/lib/delete_konsumen.php'),
        body: {'id': id.toString()},
      );

      if (response.statusCode == 200) {
        print('Customer deleted successfully'); // Debugging line
        await fetchKonsumen(); // Refetch the customer list
        print('Updated local list: $konsumen'); // Debugging line
        _showMessage('Customer deleted successfully');
      } else {
        print('Failed to delete customer: ${response.body}');
        _showMessage('Failed to delete customer');
      }
    } catch (e) {
      print('Error: $e');
      _showMessage('Error deleting customer');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Konsumen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: konsumen.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(konsumen[index]['username']),
                  subtitle: Text("Tanggal Registrasi: ${konsumen[index]['tanggal_registrasi']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      int konsumenId = int.parse(konsumen[index]['id']);
                      hapusKonsumen(konsumenId);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Tambah Konsumen'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: usernameController,
                            decoration: InputDecoration(labelText: 'Username'),
                          ),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(labelText: 'Password'),
                            obscureText: true,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (usernameController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              tambahKonsumen(
                                usernameController.text,
                                passwordController.text,
                              );
                              Navigator.pop(context);
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text('Username dan Password tidak boleh kosong'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text('Tambah'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Tambah Konsumen'),
            ),
          ),
        ],
      ),
    );
  }
}
