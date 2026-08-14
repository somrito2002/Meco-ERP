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
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      final Brightness platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final bool isCurrentlyDark = _themeMode == ThemeMode.dark ||
          (_themeMode == ThemeMode.system &&
              platformBrightness == Brightness.dark);
      _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
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
