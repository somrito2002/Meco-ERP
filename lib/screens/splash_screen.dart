import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/particle_logo_reveal.dart';
import 'meco_onboarding_screen.dart';
/// Path to the original uploaded Meco logo.
/// Path to the transparent Meco globe used in particle reveal & login.
const String kMecoLogoAsset = 'assets/logo/MECO TECHNOLOGIES PR-Photoroom.png';

/// Shows the particle-reveal splash, then hands off to the login screen
/// using the app's existing Navigator-based routing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _navigated = false;
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  Future<void> _onRevealComplete() async {
    if (_navigated) return;
    // wait 200ms after particle reveal
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted || _navigated) return;

    // start line sweep + tagline shine (together)
    await _shineController.forward();

    // after sweep completes -> wait 600ms
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted || _navigated) return;

    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MecoOnboardingScreen(),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ParticleLogoReveal(
                assetPath: kMecoLogoAsset,
                onComplete: _onRevealComplete,
              ),
              const SizedBox(height: 12),
              _ShineSweepAnimation(
                animation: _shineController,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShineSweepAnimation extends StatelessWidget {
  final Animation<double> animation;
  final bool isDark;

  const _ShineSweepAnimation({
    required this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double progress = Curves.easeInOut.transform(animation.value);
        final double lineWidth = MediaQuery.sizeOf(context).width * 0.7;

        // Final visible line opacity: 0.7 - 1.0 (fade in as sweep happens)
        final double lineOpacity = (progress * 1.5).clamp(0.0, 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The Line
            Opacity(
              opacity: lineOpacity,
              child: SizedBox(
                width: lineWidth,
                height: 2,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Base gradient line
                    Container(
                      width: lineWidth,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0D6EFD).withOpacity(0.5),
                            const Color(0xFF7FDBFF).withOpacity(0.8),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                    // Moving glow head
                    if (progress > 0 && progress < 1)
                      Positioned(
                        left: (progress * lineWidth) - 20, // Center the glow around the head
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7FDBFF).withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                            color: const Color(0xFF7FDBFF),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tagline text with shader mask
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    // White for revealed, Dark for unrevealed
                    isDark ? Colors.white : Colors.black87,
                    isDark ? Colors.white : Colors.black87,
                    isDark ? const Color(0xFF1A1A1A) : Colors.black12,
                    isDark ? const Color(0xFF1A1A1A) : Colors.black12,
                  ],
                  stops: [
                    0.0,
                    math.max(0.0, progress - 0.1),
                    math.min(1.0, progress + 0.1),
                    1.0,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds);
              },
              child: Text(
                'Excellence in innovation',
                style: TextStyle(
                  fontFamily: 'Roboto', // Assuming app font
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                  // Color here doesn't matter much due to ShaderMask, but provides base
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
