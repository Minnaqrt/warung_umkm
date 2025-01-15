import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'halaman_dashboard.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HalamanLogin extends StatefulWidget {
  final SharedPreferences spInstance;

  const HalamanLogin(this.spInstance, {super.key});

  @override
  State<StatefulWidget> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? loginError;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://192.168.145.99/warung_umkm/lib/login_konsumen.php'),
      body: {
        'username': usernameController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        // Login berhasil
        SharedPreferences prefs = widget.spInstance;
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUsername', usernameController.text);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanDashboard(prefs, usernameController.text),
          ),
        );
      } else {
        // Login gagal
        setState(() {
          loginError = jsonResponse['message'];
        });
      }
    } else {
      setState(() {
        loginError = "Terjadi kesalahan saat login";
      });
    }
  }

  void loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        SharedPreferences prefs = widget.spInstance;
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUsername', googleUser.displayName ?? "Pengguna Google");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanDashboard(prefs, googleUser.displayName ?? "Pengguna Google"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        loginError = "Login dengan Google gagal: $e";
      });
    }
  }

  void loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        SharedPreferences prefs = widget.spInstance;
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUsername', userData['name'] ?? "Pengguna Facebook");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanDashboard(prefs, userData['name'] ?? "Pengguna Facebook"),
          ),
        );
      } else {
        setState(() {
          loginError = "Login dengan Facebook gagal: ${result.message}";
        });
      }
    } catch (e) {
      setState(() {
        loginError = "Login dengan Facebook gagal: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(7),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Tombol kembali
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Kembali",
                        style: Theme.of(context).textTheme.bodyLarge?.apply(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.person),
                    label: const Text("Username"),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.key),
                    label: const Text("Password"),
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (loginError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      loginError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: login,
                        icon: const Icon(Icons.login),
                        label: const Text("Login"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: loginWithGoogle,
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 24,
                        ),
                        label: const Text("Login dengan Google"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: loginWithFacebook,
                        icon: const Icon(Icons.facebook),
                        label: const Text("Login dengan Facebook"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
