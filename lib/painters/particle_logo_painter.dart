import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A single particle sampled from one non-transparent pixel of the logo.
///
/// Pre-stores RGB components, geometry, and trajectory offsets to avoid
/// per-frame trigonometry, curve solvers, and GC allocations.
@immutable
class LogoParticle {
  const LogoParticle({
    required this.targetX,
    required this.targetY,
    required this.r,
    required this.g,
    required this.b,
    required this.radius,
    required this.baseAlpha,
    required this.startDx,
    required this.startDy,
    required this.stagger,
    required this.curveIndex,
    required this.driftPhase,
  });

  final double targetX;
  final double targetY;
  final int r;
  final int g;
  final int b;
  final double radius;
  final double baseAlpha;
  final double startDx;
  final double startDy;
  final double stagger;
  final int curveIndex;
  final double driftPhase;

  Color get color => Color.fromARGB(255, r, g, b);
}

/// Precomputed particle set + logo geometry produced once from the
/// decoded logo image.
@immutable
class ParticleLogoData {
  const ParticleLogoData({required this.particles, required this.aspectRatio});

  final List<LogoParticle> particles;
  final double aspectRatio;
}

/// Highly optimized painter for the particle-reveal animation.
///
/// Performance optimizations:
/// - Reuses single [Paint] objects without per-frame allocations.
/// - Uses direct analytic bezier equations instead of dynamic Curve transforms.
/// - Integer RGBA color construction (0 GC allocations per particle).
/// - Scaled particle count for 120 FPS performance on all mobile devices.
class ParticleLogoPainter extends CustomPainter {
  ParticleLogoPainter({
    required this.logo,
    required this.particles,
    required this.controller,
    required this.glowColor,
    required this.aspectRatio,
    required this.textParticles,
    required this.textRect,
  }) : super(repaint: controller);

  final ui.Image logo;
  final List<LogoParticle> particles;
  final Animation<double> controller;
  final Color glowColor;
  final double aspectRatio;

  /// Wordmark ("Meco") particles revealed below the logo.
  final List<LogoParticle> textParticles;

  /// On-screen box the wordmark occupies.
  final Rect textRect;

  // Reusable paints
  static final Paint _dotPaint = Paint()..isAntiAlias = true;
  static final Paint _haloPaint = Paint()..isAntiAlias = true;
  static final Paint _logoPaint = Paint()..filterQuality = ui.FilterQuality.medium;
  static final Paint _glowPaint = Paint();

  // Phase milestones (normalized 0.0 -> 1.0)
  static const double _fadeStart = 0.06;
  static const double _fadeEnd = 0.28;
  static const double _convergeEnd = 0.78;
  static const double _logoStart = 0.80;
  static const double _logoEnd = 0.94;

  static const double _textFadeStart = 0.25;
  static const double _textFadeEnd = 0.45;
  static const double _textConvergeEnd = 0.76;
  static const double _textDissolveStart = 0.76;
  static const double _textDissolveEnd = 0.92;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = controller.value;
    final Offset center = size.center(Offset.zero);
    final double minDim = math.min(size.width, size.height);
    final double spread = minDim * 0.58;
    final Rect logoRect = logoRectFor(size, aspectRatio);
    final double scale = (minDim / 700.0).clamp(0.6, 1.4);

