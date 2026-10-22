// Nūr's look: deep night blue and warm dawn gold, soft glass over the sky, 16 px corners.
import 'dart:ui';

import 'package:flutter/material.dart';

const gold = Color(0xFFE8B95A);
const night = Color(0xFF0E1430);

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3A4C8C), brightness: brightness).copyWith(
    surface: dark ? const Color(0xFF0E1430) : const Color(0xFFF7F3EA),
    surfaceContainerLow: dark ? const Color(0xFF171F42) : Colors.white,
    surfaceContainerHigh: dark ? const Color(0xFF222B52) : const Color(0xFFECE6D8),
    tertiary: gold,
  );
  final radius = BorderRadius.circular(16);
  return ThemeData(
    useMaterial3: true,
    fontFamilyFallback: const ['NotoSansArabic'], // Arabic letters (Latin stays in the system font)
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    splashFactory: InkRipple.splashFactory, // the sparkle effect loads a shader on first tap
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
        textStyle: const TextStyle(fontFamily: 'Roboto', fontFamilyFallback: ['NotoSansArabic'], fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    pageTransitionsTheme: PageTransitionsTheme(builders: {for (final p in TargetPlatform.values) p: FadeForwardsPageTransitionsBuilder()}),
  );
}

/// Frosted glass over the sky: light at night, brighter by day.
class Glass extends StatelessWidget {
  const Glass({super.key, required this.progress, required this.child, this.padding = const EdgeInsets.all(18), this.radius = 24, this.onTap});

  final double progress;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final day = ((progress - 0.5) / 0.3).clamp(0.0, 1.0);
    final r = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Color.lerp(Colors.white.withValues(alpha: 0.09), Colors.white.withValues(alpha: 0.5), day),
          shape: RoundedRectangleBorder(
            borderRadius: r,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.22 + 0.2 * day)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: r,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Fades and lifts its child in, after [delay].
class FadeIn extends StatefulWidget {
  const FadeIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(a),
        child: widget.child,
      ),
    );
  }
}
