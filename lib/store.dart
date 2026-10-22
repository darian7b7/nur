// What Nūr remembers, on the phone only: your goal, your stride, the light you found, and how far you
// walked each day.
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/light.dart';
import 'reminder.dart';
import 'steps.dart';

class Store extends ChangeNotifier {
  Store(this._prefs, {required this.steps, this.reminder}) {
    try {
      _read();
    } catch (e) {
      debugPrint('Could not read saved data: $e'); // damaged: start fresh rather than crash
    }
  }

  static const _key = 'nur.v1';
  final SharedPreferences? _prefs;
  final Steps steps;
  final Reminder? reminder;

  static Future<Store> load({required Steps steps, Reminder? reminder}) async {
    try {
      return Store(await SharedPreferences.getInstance(), steps: steps, reminder: reminder);
    } catch (e) {
      debugPrint('Storage unavailable: $e');
      return Store(null, steps: steps, reminder: reminder);
    }
  }

  bool welcomed = false;

  /// Today's light, in metres.
  int goal = 2000;
  int strideCm = 75;

  /// Health Connect is connected (today's steps are read from the phone, also while Nūr is closed).
  bool connected = false;

  /// The phone's step counter may be used. Null until checked. Without it Nūr can't count at all.
  bool? counterOk;

  /// Notifications were refused when the reminder was turned on.
  bool reminderRefused = false;

  /// One quiet reminder a day at [remindAt] (minutes of the day), off unless chosen.
  bool remind = false;
  int remindAt = 17 * 60;

  /// Metres walked each day: day key → metres (the most seen that day).
  Map<String, int> days = {};

  /// Steps of walks in Nūr today (used when Health Connect isn't connected).
  Map<String, int> walkSteps = {};

  /// Lights found: id → the day first found.
  Map<String, String> found = {};

  /// Today was marked a hard day: the goal is just to step outside.
  String? hardDayOn;

  static String dayKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get _today => dayKey(DateTime.now());

  int get todayMetres => days[_today] ?? 0;
  bool get isHardDay => hardDayOn == _today;

  /// The goal for today: just outside the door on a hard day.
  int get todayGoal => isHardDay ? hardDayMetres : goal;

  /// 0 at dawn, 1 when today's goal is reached (can go beyond).
  double get progress => todayMetres / max(1, todayGoal);

  double get totalKm => days.values.fold(0, (s, m) => s + m) / 1000;

  /// Metres for each of the last 7 days, oldest first.
  List<int> lastWeek([DateTime? now]) {
    final n = now ?? DateTime.now();
    return [for (var i = 6; i >= 0; i--) days[dayKey(DateTime(n.year, n.month, n.day - i))] ?? 0];
  }

  /// Today's steps as best known: the most of Health Connect, the live counter and walks.
  int stepsToday = 0;
  String? _stepsDay;

  /// The phone's step counter right now (null until it has been read, or without a sensor).
  int? rawNow;

  /// The counter's last reading saved: (day, counter, today's steps then). Steps taken while Nūr was
  /// closed are the difference, as long as it is the same day and the phone wasn't restarted.
  String? _rawDay;
  int _rawLast = 0;
  int _rawSteps = 0;

  /// Whether the live counter works on this phone.
  bool liveWorks = true;

  /// Called with light found by live steps (the screen on top shows it).
  void Function(List<Light>)? onFound;

  StreamSubscription<int>? _live;

  /// Checks what Nūr may use (the user can change it in the phone's settings at any time).
  Future<void> checkAccess() async {
    final ok = await steps.counterAllowed();
    final wasOk = counterOk;
    counterOk = ok;
    connected = await steps.connected();
    if (ok && wasOk != true) {
      // Just allowed (here or in the phone's settings): start counting.
      liveWorks = true;
      stopLive();
      startLive();
    }
    notifyListeners();
  }

  /// Asks for the step counter. True if Nūr can count now.
  Future<bool> allowCounter() async {
    await steps.allowCounter();
    await checkAccess();
    return counterOk == true;
  }

  /// Reads today's steps from the phone and finds any new light. Returns the lights newly found.
  Future<List<Light>> refresh() async {
    await checkAccess();
    final s = connected ? await steps.today() : null;
    return _setSteps(max(s ?? 0, walkSteps[_today] ?? 0));
  }

  /// Asks for Health Connect steps (and the step counter first, if needed), then reads today again.
  Future<void> connectSteps() async {
    if (counterOk != true) await allowCounter();
    await steps.connect();
    await refresh();
  }

  /// Follows the step counter while Nūr is open: each step shows at once.
  void startLive() {
    if (_live != null || !liveWorks || counterOk == false) return;
    _live = steps.live().listen(
      _onRaw,
      onError: (Object e) {
        debugPrint('No live steps: $e');
        liveWorks = false;
        _live = null;
        notifyListeners();
      },
    );
  }

  /// Stops following the counter (Nūr in the background: the counter keeps counting by itself).
  void stopLive() {
    _live?.cancel();
    _live = null;
    rawNow = null;
  }

  void _onRaw(int raw) {
    final day = _today;
    if (_stepsDay != day) stepsToday = 0;
    var n = stepsToday;
    final last = rawNow;
    if (last == null) {
      // First reading since Nūr opened: add what was walked while it was closed, the same day.
      if (_rawDay == day) n = max(n, _rawSteps + (raw >= _rawLast ? raw - _rawLast : raw));
    } else if (raw > last) {
      n += raw - last;
    }
    rawNow = raw;
    _rawDay = day;
    _rawLast = raw;
    _rawSteps = max(stepsToday, n); // before saving: the counter and the steps belong together
    final fresh = _setSteps(n);
    if (fresh.isNotEmpty) onFound?.call(fresh);
  }

