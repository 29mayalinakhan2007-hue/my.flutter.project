import 'dart:math';
import 'package:flutter/material.dart';
import '../core/weather_theme.dart';

/// The app's signature element: a full-bleed, gently animated sky
/// that matches the *actual* forecast — drifting sun rays on a clear
/// day, falling rain, settling snow, twinkling stars at night. Built
/// entirely with [CustomPainter] so there are no image assets to ship
/// or keep in sync with the data.
///
/// Motion is intentionally calm and looping — this is ambient
/// atmosphere behind the numbers, not a distraction from them.
class LivingSky extends StatefulWidget {
  final SkyMood mood;
  final Widget child;

  const LivingSky({super.key, required this.mood, required this.child});

  @override
  State<LivingSky> createState() => _LivingSkyState();
}

class _LivingSkyState extends State<LivingSky>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Particle> _particles;
  SkyMood? _particlesFor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  void _ensureParticles(SkyMood mood, Size size) {
    if (_particlesFor == mood && _particles.isNotEmpty) return;
    _particlesFor = mood;
    final rand = Random(mood.index * 7919);
    final count = switch (mood) {
      SkyMood.rain => 70,
      SkyMood.storm => 90,
      SkyMood.snow => 50,
      SkyMood.clearNight => 60,
      SkyMood.partlyCloudyNight => 40,
      SkyMood.partlyCloudyDay => 5,
      SkyMood.overcast => 6,
      SkyMood.fog => 5,
      SkyMood.clearDay => 0,
    };
    _particles = List.generate(count, (i) => _Particle.random(rand));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = WeatherTheme.paletteFor(widget.mood);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette.gradient,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _ensureParticles(widget.mood, size);
          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SkyPainter(
                      mood: widget.mood,
                      t: _controller.value,
                      particles: _particles,
                    ),
                  );
                },
              ),
              widget.child,
            ],
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x; // 0..1 horizontal seed
  final double y; // 0..1 vertical seed
  final double speed; // relative fall/drift speed
  final double size;
  final double phase; // animation offset so particles don't sync

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.phase,
  });

  factory _Particle.random(Random r) {
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble(),
      speed: 0.5 + r.nextDouble(),
      size: r.nextDouble(),
      phase: r.nextDouble(),
    );
  }
}

class _SkyPainter extends CustomPainter {
  final SkyMood mood;
  final double t;
  final List<_Particle> particles;

  _SkyPainter({required this.mood, required this.t, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case SkyMood.clearDay:
        _paintSunAndClouds(canvas, size, cloudOpacity: 0.16, rayOpacity: 0.5);
        break;
      case SkyMood.partlyCloudyDay:
        _paintSunAndClouds(canvas, size, cloudOpacity: 0.35, rayOpacity: 0.28);
        break;
      case SkyMood.overcast:
      case SkyMood.fog:
        _paintClouds(canvas, size, opacity: mood == SkyMood.fog ? 0.22 : 0.3);
        break;
      case SkyMood.clearNight:
        _paintStars(canvas, size);
        break;
      case SkyMood.partlyCloudyNight:
        _paintStars(canvas, size, count: 24);
        _paintClouds(canvas, size, opacity: 0.18);
        break;
      case SkyMood.rain:
        _paintClouds(canvas, size, opacity: 0.2);
        _paintRain(canvas, size, intensity: 1.0);
        break;
      case SkyMood.storm:
        _paintClouds(canvas, size, opacity: 0.28);
        _paintRain(canvas, size, intensity: 1.4);
        _paintLightningFlash(canvas, size);
        break;
      case SkyMood.snow:
        _paintClouds(canvas, size, opacity: 0.2);
        _paintSnow(canvas, size);
        break;
    }
  }