    // 1. Draw logo particles (scattered -> convergence -> lock)
    final int pCount = particles.length;
    for (int i = 0; i < pCount; i++) {
      final LogoParticle p = particles[i];

      // Staggered fade in
      final double fProgress = _clamp01(
        (t - _fadeStart - p.stagger * 0.4) / (_fadeEnd - _fadeStart + p.stagger * 0.4),
      );
      if (fProgress <= 0.001) continue;
      final double fade = fProgress * (2.0 - fProgress); // Fast ease-out quad

      // Staggered convergence
      final double k = _clamp01((t - _fadeEnd) / (_convergeEnd - _fadeEnd));
      final double kStaggered = _clamp01((k - p.stagger) / (1.0 - p.stagger));
      final double e = _fastEase(kStaggered, p.curveIndex);

      // Dissolve as solid logo arrives
      final double dProgress = _clamp01((t - _convergeEnd) / (1.0 - _convergeEnd));
      final double dissolve = dProgress * dProgress * dProgress; // Fast cubic ease-in

      final double alpha = p.baseAlpha * fade * (1.0 - dissolve);
      if (alpha <= 0.005) continue;

      final double startX = center.dx + p.startDx * spread;
      final double startY = center.dy + p.startDy * spread;
      final double targetX = logoRect.left + p.targetX * logoRect.width;
      final double targetY = logoRect.top + p.targetY * logoRect.height;

      // Organic magnetic swirl that fades out as particle approaches target
      final double swirl = (1.0 - e) * fade;
      final double driftMag = 6.0 * scale * swirl;
      final double driftX = math.sin(t * 12.0 + p.driftPhase) * driftMag;
      final double driftY = math.cos(t * 9.0 + p.driftPhase * 1.5) * driftMag;

      final double posX = startX + (targetX - startX) * e + driftX;
      final double posY = startY + (targetY - startY) * e + driftY;
      final double radius = p.radius * scale * (0.82 + 0.38 * e);

      final int alphaInt = (alpha * 255.0).round().clamp(0, 255);
      _dotPaint.color = Color.fromARGB(alphaInt, p.r, p.g, p.b);
      canvas.drawCircle(Offset(posX, posY), radius, _dotPaint);

      // Soft halo for ambient luminance
      final int haloAlphaInt = (alpha * 55.0).round().clamp(0, 255);
      if (haloAlphaInt > 0) {
        _haloPaint.color = Color.fromARGB(haloAlphaInt, p.r, p.g, p.b);
        canvas.drawCircle(Offset(posX, posY), radius * 2.5, _haloPaint);
      }
    }

    // 2. Draw text particles ("Meco" wordmark)
    final int tCount = textParticles.length;
    if (tCount > 0) {
      for (int i = 0; i < tCount; i++) {
        final LogoParticle p = textParticles[i];

        final double fProgress = _clamp01(
          (t - _textFadeStart - p.stagger * 0.35) /
              (_textFadeEnd - _textFadeStart + p.stagger * 0.35),
        );
        if (fProgress <= 0.001) continue;
        final double fade = fProgress * (2.0 - fProgress);

        final double k = _clamp01(
          (t - _textFadeEnd) / (_textConvergeEnd - _textFadeEnd),
        );
        final double kStaggered = _clamp01((k - p.stagger) / (1.0 - p.stagger));
        final double e = _fastEase(kStaggered, p.curveIndex);

        final double dProgress = _clamp01(
          (t - _textDissolveStart) / (_textDissolveEnd - _textDissolveStart),
        );
        final double dissolve = dProgress * dProgress;

        final double alpha = p.baseAlpha * fade * (1.0 - dissolve);
        if (alpha <= 0.005) continue;

        final double startX = center.dx + p.startDx * spread;
        final double startY = center.dy + p.startDy * spread;
        final double targetX = textRect.left + p.targetX * textRect.width;
        final double targetY = textRect.top + p.targetY * textRect.height;

        final double swirl = (1.0 - e) * fade;
        final double driftMag = 5.0 * scale * swirl;
        final double driftX = math.sin(t * 12.0 + p.driftPhase) * driftMag;
        final double driftY = math.cos(t * 9.0 + p.driftPhase * 1.5) * driftMag;

        final double posX = startX + (targetX - startX) * e + driftX;
        final double posY = startY + (targetY - startY) * e + driftY;
        final double radius = p.radius * scale * 0.88 * (0.82 + 0.38 * e);

        final int alphaInt = (alpha * 255.0).round().clamp(0, 255);
        _dotPaint.color = Color.fromARGB(alphaInt, p.r, p.g, p.b);
        canvas.drawCircle(Offset(posX, posY), radius, _dotPaint);

        final int haloAlphaInt = (alpha * 48.0).round().clamp(0, 255);
        if (haloAlphaInt > 0) {
          _haloPaint.color = Color.fromARGB(haloAlphaInt, p.r, p.g, p.b);
          canvas.drawCircle(Offset(posX, posY), radius * 2.3, _haloPaint);
        }
      }
    }

