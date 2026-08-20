import 'package:flutter/material.dart';

import '../auth/permissions.dart';
import '../models/demo_user.dart';
import '../session.dart';
import '../theme.dart';
import '../widgets/meco_scaffold.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DemoUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final DemoUser? user = await Session.currentUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  void _handleCreate() {
    // Placeholder — existing Create behavior, unchanged for this prototype.
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool createEnabled = _user != null &&
        userHasPermission(_user!, AppPermission.createDashboard);

    return MecoScaffold(
      title: 'Insights',
      currentRoute: 'Insights',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dashboard empty-state illustration
                    const _DashboardIllustration(),
                    const SizedBox(height: 32),
                    Text(
                      'Create Dashboards Collection to get started',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: createEnabled ? _handleCreate : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: scheme.surfaceContainerHighest,
                        disabledForegroundColor: scheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dashboard empty-state illustration ──────────────────────────────────────

class _DashboardIllustration extends StatelessWidget {
  const _DashboardIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Pie chart
          Positioned(
            left: 0,
            top: 20,
            child: CustomPaint(
              size: const Size(110, 110),
              painter: _PieChartPainter(),
            ),
          ),

          // Person figure
          Positioned(
            right: 10,
            top: 0,
            child: const _PersonFigure(),
          ),

          // Checkmark badge near pie chart top
          const Positioned(
            left: 90,
            top: 5,
            child: _CheckBadge(),
          ),

          // Checkmark badge near person mid
          const Positioned(
            right: 52,
            top: 88,
            child: _CheckBadge(),
          ),

          // Checkmark badge near pie chart bottom-left
          const Positioned(
            left: 44,
            top: 118,
            child: _CheckBadge(),
          ),
        ],
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppPalette.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 14),
    );
  }
}

class _PersonFigure extends StatelessWidget {
  const _PersonFigure();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 180,
      child: CustomPaint(
        painter: _PersonPainter(),
      ),
    );
  }
}

class _PersonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = const Color(0xFFE0E0E0);
    final darkPaint = Paint()..color = const Color(0xFF37474F);
    final skinPaint = Paint()..color = const Color(0xFFFFCCBC);
    final greenPaint = Paint()..color = AppPalette.green;

    // Head
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.08), 12, skinPaint);
    // Hair
    final hairPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width * 0.55, size.height * 0.08), radius: 12),
      3.14, 3.14, false, hairPaint,
    );

    // Torso
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.32, size.height * 0.22, size.width * 0.36, size.height * 0.32),
      const Radius.circular(6),
    );
    canvas.drawRRect(torsoRect, bodyPaint);

    // Left arm (raised up-left)
    final leftArmPath = Path()
      ..moveTo(size.width * 0.36, size.height * 0.26)
      ..cubicTo(
        size.width * 0.20, size.height * 0.18,
        size.width * 0.08, size.height * 0.10,
        size.width * 0.04, size.height * 0.04,
      );
    canvas.drawPath(leftArmPath, Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);

    // Right arm (holding badge)
    final rightArmPath = Path()
      ..moveTo(size.width * 0.68, size.height * 0.28)
      ..cubicTo(
        size.width * 0.78, size.height * 0.32,
        size.width * 0.82, size.height * 0.40,
        size.width * 0.78, size.height * 0.50,
      );
    canvas.drawPath(rightArmPath, Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);

    // Green badge in right hand
    canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.53), 9, greenPaint);
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final cx = size.width * 0.76;
    final cy = size.height * 0.53;
    final checkPath = Path()
      ..moveTo(cx - 4, cy)
      ..lineTo(cx - 1, cy + 3)
      ..lineTo(cx + 4, cy - 3);
    canvas.drawPath(checkPath, checkPaint);

    // Left leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.36, size.height * 0.54, size.width * 0.14, size.height * 0.28),
        const Radius.circular(6),
      ),
      darkPaint,
    );
    // Right leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.54, size.height * 0.54, size.width * 0.14, size.height * 0.28),
        const Radius.circular(6),
      ),
      darkPaint,
    );

    // Left shoe
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.80, size.width * 0.22, size.height * 0.07),
      darkPaint,
    );
    // Right shoe
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.52, size.height * 0.80, size.width * 0.22, size.height * 0.07),
      darkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const gap = 0.06; // gap between slices in radians

    final slices = [
      // angle start, sweep, color
      (_PieSlice(-1.57, 1.60, AppPalette.green)),   // green (top-right, largest)
      (_PieSlice(0.09,  0.90, const Color(0xFF78909C))),   // blue-grey (right)
      (_PieSlice(1.05,  1.05, const Color(0xFFB0BEC5))),   // light grey (bottom)
      (_PieSlice(2.16,  0.90, const Color(0xFFCFD8DC))),   // lightest grey (left)
      (_PieSlice(3.12,  1.45, const Color(0xFFECEFF1))),   // near-white (top-left)
    ];

    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in slices) {
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        s.start + gap / 2,
        s.sweep - gap,
        true,
        paint,
      );
    }

    // White center circle (donut)
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.42, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PieSlice {
  final double start;
  final double sweep;
  final Color color;
  const _PieSlice(this.start, this.sweep, this.color);
}
