import 'package:flutter/material.dart';
import 'halaman_splash_screen.dart';
// import 'package:firebase_core/firebase_core.dart';

void main() async {
  runApp(const MyApp());
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Ajib',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 183, 139, 58),
        ),
        useMaterial3: true,
      ),
      home: const HalamanSplashScreen(),
    );
  }
}
