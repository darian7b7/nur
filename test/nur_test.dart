import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nur/core/light.dart';
import 'package:nur/main.dart';
import 'package:nur/reminder.dart';
import 'package:nur/steps.dart';
import 'package:nur/store.dart';
import 'package:nur/ui/collection.dart';
import 'package:nur/ui/sky.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSteps implements Steps {
  int? todaySteps;
  bool isConnected = false;
  var live_ = StreamController<int>.broadcast();
  bool sensorFails = false;
  bool counter = true; // "Physical activity" allowed
  bool counterAsked = false;
  bool allowWhenAsked = true;

  @override
  Future<int?> today() async => isConnected ? todaySteps : null;

  @override
  Future<bool> connect() async => isConnected = true;

  @override
  Future<bool> counterAllowed() async => counter;

  @override
  Future<bool> allowCounter() async {
    counterAsked = true;
    return counter = allowWhenAsked;
  }

  @override
  Future<bool> connected() async => isConnected;

  @override
  Stream<int> live() {
    if (sensorFails) return Stream.error(Exception('no sensor'));
    live_ = StreamController<int>.broadcast();
    return live_.stream;
  }
}

class FakeReminder implements Reminder {
  int? at;
  bool? skippedToday;

  @override
  Future<bool> requestPermission() async => true;

  List<String> lines = [];

  @override
  Future<void> plan(int? at, {required bool skipToday, required String title, required List<String> lines}) async {
    this.lines = lines;
    this.at = at;
    skippedToday = skipToday;
  }
}

/// Collects layout errors (overflow) instead of stopping at the first.
class Errors {
  Errors() : _before = FlutterError.onError {
    FlutterError.onError = (d) {
      if (found.isEmpty) debugPrint(d.toString());
      found.add(d.exceptionAsString().split('\n').first);
    };
  }

  final found = <String>[];
  final void Function(FlutterErrorDetails)? _before;

  Future<void> run(Future<void> Function() body) async {
    try {
      await body();
    } finally {
      FlutterError.onError = _before;
      if (found.isNotEmpty) debugPrint('LAYOUT: ${found.toSet().join(' | ')}');
    }
    expect(found.toSet(), isEmpty);
  }
}

Future<Store> store({FakeSteps? steps, Map<String, Object> saved = const {}, FakeReminder? reminder}) async {
  SharedPreferences.setMockInitialValues(saved);
  return Store.load(steps: steps ?? FakeSteps(), reminder: reminder);
}