  void _paintSunAndClouds(Canvas canvas, Size size,
      {required double cloudOpacity, required double rayOpacity}) {
    final center = Offset(size.width * 0.78, size.height * 0.16);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(rayOpacity),
          Colors.white.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 140));
    canvas.drawCircle(center, 140, glowPaint);

    final corePaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(center, 34, corePaint);

    // Slowly rotating soft rays.
    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(rayOpacity * 0.5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final angleOffset = t * 2 * pi;
    for (int i = 0; i < 10; i++) {
      final angle = angleOffset + (i * pi / 5);
      final start = center + Offset(cos(angle), sin(angle)) * 46;
      final end = center + Offset(cos(angle), sin(angle)) * 66;
      canvas.drawLine(start, end, rayPaint);
    }

    if (cloudOpacity > 0) {
      _paintClouds(canvas, size, opacity: cloudOpacity);
    }
  }

  void _paintClouds(Canvas canvas, Size size, {required double opacity}) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    final baseYs = [0.28, 0.42, 0.58];
    for (int i = 0; i < baseYs.length; i++) {
      final driftSpeed = 0.15 + (i * 0.08);
      final dx = ((t * driftSpeed + i * 0.33) % 1.2) * size.width - size.width * 0.1;
      final cy = size.height * baseYs[i];
      _drawCloudPuff(canvas, Offset(dx, cy), 60 + i * 18.0, paint);
    }
  }

  void _drawCloudPuff(Canvas canvas, Offset center, double scale, Paint paint) {
    canvas.drawCircle(center, scale * 0.5, paint);
    canvas.drawCircle(center + Offset(scale * 0.45, scale * 0.08), scale * 0.38, paint);
    canvas.drawCircle(center + Offset(-scale * 0.4, scale * 0.1), scale * 0.32, paint);
    canvas.drawCircle(center + Offset(scale * 0.1, -scale * 0.18), scale * 0.34, paint);
  }

  void _paintStars(Canvas canvas, Size size, {int count = 60}) {
    final rand = Random(42);
    for (int i = 0; i < count; i++) {
      final sx = rand.nextDouble() * size.width;
      final sy = rand.nextDouble() * size.height * 0.7;
      final twinkle = (sin((t * 2 * pi) + i) + 1) / 2;
      final opacity = 0.25 + twinkle * 0.6;
      final r = 0.6 + rand.nextDouble() * 1.4;
      canvas.drawCircle(
        Offset(sx, sy),
        r,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
    // A soft moon.
    final moonCenter = Offset(size.width * 0.76, size.height * 0.16);
    canvas.drawCircle(
      moonCenter,
      110,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withOpacity(0.14),
          Colors.white.withOpacity(0),
        ]).createShader(Rect.fromCircle(center: moonCenter, radius: 110)),
    );
    canvas.drawCircle(moonCenter, 26, Paint()..color = Colors.white.withOpacity(0.85));
  }

  void _paintRain(Canvas canvas, Size size, {required double intensity}) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (final p in particles) {
      final fallT = ((t * p.speed * intensity) + p.phase) % 1.0;
      final x = p.x * size.width;
      final y = fallT * (size.height + 40) - 20;
      final len = 14 + p.size * 10;
      canvas.drawLine(Offset(x, y), Offset(x - 4, y + len), paint);
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.85);
    for (final p in particles) {
      final fallT = ((t * p.speed * 0.4) + p.phase) % 1.0;
      final sway = sin((t * 2 * pi * p.speed) + p.phase * 10) * 14;
      final x = p.x * size.width + sway;
      final y = fallT * (size.height + 20) - 10;
      canvas.drawCircle(Offset(x, y), 1.4 + p.size * 2.2, paint);
    }
  }

  void _paintLightningFlash(Canvas canvas, Size size) {
    // A brief, occasional flash — pulses on a slow cycle so it reads
    // as weather, not a strobing distraction.
    final cycle = (t * 3) % 1.0;
    if (cycle < 0.04) {
      final opacity = (0.04 - cycle) / 0.04 * 0.35;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) => true;
}