  List<Light> _setSteps(int n) {
    if (_stepsDay != _today) {
      stepsToday = 0;
      _stepsDay = _today;
    }
    stepsToday = max(stepsToday, n);
    return setTodaySteps(stepsToday);
  }

  @override
  void dispose() {
    stopLive();
    super.dispose();
  }

  /// Today's steps are [n]: keeps the most, and finds the light on the way. Returns what is new.
  List<Light> setTodaySteps(int n) {
    final m = metresFor(n, strideCm);
    if (m > todayMetres) days = {...days, _today: m};
    final fresh = <Light>[
      for (final l in [
        ...foundToday(todayMetres, DateTime.now()),
        ...foundLong(totalKm),
        if (isHardDay && todayMetres >= hardDayMetres) hardDayFor(DateTime.now()),
      ])
        if (!found.containsKey(l.id)) l,
    ];
    if (fresh.isNotEmpty) found = {...found, for (final l in fresh) l.id: _today};
    _save();
    return fresh;
  }

  /// A walk in Nūr took [n] steps: they count today even without Health Connect.
  void addWalk(int n) {
    if (n <= 0) return;
    walkSteps = {_today: (walkSteps[_today] ?? 0) + n};
    _save();
  }

  /// Out in the rain: today's light for rain is found.
  void wentOutInRain() {
    final rain = rainFor(DateTime.now());
    if (found.containsKey(rain.id)) return;
    found = {...found, rain.id: _today};
    _save();
  }

  void setHardDay(bool on) {
    hardDayOn = on ? _today : null;
    _save();
  }

  void setGoal(int metres) {
    goal = metres;
    _save();
  }

  void setStride(int cm) {
    strideCm = cm.clamp(40, 120);
    _save();
  }

  void welcome() {
    welcomed = true;
    _save();
  }

  Future<void> setReminder({bool? on, int? at}) async {
    remind = on ?? remind;
    remindAt = at ?? remindAt;
    reminderRefused = false;
    if (remind && reminder != null && !await reminder!.requestPermission()) {
      remind = false;
      reminderRefused = true;
    }
    _save();
    await planReminder();
  }

  /// When the next reminder comes, or null when it is off.
  DateTime? nextReminder([DateTime? now]) {
    if (!remind) return null;
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day, remindAt ~/ 60, remindAt % 60);
    return today.isAfter(n) && progress < 1 ? today : today.add(const Duration(days: 1));
  }

  /// In plain words: "Next: today around 17:00", and why not today when it isn't.
  String reminderText([DateTime? now]) {
    final next = nextReminder(now);
    if (next == null) return '';
    final n = now ?? DateTime.now();
    final at = '${(remindAt ~/ 60).toString().padLeft(2, '0')}:${(remindAt % 60).toString().padLeft(2, '0')}';
    if (next.day == n.day) return 'Next: today around $at.';
    final why = progress >= 1 ? " Today's light is already full, so none today." : ' $at has passed today.';
    return 'Next: tomorrow around $at.$why';
  }

  /// Plans the daily reminder again (call on start): none on days the goal is already reached.
  Future<void> planReminder() async {
    try {
      await reminder?.plan(remind ? remindAt : null, skipToday: progress >= 1);
    } catch (e) {
      debugPrint('Could not plan the reminder: $e');
    }
  }

  void forgetAll() {
    days = {};
    stepsToday = 0;
    _rawSteps = 0;
    walkSteps = {};
    found = {};
    hardDayOn = null;
    _save();
  }

  void _save() {
    _prefs?.setString(
      _key,
      jsonEncode({
        'welcomed': welcomed,
        'goal': goal,
        'stride': strideCm,
        'remind': remind,
        'remindAt': remindAt,
        'days': days,
        'walkSteps': walkSteps,
        'found': found,
        'hardDayOn': hardDayOn,
        'steps': {'day': _stepsDay, 'n': stepsToday, 'rawDay': _rawDay, 'raw': _rawLast, 'rawSteps': _rawSteps},
      }),
    );
    notifyListeners();
  }

  void _read() {
    final raw = _prefs?.getString(_key);
    if (raw == null) return;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    welcomed = j['welcomed'] as bool? ?? false;
    goal = (j['goal'] as int? ?? 2000).clamp(200, 30000);
    strideCm = (j['stride'] as int? ?? 75).clamp(40, 120);
    remind = j['remind'] as bool? ?? false;
    remindAt = (j['remindAt'] as int? ?? 17 * 60).clamp(0, 24 * 60 - 1);
    days = {for (final e in (j['days'] as Map? ?? {}).entries) e.key as String: e.value as int};
    walkSteps = {for (final e in (j['walkSteps'] as Map? ?? {}).entries) e.key as String: e.value as int};
    found = {for (final e in (j['found'] as Map? ?? {}).entries) e.key as String: e.value as String};
    hardDayOn = j['hardDayOn'] as String?;
    if (j['steps'] case final Map st) {
      _stepsDay = st['day'] as String?;
      stepsToday = st['n'] as int? ?? 0;
      _rawDay = st['rawDay'] as String?;
      _rawLast = st['raw'] as int? ?? 0;
      _rawSteps = st['rawSteps'] as int? ?? 0;
    }
  }
}

class StoreScope extends InheritedNotifier<Store> {
  const StoreScope({super.key, required Store super.notifier, required super.child});

  static Store of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
