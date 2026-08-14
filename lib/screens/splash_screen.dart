import 'package:flutter/material.dart';

import '../login.dart';
import '../widgets/particle_logo_reveal.dart';

/// Path to the original uploaded Meco logo.
const String kMecoLogoAsset = 'assets/logo/MECO TECHNOLOGIES PR-Photoroom.png';

/// Shows the particle-reveal splash, then hands off to the login screen
/// using the app's existing Navigator-based routing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  Future<void> _onRevealComplete() async {
    if (_navigated) return;
    // Short pause on the finished logo before entering the app.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoginScreen(onToggleTheme: widget.onToggleTheme),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Match the native Android launch background exactly (white in light
    // mode, black in dark mode) so there is no flash at the
    // Android -> Flutter transition.
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: ParticleLogoReveal(
            assetPath: kMecoLogoAsset,
            onComplete: _onRevealComplete,
          ),
        ),
      ),
    );
  }
}