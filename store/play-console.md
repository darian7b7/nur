# Nūr: answers for the Google Play Console

App ID: `com.darian.nur` · Version 1.0.0 (code 1) · Upload: `build/app/outputs/bundle/release/app-release.aab`

## App content

| Section | Answer |
|---|---|
| Privacy policy | https://darian7b7.github.io/nur/privacy.html (live) |
| App access | All functionality is available without special access (no login). |
| Ads | No, the app does not contain ads. |
| Content rating | Fill the questionnaire: Category "Reference, News, or Educational" or "All other app types". No violence, no sexual content, no profanity, no drugs, no gambling, no user interaction or sharing, no location sharing, no purchases. Expected rating: Everyone / PEGI 3. |
| Target audience | 18 and over (simplest; avoids the Families policy). 13+ is also possible. |
| News app | No. |
| Government app | No. |
| Financial features | None. |
| Health apps | Yes: "Activity and fitness". The app is not a medical device. |

## Data safety

**Does your app collect or share any of the required user data types?** Yes (it reads step counts), but nothing leaves the device.

- **Data collected:** Health and fitness → Fitness info (step count).
  - Is it collected? Google counts data as "collected" only when it is sent off the device. Nūr never sends it, so the honest answer is **No data collected** and **No data shared**.
  - If the console insists because of the Health Connect permission, declare: Fitness info, **processed ephemerally: no**, **required**, purpose **App functionality**, **not shared**.
- **Is all user data encrypted in transit?** Not applicable: no data is transmitted.
- **Can users request that data be deleted?** Yes: "Forget all walks" in Settings, or uninstall the app.

## Health Connect declaration (Permissions declaration form)

**Permission requested:** `android.permission.health.READ_STEPS` (read only, no write).

**Why does the app need it?**
> Nūr is a walking app. It reads the user's step count for the current day to show the distance walked, to brighten the in-app sky as the user approaches their daily walking goal, and to unlock Quran verses and hadith at distance milestones (for example at 300 m, 1 km and 2 km). Without the step count, the app's core feature cannot work.

**How is the data used?**
> Only on the device, to compute today's distance (steps × stride length). It is stored locally as a daily distance total. It is never sent to a server, shared, sold, used for advertising, or used for any other purpose.

**Does the app access data in the background?** No. Steps are read only while the app is open.

**Does the app read historical data (older than 30 days)?** No.

**Rationale screen:** Health Connect's "Why this app needs access" opens `PrivacyActivity`, which shows the privacy policy above.

## Other permissions

| Permission | Why |
|---|---|
| `ACTIVITY_RECOGNITION` | Live step count from the phone's step sensor while Nūr is open. |
| `RECEIVE_BOOT_COMPLETED` | Re-plans the optional daily reminder after a restart. |
| Notifications (asked only when the reminder is turned on) | One silent daily reminder, off by default. |

## Store listing

Text: `store/listing.md`. Graphics in `store/`:

| File | Use |
|---|---|
| `icon-512.png` | App icon (512 × 512) |
| `feature-1024x500.png` | Feature graphic |
| `screenshots/*.png` | Phone screenshots (1080 × 1920) |

## Release checklist

Done:
- [x] App ID `com.darian.nur`, version 1.0.0 (code 1), signed with the upload key ("Darian")
- [x] Privacy policy live: https://darian7b7.github.io/nur/privacy.html
- [x] All 73 texts checked word for word: 57 Quran passages (Saheeh International, quran.com) and 16 hadith (sunnah.com English)
- [x] Store text (`listing.md`), icon, feature graphic, 7 screenshots
- [x] Answers for every form (this file)
- [x] Tests: 30 passing, including stress tests

Your steps:
1. Back up `~/keys/nur-upload.jks` and `~/keys/nur-upload.properties` (the password is inside) to a USB stick or password manager.
2. Create a Google Play developer account (play.google.com/console, one-time $25, identity check). Choose **Personal**.
3. Create app → name "Nūr: Walk into the Light", default language English (United States), App, Free.
4. Fill App content (above) and Store listing (`listing.md` + graphics). Add your public contact email.
5. Closed test with 12+ testers for 14 days: see `testers.md`.
6. Apply for production access, then release to production.

## Before every update

- Raise the version in `pubspec.yaml`: `1.0.1+2`, `1.0.2+3`… The number after `+` must always go up.
- Build: `flutter build appbundle --release`.
- Keep `~/keys/nur-upload.jks` and `~/keys/nur-upload.properties` backed up somewhere safe (not in git).
