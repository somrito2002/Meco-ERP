import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painters/particle_logo_painter.dart';
import '../theme.dart';

/// Decodes the logo asset with optimized native downsampling, samples visible
/// pixels into particles, and smoothly reveals the real logo with high-performance
/// particle choreography.
class ParticleLogoReveal extends StatefulWidget {
  const ParticleLogoReveal({
    super.key,
    required this.assetPath,
    required this.onComplete,
    this.glowColor,
    this.text = 'MECO',
  });

  final String assetPath;
  final VoidCallback onComplete;
  final Color? glowColor;

  /// Wordmark revealed in particle form below the logo. Empty string hides it.
  final String text;

  @override
  State<ParticleLogoReveal> createState() => _ParticleLogoRevealState();
}

class _ParticleLogoRevealState extends State<ParticleLogoReveal>
    with TickerProviderStateMixin {
  /// Fixed seed so the scatter layout is identical on every launch.
  static const int _seed = 0x5EEDC0DE;
  static const Duration _animationDuration = Duration(milliseconds: 2100);

  late final AnimationController _controller;
  late final Animation<double> _solidTextFade;
  AnimationController? _fadeIn;

  ui.Image? _logoImage;
  ParticleLogoData? _logoData;
  List<LogoParticle>? _textParticles;

  bool _loading = true;
  bool _fallback = false;
  bool _reduceMotion = false;
  bool _motionChecked = false;
  bool _finished = false;
  bool _fallbackStarted = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..addStatusListener(_onAnimationStatus);

    _solidTextFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.76, 0.92, curve: Curves.easeOutQuad),
    );
    _loadLogo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionChecked) return;
    _motionChecked = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _reduceMotion = true;
      _startFallback();
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _finish();
  }

  /// Loads the full logo asset and decodes a sampling frame natively
  /// for instant startup (< 8ms sampling time).
  Future<void> _loadLogo() async {
    try {
      final ByteData raw = await rootBundle.load(widget.assetPath);
      final Uint8List rawBytes = raw.buffer.asUint8List(
        raw.offsetInBytes,
        raw.lengthInBytes,
      );

      // 1. Decode sampling frame downsampled natively in C++/engine
      final ui.Codec sampleCodec = await ui.instantiateImageCodec(
        rawBytes,
        targetWidth: 260,
      );
      final ui.Image sampleImage = (await sampleCodec.getNextFrame()).image;

      // 2. Decode full-resolution image for final crystal-clear reveal
      final ui.Codec fullCodec = await ui.instantiateImageCodec(rawBytes);
      final ui.Image fullImage = (await fullCodec.getNextFrame()).image;

      if (!mounted) {
        sampleImage.dispose();
        fullImage.dispose();
        return;
      }
      if (_reduceMotion) {
        sampleImage.dispose();
        fullImage.dispose();
        _startFallback();
        return;
      }

      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      final ParticleLogoData? data = await _buildParticleData(
        sampleImage,
        isDark: isDark,
      );
      sampleImage.dispose();

      final List<LogoParticle>? textParticles = await _buildTextParticles();

      if (!mounted) {
        fullImage.dispose();
        return;
      }
      if (data == null || data.particles.isEmpty) {
        fullImage.dispose();
        _startFallback();
        return;
      }

      setState(() {
        _loading = false;
        _logoImage = fullImage;
        _logoData = data;
        _textParticles = textParticles;
      });
      _controller.forward();
    } catch (_) {
      if (!mounted) return;
      _startFallback();
    }
  }

  /// Samples non-transparent pixels into optimized LogoParticle structs.
  Future<ParticleLogoData?> _buildParticleData(
    ui.Image image, {
    required bool isDark,
  }) async {
    final ByteData? pixelData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (pixelData == null) return null;

    final Uint8List pixels = pixelData.buffer.asUint8List();
    final int w = image.width;
    final int h = image.height;
    final List<LogoParticle> particles = _samplePixels(
      pixels: pixels,
      w: w,
      h: h,
      targetCount: 320,
      colorTransformer: (int r, int g, int b, int a) {
        if (!isDark) return (r: r, g: g, b: b);
        // In dark mode lift very dark pixels slightly for contrast
        final int brightness = (r * 299 + g * 587 + b * 114) ~/ 1000;
        if (brightness < 60) {
          return (
            r: (r + 40).clamp(0, 255),
            g: (g + 40).clamp(0, 255),
            b: (b + 40).clamp(0, 255),
          );
        }
        return (r: r, g: g, b: b);
      },
    );
    return ParticleLogoData(particles: particles, aspectRatio: w / h);
  }

  /// Renders the "Meco" wordmark into an offscreen buffer and samples
  /// clean points corresponding to letter geometry.
  Future<List<LogoParticle>?> _buildTextParticles() async {
    if (widget.text.isEmpty) return null;
    try {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      final Color textColor = isDark ? Colors.white : AppPalette.ink;
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: widget.text,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 140,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      final int imgW = painter.width.ceil();
      final int imgH = painter.height.ceil();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);
      painter.paint(canvas, Offset.zero);

      final ui.Image image = await recorder.endRecording().toImage(imgW, imgH);
      final ByteData? pixelData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      image.dispose();
      if (pixelData == null) return null;

      final Uint8List pixels = pixelData.buffer.asUint8List();
      final int tr = (textColor.r * 255.0).round();
      final int tg = (textColor.g * 255.0).round();
      final int tb = (textColor.b * 255.0).round();

      return _samplePixels(
        pixels: pixels,
        w: imgW,
        h: imgH,
        targetCount: 130,
        colorTransformer: (r, g, b, a) => (r: tr, g: tg, b: tb),
      );
    } catch (_) {
      return null;
    }
  }

  /// Fast uniform particle sampler.
  List<LogoParticle> _samplePixels({
    required Uint8List pixels,
    required int w,
    required int h,
    required int targetCount,
    required ({int r, int g, int b}) Function(int r, int g, int b, int a)
        colorTransformer,
  }) {
    final math.Random rng = math.Random(_seed);
    final List<int> opaque = <int>[];

    final int totalPixels = w * h;
    final int stride = math.max(1, totalPixels ~/ (targetCount * 4));

    for (int idx = 0; idx < totalPixels; idx += stride) {
      final int byteOffset = idx * 4;
      if (byteOffset + 3 < pixels.length && pixels[byteOffset + 3] >= 50) {
        opaque.add(byteOffset);
      }
    }

    if (opaque.length < targetCount) {
      for (int byteOffset = 0; byteOffset < pixels.length; byteOffset += 4) {
        if (pixels[byteOffset + 3] >= 50) {
          opaque.add(byteOffset);
        }
      }
    }

    opaque.shuffle(rng);
    final int count = math.min(targetCount, opaque.length);

    return List<LogoParticle>.generate(count, (int n) {
      final int i = opaque[n];
      final int px = i ~/ 4;
      final int r = pixels[i];
      final int g = pixels[i + 1];
      final int b = pixels[i + 2];
      final int a = pixels[i + 3];
      final ({int r, int g, int b}) rgb = colorTransformer(r, g, b, a);

      final double angle = rng.nextDouble() * math.pi * 2.0;
      final double distance = 0.45 + rng.nextDouble() * 0.70;

      return LogoParticle(
        targetX: (px % w + 0.5) / w,
        targetY: (px ~/ w + 0.5) / h,
        r: rgb.r,
        g: rgb.g,
        b: rgb.b,
        radius: 1.1 + rng.nextDouble() * 1.3,
        baseAlpha: 0.60 + rng.nextDouble() * 0.40,
        startDx: math.cos(angle) * distance,
        startDy: math.sin(angle) * distance,
        stagger: rng.nextDouble() * 0.50,
        curveIndex: rng.nextDouble() < 0.20
            ? 2
            : (rng.nextDouble() < 0.50 ? 0 : 1),
        driftPhase: rng.nextDouble() * math.pi * 2.0,
      );
    });
  }

  void _startFallback() {
    if (_fallbackStarted) return;
    _fallbackStarted = true;

    final AnimationController fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    setState(() {
      _loading = false;
      _fallback = true;
      _fadeIn = fade;
    });
    fade.forward();
    _fallbackTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) _finish();
    });
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeIn?.dispose();
    _fallbackTimer?.cancel();
    _logoImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fallback || _reduceMotion) {
      final Animation<double> opacity =
          _fadeIn ?? const AlwaysStoppedAnimation<double>(1.0);
      return SizedBox.expand(
        child: FadeTransition(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.75,
                  ),
                  child: Image.asset(
                    widget.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.apartment_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.text,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 44,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppPalette.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final ui.Image? image = _logoImage;
    final ParticleLogoData? data = _logoData;
    if (_loading || image == null || data == null) {
      return const SizedBox.shrink();
    }

    final Size screenSize = MediaQuery.sizeOf(context);
    final Rect logoRect = ParticleLogoPainter.logoRectFor(
      screenSize, // Pass screen size to calculate relative logo size
      data.aspectRatio,
    );
    final TextStyle solidStyle = _solidTextStyle(context, screenSize);
    final TextPainter measure = TextPainter(
      text: TextSpan(text: widget.text, style: solidStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    final Rect textRect = ParticleLogoPainter.textRectFor(
      screenSize,
      logoRect,
      Size(measure.width, measure.height),
    );

    // Calculate the total bounding box height for the logo and text
    final double totalHeight = textRect.bottom - logoRect.top;
    final double totalWidth = screenSize.width; // Use full width

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: CustomPaint(
              painter: ParticleLogoPainter(
                logo: image,
                particles: data.particles,
                controller: _controller,
                aspectRatio: data.aspectRatio,
                textParticles: _textParticles ?? const <LogoParticle>[],
                textRect: Rect.fromLTWH(
                  textRect.left,
                  textRect.top - logoRect.top, // Offset to local coordinates
                  textRect.width,
                  textRect.height,
                ),
                glowColor: widget.glowColor ??
                    Theme.of(context).colorScheme.primary,
                screenSize: screenSize,
                localOffset: Offset(0, -logoRect.top), // Pass this to painter
              ),
            ),
          ),
          if (widget.text.isNotEmpty)
            Positioned(
              left: textRect.left,
              top: textRect.top - logoRect.top, // Offset to local coordinates
              width: textRect.width,
              height: textRect.height,
              child: FadeTransition(
                opacity: _solidTextFade,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: Text(widget.text, style: solidStyle),
                ),
              ),
            ),
        ],
      ),
    );
  }

  TextStyle _solidTextStyle(BuildContext context, Size size) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = 44.0;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      color: isDark ? Colors.white : AppPalette.ink,
    );
  }
}
