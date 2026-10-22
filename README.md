# Nūr

A calm walking app: your day starts at night, and as you walk the sun rises over your path. Along the way you find verses of the Quran (Saheeh International) and authentic hadith (Sahih al-Bukhari, Sahih Muslim), a new path every day.

- Steps from Health Connect and, live, from the phone's step sensor. No location, no account, nothing leaves the phone.
- Flutter. `flutter test` runs the tests; `flutter build appbundle --release` builds the Play Store bundle (needs `android/key.properties`, kept outside git).
- Play Store material: `store/`. Website and privacy policy: https://darian7b7.github.io/nur/

## Languages

- **App words:** `lib/l10n/app_en.arb` and `app_ar.arb` (Flutter's gen-l10n; nothing hardcoded in the screens). To add a language, copy `app_en.arb` to `app_<code>.arb`, translate the values, and add it.
- **Verses and hadith:** `assets/content/lights.json`, with the English and the original Arabic of each. After editing it, run `python3 tool/build_content.py`: it fills in the Arabic from quran.com and Sahih al-Bukhari / Sahih Muslim, and checks every English text word for word against its source.
- **Fonts:** Amiri Quran (Quran), Amiri (hadith), Noto Sans Arabic (Arabic labels), all SIL Open Font License (`assets/fonts/`).
