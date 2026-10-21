// The light you found: every verse and hadith, found or still waiting on the path, and how far you
// walked this week and in all.
import 'dart:math';

import 'package:flutter/material.dart';

import '../core/light.dart';
import '../store.dart';
import 'light_card.dart';
import 'theme.dart';

void openCollection(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Collection()));

class Collection extends StatelessWidget {
  const Collection({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    const ink = Color(0xFFF4F1EA);
    final muted = ink.withValues(alpha: 0.65);
    final all = allLights;
    final count = all.where((l) => store.found.containsKey(l.id)).length;
    final week = store.lastWeek();
    final weekKm = week.fold(0, (s, m) => s + m);
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: night,
      appBar: AppBar(backgroundColor: night, foregroundColor: ink, title: const Text('Your light'), surfaceTintColor: Colors.transparent),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              FadeIn(
                child: Glass(
                  progress: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count of ${all.length} found',
                        style: const TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text('${distanceText(store.totalKm * 1000)} in all · ${distanceText(weekKm)} this week', style: TextStyle(color: muted)),
                      const SizedBox(height: 16),
                      // The last 7 days: each a small sun, brighter the closer to the goal.
                      Row(
                        children: [
                          for (final (i, m) in week.indexed)
                            Expanded(
                              child: Column(
                                children: [
                                  _DaySun(fraction: min(1.0, m / max(1, store.goal))),
                                  const SizedBox(height: 6),
                                  Text(
                                    days[DateTime(today.year, today.month, today.day - (6 - i)).weekday - 1],
                                    style: TextStyle(color: muted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'ALONG EACH DAY',
                style: TextStyle(color: muted, fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ..._found(pool, store),
              _Waiting(count: pool.where((l) => !store.found.containsKey(l.id)).length, what: 'on your walks. Every day has a new path.'),
              const SizedBox(height: 14),
              Text(
                'ALONG THE LONG PATH',
                style: TextStyle(color: muted, fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (final (_, l) in longPath) _Entry(light: l, foundOn: store.found[l.id]),
              const SizedBox(height: 14),
              Text(
                'ON THE HARDER DAYS',
                style: TextStyle(color: muted, fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ..._found([...hardDays, ...rains], store),
              _Waiting(
                count: [...hardDays, ...rains].where((l) => !store.found.containsKey(l.id)).length,
                what: 'for hard days and for walks in the rain.',
              ),
              const SizedBox(height: 14),
              Text(
                'WHY WE WALK',
                style: TextStyle(color: muted, fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (final l in why)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: LightCard(light: l, progress: 0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The found ones of [lights], newest first.
List<Widget> _found(List<Light> lights, Store store) {
  final found = [
    for (final l in lights)
      if (store.found.containsKey(l.id)) l,
  ]..sort((a, b) => store.found[b.id]!.compareTo(store.found[a.id]!));
  return [
    for (final l in found)
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: LightCard(light: l, progress: 0),
      ),
  ];
}

/// How many are still waiting, without a long list of locks.
class _Waiting extends StatelessWidget {
  const _Waiting({required this.count, required this.what});

  final int count;
  final String what;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFFF4F1EA);
    if (count == 0) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ink.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_outlined, size: 18, color: ink.withValues(alpha: 0.45)),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$count more waiting $what', style: TextStyle(color: ink.withValues(alpha: 0.6), height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.light, required this.foundOn});

  final Light light;
  final String? foundOn;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFFF4F1EA);
    if (foundOn != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: LightCard(light: light, progress: 0),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ink.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 18, color: ink.withValues(alpha: 0.4)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(findHint(light), style: TextStyle(color: ink.withValues(alpha: 0.55))),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySun extends StatelessWidget {
  const _DaySun({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: fraction),
    duration: const Duration(milliseconds: 1200),
    curve: Curves.easeOutCubic,
    builder: (context, f, _) => Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(Colors.white.withValues(alpha: 0.08), gold, f),
        boxShadow: f >= 1 ? [BoxShadow(color: gold.withValues(alpha: 0.5), blurRadius: 12)] : null,
      ),
    ),
  );
}
