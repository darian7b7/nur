// The Play Store screenshots (1080 × 1920), with the real fonts:
//   flutter test test/store_shots_test.dart --dart-define=SHOTS=store/screenshots
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nur/main.dart';
import 'package:nur/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nur_test.dart' show FakeSteps, settle;
import 'screens_test.dart' show loadFonts;

const out = String.fromEnvironment('SHOTS');

Future<void> shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('shot')));
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 2.625));
  final png = await tester.runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
  File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
}

/// Closes a sheet if one is open (light found pops one up).
Future<void> closeSheets(WidgetTester tester) async {
  while (find.byType(BottomSheet).evaluate().isNotEmpty) {
    Navigator.of(tester.element(find.byType(BottomSheet).last)).pop();
    await settle(tester, 4);
  }
}

void main() {
  testWidgets('store screenshots', (tester) async {
    if (out.isEmpty) return;
    await loadFonts();
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final steps = FakeSteps()..isConnected = true;
    SharedPreferences.setMockInitialValues({});
    final store = await Store.load(steps: steps);
    store.setTodaySteps(0);
    await tester.pumpWidget(RepaintBoundary(key: const Key('shot'), child: NurApp(store: store)));
    await settle(tester, 15);
    await shot(tester, '1-welcome');
    store.welcome();
    await settle(tester, 15);
    await shot(tester, '2-dawn');
    steps.todaySteps = 1500; // 1.1 km
    await store.refresh();
    await settle(tester, 18);
    await closeSheets(tester);
    await shot(tester, '3-sunrise');
    // A walk: light found on the way.
    await tester.tap(find.text('Go out'));
    await settle(tester, 10);
    steps.live_.add(20000);
    await settle(tester, 3);
    steps.live_.add(20700);
    await settle(tester, 18);
    await shot(tester, '4-walk');
    await tester.tap(find.text('Finish walk'));
    await settle(tester, 8);
    await tester.tap(find.text('Done'));
    await settle(tester, 10);
    await closeSheets(tester);
    steps.todaySteps = 3000;
    await store.refresh();
    await settle(tester, 18);
    await closeSheets(tester);
    await shot(tester, '5-full-light');
    await tester.runAsync(() => Scrollable.ensureVisible(tester.element(find.text('Weather'))));
    await settle(tester, 2);
    await tester.tap(find.text('Weather'));
    await settle(tester, 10);
    await shot(tester, '6-rain');
    await closeSheets(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await settle(tester, 6);
    await tester.tap(find.byTooltip('The light you found'));
    await settle(tester, 12);
    await shot(tester, '7-collection');
  });
}
