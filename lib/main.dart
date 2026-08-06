import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MecoApp());
}

class MecoApp extends StatelessWidget {
  const MecoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meco Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: const LoginScreen(),
    );
  }
}