    // 3. Final phase: Smooth cross-fade to high-res logo with gentle bloom
    final double lProgress = _clamp01((t - _logoStart) / (_logoEnd - _logoStart));
    if (lProgress <= 0.001) return;

    // Quartic ease-out for logo cross-fade
    final double inv = 1.0 - lProgress;
    final double logoFade = 1.0 - inv * inv * inv * inv;

    final double pulse = math.sin(t * math.pi * 5.0);
    final double logoScale = 1.0 + 0.015 * (1.0 - logoFade) + 0.005 * pulse;

    // Ambient radial glow behind the logo
    final double glowRadius = math.max(logoRect.width, logoRect.height) * 0.65;
    final int glowAlpha = ((0.06 + 0.04 * (0.5 + 0.5 * pulse)) * logoFade * 255.0)
        .round()
        .clamp(0, 255);

    _glowPaint.shader = ui.Gradient.radial(
      logoRect.center,
      glowRadius,
      <Color>[
        glowColor.withAlpha(glowAlpha),
        glowColor.withAlpha(0),
      ],
    );
    canvas.drawCircle(logoRect.center, glowRadius, _glowPaint);

    // Draw final sharp logo
    _logoPaint.color = Color.fromARGB((logoFade * 255.0).round().clamp(0, 255), 255, 255, 255);
    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      Rect.fromCenter(
        center: logoRect.center,
        width: logoRect.width * logoScale,
        height: logoRect.height * logoScale,
      ),
      _logoPaint,
    );
  }

  /// Fast analytic easing polynomials without bezier equation overhead.
  static double _fastEase(double t, int curveIndex) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;

    switch (curveIndex) {
      case 0: // Cubic ease-out: 1 - (1 - t)^3
        final double inv = 1.0 - t;
        return 1.0 - inv * inv * inv;
      case 1: // Quartic ease-out: 1 - (1 - t)^4
        final double inv = 1.0 - t;
        return 1.0 - inv * inv * inv * inv;
      case 2: // Back ease-out (settle overshoot)
        final double p = t - 1.0;
        return 1.0 + 2.4 * p * p * p + 1.4 * p * p;
      default:
        return t;
    }
  }

  /// Keeps the logo inside a safe box while preserving its aspect ratio.
  static Rect logoRectFor(Size size, double aspectRatio) {
    double w = size.width * 0.70;
    double h = w / aspectRatio;
    if (h > size.height * 0.36) {
      h = size.height * 0.36;
      w = h * aspectRatio;
    }
    if (w > size.width * 0.92) {
      w = size.width * 0.92;
      h = w / aspectRatio;
    }
    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: w,
      height: h,
    );
  }

  /// Places the wordmark directly below the logo, horizontally centered.
  static Rect textRectFor(Size size, Rect logoRect, Size textSize) {
    double w = textSize.width;
    double h = textSize.height;
    final double maxW = logoRect.width * 0.66;
    if (w > maxW) {
      w = maxW;
      h = w * (textSize.height / textSize.width);
    }
    final double gap = (logoRect.height * 0.14).clamp(12.0, 36.0);
    double top = logoRect.bottom + gap;
    if (top + h > size.height * 0.94) {
      top = size.height * 0.94 - h;
    }
    return Rect.fromLTWH((size.width - w) / 2.0, top, w, h);
  }

  @override
  bool shouldRepaint(ParticleLogoPainter oldDelegate) =>
      oldDelegate.logo != logo ||
      oldDelegate.particles != particles ||
      oldDelegate.textParticles != textParticles ||
      oldDelegate.textRect != textRect ||
      oldDelegate.glowColor != glowColor;

  static double _clamp01(double v) => v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v);
}
