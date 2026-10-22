// The one screen: today's sky, how far you walked into the light, the latest verse you found, and the
// door: Go out. For harder days: a smaller goal, a new way, and words for the weather.
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/light.dart';
import '../store.dart';
import 'collection.dart';
import 'light_card.dart';
import 'settings.dart';
import 'sky.dart';
import 'theme.dart';
import 'walk.dart';
import 'words.dart';

class Today extends StatefulWidget {
  const Today({super.key});

  @override
  State<Today> createState() => _TodayState();
}

class _TodayState extends State<Today> with WidgetsBindingObserver {
  Timer? _timer;
  int? _newWay; // which New way rule, if one is on

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      StoreScope.of(context).onFound = (fresh) {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) showFound(context, fresh);
      };
      _refresh();
    });
    _timer = Timer.periodic(const Duration(minutes: 2), (_) => _refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // Back in the app: the steps of the walk you just took.
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final store = StoreScope.of(context);
    final fresh = await store.refresh();
    await store.planReminder();
    if (mounted && fresh.isNotEmpty) showFound(context, fresh);
  }

  Future<void> _go({bool rainy = false}) async {
    final store = StoreScope.of(context);
    // A walk needs the step counter: ask first, never start a walk that can't count.
    if (store.counterOk != true && !await store.allowCounter()) return;
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, a, _) => FadeTransition(
          opacity: a,
          child: WalkScreen(newWay: _newWay == null ? null : context.l.newWayRule(_newWay!), rainy: rainy),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final target = store.progress;
    final m = store.todayMetres;
    final now = DateTime.now();
    final found = foundToday(m, now);
    final next = nextToday(m, now);
    final hard = store.isHardDay;
    final l = context.l;

    final Light card;
    final String cardLabel;
    if (hard && m < hardDayMetres) {
      card = hardDayFor(now);
      cardLabel = l.cardHardDay;
    } else if (found.isNotEmpty) {
      card = found.last;
      cardLabel = l.cardFoundAt(context.dist(foundAt(found.last, now) ?? 0));
    } else {
      card = dawn;
      cardLabel = l.cardBeforeFirstStep;
    }

    return Scaffold(
      backgroundColor: night,
      body: Sky(
        progress: target,
        builder: (context, p) {
          final ink = inkOn(p), muted = mutedOn(p);
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: LayoutBuilder(
                    builder: (context, box) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: box.maxHeight),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    l.appTitle,
                                    style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w300, letterSpacing: 1.5),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: l.tooltipCollection,
                                    onPressed: () => openCollection(context),
                                    icon: Icon(Icons.auto_awesome_outlined, color: ink),
                                  ),
                                  IconButton(
                                    tooltip: l.tooltipSettings,
                                    onPressed: () => showSettings(context),
                                    icon: Icon(Icons.tune_rounded, color: ink),
                                  ),
                                ],
                              ),
                              if (store.counterOk == false) ...[const SizedBox(height: 8), _StepsOff(progress: p)],
                              SizedBox(height: max(24, box.maxHeight * 0.06)),
                              FadeIn(
                                child: Column(
                                  children: [
                                    Text(
                                      hard ? l.hardDayHeading : (p >= 1 ? l.fullLightToday : l.todaysLight),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: muted, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      child: Text(
                                        context.dist(m),
                                        style: TextStyle(
                                          color: ink,
                                          fontSize: 64,
                                          fontWeight: FontWeight.w200,
                                          letterSpacing: -1,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ),
                                    Text(l.ofGoal(context.dist(store.todayGoal)), style: TextStyle(color: muted, fontSize: 16)),
                                  ],
                                ),
                              ),
                              SizedBox(height: (box.maxHeight - 600).clamp(24.0, 260.0)), // the sun and the path show here; shorter screens give way
                              FadeIn(
                                delay: const Duration(milliseconds: 300),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 800),
                                  child: LightCard(key: ValueKey(card.id), light: card, progress: p, label: cardLabel),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 20,
                                child: next == null
                                    ? Text(l.everyLightFound, style: TextStyle(color: muted))
                                    : Text(l.nextLightIn(context.dist(next.$1)), style: TextStyle(color: muted)),
                              ),
                              const SizedBox(height: 14),
                              FadeIn(
                                delay: const Duration(milliseconds: 500),
                                child: Column(
                                  children: [
                                    if (_newWay != null) ...[
                                      Glass(
                                        progress: p,
                                        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.alt_route_rounded, color: ink, size: 20),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(l.newWayRule(_newWay!), style: TextStyle(color: ink, height: 1.35)),
                                            ),
                                            IconButton(
                                              tooltip: l.tooltipAnotherWay,
                                              onPressed: () => setState(() => _newWay = _pickWay(_newWay)),
                                              icon: Icon(Icons.refresh_rounded, color: muted, size: 20),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: _go,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: p < 0.6 ? const Color(0xFFF4E6C4) : night,
                                          foregroundColor: p < 0.6 ? night : const Color(0xFFF4E6C4),
                                        ),
                                        icon: const Icon(Icons.wb_twilight_rounded),
                                        label: Text(p >= 1 ? l.walkMore : l.goOut),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _Chip(
                                            progress: p,
                                            icon: hard ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            label: l.hardDay,
                                            on: hard,
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              store.setHardDay(!hard);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _Chip(
                                            progress: p,
                                            icon: Icons.alt_route_rounded,
                                            label: l.newWay,
                                            on: _newWay != null,
                                            onTap: () => setState(() => _newWay = _newWay == null ? _pickWay(null) : null),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _Chip(progress: p, icon: Icons.umbrella_outlined, label: l.weather, onTap: () => _weather(context)),
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),
          );
        },
      ),
    );
  }

  int _pickWay(int? not) {
    final options = [
      for (var i = 0; i < newWayCount; i++)
        if (i != not) i,
    ];
    return options[Random().nextInt(options.length)];
  }

  void _weather(BuildContext context) {
    showModalBottomSheet<void>(
      useSafeArea: true, // the handle stays below the status bar, so it can be pulled
      context: context,
      backgroundColor: night,
      isScrollControlled: true,
      builder: (sheet) => _WeatherSheet(
        onGo: (w) {
          Navigator.of(sheet).pop();
          _go(rainy: w == Weather.rain);
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.progress, required this.icon, required this.label, required this.onTap, this.on = false});

  final double progress;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final ink = inkOn(progress);
    return Glass(
      progress: progress,
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      onTap: onTap,
      child: Semantics(
        selected: on,
        child: Column(
          children: [
            Icon(icon, size: 20, color: on ? (progress < 0.6 ? gold : const Color(0xFFB07A1E)) : ink),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                label,
                style: TextStyle(color: ink, fontSize: 13, fontWeight: on ? FontWeight.w700 : FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// No weather is a reason to stay in: what to wear, and for rain, the Prophet's ﷺ way with it.
class _WeatherSheet extends StatefulWidget {
  const _WeatherSheet({required this.onGo});

  final void Function(Weather) onGo;

  @override
  State<_WeatherSheet> createState() => _WeatherSheetState();
}

class _WeatherSheetState extends State<_WeatherSheet> {
  var _w = Weather.rain;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFFF4F1EA);
    final l = context.l;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.weatherQuestion,
              style: TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final w in Weather.values)
                  ChoiceChip(
                    label: Text(l.weatherLabel(w)),
                    selected: _w == w,
                    onSelected: (_) => setState(() => _w = w),
                    selectedColor: gold,
                    labelStyle: TextStyle(color: _w == w ? night : ink, fontWeight: FontWeight.w600),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    showCheckmark: false,
                  ),
              ],
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(_w),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.weatherTip(_w), style: TextStyle(color: ink.withValues(alpha: 0.85), fontSize: 16, height: 1.45)),
                  if (_w == Weather.rain) ...[
                    const SizedBox(height: 16),
                    LightCard(light: rainFor(DateTime.now()), progress: 0, label: l.rainIsMercy, maxLines: 8, onTap: () {}),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => widget.onGo(_w),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF4E6C4), foregroundColor: night),
                child: Text(_w == Weather.rain ? l.goOutInRain : l.goOutAnyway),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// New light found: the first one shown calmly; the rest wait in the collection.
void showFound(BuildContext context, List<Light> lights) {
  if (lights.isEmpty || !context.mounted) return;
  HapticFeedback.lightImpact();
  showLight(context, lights.first, label: lights.length > 1 ? context.l.lightFoundMore : context.l.lightFound);
}

/// Shown when the step counter isn't allowed: nothing would move, so say so and offer the switch.
class _StepsOff extends StatelessWidget {
  const _StepsOff({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final ink = inkOn(progress);
    return Glass(
      progress: progress,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
      child: Row(
        children: [
          Icon(Icons.directions_walk_rounded, color: ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l.stepsOff,
                  style: TextStyle(color: ink, fontWeight: FontWeight.w700),
                ),
                Text(context.l.stepsOffBody, style: TextStyle(color: mutedOn(progress), height: 1.3)),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: gold),
            onPressed: store.allowCounter,
            child: Text(context.l.turnOn),
          ),
        ],
      ),
    );
  }
}
