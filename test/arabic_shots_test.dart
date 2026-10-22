// The Arabic screens with the real fonts, to check them by eye:
//   flutter test test/arabic_shots_test.dart --dart-define=SHOTS=/path/to/folder
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nur/core/light.dart';
import 'package:nur/main.dart';
import 'package:nur/store.dart';
import 'package:nur/ui/light_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nur_test.dart' show loadTestContent, FakeSteps, settle;
import 'screens_test.dart' show loadFonts;

const out = String.fromEnvironment('SHOTS');

Future<void> shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('shot')));
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1.5));
  final png = await tester.runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
  File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  setUpAll(loadTestContent);

  testWidgets('arabic screens', (tester) async {
    if (out.isEmpty) return;
    await loadFonts();
    tester.view.physicalSize = const Size(412, 892) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final steps = FakeSteps()..isConnected = true;
    SharedPreferences.setMockInitialValues({});
    final store = await Store.load(steps: steps);
    store.setLanguage('ar');
    await tester.pumpWidget(RepaintBoundary(key: const Key('shot'), child: NurApp(store: store)));
    await settle(tester, 15);
    await shot(tester, 'a1-welcome');
    store.welcome();
    await settle(tester, 15);
    await shot(tester, 'a2-dawn');
    steps.todaySteps = 1500;
    await store.refresh();
    await settle(tester, 18);
    while (find.byType(BottomSheet).evaluate().isNotEmpty) {
      Navigator.of(tester.element(find.byType(BottomSheet).last)).pop();
      await settle(tester, 4);
    }
    await shot(tester, 'a3-sunrise');
    showLight(tester.element(find.byType(Scaffold).first), pool.firstWhere((l) => l.id == 'q67_15'));
    await settle(tester, 10);
    await shot(tester, 'a4-verse');
    Navigator.of(tester.element(find.byType(BottomSheet).last)).pop();
    await settle(tester, 6);
    showLight(tester.element(find.byType(Scaffold).first), rains.firstWhere((l) => l.id == 'm898'));
    await settle(tester, 10);
    await shot(tester, 'a5-hadith');
    Navigator.of(tester.element(find.byType(BottomSheet).last)).pop();
    await settle(tester, 6);
    await tester.tap(find.byTooltip('الإعدادات'));
    await settle(tester, 10);
    await shot(tester, 'a6-settings');
    store.setLanguage('en');
    await settle(tester, 10);
    showLight(tester.element(find.byType(Scaffold).first), pool.firstWhere((l) => l.id == 'q67_15'));
    await settle(tester, 10);
    await shot(tester, 'a7-verse-english');
  });
}
