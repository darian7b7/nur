// The app's words in the reader's language (from lib/l10n/app_<language>.arb), and distances in its units.
import 'package:flutter/widgets.dart';

import '../core/light.dart';
import '../l10n/app_localizations.dart';

extension Words on BuildContext {
  L get l => L.of(this);

  /// 'ar' or 'en': which text of a verse or hadith to show.
  String get lang => Localizations.localeOf(this).languageCode == 'ar' ? 'ar' : 'en';

  /// "650 m", "1.4 km" ("650 م", "1.4 كم").
  String dist(num metres) => distanceText(metres, m: l.unitM, km: l.unitKm);

  /// Every metre, for a walk in progress.
  String distExact(num metres) => preciseDistance(metres, m: l.unitM, km: l.unitKm);
}

extension Names on L {
  String weatherLabel(Weather w) => switch (w) {
    Weather.rain => weatherRain,
    Weather.cold => weatherCold,
    Weather.heat => weatherHeat,
    Weather.dark => weatherDark,
    Weather.grey => weatherGrey,
  };

  String weatherTip(Weather w) => switch (w) {
    Weather.rain => weatherRainTip,
    Weather.cold => weatherColdTip,
    Weather.heat => weatherHeatTip,
    Weather.dark => weatherDarkTip,
    Weather.grey => weatherGreyTip,
  };

  /// New way rule [i] of [newWayCount].
  String newWayRule(int i) => [newWay0, newWay1, newWay2, newWay3, newWay4, newWay5, newWay6, newWay7, newWay8, newWay9, newWay10, newWay11][i];
}
