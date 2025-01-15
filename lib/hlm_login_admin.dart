import 'package:flutter/material.dart';
import 'halaman_admin.dart'; // Import halaman admin

class HalamanLoginAdmin extends StatefulWidget {
  @override
  _HalamanLoginAdminState createState() => _HalamanLoginAdminState();
}

class _HalamanLoginAdminState extends State<HalamanLoginAdmin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Username dan password yang telah ditetapkan
    String adminUsername = "admin";
    String adminPassword = "admin123";

    if (username == adminUsername && password == adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HalamanAdmin()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
