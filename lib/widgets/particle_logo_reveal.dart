import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painters/particle_logo_painter.dart';
import '../theme.dart';

/// Decodes the logo asset once, samples its visible pixels into particles
/// and reveals the real logo with a particle-construction animation.
///
/// The final logo that stays on screen is the original asset image, never
/// an approximation. The wordmark below the logo (e.g. "Meco") is revealed
/// by the same particle mechanism and then resolves into a clean solid
/// Roboto text widget that fills the exact same box.
class ParticleLogoReveal extends StatefulWidget {
  const ParticleLogoReveal({
    super.key,
    required this.assetPath,
    required this.onComplete,
    this.glowColor,
    this.text = 'Meco',
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
  static const Duration _animationDuration = Duration(milliseconds: 2200);

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
    // The solid Roboto wordmark fades in as the text particles dissolve.
    // Keep this window in sync with ParticleLogoPainter's text dissolve.
    _solidTextFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 0.94, curve: Curves.easeOutQuad),
    );
    _loadLogo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionChecked) return;
    _motionChecked = true;
    // Respect the platform "reduce motion" setting: skip the particle
    // animation and show a short fade-in of the plain logo instead.
    if (MediaQuery.disableAnimationsOf(context)) {
      _reduceMotion = true;
      _startFallback();
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _finish();
  }

  /// Loads and decodes the logo image exactly once, then generates the
  /// particle set from its actual pixels.
  Future<void> _loadLogo() async {
    try {
      final ByteData raw = await rootBundle.load(widget.assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes),
      );
      final ui.Image image = (await codec.getNextFrame()).image;

      if (!mounted) {
        image.dispose();
        return;
      }
      if (_reduceMotion) {
        image.dispose();
        _startFallback();
        return;
      }

      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      final ParticleLogoData? data = await _buildParticleData(
        image,
        isDark: isDark,
      );
      final List<LogoParticle>? textParticles = await _buildTextParticles();

      if (!mounted) {
        image.dispose();
        return;
      }
      if (data == null || data.particles.isEmpty) {
        image.dispose();
        _startFallback();
        return;
      }

      setState(() {
        _loading = false;
        _logoImage = image;
        _logoData = data;
        _textParticles = textParticles;
      });
      _controller.forward();
    } catch (_) {
      // Graceful degradation: show the plain logo and continue navigation.
      if (!mounted) return;
      _startFallback();
    }
  }

  /// Samples non-transparent pixels of the decoded logo and converts them
  /// into particles whose targets reproduce the logo shape and colors.
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
      colorAt: (int i) => _themeAwareColor(
        Color.fromARGB(
          pixels[i + 3],
          pixels[i],
          pixels[i + 1],
          pixels[i + 2],
        ),
        isDark: isDark,
      ),
    );
    return ParticleLogoData(particles: particles, aspectRatio: w / h);
  }

  /// Renders the wordmark ("Meco") once with Roboto into an image and
  /// samples its pixels into particles, so the text is constructed by the
  /// same particle reveal as the logo. The targets follow the exact shape
  /// of the rendered Roboto letters (same font, weight and string as the
  /// final solid wordmark).
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
            fontSize: 180,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      // Zero padding: the image is exactly the text's layout box, so the
      // normalized particle targets map 1:1 onto the solid wordmark box.
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
      return _samplePixels(
        pixels: pixels,
        w: imgW,
        h: imgH,
        maxParticles: 300,
        colorAt: (int i) => textColor,
      );
    } catch (_) {
      return null;
    }
  }

  /// Shared particle sampler.
  ///
  /// Algorithm:
  ///  1. Read the raw RGBA bytes (one-time cost).
  ///  2. Visit pixels via a deterministic hash stride so samples spread
  ///     over the whole image without forming a visible grid.
  ///  3. Keep pixels with meaningful alpha; shuffle with the fixed seed
  ///     and cap to the target particle count (500-1000, or [maxParticles]).
  ///  4. Each particle keeps its color and its normalized target
  ///     coordinate; scatter/stagger/curve params are randomized.
  List<LogoParticle> _samplePixels({
    required Uint8List pixels,
    required int w,
    required int h,
    required Color Function(int byteIndex) colorAt,
    int? maxParticles,
  }) {
    final int area = w * h;
    final math.Random rng = math.Random(_seed);

    // Particle budget adapted to the image's pixel area (mobile friendly).
    final int targetCount =
        maxParticles ?? (area > 400000 ? 800 : math.max(500, area ~/ 400));

    final int stride = math.max(1, (math.sqrt(area / 3200)).round());
    final List<int> opaque = <int>[];
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if ((x * 131 + y * 89) % stride != 0) continue;
        final int i = (y * w + x) * 4;
        if (pixels[i + 3] >= 45) opaque.add(i);
      }
    }
    // Thin/outlined art: scan every pixel to collect enough samples.
    if (opaque.length < targetCount) {
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final int i = (y * w + x) * 4;
          if (pixels[i + 3] >= 45) opaque.add(i);
        }
      }
    }

    opaque.shuffle(rng);
    final int count = math.min(targetCount, opaque.length);

    return List<LogoParticle>.generate(count, (int n) {
      final int i = opaque[n];
      final int px = i ~/ 4;
      // Scatter direction is baked once into startDx/startDy so the painter
      // avoids per-frame trigonometry.
      final double angle = rng.nextDouble() * math.pi * 2;
      final double distance = 0.5 + rng.nextDouble() * 0.75;
      return LogoParticle(
        targetX: (px % w + 0.5) / w,
        targetY: (px ~/ w + 0.5) / h,
        color: colorAt(i),
        radius: 1.1 + rng.nextDouble() * 1.3,
        baseAlpha: 0.55 + rng.nextDouble() * 0.45,
        startDx: math.cos(angle) * distance,
        startDy: math.sin(angle) * distance,
        stagger: rng.nextDouble() * 0.55,
        curveIndex: rng.nextDouble() < 0.16
            ? 2
            : (rng.nextDouble() < 0.5 ? 0 : 1),
        driftPhase: rng.nextDouble() * math.pi * 2,
      );
    });
  }

  /// Keeps sampled colors identical in light mode. In dark mode only the
  /// darkest samples are lifted slightly so they read against the black
  /// background; hue is preserved, so logo color regions stay recognizable.
  Color _themeAwareColor(Color color, {required bool isDark}) {
    if (!isDark) return color;
    final HSVColor hsv = HSVColor.fromColor(color);
    if (hsv.value >= 0.45) return color;
    return hsv.withValue(math.min(1.0, hsv.value + 0.25)).toColor();
  }

  /// Reduced-motion / failure path: plain logo with a quick fade-in,
  /// then the normal navigation flow continues.
  void _startFallback() {
    if (_fallbackStarted) return;
    _fallbackStarted = true;

    final AnimationController fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    setState(() {
      _loading = false;
      _fallback = true;
      _fadeIn = fade;
    });
    fade.forward();
    _fallbackTimer = Timer(const Duration(milliseconds: 900), () {
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
                    maxHeight: MediaQuery.sizeOf(context).height * 0.36,
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
                    fontSize: 30,
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
      // Phase 1: empty screen while the logo is being prepared.
      return const SizedBox.expand();
    }

    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size size = constraints.biggest;
          final Rect logoRect = ParticleLogoPainter.logoRectFor(
            size,
            data.aspectRatio,
          );
          final TextStyle solidStyle = _solidTextStyle(context, size);
          final TextPainter measure = TextPainter(
            text: TextSpan(text: widget.text, style: solidStyle),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();
          final Rect textRect = ParticleLogoPainter.textRectFor(
            size,
            logoRect,
            Size(measure.width, measure.height),
          );

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(
                painter: ParticleLogoPainter(
                  logo: image,
                  particles: data.particles,
                  controller: _controller,
                  aspectRatio: data.aspectRatio,
                  textParticles: _textParticles ?? const <LogoParticle>[],
                  textRect: textRect,
                  glowColor:
                      widget.glowColor ?? Theme.of(context).colorScheme.primary,
                ),
              ),
              // Phase 6: the solid Roboto wordmark cross-fades in over the
              // dissolving text particles, filling the exact same box.
              if (widget.text.isNotEmpty)
                Positioned(
                  left: textRect.left,
                  top: textRect.top,
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
          );
        },
      ),
    );
  }

  /// Solid wordmark style: clean, sharp Roboto, sized for the device,
  /// with strong theme contrast (dark navy on light, white on dark).
  TextStyle _solidTextStyle(BuildContext context, Size size) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = (size.shortestSide / 12.5).clamp(26.0, 44.0);
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      color: isDark ? Colors.white : AppPalette.ink,
    );
  }
}
