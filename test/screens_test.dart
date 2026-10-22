// Renders the main screens with the real fonts, to check the design by eye:
//   flutter test test/screens_test.dart --dart-define=SHOTS=/path/to/folder
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nur/main.dart';
import 'package:nur/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nur_test.dart' show loadTestContent, FakeSteps, settle;

const out = String.fromEnvironment('SHOTS');

Future<void> loadFonts() async {
  final dir = '${Platform.environment['HOME']}/flutter/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold', 'Black', 'Light', 'Thin']) {
    roboto.addFont(Future.value(ByteData.sublistView(File('$dir/Roboto-$w.ttf').readAsBytesSync())));
  }
  await roboto.load();
  for (final (family, files) in const [
    ('AmiriQuran', ['AmiriQuran-Regular.ttf']),
    ('Amiri', ['Amiri-Regular.ttf']),
    ('NotoSansArabic', ['NotoSansArabic-Regular.ttf', 'NotoSansArabic-Bold.ttf']),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync())));
    }
    await loader.load();
  }
  final icons = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(File('$dir/MaterialIcons-Regular.otf').readAsBytesSync())));
  await icons.load();
}

Future<void> shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('shot')));
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1.5));
  final png = await tester.runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
  File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  setUpAll(loadTestContent);
  testWidgets('screens', (tester) async {
    if (out.isEmpty) return;
    await loadFonts();
    tester.view.physicalSize = const Size(412, 892) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final steps = FakeSteps();
    SharedPreferences.setMockInitialValues({});
    final store = await Store.load(steps: steps);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('shot'),
        child: NurApp(store: store),
      ),
    );
    await settle(tester, 15);
    await shot(tester, '01-welcome');
    await tester.tap(find.text('Begin'));
    await settle(tester, 15);
    await shot(tester, '02-welcome');
    await tester.tap(find.text('Next'));
    await settle(tester, 15);
    await shot(tester, '03-welcome');
    store.welcome();
    await settle(tester, 15);
    for (final (i, n) in [0, 900, 1650, 2750].indexed) {
      store.setTodaySteps(n);
      await settle(tester, 18);
      if (i > 0 && find.text('Read more in Sakina').evaluate().isNotEmpty) {
        Navigator.of(tester.element(find.text('Read more in Sakina'))).pop();
        await settle(tester, 6);
      }
      await shot(tester, '1$i-today');
    }
    await tester.tap(find.text('Walk a little more'));
    await settle(tester, 15);
    steps.live_.add(300);
    await settle(tester, 18);
    await shot(tester, '20-walk');
    jsonEncode({});
  });
}
