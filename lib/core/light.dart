// The light you find by walking: verses and authentic hadith about walking, the earth, light, hardship
// and hope, each with its reference. Translations of the meaning follow Saheeh International (Quran) and
// sunnah.com (hadith). Pure Dart.

import 'dart:math';

class Light {
  const Light({required this.id, required this.text, required this.source, this.surah, this.ayah});

  final String id;
  final String text;

  /// "Al-Mulk 67:15", "Sahih Muslim 898".
  final String source;

  /// The surah and ayah (null for hadith).
  final int? surah;
  final int? ayah;

  bool get isQuran => surah != null;

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

/// Shown at dawn, before the first step: what the app is about.
const dawn = Light(
  id: 'dawn',
  text: 'Allah is the ally of those who believe. He brings them out from darknesses into the light.',
  source: 'Al-Baqarah 2:257',
  surah: 2,
  ayah: 257,
);

/// Where the day's lights are found: metres walked today.
const dayMarks = [300, 700, 1000, 1500, 2000, 3000, 4000, 5000, 7000, 10000];

/// Everything that can be found along a day's path. Each day draws its own, in a new order: tomorrow
/// never repeats today, and nothing comes back before the whole pool has been seen.
const pool = [
  // Light out of darkness.
  Light(
    id: 'q6_122',
    text: 'And is one who was dead and We gave him life and made for him light by which to walk among the people like one who is in darkness, never to emerge therefrom?',
    source: 'Al-An\'am 6:122',
    surah: 6,
    ayah: 122,
  ),
  Light(
    id: 'q57_28',
    text: 'O you who have believed, fear Allah and believe in His Messenger; He will [then] give you a double portion of His mercy and make for you a light by which you will walk and forgive you; and Allah is Forgiving and Merciful.',
    source: 'Al-Hadid 57:28',
    surah: 57,
    ayah: 28,
  ),
  Light(
    id: 'q24_35',
    text: 'Allah is the Light of the heavens and the earth … Light upon light. Allah guides to His light whom He wills.',
    source: 'An-Nur 24:35',
    surah: 24,
    ayah: 35,
  ),
  Light(
    id: 'q14_1',
    text: '[This is] a Book which We have revealed to you, [O Muhammad], that you might bring mankind out of darknesses into the light by permission of their Lord.',
    source: 'Ibrahim 14:1',
    surah: 14,
    ayah: 1,
  ),
  Light(
    id: 'q5_15',
    text: 'There has come to you from Allah a light and a clear Book by which Allah guides those who pursue His pleasure to the ways of peace and brings them out from darknesses into the light, by His permission, and guides them to a straight path.',
    source: 'Al-Ma\'idah 5:15–16',
    surah: 5,
    ayah: 15,
  ),
  Light(
    id: 'q33_43',
    text: 'It is He who confers blessing upon you, and His angels [ask Him to do so] that He may bring you out from darknesses into the light. And ever is He, to the believers, Merciful.',
    source: 'Al-Ahzab 33:43',
    surah: 33,
    ayah: 43,
  ),
  Light(
    id: 'q39_22',
    text: 'So is one whose breast Allah has expanded to [accept] Islam and he is upon a light from his Lord [like one whose heart rejects it]?',
    source: 'Az-Zumar 39:22',
    surah: 39,
    ayah: 22,
  ),
  Light(id: 'q10_5', text: 'It is He who made the sun a shining light and the moon a derived light.', source: 'Yunus 10:5', surah: 10, ayah: 5),
  Light(
    id: 'q6_1',
    text: '[All] praise is [due] to Allah, who created the heavens and the earth and made the darkness and the light.',
    source: 'Al-An\'am 6:1',
    surah: 6,
    ayah: 1,
  ),
  Light(
    id: 'q64_8',
    text: 'So believe in Allah and His Messenger and the light which We have sent down. And Allah is Aware of what you do.',
    source: 'At-Taghabun 64:8',
    surah: 64,
    ayah: 8,
  ),
  // Walking the earth.
  Light(
    id: 'q67_15',
    text: 'It is He who made the earth tame for you – so walk among its slopes and eat of His provision – and to Him is the resurrection.',
    source: 'Al-Mulk 67:15',
    surah: 67,
    ayah: 15,
  ),
  Light(
    id: 'q25_63',
    text: 'And the servants of the Most Merciful are those who walk upon the earth easily, and when the ignorant address them [harshly], they say [words of] peace.',
    source: 'Al-Furqan 25:63',
    surah: 25,
    ayah: 63,
  ),
  Light(
    id: 'q17_37',
    text:
        'And do not walk upon the earth exultantly. Indeed, you will never tear the earth [apart], and you will never reach the mountains in height.',
    source: 'Al-Isra 17:37',
    surah: 17,
    ayah: 37,
  ),
  Light(
    id: 'q71_19',
    text: 'And Allah has made for you the earth an expanse that you may follow therein roads of passage.',
    source: 'Nuh 71:19–20',
    surah: 71,
    ayah: 19,
  ),
  Light(
    id: 'q20_53',
    text: '[It is He] who has made for you the earth as a bed [spread out] and inserted therein for you roadways.',
    source: 'Ta-Ha 20:53',
    surah: 20,
    ayah: 53,
  ),
  Light(
    id: 'q43_10',
    text: '[The one] who has made for you the earth a bed and made for you upon it roads that you might be guided.',
    source: 'Az-Zukhruf 43:10',
    surah: 43,
    ayah: 10,
  ),
  Light(
    id: 'q16_15',
    text: 'And He has cast into the earth firmly set mountains, lest it shift with you, and [made] rivers and roads, that you may be guided.',
    source: 'An-Nahl 16:15',
    surah: 16,
    ayah: 15,
  ),
  Light(
    id: 'q62_10',
    text: 'And when the prayer has been concluded, disperse within the land and seek from the bounty of Allah, and remember Allah often that you may succeed.',
    source: 'Al-Jumu\'ah 62:10',
    surah: 62,
    ayah: 10,
  ),
  Light(
    id: 'q2_115',
    text: 'And to Allah belongs the east and the west. So wherever you [might] turn, there is the Face of Allah.',
    source: 'Al-Baqarah 2:115',
    surah: 2,
    ayah: 115,
  ),
  Light(id: 'q57_4', text: 'And He is with you wherever you are. And Allah, of what you do, is Seeing.', source: 'Al-Hadid 57:4', surah: 57, ayah: 4),
  // Look at creation.
  Light(
    id: 'q88_17',
    text: 'Then do they not look at the camels – how they are created? And at the sky – how it is raised? And at the mountains – how they are erected? And at the earth – how it is spread out?',
    source: 'Al-Ghashiyah 88:17–20',
    surah: 88,
    ayah: 17,
  ),
  Light(
    id: 'q51_20',
    text: 'And on the earth are signs for the certain [in faith], and in yourselves. Then will you not see?',
    source: 'Adh-Dhariyat 51:20–21',
    surah: 51,
    ayah: 20,
  ),
  Light(
    id: 'q3_190',
    text: 'Indeed, in the creation of the heavens and the earth and the alternation of the night and the day are signs for those of understanding.',
    source: 'Al \'Imran 3:190',
    surah: 3,
    ayah: 190,
  ),
  Light(
    id: 'q3_191',
    text: 'Who remember Allah while standing or sitting or [lying] on their sides and give thought to the creation of the heavens and the earth, [saying], "Our Lord, You did not create this aimlessly."',
    source: 'Al \'Imran 3:191',
    surah: 3,
    ayah: 191,
  ),
  Light(
    id: 'q30_50',
    text: 'So observe the effects of the mercy of Allah – how He gives life to the earth after its lifelessness.',
    source: 'Ar-Rum 30:50',
    surah: 30,
    ayah: 50,
  ),
  Light(
    id: 'q45_13',
    text: 'And He has subjected to you whatever is in the heavens and whatever is on the earth – all from Him. Indeed in that are signs for a people who give thought.',
    source: 'Al-Jathiyah 45:13',
    surah: 45,
    ayah: 13,
  ),
  Light(id: 'q55_10', text: 'And the earth He laid [out] for the creatures.', source: 'Ar-Rahman 55:10', surah: 55, ayah: 10),
  Light(id: 'q55_13', text: 'So which of the favors of your Lord would you deny?', source: 'Ar-Rahman 55:13', surah: 55, ayah: 13),
  Light(
    id: 'q16_18',
    text: 'And if you should count the favors of Allah, you could not enumerate them. Indeed, Allah is Forgiving and Merciful.',
    source: 'An-Nahl 16:18',
    surah: 16,
    ayah: 18,
  ),
  // Hope after hardship.
  Light(
    id: 'q94_5',
    text: 'For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.',
    source: 'Ash-Sharh 94:5–6',
    surah: 94,
    ayah: 5,
  ),
  Light(
    id: 'q94_7',
    text: 'So when you have finished [your duties], then stand up [for worship]. And to your Lord direct [your] longing.',
    source: 'Ash-Sharh 94:7–8',
    surah: 94,
    ayah: 7,
  ),
  Light(
    id: 'q65_2',
    text: 'And whoever fears Allah – He will make for him a way out and will provide for him from where he does not expect.',
    source: 'At-Talaq 65:2–3',
    surah: 65,
    ayah: 2,
  ),
  Light(id: 'q65_7', text: 'Allah will bring about, after hardship, ease.', source: 'At-Talaq 65:7', surah: 65, ayah: 7),
  Light(id: 'q2_286', text: 'Allah does not charge a soul except [with that within] its capacity.', source: 'Al-Baqarah 2:286', surah: 2, ayah: 286),
  Light(
    id: 'q39_53',
    text: 'Say, "O My servants who have transgressed against themselves [by sinning], do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful."',
    source: 'Az-Zumar 39:53',
    surah: 39,
    ayah: 53,
  ),
  Light(
    id: 'q12_87',
    text: 'And despair not of relief from Allah. Indeed, no one despairs of relief from Allah except the disbelieving people.',
    source: 'Yusuf 12:87',
    surah: 12,
    ayah: 87,
  ),
  Light(
    id: 'q3_139',
    text: 'So do not weaken and do not grieve, and you will be superior if you are [true] believers.',
    source: 'Al \'Imran 3:139',
    surah: 3,
    ayah: 139,
  ),
  Light(id: 'q9_40', text: '"Do not grieve; indeed Allah is with us."', source: 'At-Tawbah 9:40', surah: 9, ayah: 40),
  Light(
    id: 'q13_11',
    text: 'Indeed, Allah will not change the condition of a people until they change what is in themselves.',
    source: 'Ar-Ra\'d 13:11',
    surah: 13,
    ayah: 11,
  ),
  Light(
    id: 'q53_39',
    text: 'And that there is not for man except that [good] for which he strives, and that his effort is going to be seen.',
    source: 'An-Najm 53:39–40',
    surah: 53,
    ayah: 39,
  ),
  // Patience, nearness, the heart at rest.
  Light(
    id: 'q2_153',
    text: 'O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.',
    source: 'Al-Baqarah 2:153',
    surah: 2,
    ayah: 153,
  ),
  Light(
    id: 'q11_115',
    text: 'And be patient, for indeed, Allah does not allow to be lost the reward of those who do good.',
    source: 'Hud 11:115',
    surah: 11,
    ayah: 115,
  ),
  Light(
    id: 'q16_128',
    text: 'Indeed, Allah is with those who fear Him and those who are doers of good.',
    source: 'An-Nahl 16:128',
    surah: 16,
    ayah: 128,
  ),
  Light(
    id: 'q2_186',
    text: 'And when My servants ask you, [O Muhammad], concerning Me – indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.',
    source: 'Al-Baqarah 2:186',
    surah: 2,
    ayah: 186,
  ),
  Light(id: 'q40_60', text: 'And your Lord says, "Call upon Me; I will respond to you."', source: 'Ghafir 40:60', surah: 40, ayah: 60),
  Light(
    id: 'q50_16',
    text: 'And We have already created man and know what his soul whispers to him, and We are closer to him than [his] jugular vein.',
    source: 'Qaf 50:16',
    surah: 50,
    ayah: 16,
  ),
  Light(id: 'q13_28', text: 'Unquestionably, by the remembrance of Allah hearts are assured.', source: 'Ar-Ra\'d 13:28', surah: 13, ayah: 28),
  // The Sunnah: steps, body, light.
  Light(
    id: 'b7405',
    text: 'The Prophet ﷺ said, "Allah says: \'… If he comes one span nearer to Me, I go one cubit nearer to him; and if he comes one cubit nearer to Me, I go a distance of two outstretched arms nearer to him; and if he comes to Me walking, I go to him running.\'"',
    source: 'Sahih al-Bukhari 7405',
  ),
  Light(
    id: 'm666',
    text: 'He who purified himself in his house, and then he walked to one of the houses of Allah for the sake of performing a Fard (obligatory act), both his steps would be significant, as one of them would obliterate his sin and the second one would raise his status.',
    source: 'Sahih Muslim 666',
  ),
  Light(
    id: 'm223',
    text: 'Cleanliness is half of faith … and prayer is a light, and charity is proof (of one\'s faith), and endurance is a brightness.',
    source: 'Sahih Muslim 223',
  ),
  Light(
    id: 'b6412',
    text: 'There are two blessings that many people are deceived into losing: health and free time.',
    source: 'Sahih al-Bukhari 6412',
  ),
  Light(
    id: 'b1',
    text: 'The reward of deeds depends upon the intentions, and every person will get the reward according to what he has intended.',
    source: 'Sahih al-Bukhari 1',
  ),
  Light(
    id: 'b5678',
    text: 'There is no disease that Allah has created, except that He also has created its treatment.',
    source: 'Sahih al-Bukhari 5678',
  ),
];

/// Found over all your walks together: (kilometres in total, the light). Found once; always the same.
const longPath = [
  (
    5,
    Light(
      id: 'q29_20',
      text: 'Say, [O Muhammad], "Travel through the land and observe how He began creation."',
      source: 'Al-\'Ankabut 29:20',
      surah: 29,
      ayah: 20,
    ),
  ),
  (25, Light(id: 'q31_19', text: 'And be moderate in your pace and lower your voice.', source: 'Luqman 31:19', surah: 31, ayah: 19)),
  (
    50,
    Light(
      id: 'm2699',
      text: 'He who treads the path in search of knowledge, Allah would make that path easy, leading to Paradise for him.',
      source: 'Sahih Muslim 2699',
    ),
  ),
  (
    100,
    Light(
      id: 'q16_97',
      text: 'Whoever does righteousness, whether male or female, while he is a believer – We will surely cause him to live a good life.',
      source: 'An-Nahl 16:97',
      surah: 16,
      ayah: 97,
    ),
  ),
  (
    250,
    Light(
      id: 'q29_69',
      text: 'And those who strive for Us – We will surely guide them to Our ways. And indeed, Allah is with the doers of good.',
      source: 'Al-\'Ankabut 29:69',
      surah: 29,
      ayah: 69,
    ),
  ),
  (
    500,
    Light(
      id: 'q57_12',
      text: 'On the Day you see the believing men and believing women, their light proceeding before them and on their right.',
      source: 'Al-Hadid 57:12',
      surah: 57,
      ayah: 12,
    ),
  ),
  (
    1000,
    Light(
      id: 'q66_8',
      text: 'Their light will proceed before them and on their right; they will say, "Our Lord, perfect for us our light and forgive us. Indeed, You are over all things competent."',
      source: 'At-Tahrim 66:8',
      surah: 66,
      ayah: 8,
    ),
  ),
];

/// For a hard day: small is enough. One a day, taking turns.
const hardDays = [
  Light(
    id: 'b6464',
    text: 'The most beloved deed to Allah is the most regular and constant, even if it were little.',
    source: 'Sahih al-Bukhari 6464',
  ),
  Light(
    id: 'b39',
    text: 'Religion is very easy … So you should not be extremists, but try to be near to perfection and receive the good tidings that you will be rewarded; and gain strength by worshipping in the mornings, the afternoons, and during the last hours of the nights.',
    source: 'Sahih al-Bukhari 39',
  ),
  Light(
    id: 'm2999',
    text: 'Strange are the ways of a believer, for there is good in every affair of his … If he has an occasion to feel delight, he thanks (God), thus there is a good for him in it; and if he gets into trouble and shows resignation (and endures it patiently), there is a good for him in it.',
    source: 'Sahih Muslim 2999',
  ),
  Light(
    id: 'b2996',
    text: 'When a slave falls ill or travels, then he will get reward similar to that he gets for good deeds practiced at home when in good health.',
    source: 'Sahih al-Bukhari 2996',
  ),
];

/// For rain: a mercy, not a reason to stay in. One a day, taking turns.
const rains = [
  Light(
    id: 'm898',
    text: 'It rained upon us as we were with the Messenger of Allah ﷺ. The Messenger of Allah ﷺ removed his cloth (from a part of his body) till the rain fell on it. We said: Messenger of Allah, why did you do this? He said: It is because it (the rainfall) has just come from the Exalted Lord.',
    source: 'Sahih Muslim 898',
  ),
  Light(
    id: 'b1032',
    text: 'Whenever Allah\'s Messenger ﷺ saw the rain, he used to say, "O Allah! Let it be a strong fruitful rain."',
    source: 'Sahih al-Bukhari 1032',
  ),
  Light(
    id: 'q50_9',
    text: 'And We have sent down blessed rain from the sky and made grow thereby gardens and grain from the harvest.',
    source: 'Qaf 50:9',
    surah: 50,
    ayah: 9,
  ),
  Light(
    id: 'q25_48',
    text: 'And it is He who sends the winds as good tidings before His mercy, and We send down from the sky pure water.',
    source: 'Al-Furqan 25:48',
    surah: 25,
    ayah: 48,
  ),
  Light(
    id: 'q42_28',
    text: 'And it is He who sends down the rain after they had despaired and spreads His mercy. And He is the Protector, the Praiseworthy.',
    source: 'Ash-Shura 42:28',
    surah: 42,
    ayah: 28,
  ),
];

/// Why walking matters: shown at the start and in the collection.
const why = [
  Light(
    id: 'm2664',
    text: 'A strong believer is better and is more lovable to Allah than a weak believer, and there is good in everyone.',
    source: 'Sahih Muslim 2664',
  ),
  Light(id: 'b1975', text: 'Your body has a right on you.', source: 'Sahih al-Bukhari 1975'),
  Light(
    id: 'b2989',
    text: '(Saying) a good word is also Sadaqa, and every step taken on one\'s way to offer the compulsory prayer (in the mosque) is also Sadaqa.',
    source: 'Sahih al-Bukhari 2989',
  ),
];

/// Everything there is to find.
List<Light> get allLights => [...pool, for (final (_, l) in longPath) l, ...hardDays, ...rains];

/// The day number, counted from 1 January 2026 (by the calendar, not the clock).
int dayNumber(DateTime d) => DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(2026)).inDays;

