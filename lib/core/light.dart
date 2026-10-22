// The light you find by walking: verses and authentic hadith about walking, the earth, light, hardship
// and hope. The texts themselves live in assets/content/lights.json (English and the original Arabic,
// each checked against its source by tool/build_content.py); this file is what Nūr does with them.
// Pure Dart.

import 'dart:convert';
import 'dart:math';

class Light {
  const Light({required this.id, required this.text, required this.arabic, required this.source, required this.sourceArabic, this.surah, this.ayah});

  factory Light.fromJson(Map<String, dynamic> j) => Light(
    id: j['id'] as String,
    text: j['en'] as String,
    arabic: j['ar'] as String,
    source: j['source'] as String,
    sourceArabic: j['sourceAr'] as String,
    surah: j['surah'] as int?,
    ayah: j['ayah'] as int?,
  );

  final String id;

  /// The English: Saheeh International for the Quran, the sunnah.com English for hadith.
  final String text;

  /// The original Arabic (the Quran in Uthmani script).
  final String arabic;

  /// "Al-Mulk 67:15", "Sahih Muslim 898".
  final String source;

  /// "الملك ١٥", "صحيح مسلم ٨٩٨".
  final String sourceArabic;

  /// The surah and ayah (null for hadith).
  final int? surah;
  final int? ayah;

  bool get isQuran => surah != null;

  /// The text to read in [language]: the Arabic in Arabic, the English otherwise.
  String textIn(String language) => language == 'ar' ? arabic : text;
  String sourceIn(String language) => language == 'ar' ? sourceArabic : source;

  /// Where to read it at its source: the exact ayah on quran.com, the exact hadith on sunnah.com.
  Uri get sourceUrl {
    final q = RegExp(r'(\d+):(\d+)(?:–(\d+))?$').firstMatch(source);
    if (isQuran && q != null) return Uri.parse('https://quran.com/${q[1]}/${q[2]}${q[3] == null ? '' : '-${q[3]}'}');
    final h = RegExp(r'^Sahih (Muslim|al-Bukhari) (\d+)$').firstMatch(source)!;
    return Uri.parse('https://sunnah.com/${h[1] == 'Muslim' ? 'muslim' : 'bukhari'}:${h[2]}');
  }

  /// "quran.com" or "sunnah.com", for the button.
  String get sourceSite => isQuran ? 'quran.com' : 'sunnah.com';
}

/// Where the day's lights are found: metres walked today.
const dayMarks = [300, 700, 1000, 1500, 2000, 3000, 4000, 5000, 7000, 10000];

/// Where the content file is, for loading it.
const contentAsset = 'assets/content/lights.json';

/// Reads the content file (call once, before anything else here is used).
void loadContent(String json) {
  final j = jsonDecode(json) as Map<String, dynamic>;
  List<Light> list(String key) => [for (final x in j[key] as List) Light.fromJson(x as Map<String, dynamic>)];
  dawn = Light.fromJson(j['dawn'] as Map<String, dynamic>);
  pool = list('pool');
  longPath = [for (final x in j['long'] as List) ((x as Map<String, dynamic>)['km'] as int, Light.fromJson(x))];
  hardDays = list('hardDays');
  rains = list('rains');
  why = list('why');
  // The pool in two fixed halves. Each round of the pool is the first half shuffled, then the second
  // half shuffled: within a round nothing repeats, and where one round meets the next, the end (second
  // half) and the start (first half) share nothing. So no light is found two days in a row.
  _halves = [
    [for (var i = 0; i < pool.length; i += 2) pool[i]],
    [for (var i = 1; i < pool.length; i += 2) pool[i]],
  ];
  _rounds.clear();
}

/// Shown at dawn, before the first step: what the app is about.
late Light dawn;

/// Everything that can be found along a day's path. Each day draws its own, in a new order: tomorrow
/// never repeats today, and nothing comes back before the whole pool has been seen.
late List<Light> pool;

