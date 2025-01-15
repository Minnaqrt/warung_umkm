import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanEditProfile extends StatefulWidget {
  final SharedPreferences spInstance;
  final String currentUsername;

  const HalamanEditProfile(this.spInstance, this.currentUsername, {super.key});

  @override
  State<StatefulWidget> createState() => _HalamanEditProfileState();
}

class _HalamanEditProfileState extends State<HalamanEditProfile> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController konfirmasiPasswordController = TextEditingController();

  bool showPassword = false, showKonfirmasiPassword = false;
  String? usernameError, passwordError, konfirmasiPasswordError;
  Map<String, dynamic> imitasiTabelUser = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    String? imitasiTabelUserSp = widget.spInstance.getString("user");
    if (imitasiTabelUserSp != null) {
      imitasiTabelUser = json.decode(imitasiTabelUserSp);
      usernameController.text = widget.currentUsername;
      passwordController.text = imitasiTabelUser[widget.currentUsername] ?? '';
    }
  }

  void simpanPerubahan() async {
  if (usernameController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      passwordController.text == konfirmasiPasswordController.text) {
    String? imitasiTabelUserSp = widget.spInstance.getString("user");
    Map<String, dynamic> imitasiTabelUser = {};

    if (imitasiTabelUserSp != null) {
      imitasiTabelUser = json.decode(imitasiTabelUserSp);
    }

    // Hapus username lama
    imitasiTabelUser.remove(widget.currentUsername);

    // Tambahkan username baru dan password baru
    imitasiTabelUser[usernameController.text] = passwordController.text;

    // Simpan kembali ke SharedPreferences
    await widget.spInstance.setString('user', json.encode(imitasiTabelUser));

    // Debugging: Cetak data yang disimpan
    print('Data user setelah update: ${widget.spInstance.getString("user")}');

    // Kirim kembali informasi bahwa perubahan berhasil
    Navigator.pop(context, true);
  } else {
    // Tampilkan pesan error jika validasi gagal
    setState(() {
      if (usernameController.text.isEmpty) {
        usernameError = "Username tidak boleh kosong";
      }
      if (passwordController.text.isEmpty) {
        passwordError = "Password tidak boleh kosong";
      }
      if (passwordController.text != konfirmasiPasswordController.text) {
        konfirmasiPasswordError = "Password tidak sama";
      }
    });
  }
}


  void validasiUsername(String value) {
    if (value.isEmpty) {
      setState(() {
        usernameError = "Username tidak boleh kosong";
      });
      return;
    }
    if (imitasiTabelUser.keys.contains(value) && value != widget.currentUsername) {
      setState(() {
        usernameError = "Username telah terpakai";
      });
      return;
    }
    setState(() {
      usernameError = null;
    });
  }

  void validasiPassword(String value) {
    if (value.isEmpty) {
      setState(() {
        passwordError = "Password tidak boleh kosong";
      });
      return;
    }
    if (!RegExp(r"[A-Z]").hasMatch(value)) {
      setState(() {
        passwordError = "Password harus mengandung huruf besar";
      });
      return;
    }
    if (!RegExp(r"[a-z]").hasMatch(value)) {
      setState(() {
        passwordError = "Password harus mengandung huruf kecil";
      });
      return;
    }
    if (!RegExp(r"[0-9]").hasMatch(value)) {
      setState(() {
        passwordError = "Password harus mengandung angka";
      });
      return;
    }
    setState(() {
      passwordError = null;
    });
  }

  void validasiKonfirmasiPassword(String value) {
    if (value != passwordController.text) {
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
                  onChanged: (value) => validasiUsername(value),
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
                  onChanged: (value) => validasiPassword(value),
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
                  onChanged: (value) => validasiKonfirmasiPassword(value),
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
                      child: FilledButton.icon(
                        onPressed: (usernameError == null &&
                                passwordError == null &&
                                konfirmasiPasswordError == null &&
                                passwordController.text == konfirmasiPasswordController.text)
                            ? () async {
                                simpanPerubahan();
                              }
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text("Simpan"),
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
