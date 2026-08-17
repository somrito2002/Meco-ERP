import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  runApp(const MecoApp());
}

class MecoApp extends StatefulWidget {
  const MecoApp({super.key});

  @override
  State<MecoApp> createState() => _MecoAppState();
}

class _MecoAppState extends State<MecoApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meco Login',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
