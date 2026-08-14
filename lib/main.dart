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
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meco Login',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: SplashScreen(onToggleTheme: _toggleTheme),
    );
  }
}
