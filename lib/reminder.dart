// The one optional daily reminder: silent, at a time you choose, and not on days you already walked.
import 'package:family_reminders/family_reminders.dart';

abstract class Reminder {
  Future<bool> requestPermission();

  /// Plans the reminder at [at] (minutes of the day) for the next days; null: none.
  /// [title] and [lines] are in the reader's language; the lines take turns by day.
  Future<void> plan(int? at, {required bool skipToday, required String title, required List<String> lines});
}

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
  Future<void> plan(int? at, {required bool skipToday, required String title, required List<String> lines}) async {
    if (!_ready) return;
    final now = DateTime.now();
    final items = <(DateTime, Notice)>[];
    if (at != null) {
      for (var d = skipToday ? 1 : 0; d < 8; d++) {
        final when = DateTime(now.year, now.month, now.day + d, at ~/ 60, at % 60);
        if (!when.isAfter(now)) continue;
        items.add((when, Notice(title: title, body: lines[when.day % lines.length], payload: 'walk')));
      }
    }
    await _notifier.scheduleAll(items, channelName: 'Daily walk');
  }
}