/// Found over all your walks together: (kilometres in total, the light). Found once; always the same.
late List<(int km, Light)> longPath;

/// For a hard day: small is enough. One a day, taking turns.
late List<Light> hardDays;

/// For rain: a mercy, not a reason to stay in. One a day, taking turns.
late List<Light> rains;

/// Why walking matters: shown at the start and in the collection.
late List<Light> why;

/// Everything there is to find.
List<Light> get allLights => [...pool, for (final (_, l) in longPath) l, ...hardDays, ...rains];

/// The day number, counted from 1 January 2026 (by the calendar, not the clock).
int dayNumber(DateTime d) => DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(2026)).inDays;

var _halves = <List<Light>>[];

List<Light> _round(int r) => [
  for (final (h, half) in _halves.indexed) ...([...half]..shuffle(Random(r * 2 + h + 7))),
];

final _rounds = <int, List<Light>>{};

/// The lights on [day]'s path: one at each of [dayMarks].
List<(int metres, Light)> pathFor(DateTime day) {
  final start = max(0, dayNumber(day)) * dayMarks.length;
  return [
    for (final (i, m) in dayMarks.indexed)
      (m, _rounds.putIfAbsent((start + i) ~/ pool.length, () => _round((start + i) ~/ pool.length))[(start + i) % pool.length]),
  ];
}

/// The light for a hard day on [day], and for rain.
Light hardDayFor(DateTime day) => hardDays[max(0, dayNumber(day)) % hardDays.length];
Light rainFor(DateTime day) => rains[max(0, dayNumber(day)) % rains.length];

/// The day's lights found by [metres] walked on [day].
List<Light> foundToday(int metres, DateTime day) => [
  for (final (m, l) in pathFor(day))
    if (metres >= m) l,
];

/// The next light on [day]'s path and how far it is, or null when all are found.
(int metres, Light)? nextToday(int metres, DateTime day) {
  for (final (m, l) in pathFor(day)) {
    if (metres < m) return (m - metres, l);
  }
  return null;
}

/// Where on [day]'s path [l] was found, in metres (null if it isn't on it).
int? foundAt(Light l, DateTime day) => pathFor(day).where((e) => e.$2.id == l.id).firstOrNull?.$1;

/// The long-path lights found by [km] in total.
List<Light> foundLong(double km) => [
  for (final (k, l) in longPath)
    if (km >= k) l,
];

/// The kilometres in total that find [l] on the long path (null if it isn't on it).
int? longPathKm(Light l) => longPath.where((e) => e.$2.id == l.id).firstOrNull?.$1;

/// Every metre, for a walk in progress: "37 m", "648 m", "1.24 km", "12.3 km". [m] and [km] are the
/// units in the reader's language.
String preciseDistance(num metres, {String m = 'm', String km = 'km'}) {
  if (metres < 1000) return '${metres.round()} $m';
  final k = metres / 1000;
  return k >= 10 ? '${k.toStringAsFixed(1)} $km' : '${k.toStringAsFixed(2)} $km';
}

/// "650 m", "1.4 km", "12 km".
String distanceText(num metres, {String m = 'm', String km = 'km'}) {
  if (metres < 1000) return '${(metres / 10).round() * 10} $m';
  final k = metres / 1000;
  final shown = k >= 10 ? '${k.round()}' : '${(k * 10).round() / 10}'.replaceAll(RegExp(r'\.0$'), '');
  return '$shown $km';
}

/// Steps to metres with a stride length.
int metresFor(int steps, int strideCm) => (steps * strideCm / 100).round();

/// A stride from body height: about 41.5% of it.
int strideFor(int heightCm) => (heightCm * 0.415).round();

/// New way: one simple rule for today's walk, so old paths and old memories don't decide it. The rules
/// are in the language files (newWay0 … newWay11).
const newWayCount = 12;

/// No weather is a reason to stay in. What to wear for each is in the language files.
enum Weather { rain, cold, heat, dark, grey }

/// The smallest goal, for a hard day: just step outside.
const hardDayMetres = 200;
