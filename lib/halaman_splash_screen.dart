import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'halaman_user.dart';
import 'halaman_dashboard.dart';

class HalamanSplashScreen extends StatefulWidget {
  const HalamanSplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HalamanSplashScreenState();
}

class _HalamanSplashScreenState extends State<HalamanSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      SharedPreferences spInstance = await SharedPreferences.getInstance();
      bool isLoggedIn = spInstance.getBool("isLoggedIn") ?? false;
    String? lastUsername = spInstance.getString("last_username");

    if (!context.mounted) return;

    // Cek apakah pengguna sudah login sebelumnya
    if (isLoggedIn && lastUsername != null) {
      // Jika sudah login, arahkan ke HalamanDashboard dengan username
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanDashboard(spInstance, lastUsername),
        ),
      );
    } else {
      // Jika belum login, arahkan ke HalamanUser (halaman login)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanUser(spInstance),
        ),
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo-warung.png", 
              width: 400.0,
              height: 300.0,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24.0),  
            Text(
              "Selamat Datang di Warung Ajib!",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}