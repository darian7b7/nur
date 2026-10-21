// Crash hunting: thousands of random step readings, restarts, goals, hard days and damaged data.
import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nur/core/light.dart';
import 'package:nur/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nur_test.dart' show FakeSteps;

void main() {
  test('5000 random events: the day only grows, every light is real, nothing throws', () async {
    final r = Random(3);
    final steps = FakeSteps();
    SharedPreferences.setMockInitialValues({});
    var s = await Store.load(steps: steps);
    var raw = r.nextInt(100000);
    var lastSteps = 0;
    for (var i = 0; i < 5000; i++) {
      switch (r.nextInt(10)) {
        case 0:
          s.stopLive();
          s = await Store.load(steps: steps); // Nūr closed and opened again
        case 1:
          raw = r.nextInt(50); // the phone restarted
        case 2:
          steps
            ..isConnected = r.nextBool()
            ..todaySteps = r.nextInt(30000);
          await s.refresh();
        case 3:
          s.setGoal([200, 1000, 2000, 5000, 30000][r.nextInt(5)]);
        case 4:
          s.setHardDay(r.nextBool());
        case 5:
          s.setStride(r.nextInt(200));
        case 6:
          s.addWalk(r.nextInt(3000) - 100);
        default:
          s.startLive();
          raw += r.nextInt(400);
          steps.live_.add(raw);
          await Future<void>.delayed(Duration.zero);
      }
      expect(s.stepsToday, greaterThanOrEqualTo(lastSteps), reason: 'event $i: the day went backwards');
      lastSteps = s.stepsToday;
      expect(s.progress.isFinite, isTrue);
      expect(s.found.keys.every((id) => allLights.any((l) => l.id == id)), isTrue);
      expect(s.todayGoal, greaterThan(0));
    }
  });

  test('every day for 10 years: a path of 10 different lights, the long path in order', () {
    for (var d = 0; d < 3650; d++) {
      final day = DateTime(2026, 1, 1 + d);
      final path = pathFor(day);
      expect(path.length, dayMarks.length);
      expect(path.map((e) => e.$2.id).toSet().length, dayMarks.length);
      expect(foundToday(1 << 30, day).length, dayMarks.length);
    }
    expect(pathFor(DateTime(2020, 5, 5)).length, dayMarks.length, reason: 'a phone clock set in the past');
  });

  test('saved data of every odd shape opens', () async {
    final r = Random(9);
    final values = <Object?>[null, 0, -1, 1 << 40, 'x', true, [], {}, 1.5];
    for (var i = 0; i < 500; i++) {
      final j = {
        for (final k in ['welcomed', 'goal', 'stride', 'remind', 'remindAt', 'days', 'walkSteps', 'found', 'hardDayOn', 'steps'])
          if (r.nextBool()) k: values[r.nextInt(values.length)],
      };
      SharedPreferences.setMockInitialValues({'nur.v1': jsonEncode(j)});
      final s = await Store.load(steps: FakeSteps());
      expect(() => s.setTodaySteps(r.nextInt(5000)), returnsNormally, reason: jsonEncode(j));
      expect(s.goal, inInclusiveRange(200, 30000));
    }
  });
}
