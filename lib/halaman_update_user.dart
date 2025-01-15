import 'dart:convert';

import 'package:flutter/material.dart';
// import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'halaman_login.dart';

class HalamanUpdateUser extends StatefulWidget {
  @override
  _HalamanUpdateUserState createState() => _HalamanUpdateUserState();
}

class _HalamanUpdateUserState extends State<HalamanUpdateUser> {
  String? username = "";
  String? password = "";
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getFromSharedPreferences(); // Load existing data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Input username
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 4)),
          // Input password
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            obscureText: true, // Mengaburkan teks untuk password
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
          // Button to update username and password
          ElevatedButton(
            child: const Text("Update"),
            // onPressed: () async {
            onPressed: () async {
              // await updateSharedPreferences();
              updateSharedPreferences();
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => HalamanLogin(widget.spInstance)));
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
          // Displaying Username in Text Widget
          Text(
            "Your Username : $username",
            style: const TextStyle(fontSize: 20),
          ),
          // Displaying Password in Text Widget
          Text(
            "Your Password : $password",
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  // Method to save data in SharedPreferences
  void updateSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString("username", usernameController.text);
    // await prefs.setString("password", passwordController.text);

    // Simpan username dan password sebagai JSON
    Map<String, String> userData = {
      "username": usernameController.text,
      "password": passwordController.text,
    };

    await prefs.setString("user", json.encode(userData));

    setState(() {
      username = usernameController.text;
      password = passwordController.text;
    });
  }

  // Method to retrieve data from SharedPreferences
  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "";
      password = prefs.getString("password") ?? "";
      usernameController.text = username!;
      passwordController.text = password!;
    });
  }
}