// The pool in two fixed halves. Each round of the pool is the first half shuffled, then the second
// half shuffled: within a round nothing repeats, and where one round meets the next, the end (second
// half) and the start (first half) share nothing. So no light is found two days in a row.
final _halves = [
  [for (var i = 0; i < pool.length; i += 2) pool[i]],
  [for (var i = 1; i < pool.length; i += 2) pool[i]],
];

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

/// What it takes to find a long-path light, for the collection: "Walk 25 km in all".
String findHint(Light l) {
  for (final (k, d) in longPath) {
    if (d.id == l.id) return 'Walk $k km in all';
  }
  return '';
}

/// Every metre, for a walk in progress: "37 m", "648 m", "1.24 km", "12.3 km".
String preciseDistance(num metres) {
  if (metres < 1000) return '${metres.round()} m';
  final km = metres / 1000;
  return km >= 10 ? '${km.toStringAsFixed(1)} km' : '${km.toStringAsFixed(2)} km';
}

/// "650 m", "1.4 km", "12 km".
String distanceText(num metres) {
  if (metres < 1000) return '${(metres / 10).round() * 10} m';
  final km = metres / 1000;
  return km >= 10 ? '${km.round()} km' : '${(km * 10).round() / 10} km'.replaceAll('.0 km', ' km');
}

