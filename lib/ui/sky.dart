// The sky: night before the first step, dawn as you walk, full light at your goal. Stars fade, the
// crescent sets, the sun rises over the hills, and the path you walked glows.
import 'dart:math';

import 'package:flutter/material.dart';

/// The sky's colours at points of the day's progress: (progress, top, middle, bottom).
const _keys = [
  (0.0, Color(0xFF070B1E), Color(0xFF111A3A), Color(0xFF1C2550)),
  (0.3, Color(0xFF141E4A), Color(0xFF3A3570), Color(0xFF7A4E7E)),
  (0.6, Color(0xFF34508E), Color(0xFFB0708A), Color(0xFFF4A576)),
  (0.85, Color(0xFF5E9AD6), Color(0xFFA9CBEB), Color(0xFFFFD9A6)),
  (1.0, Color(0xFF7FB8EC), Color(0xFFC4E0F5), Color(0xFFFFF0D2)),
];

(Color, Color, Color) skyColors(double p) {
  final x = p.clamp(0.0, 1.0);
  for (var i = 1; i < _keys.length; i++) {
    final (p1, t1, m1, b1) = _keys[i];
    final (p0, t0, m0, b0) = _keys[i - 1];
    if (x <= p1) {
      final u = (x - p0) / (p1 - p0);
      return (Color.lerp(t0, t1, u)!, Color.lerp(m0, m1, u)!, Color.lerp(b0, b1, u)!);
    }
  }
  final (_, t, m, b) = _keys.last;
  return (t, m, b);
}

/// Text on the sky: cream at night, deep blue by day — whichever reads better on the sky behind it.
Color inkOn(double p) {
  const light = Color(0xFFFFFCF5), dark = Color(0xFF0F1630);
  final (top, mid, _) = skyColors(p);
  final behind = Color.lerp(top, mid, 0.5)!;
  // No blend: halfway between cream and blue is a grey that reads on nothing.
  return contrast(dark, behind) > contrast(light, behind) ? dark : light;
}

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (max(x, y) + 0.05) / (min(x, y) + 0.05);
}

/// Softer text on the sky.
Color mutedOn(double p) => inkOn(p).withValues(alpha: 0.72);

/// The sky for today's [progress] (0 at dawn, 1 at the goal). Changes of progress glide slowly.
class Sky extends StatefulWidget {
  const Sky({super.key, required this.progress, this.child, this.builder});

  final double progress;
  final Widget? child;

  /// Builds what is on the sky with the sky's own gliding progress, so text and glass change colour
  /// together with the sky, frame by frame (never dark text on a sky that is still dark).
  final Widget Function(BuildContext context, double progress)? builder;

  @override
  State<Sky> createState() => _SkyState();
}

class _SkyState extends State<Sky> with SingleTickerProviderStateMixin {
  // Slow time for twinkling stars and drifting clouds.
  late final _time = AnimationController(vsync: this, duration: const Duration(seconds: 120));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still && _time.isAnimating) _time.stop();
    if (!still && !_time.isAnimating) _time.repeat();
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: widget.progress),
    duration: const Duration(milliseconds: 2600),
    curve: Curves.easeInOutCubic,
    builder: (context, p, child) => CustomPaint(
      painter: SkyPainter(progress: p, time: _time),
      child: widget.builder?.call(context, p) ?? child,
    ),
    child: widget.child,
  );
}

class SkyPainter extends CustomPainter {
  SkyPainter({required this.progress, required this.time}) : super(repaint: time);

  final double progress;
  final Animation<double> time;

  static final _stars = () {
    final r = Random(11);
    return [
      for (var i = 0; i < 90; i++) (r.nextDouble(), pow(r.nextDouble(), 1.4).toDouble() * 0.62, 0.5 + r.nextDouble() * 1.3, r.nextDouble() * 2 * pi),
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = progress.clamp(0.0, 1.2);
    final t = time.value * 2 * pi; // one slow turn every two minutes
    final horizon = h * 0.64;
    final (top, mid, bottom) = skyColors(p);

    // The sky.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, mid, bottom],
          stops: const [0, 0.45, 0.66],
        ).createShader(Offset.zero & size),
    );

    // Stars, fading as the light comes.
    final starAlpha = (1 - p / 0.55).clamp(0.0, 1.0);
    if (starAlpha > 0) {
      final paint = Paint();
      for (final (x, y, r, phase) in _stars) {
        final twinkle = 0.55 + 0.45 * sin(t * 6 + phase);
        paint.color = Colors.white.withValues(alpha: starAlpha * twinkle * 0.9);
        canvas.drawCircle(Offset(x * w, y * h), r, paint);
      }
    }

