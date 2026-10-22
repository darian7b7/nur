// The first time: three calm pages, and the sky goes from night to dawn as you read them.
import 'package:flutter/material.dart';

import '../core/light.dart';
import '../store.dart';
import 'settings.dart' show goals;
import 'sky.dart';
import 'light_card.dart';
import 'step_access.dart';
import 'words.dart';
import 'theme.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final _pages = PageController();
  var _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) StoreScope.of(context).checkAccess();
    });
  }

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
                        context.l.appTitle,
                        style: TextStyle(color: ink, fontSize: 56, fontWeight: FontWeight.w200, letterSpacing: 3),
                      ),
                      const SizedBox(height: 4),
                      Text(context.l.tagline, style: TextStyle(color: muted, fontSize: 20)),
                      const SizedBox(height: 36),
                      LightWords(
                        light: dawn,
                        language: context.lang,
                        style: TextStyle(color: ink, fontSize: 21, height: 1.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        dawn.sourceIn(context.lang),
                        style: TextStyle(color: muted, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 120),
                    ],
                    button: FilledButton(onPressed: _next, style: buttonStyle, child: Text(context.l.begin)),
                  ),
                  page(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        context.l.everyStepBringsLight,
                        style: TextStyle(color: ink, fontSize: 40, fontWeight: FontWeight.w300, height: 1.15),
                      ),
                      const SizedBox(height: 22),
                      Text(context.l.welcomeBody, style: TextStyle(color: ink, fontSize: 17, height: 1.5)),
                      const SizedBox(height: 16),
                      Text(context.l.welcomeHarder, style: TextStyle(color: muted, fontSize: 16, height: 1.5)),
                      const SizedBox(height: 26),
                      LightWords(
                        light: why.first,
                        language: context.lang,
                        style: TextStyle(color: ink, fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        why.first.sourceIn(context.lang),
                        style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                    button: FilledButton(onPressed: _next, style: buttonStyle, child: Text(context.l.next)),
                  ),
                  page(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        context.l.yourDailyLight,
                        style: TextStyle(color: ink, fontSize: 36, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 14),
                      Text(context.l.dailyLightQuestion, style: TextStyle(color: ink, fontSize: 16, height: 1.45)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final g in goals)
                            ChoiceChip(
                              label: Text(context.dist(g)),
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
                              context.l.yourStepsFromPhone,
                              style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(context.l.onlyStepCount, style: TextStyle(color: ink, height: 1.4)),
                            const SizedBox(height: 6),
                            StepAccess(ink: ink, muted: ink.withValues(alpha: 0.75), accent: night),
                          ],
                        ),
                      ),
                    ],
                    button: FilledButton(
                      // Nūr can't work without the step counter: Start asks for it first.
                      onPressed: () async {
                        if (store.counterOk == true || await store.allowCounter()) store.welcome();
                      },
                      style: buttonStyle,
                      child: Text(store.counterOk == true ? context.l.start : context.l.allowStepCounting),
                    ),
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
