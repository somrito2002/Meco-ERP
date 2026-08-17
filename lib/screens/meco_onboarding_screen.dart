import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../login.dart';
import '../theme.dart';
import 'splash_screen.dart' show kMecoLogoAsset;

const Color mecoPrimaryColor = AppPalette.navyLight;
const Color mecoDarkAccent = AppPalette.navy;

class MecoOnboardingScreen extends StatefulWidget {
  const MecoOnboardingScreen({super.key});

  @override
  State<MecoOnboardingScreen> createState() => _MecoOnboardingScreenState();
}

class _MecoOnboardingScreenState extends State<MecoOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;
  late final AnimationController _breathController;

  final List<String> _headlines = const [
    'Organise tasks, request approvals and share comments',
    'Share drawings, manage revisions and get approvals',
    'Schedule activities and track planned vs actual progress',
    'Update progress, generate reports and share instantly',
    'Capture snags, track closures and handle projects',
  ];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    // Automatic page transition, matching the reference video.
    // Remove this block if auto-advance isn't wanted.
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _headlines.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _breathController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
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

  void _openTerms() {
    // TODO: wire to existing Terms & Conditions handler/URL if one exists.
  }

  void _openPrivacy() {
    // TODO: wire to existing Privacy Policy handler/URL if one exists.
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              kMecoLogoAsset,
              height: 44,
              errorBuilder: (_, __, ___) => Text(
                'MECO',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'MECO',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.5,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _OnboardingPage(
                    headline: _headlines[0],
                    textColor: textColor,
                    mock: const _TaskManagerMock(),
                  ),
                  _OnboardingPage(
                    headline: _headlines[1],
                    textColor: textColor,
                    mock: const _DesignsMock(),
                  ),
                  _OnboardingPage(
                    headline: _headlines[2],
                    textColor: textColor,
                    mock: const _ActivityScheduleMock(),
                  ),
                  _OnboardingPage(
                    headline: _headlines[3],
                    textColor: textColor,
                    mock: const _ProgressReportMock(),
                  ),
                  _OnboardingPage(
                    headline: _headlines[4],
                    textColor: textColor,
                    mock: const _SnagsMock(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_headlines.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 10 : 8,
                  height: active ? 10 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? mecoPrimaryColor : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 0.965).animate(
                        CurvedAnimation(
                          parent: _breathController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _goToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mecoDarkAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Get started →',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: subTextColor),
                  children: [
                    const TextSpan(text: 'By signing in, I agree to '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: mecoPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _openTerms,
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: mecoPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _openPrivacy,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// One onboarding page: phone mockup + headline text below it.
class _OnboardingPage extends StatelessWidget {
  final Widget mock;
  final String headline;
  final Color textColor;

  const _OnboardingPage({
    required this.mock,
    required this.headline,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(child: Center(child: mock)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                headline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared animation helpers
// ─────────────────────────────────────────────────────────────────────────

double _staggerT(double t, double begin, double end) {
  if (t <= begin) return 0;
  if (t >= end) return 1;
  return Curves.easeOut.transform((t - begin) / (end - begin));
}

/// Fades + slides a child in during [begin, end] of the parent controller.
class _StaggerIn extends AnimatedWidget {
  final double begin;
  final double end;
  final Offset slideFrom; // multiplied by 24px
  final Widget child;

  const _StaggerIn({
    required Animation<double> controller,
    required this.begin,
    required this.end,
    this.slideFrom = const Offset(0, 0.6),
    required this.child,
  }) : super(listenable: controller);

  Animation<double> get _controller => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final t = _staggerT(_controller.value, begin, end);
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(
          slideFrom.dx * 24 * (1 - t),
          slideFrom.dy * 24 * (1 - t),
        ),
        child: child,
      ),
    );
  }
}

/// A small floating colored pill: icon + label. Positioned absolutely by
/// the caller inside a Stack.
class _CalloutBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CalloutBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The white phone-frame chrome that every mock screen sits inside,
/// matching the reference video's device mockup.
class _PhoneFrame extends StatelessWidget {
  final Widget child;
  const _PhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 340,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300, width: 6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
    );
  }
}

class _ScreenTitle extends StatelessWidget {
  final String title;
  const _ScreenTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// A skeleton row used inside the mock screens: icon + title + a light
/// placeholder bar underneath (mirrors the reference video's row style).
class _MockRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;

  const _MockRow({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted ? Colors.grey.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// White floating detail card with a drop shadow, used for the popup that
/// appears over the mock screen (approval request, progress slider,
/// snag checklist, etc).
class _FloatingCard extends StatelessWidget {
  final Widget child;
  const _FloatingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Base class: gives every mock page its own AnimationController that
// plays once (staggered entrance) when the page is built/shown.
// ─────────────────────────────────────────────────────────────────────────

abstract class _AnimatedMock extends StatefulWidget {
  const _AnimatedMock();
}

abstract class _AnimatedMockState<T extends _AnimatedMock> extends State<T>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PAGE 1 — Task Manager
// ─────────────────────────────────────────────────────────────────────────

class _TaskManagerMock extends _AnimatedMock {
  const _TaskManagerMock();
  @override
  State<_TaskManagerMock> createState() => _TaskManagerMockState();
}

class _TaskManagerMockState extends _AnimatedMockState<_TaskManagerMock> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        _PhoneFrame(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ScreenTitle('Task Manager'),
                _StaggerIn(
                  controller: controller,
                  begin: 0.05,
                  end: 0.3,
                  child: const _MockRow(
                    icon: Icons.star_border,
                    label: 'Important',
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.12,
                  end: 0.37,
                  child: const _MockRow(
                    icon: Icons.notifications_none,
                    label: 'Reminder',
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.19,
                  end: 0.44,
                  child: const _MockRow(
                    icon: Icons.alternate_email,
                    label: 'Mentions',
                  ),
                ),
                const Divider(height: 14),
                _StaggerIn(
                  controller: controller,
                  begin: 0.26,
                  end: 0.5,
                  child: const _MockRow(icon: Icons.checklist, label: 'Tasks'),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.32,
                  end: 0.56,
                  child: const _MockRow(
                    icon: Icons.swap_horiz,
                    label: 'Requests',
                    highlighted: true,
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.38,
                  end: 0.62,
                  child: const _MockRow(
                    icon: Icons.check_circle_outline,
                    label: 'Approvals',
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: -8,
          top: 90,
          child: _StaggerIn(
            controller: controller,
            begin: 0.15,
            end: 0.4,
            slideFrom: const Offset(-1, 0),
            child: const _CalloutBadge(
              icon: Icons.notifications_active,
              label: 'Alerts',
              color: mecoPrimaryColor,
            ),
          ),
        ),
        Positioned(
          right: -14,
          top: 60,
          child: _StaggerIn(
            controller: controller,
            begin: 0.3,
            end: 0.55,
            slideFrom: const Offset(1, 0),
            child: const _CalloutBadge(
              icon: Icons.fact_check,
              label: 'Requests',
              color: mecoDarkAccent,
            ),
          ),
        ),
        Positioned(
          right: -10,
          top: 130,
          child: _StaggerIn(
            controller: controller,
            begin: 0.55,
            end: 0.85,
            slideFrom: const Offset(0, 0.6),
            child: _FloatingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Priya requested an approval on vendor invoice',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Delayed',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '₹45,072',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PAGE 2 — Designs
// ─────────────────────────────────────────────────────────────────────────

class _DesignsMock extends _AnimatedMock {
  const _DesignsMock();
  @override
  State<_DesignsMock> createState() => _DesignsMockState();
}

class _DesignsMockState extends _AnimatedMockState<_DesignsMock> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        _PhoneFrame(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ScreenTitle('Designs'),
                // Simple floor-plan sketch standing in for the drawing preview.
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _StaggerIn(
                            controller: controller,
                            begin: 0.05,
                            end: 0.35,
                            child: CustomPaint(
                              painter: _FloorPlanPainter(),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: List.generate(4, (i) {
                              return _StaggerIn(
                                controller: controller,
                                begin: 0.3 + i * 0.1,
                                end: 0.55 + i * 0.1,
                                slideFrom: const Offset(0.4, 0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 8,
                                        backgroundColor: mecoPrimaryColor
                                            .withOpacity(0.6),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Container(
                                          height: 5,
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.6,
                  end: 0.8,
                  child: const _MockRow(
                    icon: Icons.picture_as_pdf,
                    label: 'IFC Ground Floor Layout  ·  V1',
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.68,
                  end: 0.88,
                  child: const _MockRow(
                    icon: Icons.map,
                    label: 'RCP Lighting Plan Level 1  ·  V2',
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
        Positioned(
          left: -10,
          top: 150,
          child: _StaggerIn(
            controller: controller,
            begin: 0.2,
            end: 0.45,
            slideFrom: const Offset(-1, 0),
            child: const _CalloutBadge(
              icon: Icons.push_pin,
              label: 'Pin',
              color: mecoPrimaryColor,
            ),
          ),
        ),
        Positioned(
          right: -14,
          top: 60,
          child: _StaggerIn(
            controller: controller,
            begin: 0.35,
            end: 0.6,
            slideFrom: const Offset(1, 0),
            child: const _CalloutBadge(
              icon: Icons.how_to_reg,
              label: 'Approvals',
              color: mecoDarkAccent,
            ),
          ),
        ),
        Positioned(
          right: -16,
          bottom: 60,
          child: _StaggerIn(
            controller: controller,
            begin: 0.5,
            end: 0.75,
            slideFrom: const Offset(1, 0),
            child: const _CalloutBadge(
              icon: Icons.layers,
              label: 'Revisions',
              color: mecoPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _FloorPlanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wall = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final highlight = Paint()
      ..color = Colors.red.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRect(Rect.fromLTWH(2, 2, size.width - 4, size.height - 4), wall);
    canvas.drawLine(
      Offset(2, size.height * 0.45),
      Offset(size.width - 2, size.height * 0.45),
      wall,
    );
    canvas.drawRect(
      Rect.fromLTWH(6, 6, size.width * 0.55, size.height * 0.35),
      highlight,
    );
    canvas.drawRect(
      Rect.fromLTWH(6, size.height * 0.52, size.width * 0.6, size.height * 0.4),
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────
// PAGE 3 — Activity Schedule
// ─────────────────────────────────────────────────────────────────────────

class _ActivityScheduleMock extends _AnimatedMock {
  const _ActivityScheduleMock();
  @override
  State<_ActivityScheduleMock> createState() => _ActivityScheduleMockState();
}

class _ActivityScheduleMockState
    extends _AnimatedMockState<_ActivityScheduleMock> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        _PhoneFrame(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ScreenTitle('Activity Schedule'),
                _StaggerIn(
                  controller: controller,
                  begin: 0.05,
                  end: 0.3,
                  child: const _MockRow(
                    icon: Icons.looks_one,
                    label: 'Kickoff Meeting',
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.12,
                  end: 0.37,
                  child: const _MockRow(
                    icon: Icons.looks_two,
                    label: 'Execution',
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.2,
                  end: 0.45,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: const _MockRow(
                      icon: Icons.expand_more,
                      label: '2.1  Civil Work',
                      highlighted: true,
                    ),
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.28,
                  end: 0.52,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 34),
                    child: const _MockRow(
                      icon: Icons.subdirectory_arrow_right,
                      label: '2.1.1  Foundation Work',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: -14,
          top: 130,
          child: _StaggerIn(
            controller: controller,
            begin: 0.18,
            end: 0.4,
            slideFrom: const Offset(-1, 0),
            child: const _CalloutBadge(
              icon: Icons.timeline,
              label: 'Critical Path',
              color: mecoPrimaryColor,
            ),
          ),
        ),
        Positioned(
          right: -18,
          top: 55,
          child: _StaggerIn(
            controller: controller,
            begin: 0.32,
            end: 0.56,
            slideFrom: const Offset(1, 0),
            child: const _CalloutBadge(
              icon: Icons.tune,
              label: 'Work Planning',
              color: mecoDarkAccent,
            ),
          ),
        ),
        Positioned(
          right: -22,
          top: 140,
          child: _StaggerIn(
            controller: controller,
            begin: 0.55,
            end: 0.85,
            slideFrom: const Offset(0, 0.6),
            child: _FloatingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2.1 Civil Work',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Delayed',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Planned End: 30 Aug',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  const Text(
                    'Actual End: 2 Sep',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  _StaggerIn(
                    controller: controller,
                    begin: 0.7,
                    end: 0.95,
                    slideFrom: const Offset(-1, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.5,
                        minHeight: 5,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(mecoPrimaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PAGE 4 — Progress Report
// ─────────────────────────────────────────────────────────────────────────

class _ProgressReportMock extends _AnimatedMock {
  const _ProgressReportMock();
  @override
  State<_ProgressReportMock> createState() => _ProgressReportMockState();
}

class _ProgressReportMockState extends _AnimatedMockState<_ProgressReportMock> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        _PhoneFrame(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ScreenTitle('Progress Report'),
                _StaggerIn(
                  controller: controller,
                  begin: 0.05,
                  end: 0.3,
                  child: const _MockRow(
                    icon: Icons.event_note,
                    label: 'Daily Log',
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.12,
                  end: 0.37,
                  child: const _MockRow(
                    icon: Icons.inventory_2,
                    label: 'Material Update',
                  ),
                ),
                const SizedBox(height: 4),
                _StaggerIn(
                  controller: controller,
                  begin: 0.22,
                  end: 0.46,
                  slideFrom: const Offset(-0.6, 0),
                  child: _ChipStat(
                    label: 'Received',
                    value: '+400 Sqft',
                    color: Colors.green,
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.3,
                  end: 0.54,
                  slideFrom: const Offset(-0.6, 0),
                  child: _ChipStat(
                    label: 'Consumed',
                    value: '-200 Sqft',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                _StaggerIn(
                  controller: controller,
                  begin: 0.4,
                  end: 0.62,
                  child: const _MockRow(icon: Icons.groups, label: 'Manpower'),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.47,
                  end: 0.68,
                  child: const _MockRow(
                    icon: Icons.place,
                    label: 'Site View Point',
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -6,
          child: _StaggerIn(
            controller: controller,
            begin: 0.55,
            end: 0.8,
            slideFrom: const Offset(0, -1),
            child: const _CalloutBadge(
              icon: Icons.summarize,
              label: 'Generate Report',
              color: mecoDarkAccent,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String label;
  final String value;
  final MaterialColor color;

  const _ChipStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.shade200),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10.5,
                color: color.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 5, color: Colors.grey.shade200)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PAGE 5 — Snags
// ─────────────────────────────────────────────────────────────────────────

class _SnagsMock extends _AnimatedMock {
  const _SnagsMock();
  @override
  State<_SnagsMock> createState() => _SnagsMockState();
}

class _SnagsMockState extends _AnimatedMockState<_SnagsMock> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        _PhoneFrame(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ScreenTitle('Snags'),
                _StaggerIn(
                  controller: controller,
                  begin: 0.05,
                  end: 0.3,
                  child: const _MockRow(
                    icon: Icons.bathtub_outlined,
                    label: 'Broken Wash Basin',
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.13,
                  end: 0.38,
                  child: const _MockRow(
                    icon: Icons.grid_view,
                    label: 'Broken Tiles',
                  ),
                ),
                _StaggerIn(
                  controller: controller,
                  begin: 0.21,
                  end: 0.46,
                  child: const _MockRow(
                    icon: Icons.cable,
                    label: 'Wire Broken',
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: -18,
          top: 50,
          child: _StaggerIn(
            controller: controller,
            begin: 0.15,
            end: 0.4,
            slideFrom: const Offset(1, 0),
            child: const _CalloutBadge(
              icon: Icons.assignment_ind,
              label: 'Assign Snag',
              color: mecoDarkAccent,
            ),
          ),
        ),
        Positioned(
          right: -10,
          top: 120,
          child: _StaggerIn(
            controller: controller,
            begin: 0.5,
            end: 0.75,
            slideFrom: const Offset(0, 0.6),
            child: _FloatingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Broken Wash Basin',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _StaggerIn(
                    controller: controller,
                    begin: 0.6,
                    end: 0.78,
                    child: const _CheckRow(
                      title: 'Assigned to Contico',
                      subtitle: 'By James Smith, 2 Jul',
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StaggerIn(
                    controller: controller,
                    begin: 0.75,
                    end: 0.95,
                    child: const _CheckRow(
                      title: 'Date Committed',
                      subtitle: 'Committed: 10 Jul',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String title;
  final String subtitle;
  const _CheckRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 14, color: mecoPrimaryColor),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 9.5, color: Colors.black45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