    // The crescent, setting as dawn comes.
    final moonAlpha = (1 - p / 0.25).clamp(0.0, 1.0);
    if (moonAlpha > 0) {
      final c = Offset(w * 0.8, h * (0.12 + p * 0.08));
      final r = w * 0.055;
      canvas.saveLayer(Rect.fromCircle(center: c, radius: r * 3), Paint());
      canvas.drawCircle(
        c,
        r * 2.6,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF6D8).withValues(alpha: 0.18 * moonAlpha),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r * 2.6)),
      );
      canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFF4D6).withValues(alpha: moonAlpha));
      canvas.drawCircle(c + Offset(r * 0.42, -r * 0.18), r * 0.9, Paint()..blendMode = BlendMode.dstOut);
      canvas.restore();
    }

    // The sun, rising from behind the hills.
    final rise = ((p - 0.22) / 0.78).clamp(0.0, 1.0);
    if (p > 0.18) {
      final sunR = w * 0.085;
      final c = Offset(w * 0.5, horizon + sunR * 1.2 - Curves.easeOutCubic.transform(rise) * h * 0.36);
      final warm = Color.lerp(const Color(0xFFFF9A5A), const Color(0xFFFFF4DA), rise)!;
      final glow = sunR * (5 + 1.2 * sin(t * 2));
      canvas.drawCircle(
        c,
        glow,
        Paint()
          ..shader = RadialGradient(
            colors: [warm.withValues(alpha: 0.55), warm.withValues(alpha: 0.12), Colors.transparent],
            stops: const [0, 0.35, 1],
          ).createShader(Rect.fromCircle(center: c, radius: glow)),
      );
      canvas.drawCircle(c, sunR, Paint()..color = Color.lerp(warm, Colors.white, 0.35)!);
      // Soft rays once the goal is reached.
      if (p >= 1) {
        final rays = Paint()
          ..color = Colors.white.withValues(alpha: 0.10 * ((p - 1) / 0.05).clamp(0.0, 1.0))
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 12; i++) {
          final a = i * pi / 6 + t;
          canvas.drawLine(c + Offset(cos(a), sin(a)) * sunR * 1.5, c + Offset(cos(a), sin(a)) * sunR * 2.6, rays);
        }
      }
    }

    // Clouds, drifting slowly once it is light.
    final cloudAlpha = ((p - 0.45) / 0.4).clamp(0.0, 1.0);
    if (cloudAlpha > 0) {
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.32 * cloudAlpha);
      for (final (y, s, speed) in const [(0.40, 0.8, 1.0), (0.47, 0.6, 0.6), (0.05, 0.5, 1.4)]) {
        // above and below the words, never over them
        final x = ((time.value * speed + y * 3) % 1.3 - 0.15) * w;
        _cloud(canvas, Offset(x, h * y), w * 0.12 * s, paint);
      }
    }

    // Hills: three layers, darker at night, green-gold by day.
    Color hill(Color night, Color day) => Color.lerp(night, day, Curves.easeIn.transform(p.clamp(0.0, 1.0)))!;
    _hill(canvas, size, horizon - h * 0.02, 0.035, 1.3, 0.7, hill(const Color(0xFF1A2147), const Color(0xFF9DB89A)));
    _hill(canvas, size, horizon + h * 0.05, 0.03, 2.1, 2.2, hill(const Color(0xFF131936), const Color(0xFF7DA27F)));
    final front = hill(const Color(0xFF0C1028), const Color(0xFF5E8A66));
    _hill(canvas, size, horizon + h * 0.13, 0.025, 1.6, 4.0, front);

    // The path: from your feet to the horizon. The walked part glows.
    final path = Path()
      ..moveTo(w * 0.5, h * 1.02)
      ..cubicTo(w * 0.15, h * 0.92, w * 0.85, h * 0.80, w * 0.46, horizon + h * 0.02);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(const Color(0xFF2A3263), const Color(0xFFE9DDBF), p.clamp(0.0, 1.0))!.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..strokeCap = StrokeCap.round,
    );
    final walked = metric.extractPath(0, metric.length * p.clamp(0.0, 1.0));
    canvas.drawPath(
      walked,
      Paint()
        ..color = const Color(0xFFFFD27A).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      walked,
      Paint()
        ..color = const Color(0xFFFFE3A3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..strokeCap = StrokeCap.round,
    );
    // You, where you are on the path.
    final at = metric.getTangentForOffset(metric.length * p.clamp(0.002, 1.0))!.position;
    canvas.drawCircle(at, w * 0.03 * (1 + 0.15 * sin(t * 4)), Paint()..color = const Color(0xFFFFE3A3).withValues(alpha: 0.35));
    canvas.drawCircle(at, w * 0.012, Paint()..color = const Color(0xFFFFF6DE));
  }

  void _hill(Canvas canvas, Size size, double y, double amp, double freq, double phase, Color color) {
    final w = size.width, h = size.height;
    final path = Path()..moveTo(0, h);
    for (var x = 0.0; x <= w + 1; x += 6) {
      path.lineTo(x, y - h * amp * (sin(x / w * pi * freq + phase) + 0.4 * sin(x / w * pi * freq * 2.7 + phase * 1.7)));
    }
    path
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _cloud(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: r * 3.2, height: r * 0.9), Radius.circular(r)), paint);
    canvas.drawCircle(c + Offset(-r * 0.5, -r * 0.3), r * 0.6, paint);
    canvas.drawCircle(c + Offset(r * 0.35, -r * 0.45), r * 0.75, paint);
  }

  @override
  bool shouldRepaint(SkyPainter old) => old.progress != progress;
}
