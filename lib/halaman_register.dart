import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'halaman_user.dart';

class HalamanRegistrasi extends StatefulWidget {
  final SharedPreferences spInstance;

  const HalamanRegistrasi(this.spInstance, {super.key});

  @override
  State<StatefulWidget> createState() => _HalamanRegistrasiState();
}

class _HalamanRegistrasiState extends State<HalamanRegistrasi> {
  TextEditingController usernameController = TextEditingController(),
      passwordController = TextEditingController(),
      konfirmasiPasswordController = TextEditingController();
  bool showPassword = false, showKonfirmasiPassword = false;
  Map<String, dynamic> imitasiTabelUser = {};
  String? usernameError, passwordError, konfirmasiPasswordError;

  @override
  void initState() {
    super.initState();
    String? imitasiTabelUserSp = widget.spInstance.getString("user");
    imitasiTabelUser = imitasiTabelUserSp == null ? {} : json.decode(imitasiTabelUserSp);
    validasiUsername();
    validasiPassword();
    validasiKonfirmasiPassword();
  }

  void validasiUsername() {
    if (usernameController.text.isEmpty) {
      setState(() {
        usernameError = "Username tidak boleh kosong";
      });
      return;
    }
    if (imitasiTabelUser.keys.contains(usernameController.text)) {
      setState(() {
        usernameError = "Username telah terpakai";
      });
      return;
    }
    setState(() {
      usernameError = null;
    });
  }

  void validasiPassword() {
    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = "Password tidak boleh kosong";
      });
      return;
    }
    if (!RegExp(r"[A-Z]").hasMatch(passwordController.text)) {
      setState(() {
        passwordError = "Password harus mengandung huruf besar";
      });
      return;
    }
    if (!RegExp(r"[a-z]").hasMatch(passwordController.text)) {
      setState(() {
        passwordError = "Password harus mengandung huruf kecil";
      });
      return;
    }
    if (!RegExp(r"[0-9]").hasMatch(passwordController.text)) {
      setState(() {
        passwordError = "Password harus mengandung angka";
      });
      return;
    }
    setState(() {
      passwordError = null;
    });
  }

  void validasiKonfirmasiPassword() {
    if (konfirmasiPasswordController.text != passwordController.text) {
      setState(() {
        konfirmasiPasswordError = "Password tidak sama";
      });
      return;
    }
    setState(() {
      konfirmasiPasswordError = null;
    });
  }

  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void toggleShowKonfirmasiPassword() {
    setState(() {
      showKonfirmasiPassword = !showKonfirmasiPassword;
    });
  }

  Future<void> registrasi() async {
    final response = await http.post(
      Uri.parse("http://192.168.145.99/warung_umkm/lib/registrasi.php"),
      body: {
        "username": usernameController.text,
        "password": passwordController.text,
      },
    );

    final data = json.decode(response.body);
    if (data["status"] == "success") {
      // Simpan data user ke SharedPreferences
      await widget.spInstance.setString("username", usernameController.text);
      if (!context.mounted) return;
      // Arahkan ke halaman user
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanUser(widget.spInstance),
        ),
        (route) => false,
      );
    } else {
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"])),
      );
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
                    Navigator.pop(context);
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
                  onChanged: (value) => validasiUsername(),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.person),
                    label: const Text("Username"),
                    errorText: usernameError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordController,
                  onChanged: (value) {
                    validasiPassword();
                    validasiKonfirmasiPassword();
                  },
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.key),
                    label: const Text("Password"),
                    errorText: passwordError,
                    suffixIcon: GestureDetector(
                      onTap: toggleShowPassword,
                      child: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: konfirmasiPasswordController,
                  onChanged: (value) => validasiKonfirmasiPassword(),
                  obscureText: !showKonfirmasiPassword,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Konfirmasi password"),
                    errorText: konfirmasiPasswordError,
                    suffixIcon: GestureDetector(
                      onTap: toggleShowKonfirmasiPassword,
                      child: Icon(
                        showKonfirmasiPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (usernameError == null &&
                                passwordError == null &&
                                konfirmasiPasswordError == null)
                            ? registrasi
                            : null,
                        icon: const Icon(Icons.person_add),
                        label: const Text("Registrasi"),
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