Future<(Store, FakeSteps)> pump(
  WidgetTester tester, {
  Size size = const Size(412, 915),
  double text = 1,
  bool welcomed = true,
  FakeSteps? steps,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = text;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final s = steps ?? FakeSteps();
  final st = await store(
    steps: s,
    saved: welcomed
        ? {
            'nur.v1': jsonEncode({'welcomed': true}),
          }
        : {},
  );
  await tester.pumpWidget(NurApp(store: st));
  await settle(tester);
  return (st, s);
}

Future<void> settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// The verses and hadith, as the app loads them.
void loadTestContent() => loadContent(File('assets/content/lights.json').readAsStringSync());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadTestContent);

  group('the light', () {
    test('every light has a text and a reference; the day path climbs; ids are unique', () {
      final ids = <String>{};
      for (final l in [...allLights, dawn, ...why]) {
        expect(l.text.length, greaterThan(20));
        expect(l.source, matches(RegExp(r'^(.+ \d+:\d+(–\d+)?|Sahih (Muslim|al-Bukhari) \d+)$')), reason: l.source);
        expect(ids.add(l.id), isTrue, reason: 'duplicate ${l.id}');
        if (l.isQuran) expect(l.source, contains('${l.surah}:${l.ayah}'));
        expect(l.sourceUrl.host, l.isQuran ? 'quran.com' : 'sunnah.com', reason: l.source);
      }
      for (var i = 1; i < dayMarks.length; i++) {
        expect(dayMarks[i], greaterThan(dayMarks[i - 1]));
      }
    });

    test('each light links to its exact source', () {
      Light byId(String id) => allLights.firstWhere((l) => l.id == id);
      expect(byId('q67_15').sourceUrl.toString(), 'https://quran.com/67/15');
      expect(byId('q94_5').sourceUrl.toString(), 'https://quran.com/94/5-6');
      expect(byId('m898').sourceUrl.toString(), 'https://sunnah.com/muslim:898');
      expect(byId('b6464').sourceUrl.toString(), 'https://sunnah.com/bukhari:6464');
    });

    test('found along the way, and what comes next', () {
      final day = DateTime(2026, 10, 21);
      final path = pathFor(day);
      expect(foundToday(0, day), isEmpty);
      expect(foundToday(1000, day), [path[0].$2, path[1].$2, path[2].$2]);
      expect(nextToday(950, day), (50, path[2].$2));
      expect(nextToday(20000, day), isNull);
      expect(foundAt(path[3].$2, day), 1500);
      expect(foundLong(30).length, 2);
    });

    test('a new path every day: never the same light two days running, nothing back before the pool is seen', () {
      final start = DateTime(2026, 1, 1);
      final seen = <String>[];
      for (var d = 0; d < 1500; d++) {
        final today = pathFor(DateTime(start.year, start.month, start.day + d)).map((e) => e.$2.id).toList();
        final tomorrow = pathFor(DateTime(start.year, start.month, start.day + d + 1)).map((e) => e.$2.id).toSet();
        expect(today.toSet().length, dayMarks.length, reason: 'day $d: a light twice on one path');
        expect(today.toSet().intersection(tomorrow), isEmpty, reason: 'day $d repeats tomorrow');
        seen.addAll(today);
      }
      // Each round of the pool shows every light once.
      for (var r = 0; r + pool.length <= seen.length; r += pool.length) {
        expect(seen.sublist(r, r + pool.length).toSet().length, pool.length);
      }
      // The same day always has the same path (it doesn't change when Nūr is reopened).
      expect(pathFor(DateTime(2026, 10, 21, 8)).map((e) => e.$2.id), pathFor(DateTime(2026, 10, 21, 22)).map((e) => e.$2.id));
      expect(pool.length, greaterThanOrEqualTo(dayMarks.length * 4));
      expect(hardDayFor(DateTime(2026, 3, 2)), isNot(hardDayFor(DateTime(2026, 3, 3))));
      expect(rainFor(DateTime(2026, 3, 2)), isNot(rainFor(DateTime(2026, 3, 3))));
    });

    test('distances read plainly', () {
      expect(distanceText(0), '0 m');
      expect(distanceText(648), '650 m');
      expect(distanceText(1000), '1 km');
      expect(distanceText(1450), '1.5 km');
      expect(distanceText(12400), '12 km');
      expect(preciseDistance(37.4), '37 m');
      expect(preciseDistance(1237), '1.24 km');
      expect(preciseDistance(12340), '12.3 km');
      expect(metresFor(1000, 75), 750);
      expect(strideFor(180), 75);
    });

    test('the sky: dark at dawn, bright at the goal; text stays readable on it', () {
      final (top0, _, _) = skyColors(0);
      final (top1, _, _) = skyColors(1);
      expect(top0.computeLuminance(), lessThan(0.02));
      expect(top1.computeLuminance(), greaterThan(0.3));
      for (var p = 0.0; p <= 1.0; p += 0.02) {
        final (top, mid, _) = skyColors(p);
        expect(contrast(inkOn(p), Color.lerp(top, mid, 0.5)!), greaterThan(3.0), reason: 'progress $p');
      }
    });
  });

  group('Arabic', () {
    test('every verse and hadith has its Arabic and an Arabic reference', () {
      final latin = RegExp('[A-Za-z]');
      for (final l in [...allLights, dawn, ...why]) {
        expect(l.arabic, isNotEmpty, reason: l.id);
        expect(latin.hasMatch(l.arabic), isFalse, reason: '${l.id}: Latin letters in the Arabic');
        expect(l.sourceArabic, matches(RegExp(r'^[\u0600-\u06FF ]+ [٠-٩]+(–[٠-٩]+)?$')), reason: l.id);
        expect(l.textIn('ar'), l.arabic);
        expect(l.textIn('en'), l.text);
      }
    });

    test('the English and Arabic language files have the same texts, with the same blanks', () {
      final en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
      final ar = jsonDecode(File('lib/l10n/app_ar.arb').readAsStringSync()) as Map<String, dynamic>;
      final keys = en.keys.where((k) => !k.startsWith('@'));
      expect(ar.keys.where((k) => !k.startsWith('@')).toSet(), keys.toSet());
      for (final k in keys) {
        final blanks = RegExp(r'\{(\w+)\}').allMatches(en[k] as String).map((m) => m[1]).toSet();
        expect(RegExp(r'\{(\w+)\}').allMatches(ar[k] as String).map((m) => m[1]).toSet(), blanks, reason: k);
        expect((ar[k] as String).trim(), isNotEmpty, reason: k);
      }
    });
  });

  group('store', () {
    test('steps become metres; each light is found once; the most of the day is kept', () async {
      final s = await store();
      expect(s.setTodaySteps(500), [pathFor(DateTime.now()).first.$2]); // 375 m
      expect(s.setTodaySteps(600), isEmpty);
      expect(s.setTodaySteps(100), isEmpty);
      expect(s.todayMetres, 450, reason: 'a lower reading never takes the day back');
      expect(s.found.keys, [pathFor(DateTime.now()).first.$2.id]);
    });

    test('a hard day: the goal is just outside the door, and it has its own light', () async {
      final s = await store();
      s.setHardDay(true);
      expect(s.todayGoal, hardDayMetres);
      final fresh = s.setTodaySteps(300);
      expect(fresh, contains(hardDayFor(DateTime.now())));
      expect(s.progress, greaterThan(1));
      s.setHardDay(false);
      expect(s.todayGoal, 2000);
    });

    test('walks without Health Connect still count; with it, the phone\'s count wins', () async {
      final steps = FakeSteps();
      final s = await store(steps: steps);
      s.addWalk(2000);
      await s.refresh();
      expect(s.connected, isFalse);
      expect(s.todayMetres, 1500);
      steps
        ..isConnected = true
        ..todaySteps = 5000;
      await s.refresh();
      expect(s.connected, isTrue);
      expect(s.todayMetres, 3750);
    });

    test('the long path adds up the days', () async {
      final s = await store(
        saved: {
          'nur.v1': jsonEncode({
            'days': {'2026-10-01': 3000, '2026-10-02': 2500},
          }),
        },
      );
      expect(s.totalKm, 5.5);
      s.setTodaySteps(0);
      expect(s.found.containsKey('q29_20'), isTrue, reason: '5 km in all');
    });

    test('the reminder says when it comes next, and why not today; it speaks the chosen language', () async {
      final r = FakeReminder();
      final s = await store(reminder: r);
      await s.setReminder(on: true, at: 17 * 60);
      final morning = DateTime.now().copyWith(hour: 9, minute: 0);
      final evening = DateTime.now().copyWith(hour: 20, minute: 0);
      expect(s.reminderNext(morning), ReminderNext.today);
      expect(s.reminderNext(evening), ReminderNext.passed);
      expect(r.lines.first, 'The light is outside. A short walk?');
      s.setLanguage('ar');
      await Future<void>.delayed(Duration.zero);
      expect(r.lines.first, 'النور في الخارج. مشيٌ قصير؟');
      s.setTodaySteps(5000);
      expect(s.reminderNext(morning), ReminderNext.full);
      await s.setReminder(on: false);
      expect(s.reminderNext(morning), isNull);
    });

    test('refused notifications: the reminder stays off and says why', () async {
      final s = await store(reminder: _RefusingReminder());
      await s.setReminder(on: true);
      expect(s.remind, isFalse);
      expect(s.reminderRefused, isTrue);
    });

    test('rain is found by going out in it; reminders skip a day already in full light', () async {
      final r = FakeReminder();
      final s = await store(reminder: r);
      s.wentOutInRain();
      expect(s.found.containsKey(rainFor(DateTime.now()).id), isTrue);
      await s.setReminder(on: true, at: 18 * 60);
      expect(r.at, 18 * 60);
      expect(r.skippedToday, isFalse);
      s.setTodaySteps(3000);
      await s.planReminder();
      expect(r.skippedToday, isTrue);
    });

    test('damaged saved data: Nūr opens fresh instead of crashing', () async {
      for (final bad in ['x', '[]', '{"days": 4}', '{"goal": "far"}', '{"found": {"a": 1}}']) {
        final s = await store(saved: {'nur.v1': bad});
        expect(() => s.setTodaySteps(100), returnsNormally, reason: bad);
      }
      final s = await store(saved: {'nur.v1': '{"goal": 999999, "stride": 3}'});
      expect(s.goal, 30000);
      expect(s.strideCm, 40);
    });

    test('live steps: each step counts at once, steps while closed are caught up, no double counting', () async {
      final steps = FakeSteps();
      final s = await store(steps: steps);
      s.startLive();
      steps.live_.add(5000); // first reading: nothing walked yet
      await Future<void>.delayed(Duration.zero);
      expect(s.stepsToday, 0);
      steps.live_.add(5400);
      await Future<void>.delayed(Duration.zero);
      expect(s.stepsToday, 400);
      s.stopLive(); // Nūr in the background; the phone keeps counting
      final again = await Store.load(steps: steps); // Nūr opened again, same saved data
      expect(again.stepsToday, 400);
      again.startLive();
      steps.live_.add(6000); // 600 more while closed
      await Future<void>.delayed(Duration.zero);
      expect(again.stepsToday, 1000);
      // Health Connect catches up with the same steps: the most wins, nothing is added twice.
      steps
        ..isConnected = true
        ..todaySteps = 1000;
      await again.refresh();
      expect(again.stepsToday, 1000);
      steps.live_.add(6100);
      await Future<void>.delayed(Duration.zero);
      expect(again.stepsToday, 1100);
    });

    test('a restarted phone starts its counter at zero: Nūr keeps the day', () async {
      final steps = FakeSteps();
      final s = await store(steps: steps);
      s.startLive();
      steps.live_
        ..add(8000)
        ..add(8500);
      await Future<void>.delayed(Duration.zero);
      s.stopLive();
      s.startLive();
      steps.live_.add(120); // after a restart
      await Future<void>.delayed(Duration.zero);
      expect(s.stepsToday, 620);
    });

    test('the week: seven days, today last', () async {
      final now = DateTime.now();
      final s = await store(
        saved: {
          'nur.v1': jsonEncode({
            'days': {Store.dayKey(now): 1200, Store.dayKey(DateTime(now.year, now.month, now.day - 6)): 800},
          }),
        },
      );
      expect(s.lastWeek(now), [800, 0, 0, 0, 0, 0, 1200]);
    });
  });

  group('screens', () {
    testWidgets('welcome: night to dawn in three pages, connect, then Today', (tester) async {
      final (s, steps) = await pump(tester, welcomed: false);
      expect(find.text('Nūr'), findsOneWidget);
      await tester.tap(find.text('Begin'));
      await settle(tester);
      expect(find.textContaining('Every step'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await settle(tester);
      await tester.tap(find.text('3 km'));
      await tester.tap(find.text('Connect Health Connect'));
      await settle(tester);
      expect(find.textContaining('Connected. Steps count also while'), findsOneWidget);
      await tester.tap(find.text('Start'));
      await settle(tester);
      expect(s.welcomed, isTrue);
      expect(s.goal, 3000);
      expect(find.text('Go out'), findsOneWidget);
      expect(steps.isConnected, isTrue);
    });

    testWidgets('step counting refused: Start asks for it, Today says so plainly, Go out asks again', (tester) async {
      final steps = FakeSteps()
        ..counter = false
        ..allowWhenAsked = false;
      final (s, _) = await pump(tester, welcomed: false, steps: steps);
      await tester.tap(find.text('Begin'));
      await settle(tester);
      await tester.tap(find.text('Next'));
      await settle(tester);
      expect(find.text('Allow step counting'), findsWidgets, reason: 'no Start without the step counter');
      await tester.runAsync(() => Scrollable.ensureVisible(tester.element(find.widgetWithText(FilledButton, 'Allow step counting'))));
      await settle(tester, 2);
      await tester.tap(find.widgetWithText(FilledButton, 'Allow step counting'));
      await settle(tester);
      expect(steps.counterAsked, isTrue);
      expect(s.welcomed, isFalse, reason: 'refused: still on the welcome');
      s.welcome(); // e.g. from an earlier version
      await settle(tester);
      expect(find.text('Steps are off'), findsOneWidget);
      steps.counterAsked = false;
      await tester.runAsync(() => Scrollable.ensureVisible(tester.element(find.text('Go out')), alignment: 0.5));
      await settle(tester, 2);
      await tester.tap(find.text('Go out'));
      await settle(tester);
      expect(steps.counterAsked, isTrue);
      expect(find.text('WALKING INTO THE LIGHT'), findsNothing, reason: 'no walk that cannot count');
      // Allowed later (for example in the phone's settings): the banner goes, counting starts.
      steps.counter = true;
      await s.refresh();
      await settle(tester);
      expect(find.text('Steps are off'), findsNothing);
    });

    testWidgets('in Arabic: right to left, Arabic words, the verse in Arabic; English again from Settings', (tester) async {
      final (s, steps) = await pump(tester);
      s.setLanguage('ar');
      await settle(tester);
      expect(Directionality.of(tester.element(find.text('اخرج'))), TextDirection.rtl);
      expect(find.text('نور اليوم'), findsOneWidget);
      expect(find.textContaining(dawn.arabic.substring(0, 12)), findsOneWidget, reason: 'the dawn verse in Arabic');
      expect(find.text(dawn.sourceArabic), findsOneWidget);
      await tester.tap(find.text('اخرج'));
      await settle(tester);
      expect(find.text('تمشي نحو النور'), findsOneWidget);
      steps.live_.add(5000);
      await settle(tester, 2);
      steps.live_.add(5600);
      await settle(tester);
      expect(find.textContaining(' م'), findsWidgets, reason: 'metres in Arabic');
      await tester.tap(find.text('إنهاء المشي'));
      await settle(tester);
      await tester.tap(find.text('تم'));
      await settle(tester);
      await tester.tap(find.byTooltip('الإعدادات'));
      await settle(tester);
      await tester.tap(find.text('English'));
      await settle(tester);
      expect(find.text('Settings'), findsOneWidget);
      expect(s.language, 'en');
    });

    testWidgets('Today at dawn: the first verse, the next light, Go out', (tester) async {
      await pump(tester);
      expect(find.text("TODAY'S LIGHT"), findsOneWidget);
      expect(find.text('0 m'), findsOneWidget);
      expect(find.textContaining('Allah is the ally'), findsOneWidget);
      expect(find.text('Next light in 300 m'), findsOneWidget);
    });

    testWidgets('a walk: the sky brightens, light appears on the way, the end says what you found', (tester) async {
      final (s, steps) = await pump(tester);
      await tester.tap(find.text('Go out'));
      await settle(tester);
      expect(find.text('WALKING INTO THE LIGHT'), findsOneWidget);
      steps.live_.add(10000); // the phone's counter as the walk starts
      await settle(tester, 2);
      steps.live_.add(10200);
      await settle(tester, 3);
      expect(find.textContaining('200 steps'), findsOneWidget);
      steps.live_.add(10450); // 337 m: the first light
      await settle(tester);
      expect(find.text('LIGHT FOUND'), findsOneWidget);
      expect(find.textContaining(pathFor(DateTime.now())[0].$2.text.substring(0, 30)), findsOneWidget);
      steps.live_.add(11400); // 1050 m
      await settle(tester);
      await tester.tap(find.text('Finish walk'));
      await settle(tester);
      expect(find.text('You went out.'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await settle(tester);
      expect(find.text('1.1 km'), findsOneWidget);
      expect(s.found.keys, containsAll([for (final e in pathFor(DateTime.now()).take(3)) e.$2.id]));
      expect(find.textContaining(pathFor(DateTime.now())[2].$2.text.substring(0, 30)), findsOneWidget, reason: 'the latest light shows on Today');
    });

    testWidgets('without a step sensor the walk still runs on time', (tester) async {
      final _ = await pump(tester, steps: FakeSteps()..sensorFails = true);
      await tester.tap(find.text('Go out'));
      await settle(tester);
      expect(find.textContaining('steps are counted by your phone'), findsOneWidget);
      await tester.tap(find.text('Finish walk'));
      await settle(tester);
      expect(find.text('You stepped out.'), findsOneWidget);
    });

    testWidgets('the back gesture during a walk finishes it, never loses it', (tester) async {
      final (s, steps) = await pump(tester);
      await tester.tap(find.text('Go out'));
      await settle(tester);
      steps.live_.add(5000);
      await settle(tester, 2);
      steps.live_.add(5800);
      await settle(tester, 3);
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      await nav.maybePop();
      await settle(tester);
      expect(find.text('You went out.'), findsOneWidget);
      expect(s.walkSteps.values.single, 800);
    });

    testWidgets('hard day, new way and the weather', (tester) async {
      final (s, _) = await pump(tester);
      await tester.tap(find.text('Hard day'));
      await settle(tester);
      expect(find.text('A HARD DAY · JUST STEP OUTSIDE'), findsOneWidget);
      expect(find.text('of 200 m'), findsOneWidget);
      expect(find.textContaining(hardDayFor(DateTime.now()).text.substring(0, 30)), findsOneWidget);
      await tester.tap(find.text('New way'));
      await settle(tester);
      expect(find.byTooltip('Another way'), findsOneWidget);
      await tester.runAsync(() => Scrollable.ensureVisible(tester.element(find.text('Weather')), alignment: 0.5));
      await settle(tester, 2);
      await tester.tap(find.text('Weather'));
      await settle(tester);
      expect(find.textContaining(rainFor(DateTime.now()).text.substring(0, 30)), findsOneWidget);
      await tester.tap(find.text('Go out in the rain'));
      await settle(tester);
      expect(find.text('WALKING IN THE RAIN'), findsOneWidget);
      expect(s.isHardDay, isTrue);
    });

    testWidgets('the collection shows found light and what the rest needs', (tester) async {
      final (s, _) = await pump(tester);
      s.setTodaySteps(1400);
      await settle(tester);
      await tester.tap(find.byTooltip('The light you found'));
      await settle(tester);
      expect(find.byType(Collection), findsOneWidget);
      expect(find.text('3 of ${allLights.length} found'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('more waiting on your walks'),
        300,
        scrollable: find.descendant(of: find.byType(Collection), matching: find.byType(Scrollable)).first,
      );
      expect(find.textContaining('${pool.length - 3} more waiting on your walks'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -900));
      await settle(tester, 3);
      expect(find.text('Walk 1000 km in all'), findsOneWidget);
      expect(find.textContaining('9 more waiting for hard days'), findsOneWidget);
    });

    testWidgets('settings: goal, height, connect, reminder', (tester) async {
      final (s, steps) = await pump(tester);
      await tester.tap(find.byTooltip('Settings'));
      await settle(tester);
      await tester.tap(find.text('5 km'));
      await tester.pump();
      expect(s.goal, 5000);
      await tester.tap(find.text('Connect Health Connect'));
      await settle(tester);
      expect(steps.isConnected, isTrue);
      expect(find.textContaining('Connected. Steps count also while'), findsOneWidget);
      expect(find.text('Remind me to walk'), findsOneWidget);
    });

    for (final (size, text, lang) in const [
      (Size(360, 640), 1.0, 'en'),
      (Size(360, 640), 2.0, 'en'),
      (Size(320, 568), 1.5, 'en'),
      (Size(412, 915), 1.3, 'en'),
      (Size(360, 640), 1.0, 'ar'),
      (Size(360, 640), 2.0, 'ar'),
      (Size(320, 568), 1.5, 'ar'),
    ]) {
      testWidgets('every screen fits: ${size.width.toInt()}×${size.height.toInt()}, text ×$text, $lang', (tester) async {
        final errors = Errors();
        await errors.run(() async {
          final (s, steps) = await pump(tester, size: size, text: text, welcomed: false);
          s.setLanguage(lang);
          await settle(tester);
          final ar = lang == 'ar';
          for (final b in ar ? ['ابدأ', 'التالي'] : ['Begin', 'Next']) {
            await tester.runAsync(() => Scrollable.ensureVisible(tester.element(find.text(b))));
            await settle(tester, 2);
            await tester.tap(find.text(b));
            await settle(tester);
          }
          s.welcome();
          await settle(tester);
          String t(String en, String arabic) => ar ? arabic : en;
          for (final steps_ in [0, 1500, 3000, 6000]) {
            s.setTodaySteps(steps_);
            await settle(tester, 15);
          }
          await tester.tap(find.byTooltip(t('Settings', 'الإعدادات')));
          await settle(tester);
          await tester.tapAt(const Offset(5, 5));
          await settle(tester);
          await tester.tap(find.byTooltip(t('The light you found', 'النور الذي وجدته')));
          await settle(tester);
          await tester.drag(find.byType(Scrollable).first, const Offset(0, -5000));
          await settle(tester);
          Navigator.of(tester.element(find.byType(Collection))).pop();
          await settle(tester);
          final more = t('Walk a little more', 'امشِ قليلًا بعد');
          await tester.runAsync(() => Scrollable.ensureVisible(tester.element(find.text(more))));
          await settle(tester, 2);
          await tester.tap(find.text(t('New way', 'طريق جديد')));
          await tester.tap(find.text(more));
          await settle(tester);
          steps.live_.add(1000);
          await settle(tester, 2);
          steps.live_.add(9000);
          await settle(tester);
          await tester.tap(find.text(t('Finish walk', 'إنهاء المشي')));
          await settle(tester);
          await tester.tap(find.text(t('Done', 'تم')));
          await settle(tester);
          await tester.pumpWidget(const SizedBox());
        });
      });
    }
  });
}

class _RefusingReminder extends FakeReminder {
  @override
  Future<bool> requestPermission() async => false;
}
