import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A single particle sampled from one non-transparent pixel of the logo.
///
/// [targetX] / [targetY] are normalized coordinates inside the logo box.
/// [startDx] / [startDy] are the precomputed offset of the scattered start
/// position (unit vector toward [angle] times [distance]), so the painter
/// never recomputes trigonometry per frame.
@immutable
class LogoParticle {
  const LogoParticle({
    required this.targetX,
    required this.targetY,
    required this.color,
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
  final Color color;
  final double radius;
  final double baseAlpha;
  final double startDx;
  final double startDy;
  final double stagger;
  final int curveIndex;
  final double driftPhase;
}

/// Precomputed particle set + logo geometry produced once from the
/// decoded logo image (never regenerated during animation).
@immutable
class ParticleLogoData {
  const ParticleLogoData({required this.particles, required this.aspectRatio});

  final List<LogoParticle> particles;
  final double aspectRatio;
}

/// Paints the whole particle-reveal animation onto a single [Canvas].
///
/// The painter is repainted via its `repaint` listenable (the animation
/// controller), so no widgets are rebuilt on animation frames.
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

  /// On-screen box the wordmark occupies. The solid Roboto wordmark drawn
  /// by the widget fills this exact box, so the particle targets line up
  /// perfectly with the final text.
  final Rect textRect;

  /// Motion curves: most particles ease out gently, some use a stronger
  /// exponential ease, and ~16% overshoot past their target then settle.
  static const List<Curve> _curves = <Curve>[
    Curves.easeOutCubic,
    Curves.easeOutExpo,
    Curves.easeOutBack,
  ];

  // Phase boundaries as a fraction of the total animation (~2.2 s):
  //   1. empty screen        (0.00 - 0.09)
  //   2. logo particles fade in   (0.09 - 0.32)
  //   3. logo particles converge  (0.32 - 0.80)
  //   4. logo dissolves as the real image cross-fades in (0.80 - 1.00)
  //   5. wordmark particles form  (0.30 - 0.78), slightly after the logo
  //   6. wordmark particles dissolve while the solid Roboto wordmark
  //      cross-fades in           (0.78 - 0.94)
  static const double _fadeStart = 0.09;
  static const double _fadeEnd = 0.32;
  static const double _convergeEnd = 0.80;
  static const double _logoStart = 0.84;
  static const double _logoEnd = 0.95;

  static const double _textFadeStart = 0.30;
  static const double _textFadeEnd = 0.48;
  static const double _textConvergeEnd = 0.78;
  static const double _textDissolveStart = 0.78;
  static const double _textDissolveEnd = 0.94;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = controller.value;
    final Offset center = size.center(Offset.zero);
    final double spread = math.min(size.width, size.height) * 0.58;
    final Rect logoRect = logoRectFor(size, aspectRatio);
    final double scale =
        (math.min(size.width, size.height) / 700).clamp(0.55, 1.5);

    // Reused per-frame paints (never per-particle allocations).
    final Paint dot = Paint();
    final Paint halo = Paint();

    // Phases 1-3: staggered fade-in at scattered positions, then
    // convergence onto the logo's own pixels with an organic swirl.
    for (final LogoParticle p in particles) {
      final double fade = Curves.easeOutQuad.transform(
        _clamp01((t - _fadeStart - p.stagger * 0.5) / (_fadeEnd - _fadeStart + p.stagger)),
      );
      if (fade <= 0.001) continue;

      final double k = _clamp01((t - _fadeEnd) / (_convergeEnd - _fadeEnd));
      final double kStaggered = _clamp01((k - p.stagger) / (1.0 - p.stagger));
      final double e = _curves[p.curveIndex].transform(kStaggered);

      final double dissolve = Curves.easeInCubic.transform(
        _clamp01((t - _convergeEnd) / (1.0 - _convergeEnd)),
      );

      final double alpha = p.baseAlpha * fade * (1.0 - dissolve);
      if (alpha <= 0.004) continue;

      final Offset start = center +
          Offset(p.startDx * spread, p.startDy * spread);
      final Offset target = Offset(
        logoRect.left + p.targetX * logoRect.width,
        logoRect.top + p.targetY * logoRect.height,
      );

      // Gentle drift that is strongest while the particle is far from its
      // target, giving the convergence an organic, non-mechanical feel.
      final double swirl = math.max(0.0, 1.0 - e) * fade * fade;
      final Offset drift = Offset(
        math.sin(t * 14.0 + p.driftPhase),
        math.cos(t * 10.0 + p.driftPhase * 1.7),
      ) * (7.0 * scale * swirl);

      final Offset pos = Offset.lerp(start, target, e)! + drift;
      final double radius = p.radius * scale * (0.8 + 0.35 * e);

      dot.color = p.color.withValues(alpha: alpha);
      canvas.drawCircle(pos, radius, dot);

      // Soft halo makes the point glow without expensive blur passes.
      halo.color = p.color.withValues(alpha: alpha * 0.22);
      canvas.drawCircle(pos, radius * 2.6, halo);
    }

    // Phases 5-6: the "Meco" wordmark particles scatter in and converge
    // below the logo, then dissolve while the solid Roboto wordmark
    // cross-fades in (drawn by the widget over this canvas).
    if (textParticles.isNotEmpty) {
      for (final LogoParticle p in textParticles) {
        final double fade = Curves.easeOutQuad.transform(
          _clamp01(
            (t - _textFadeStart - p.stagger * 0.4) /
                (_textFadeEnd - _textFadeStart + p.stagger * 0.4),
          ),
        );
        if (fade <= 0.001) continue;

        final double k = _clamp01(
          (t - _textFadeEnd) / (_textConvergeEnd - _textFadeEnd),
        );
        final double kStaggered = _clamp01((k - p.stagger) / (1.0 - p.stagger));
        final double e = _curves[p.curveIndex].transform(kStaggered);

        final double dissolve = Curves.easeInCubic.transform(
          _clamp01(
            (t - _textDissolveStart) /
                (_textDissolveEnd - _textDissolveStart),
          ),
        );

        final double alpha = p.baseAlpha * fade * (1.0 - dissolve);
        if (alpha <= 0.004) continue;

        final Offset start = center +
            Offset(p.startDx * spread, p.startDy * spread);
        final Offset target = Offset(
          textRect.left + p.targetX * textRect.width,
          textRect.top + p.targetY * textRect.height,
        );

        // Gentle drift, same organic feel as the logo convergence.
        final double swirl = math.max(0.0, 1.0 - e) * fade * fade;
        final Offset drift = Offset(
          math.sin(t * 14.0 + p.driftPhase),
          math.cos(t * 10.0 + p.driftPhase * 1.7),
        ) * (7.0 * scale * swirl);

        final Offset pos = Offset.lerp(start, target, e)! + drift;
        final double radius = p.radius * scale * 0.9 * (0.8 + 0.35 * e);

        dot.color = p.color.withValues(alpha: alpha);
        canvas.drawCircle(pos, radius, dot);

        halo.color = p.color.withValues(alpha: alpha * 0.22);
        canvas.drawCircle(pos, radius * 2.6, halo);
      }
    }

    // Phase 4: cross-fade the real logo in and pulse it very subtly.
    final double logoFade = Curves.easeOutQuart.transform(
      _clamp01((t - _logoStart) / (_logoEnd - _logoStart)),
    );
    if (logoFade <= 0.001) return;

    final double pulse = math.sin(t * math.pi * 6.0);
    final double logoScale = 1.0 + 0.02 * (1.0 - logoFade) + 0.006 * pulse;

    // Subtle glow behind the logo while it materializes.
    final double glowRadius = math.max(logoRect.width, logoRect.height) * 0.62;
    canvas.drawCircle(
      logoRect.center,
      glowRadius,
      Paint()
        ..shader = ui.Gradient.radial(
          logoRect.center,
          glowRadius,
          <Color>[
            glowColor.withValues(
              alpha: (0.05 + 0.03 * (0.5 + 0.5 * pulse)) * logoFade,
            ),
            glowColor.withValues(alpha: 0.0),
          ],
        ),
    );

    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      Rect.fromCenter(
        center: logoRect.center,
        width: logoRect.width * logoScale,
        height: logoRect.height * logoScale,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: logoFade)
        ..filterQuality = ui.FilterQuality.high,
    );
  }

  /// Keeps the logo inside a safe box while preserving its aspect ratio.
  /// Shared with the widget so both particle and image layouts match.
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

  /// Places the wordmark directly below the logo, horizontally centered,
  /// keeping the logo + text pair inside the screen. [textSize] is the
  /// natural size of the solid Roboto wordmark.
  /// Shared with the widget so particle targets and the solid text align.
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
