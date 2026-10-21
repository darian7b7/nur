// The one optional daily reminder: silent, at a time you choose, and not on days you already walked.
import 'package:family_reminders/family_reminders.dart';

abstract class Reminder {
  Future<bool> requestPermission();

  /// Plans the reminder at [at] (minutes of the day) for the next days; null: none.
  Future<void> plan(int? at, {required bool skipToday});
}

/// What the reminder says, taking turns by day so it never feels like the same nag.
const reminderLines = [
  'The light is outside. A short walk?',
  'Even ten minutes outside brightens the day.',
  'Walk among its paths (67:15). The door is right there.',
  'With hardship comes ease (94:5). Step out for a moment.',
  'A few steps today. Small and regular is beloved.',
  'Whatever the weather, a little light is waiting.',
  'Your body has a right over you. Two minutes outside?',
];

class LocalReminder implements Reminder {
  final _notifier = LocalNotifier(channelId: 'walk', silent: true);
  var _ready = false;

  Future<void> init() async {
    await _notifier.init();
    _ready = true;
  }

  @override
  Future<bool> requestPermission() => _notifier.requestPermission(web: false);

  @override
  Future<void> plan(int? at, {required bool skipToday}) async {
    if (!_ready) return;
    final now = DateTime.now();
    final items = <(DateTime, Notice)>[];
    if (at != null) {
      for (var d = skipToday ? 1 : 0; d < 8; d++) {
        final when = DateTime(now.year, now.month, now.day + d, at ~/ 60, at % 60);
        if (!when.isAfter(now)) continue;
        items.add((when, Notice(title: 'Nūr', body: reminderLines[when.day % reminderLines.length], payload: 'walk')));
      }
    }
    await _notifier.scheduleAll(items, channelName: 'Daily walk');
  }
}