/// Steps to metres with a stride length.
int metresFor(int steps, int strideCm) => (steps * strideCm / 100).round();

/// A stride from body height: about 41.5% of it.
int strideFor(int heightCm) => (heightCm * 0.415).round();

// --- New way: one simple rule for today's walk, so old paths and old memories don't decide it --------

const newWays = [
  'Take a street you have never walked down.',
  'At the first corner, turn the other way than you always do.',
  'Walk until you have seen three trees, then choose a new direction.',
  'Walk towards the brightest part of the sky.',
  'Find a place you have never stood before, and stand there for a moment.',
  'Walk to the nearest mosque, and back a different way.',
  'Follow the first bird you see, as far as it goes.',
  'Walk with the wind at your back, then turn into it on the way home.',
  'Look up at every corner: notice a window, a roof, the sky.',
  'Take every second turn to the right.',
  'Walk to the edge of your neighbourhood, and look past it.',
  'Choose the quietest street you can find.',
];

/// Gentle words for weather: no weather is a reason to stay in.
enum Weather {
  rain('Rain', 'A rain jacket or an umbrella, and shoes that can get wet. Rain clears the air and the mind.'),
  cold('Cold', 'Layers, a hat and gloves. Walk briskly for the first five minutes and you will be warm.'),
  heat('Heat', 'Go early or late, in the shade. Water with you, a cap, light clothes.'),
  dark('Dark', 'Lit streets you know, something bright to wear, a light on your phone if you need it.'),
  grey('Grey', 'Grey days need the light most. Even ten minutes outside lifts the day.');

  const Weather(this.label, this.tip);
  final String label;
  final String tip;
}

/// The smallest goal, for a hard day: just step outside.
const hardDayMetres = 200;
