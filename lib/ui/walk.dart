// A walk: the sky brightens with every step, and the light along the way appears as you reach it.
// The phone can go in your pocket: steps keep counting, and the light waits for you when you look.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../core/light.dart';
import '../store.dart';
import 'light_card.dart';
import 'sky.dart';
import 'theme.dart';

class WalkScreen extends StatefulWidget {
  const WalkScreen({super.key, this.newWay, this.rainy = false});

  final String? newWay;
  final bool rainy;

  @override
  State<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends State<WalkScreen> with SingleTickerProviderStateMixin {
  late final Store _store = StoreScope.of(context);
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  int? _startRaw; // the phone's counter when the walk began
  var _steps = 0;
  Light? _justFound;
  Timer? _hideFound;
  var _ending = false;
  void Function(List<Light>)? _before;

  int get _walkMetres => metresFor(_steps, _store.strideCm);

  @override
  void initState() {
    super.initState();
    // No wake lock: the screen may sleep in your pocket, and the step counter keeps counting.
    _ticker = createTicker((e) => setState(() => _elapsed = e))..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _before = _store.onFound;
      _store.onFound = (fresh) => _found(fresh.last); // light found on the walk shows here
      _store.addListener(_onSteps);
      _store.startLive();
      _onSteps();
    });
  }

  void _onSteps() {
    final raw = _store.rawNow;
    if (raw == null || _ending || !mounted) return;
    _startRaw ??= raw;
    if (raw - _startRaw! > _steps) setState(() => _steps = raw - _startRaw!);
  }

  void _found(Light l) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _justFound = l);
    _hideFound?.cancel();
    _hideFound = Timer(const Duration(seconds: 12), () {
      if (mounted) setState(() => _justFound = null);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _store.removeListener(_onSteps);
    if (_store.onFound != null && _before != _store.onFound) _store.onFound = _before;
    _hideFound?.cancel();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_ending) return;
    _ending = true;
    _ticker.stop();
    _store.onFound = _before;
    _store.addWalk(_steps);
    if (widget.rainy && _walkMetres >= hardDayMetres) _store.wentOutInRain();
    final fresh = await _store.refresh();
    if (!mounted) return;
    HapticFeedback.lightImpact();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: night,
      isScrollControlled: true,
      builder: (sheet) => _WalkDone(metres: _walkMetres, elapsed: _elapsed, fresh: fresh, rainy: widget.rainy),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    StoreScope.of(context); // follow the steps
    final p = _store.progress;
    final noSensor = !_store.liveWorks;
    final ink = inkOn(p);
    final muted = mutedOn(p);
    final mins = _elapsed.inMinutes, secs = _elapsed.inSeconds % 60;
    final next = nextToday(_store.todayMetres, DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        backgroundColor: night,
        body: Sky(
          progress: p,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, box) => SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: box.maxHeight),
                              child: IntrinsicHeight(
                                child: Column(
                                  children: [
                                    Text(
                                      widget.rainy ? 'WALKING IN THE RAIN' : 'WALKING INTO THE LIGHT',
                                      style: TextStyle(color: muted, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 18),
                                    FittedBox(
                                      child: Text(
                                        preciseDistance(_walkMetres), // every metre while you walk
                                        style: TextStyle(
                                          color: ink,
                                          fontSize: 64,
                                          fontWeight: FontWeight.w200,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      noSensor
                                          ? '$mins:${secs.toString().padLeft(2, '0')} · steps are counted by your phone'
                                          : '$_steps steps · $mins:${secs.toString().padLeft(2, '0')}',
                                      style: TextStyle(color: muted, fontSize: 16, fontFeatures: const [FontFeature.tabularFigures()]),
                                    ),
                                    if (widget.newWay != null) ...[
                                      const SizedBox(height: 18),
                                      Glass(
                                        progress: p,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.alt_route_rounded, color: ink, size: 20),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(widget.newWay!, style: TextStyle(color: ink, height: 1.35)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 900),
                                      switchInCurve: Curves.easeOutCubic,
                                      transitionBuilder: (c, a) => FadeTransition(
                                        opacity: a,
                                        child: SlideTransition(
                                          position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(a),
                                          child: c,
                                        ),
                                      ),
                                      child: _justFound == null
                                          ? SizedBox(
                                              key: const ValueKey('next'),
                                              height: 24,
                                              child: Text(
                                                next == null ? 'Every light of today found' : 'Next light in ${distanceText(next.$1)}',
                                                style: TextStyle(color: muted),
                                              ),
                                            )
                                          : LightCard(key: ValueKey(_justFound!.id), light: _justFound!, progress: p, label: 'Light found'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('The phone can go in your pocket.', style: TextStyle(color: muted, fontSize: 13)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _finish,
                          style: FilledButton.styleFrom(
                            backgroundColor: p < 0.6 ? const Color(0xFFF4E6C4) : night,
                            foregroundColor: p < 0.6 ? night : const Color(0xFFF4E6C4),
                          ),
                          child: const Text('Finish walk'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WalkDone extends StatelessWidget {
  const _WalkDone({required this.metres, required this.elapsed, required this.fresh, required this.rainy});

  final int metres;
  final Duration elapsed;
  final List<Light> fresh;
  final bool rainy;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFFF4F1EA);
    final mins = elapsed.inMinutes;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          children: [
            const Icon(Icons.wb_sunny_outlined, color: gold, size: 40),
            const SizedBox(height: 10),
            Text(
              metres >= 50 ? 'You went out.' : 'You stepped out.',
              style: const TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${distanceText(metres)} · ${mins < 1 ? 'under a minute' : '$mins min'}${rainy ? ' · in the rain' : ''}',
              style: TextStyle(color: ink.withValues(alpha: 0.7), fontSize: 16),
            ),
            const SizedBox(height: 18),
            if (fresh.isNotEmpty) ...[
              LightCard(light: fresh.last, progress: 0, label: fresh.length > 1 ? '${fresh.length} lights found' : 'Light found', maxLines: 6),
              const SizedBox(height: 18),
            ] else
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Text('Every step counts, the small ones too.', style: TextStyle(color: ink.withValues(alpha: 0.7))),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF4E6C4), foregroundColor: night),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
