// The first time: three calm pages, and the sky goes from night to dawn as you read them.
import 'package:flutter/material.dart';

import '../core/light.dart';
import '../store.dart';
import 'settings.dart' show goals;
import 'sky.dart';
import 'theme.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final _pages = PageController();
  var _page = 0;
  var _connecting = false;

  void _next() => _pages.nextPage(duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final p = [0.0, 0.35, 0.62][_page];
    final ink = inkOn(p);
    final muted = mutedOn(p);
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: p < 0.6 ? const Color(0xFFF4E6C4) : night,
      foregroundColor: p < 0.6 ? night : const Color(0xFFF4E6C4),
    );

    Widget page({required List<Widget> children, required Widget button}) => LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight - 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...children,
              const SizedBox(height: 28),
              SizedBox(width: double.infinity, child: button),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: night,
      body: Sky(
        progress: p,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  page(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Nūr',
                        style: TextStyle(color: ink, fontSize: 56, fontWeight: FontWeight.w200, letterSpacing: 3),
                      ),
                      const SizedBox(height: 4),
                      Text('Walk into the light.', style: TextStyle(color: muted, fontSize: 20)),
                      const SizedBox(height: 36),
                      Text('"${dawn.text}"', style: TextStyle(color: ink, fontSize: 21, height: 1.5)),
                      const SizedBox(height: 10),
                      Text(
                        dawn.source,
                        style: TextStyle(color: muted, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 120),
                    ],
                    button: FilledButton(onPressed: _next, style: buttonStyle, child: const Text('Begin')),
                  ),
                  page(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Every step\nbrings light',
                        style: TextStyle(color: ink, fontSize: 40, fontWeight: FontWeight.w300, height: 1.15),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Your day starts at night. As you walk, the sun comes up over your path. '
                        'Along the way you find verses and hadith about walking, hope and light.',
                        style: TextStyle(color: ink, fontSize: 17, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Rain, cold, a hard day, a place with old memories: Nūr has a small way out for each.',
                        style: TextStyle(color: muted, fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        '"${why.first.text}"',
                        style: TextStyle(color: ink, fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        why.first.source,
                        style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                    button: FilledButton(onPressed: _next, style: buttonStyle, child: const Text('Next')),
                  ),
                  page(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Your daily light',
                        style: TextStyle(color: ink, fontSize: 36, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 14),
                      Text('How far to full light each day? You can change it any time.', style: TextStyle(color: ink, fontSize: 16, height: 1.45)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final g in goals)
                            ChoiceChip(
                              label: Text(distanceText(g)),
                              selected: store.goal == g,
                              onSelected: (_) => store.setGoal(g),
                              selectedColor: night,
                              labelStyle: TextStyle(color: store.goal == g ? const Color(0xFFF4E6C4) : ink, fontWeight: FontWeight.w600),
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                              showCheckmark: false,
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Glass(
                        progress: p,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your steps, from your phone',
                              style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Nūr reads only the step count your phone already keeps (Health Connect). No location, no battery drain, nothing leaves the phone.',
                              style: TextStyle(color: ink, height: 1.45),
                            ),
                            const SizedBox(height: 10),
                            if (store.connected)
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D4F), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Connected',
                                    style: TextStyle(color: ink, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              )
                            else
                              OutlinedButton(
                                onPressed: _connecting
                                    ? null
                                    : () async {
                                        setState(() => _connecting = true);
                                        await store.connectSteps();
                                        if (mounted) setState(() => _connecting = false);
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ink,
                                  side: BorderSide(color: ink.withValues(alpha: 0.5)),
                                ),
                                child: Text(_connecting ? 'Connecting…' : 'Connect my steps'),
                              ),
                          ],
                        ),
                      ),
                    ],
                    button: FilledButton(onPressed: store.welcome, style: buttonStyle, child: const Text('Start')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
