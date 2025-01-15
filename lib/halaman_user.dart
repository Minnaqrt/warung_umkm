import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'halaman_login.dart';
import 'halaman_register.dart';

class HalamanUser extends StatelessWidget {
  final SharedPreferences spInstance;

  const HalamanUser(this.spInstance, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  label: const Text("Login"),
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanLogin(spInstance),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    "atau",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                ElevatedButton.icon(
                  label: const Text("Registrasi"),
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanRegistrasi(spInstance),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
