import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nūr'**
  String get appTitle;

  /// No description provided for @unitM.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitM;

  /// No description provided for @unitKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @todaysLight.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S LIGHT'**
  String get todaysLight;

  /// No description provided for @fullLightToday.
  ///
  /// In en, this message translates to:
  /// **'FULL LIGHT TODAY'**
  String get fullLightToday;

  /// No description provided for @hardDayHeading.
  ///
  /// In en, this message translates to:
  /// **'A HARD DAY · JUST STEP OUTSIDE'**
  String get hardDayHeading;

  /// No description provided for @ofGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String ofGoal(String goal);

  /// No description provided for @cardHardDay.
  ///
  /// In en, this message translates to:
  /// **'For a hard day'**
  String get cardHardDay;

  /// No description provided for @cardFoundAt.
  ///
  /// In en, this message translates to:
  /// **'Found today at {distance}'**
  String cardFoundAt(String distance);

  /// No description provided for @cardBeforeFirstStep.
  ///
  /// In en, this message translates to:
  /// **'Before the first step'**
  String get cardBeforeFirstStep;

  /// No description provided for @everyLightFound.
  ///
  /// In en, this message translates to:
  /// **'Every light of today found.'**
  String get everyLightFound;

  /// No description provided for @nextLightIn.
  ///
  /// In en, this message translates to:
  /// **'Next light in {distance}'**
  String nextLightIn(String distance);

  /// No description provided for @tooltipCollection.
  ///
  /// In en, this message translates to:
  /// **'The light you found'**
  String get tooltipCollection;

  /// No description provided for @tooltipSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltipSettings;

  /// No description provided for @tooltipAnotherWay.
  ///
  /// In en, this message translates to:
  /// **'Another way'**
  String get tooltipAnotherWay;

  /// No description provided for @goOut.
  ///
  /// In en, this message translates to:
  /// **'Go out'**
  String get goOut;

  /// No description provided for @walkMore.
  ///
  /// In en, this message translates to:
  /// **'Walk a little more'**
  String get walkMore;

  /// No description provided for @hardDay.
  ///
  /// In en, this message translates to:
  /// **'Hard day'**
  String get hardDay;

  /// No description provided for @newWay.
  ///
  /// In en, this message translates to:
  /// **'New way'**
  String get newWay;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @stepsOff.
  ///
  /// In en, this message translates to:
  /// **'Steps are off'**
  String get stepsOff;

  /// No description provided for @stepsOffBody.
  ///
  /// In en, this message translates to:
  /// **'Nūr can\'t see your walk until step counting is allowed.'**
  String get stepsOffBody;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @lightFound.
  ///
  /// In en, this message translates to:
  /// **'Light found'**
  String get lightFound;

  /// No description provided for @lightFoundMore.
  ///
  /// In en, this message translates to:
  /// **'Light found · more in your collection'**
  String get lightFoundMore;

  /// No description provided for @weatherQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is it like outside?'**
  String get weatherQuestion;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherRain;

  /// No description provided for @weatherCold.
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get weatherCold;

  /// No description provided for @weatherHeat.
  ///
  /// In en, this message translates to:
  /// **'Heat'**
  String get weatherHeat;

  /// No description provided for @weatherDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get weatherDark;

  /// No description provided for @weatherGrey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get weatherGrey;

  /// No description provided for @weatherRainTip.
  ///
  /// In en, this message translates to:
  /// **'A rain jacket or an umbrella, and shoes that can get wet. Rain clears the air and the mind.'**
  String get weatherRainTip;

  /// No description provided for @weatherColdTip.
  ///
  /// In en, this message translates to:
  /// **'Layers, a hat and gloves. Walk briskly for the first five minutes and you will be warm.'**
  String get weatherColdTip;

  /// No description provided for @weatherHeatTip.
  ///
  /// In en, this message translates to:
  /// **'Go early or late, in the shade. Water with you, a cap, light clothes.'**
  String get weatherHeatTip;

  /// No description provided for @weatherDarkTip.
  ///
  /// In en, this message translates to:
  /// **'Lit streets you know, something bright to wear, a light on your phone if you need it.'**
  String get weatherDarkTip;

  /// No description provided for @weatherGreyTip.
  ///
  /// In en, this message translates to:
  /// **'Grey days need the light most. Even ten minutes outside lifts the day.'**
  String get weatherGreyTip;

  /// No description provided for @rainIsMercy.
  ///
  /// In en, this message translates to:
  /// **'The rain is a mercy'**
  String get rainIsMercy;

  /// No description provided for @goOutInRain.
  ///
  /// In en, this message translates to:
  /// **'Go out in the rain'**
  String get goOutInRain;

  /// No description provided for @goOutAnyway.
  ///
  /// In en, this message translates to:
  /// **'Go out anyway'**
  String get goOutAnyway;

  /// No description provided for @newWay0.
  ///
  /// In en, this message translates to:
  /// **'Take a street you have never walked down.'**
  String get newWay0;

  /// No description provided for @newWay1.
  ///
  /// In en, this message translates to:
  /// **'At the first corner, turn the other way than you always do.'**
  String get newWay1;

  /// No description provided for @newWay2.
  ///
  /// In en, this message translates to:
  /// **'Walk until you have seen three trees, then choose a new direction.'**
  String get newWay2;

  /// No description provided for @newWay3.
  ///
  /// In en, this message translates to:
  /// **'Walk towards the brightest part of the sky.'**
  String get newWay3;

  /// No description provided for @newWay4.
  ///
  /// In en, this message translates to:
  /// **'Find a place you have never stood before, and stand there for a moment.'**
  String get newWay4;

  /// No description provided for @newWay5.
  ///
  /// In en, this message translates to:
  /// **'Walk to the nearest mosque, and back a different way.'**
  String get newWay5;

  /// No description provided for @newWay6.
  ///
  /// In en, this message translates to:
  /// **'Follow the first bird you see, as far as it goes.'**
  String get newWay6;

  /// No description provided for @newWay7.
  ///
  /// In en, this message translates to:
  /// **'Walk with the wind at your back, then turn into it on the way home.'**
  String get newWay7;

  /// No description provided for @newWay8.
  ///
  /// In en, this message translates to:
  /// **'Look up at every corner: notice a window, a roof, the sky.'**
  String get newWay8;

  /// No description provided for @newWay9.
  ///
  /// In en, this message translates to:
  /// **'Take every second turn to the right.'**
  String get newWay9;

  /// No description provided for @newWay10.
  ///
  /// In en, this message translates to:
  /// **'Walk to the edge of your neighbourhood, and look past it.'**
  String get newWay10;

  /// No description provided for @newWay11.
  ///
  /// In en, this message translates to:
  /// **'Choose the quietest street you can find.'**
  String get newWay11;

  /// No description provided for @walkingIntoLight.
  ///
  /// In en, this message translates to:
  /// **'WALKING INTO THE LIGHT'**
  String get walkingIntoLight;

  /// No description provided for @walkingInRain.
  ///
  /// In en, this message translates to:
  /// **'WALKING IN THE RAIN'**
  String get walkingInRain;

  /// No description provided for @walkSteps.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps · {time}'**
  String walkSteps(String steps, String time);

  /// No description provided for @walkNoSensor.
  ///
  /// In en, this message translates to:
  /// **'{time} · steps are counted by your phone'**
  String walkNoSensor(String time);

  /// No description provided for @pocket.
  ///
  /// In en, this message translates to:
  /// **'The phone can go in your pocket.'**
  String get pocket;

  /// No description provided for @finishWalk.
  ///
  /// In en, this message translates to:
  /// **'Finish walk'**
  String get finishWalk;

  /// No description provided for @wentOut.
  ///
  /// In en, this message translates to:
  /// **'You went out.'**
  String get wentOut;

  /// No description provided for @steppedOut.
  ///
  /// In en, this message translates to:
  /// **'You stepped out.'**
  String get steppedOut;

  /// No description provided for @underMinute.
  ///
  /// In en, this message translates to:
  /// **'under a minute'**
  String get underMinute;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String minutes(String n);

  /// No description provided for @inTheRain.
  ///
  /// In en, this message translates to:
  /// **'in the rain'**
  String get inTheRain;

  /// No description provided for @lightsFound.
  ///
  /// In en, this message translates to:
  /// **'Lights found'**
  String get lightsFound;

  /// No description provided for @everyStepCounts.
  ///
  /// In en, this message translates to:
  /// **'Every step counts, the small ones too.'**
  String get everyStepCounts;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Walk into the light.'**
  String get tagline;

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @everyStepBringsLight.
  ///
  /// In en, this message translates to:
  /// **'Every step\nbrings light'**
  String get everyStepBringsLight;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your day starts at night. As you walk, the sun comes up over your path. Along the way you find verses and hadith about walking, hope and light.'**
  String get welcomeBody;

  /// No description provided for @welcomeHarder.
  ///
  /// In en, this message translates to:
  /// **'Rain, cold, a hard day, a place with old memories: Nūr has a small way out for each.'**
  String get welcomeHarder;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @yourDailyLight.
  ///
  /// In en, this message translates to:
  /// **'Your daily light'**
  String get yourDailyLight;

  /// No description provided for @dailyLightQuestion.
  ///
  /// In en, this message translates to:
  /// **'How far to full light each day? You can change it any time.'**
  String get dailyLightQuestion;

  /// No description provided for @yourStepsFromPhone.
  ///
  /// In en, this message translates to:
  /// **'Your steps, from your phone'**
  String get yourStepsFromPhone;

  /// No description provided for @onlyStepCount.
  ///
  /// In en, this message translates to:
  /// **'Only the step count. No location, no battery drain, nothing leaves the phone.'**
  String get onlyStepCount;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @allowStepCounting.
  ///
  /// In en, this message translates to:
  /// **'Allow step counting'**
  String get allowStepCounting;

  /// No description provided for @oneMoment.
  ///
  /// In en, this message translates to:
  /// **'One moment…'**
  String get oneMoment;

  /// No description provided for @counterTitle.
  ///
  /// In en, this message translates to:
  /// **'Step counter · needed'**
  String get counterTitle;

  /// No description provided for @counterOn.
  ///
  /// In en, this message translates to:
  /// **'Allowed. Every step counts while Nūr is open.'**
  String get counterOn;

  /// No description provided for @counterOff.
  ///
  /// In en, this message translates to:
  /// **'Nūr needs Android\'s \"Physical activity\" permission to count your steps. Without it, nothing moves.'**
  String get counterOff;

  /// No description provided for @healthConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Connect · recommended'**
  String get healthConnectTitle;

  /// No description provided for @healthConnectOn.
  ///
  /// In en, this message translates to:
  /// **'Connected. Steps count also while Nūr is closed.'**
  String get healthConnectOn;

  /// No description provided for @healthConnectOff.
  ///
  /// In en, this message translates to:
  /// **'Lets Nūr see the steps you took while it was closed, too.'**
  String get healthConnectOff;

  /// No description provided for @connectHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect Health Connect'**
  String get connectHealthConnect;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languagePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languagePhone;

  /// No description provided for @dailyLightNote.
  ///
  /// In en, this message translates to:
  /// **'Full light when you reach it. Any step brightens the sky.'**
  String get dailyLightNote;

  /// No description provided for @yourHeight.
  ///
  /// In en, this message translates to:
  /// **'Your height'**
  String get yourHeight;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'{n} cm'**
  String cm(String n);

  /// No description provided for @strideNote.
  ///
  /// In en, this message translates to:
  /// **'For your stride: {cm} cm a step.'**
  String strideNote(String cm);

  /// No description provided for @yourSteps.
  ///
  /// In en, this message translates to:
  /// **'Your steps'**
  String get yourSteps;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily walk reminder'**
  String get dailyReminder;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me to walk'**
  String get remindMe;

  /// No description provided for @remindNote.
  ///
  /// In en, this message translates to:
  /// **'One quiet notification a day (no sound), only on days you haven\'t reached your light yet.'**
  String get remindNote;

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Nūr in your phone\'s settings.'**
  String get notificationsOff;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @reminderToday.
  ///
  /// In en, this message translates to:
  /// **'Next: today around {time}.'**
  String reminderToday(String time);

  /// No description provided for @reminderPassed.
  ///
  /// In en, this message translates to:
  /// **'Next: tomorrow around {time}. {time} has passed today.'**
  String reminderPassed(String time);

  /// No description provided for @reminderFull.
  ///
  /// In en, this message translates to:
  /// **'Next: tomorrow around {time}. Today\'s light is already full, so none today.'**
  String reminderFull(String time);

  /// No description provided for @moreFromUs.
  ///
  /// In en, this message translates to:
  /// **'More from us'**
  String get moreFromUs;

  /// No description provided for @sakinaLine.
  ///
  /// In en, this message translates to:
  /// **'Quran verses for how you feel'**
  String get sakinaLine;

  /// No description provided for @majlisLine.
  ///
  /// In en, this message translates to:
  /// **'A quiz on the Quran and the Sunnah'**
  String get majlisLine;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// No description provided for @dataNote.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone. Nūr reads only your step count: no location, no account.'**
  String get dataNote;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @forgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Forget all walks?'**
  String get forgetTitle;

  /// No description provided for @forgetBody.
  ///
  /// In en, this message translates to:
  /// **'Your distances and the light you found. Your settings stay.'**
  String get forgetBody;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @forget.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get forget;

  /// No description provided for @forgetAllWalks.
  ///
  /// In en, this message translates to:
  /// **'Forget all walks'**
  String get forgetAllWalks;

  /// No description provided for @yourLight.
  ///
  /// In en, this message translates to:
  /// **'Your light'**
  String get yourLight;

  /// No description provided for @foundOf.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} found'**
  String foundOf(String count, String total);

  /// No description provided for @totals.
  ///
  /// In en, this message translates to:
  /// **'{all} in all · {week} this week'**
  String totals(String all, String week);

  /// No description provided for @alongEachDay.
  ///
  /// In en, this message translates to:
  /// **'ALONG EACH DAY'**
  String get alongEachDay;

  /// No description provided for @alongLongPath.
  ///
  /// In en, this message translates to:
  /// **'ALONG THE LONG PATH'**
  String get alongLongPath;

  /// No description provided for @harderDays.
  ///
  /// In en, this message translates to:
  /// **'ON THE HARDER DAYS'**
  String get harderDays;

  /// No description provided for @whyWeWalk.
  ///
  /// In en, this message translates to:
  /// **'WHY WE WALK'**
  String get whyWeWalk;

  /// No description provided for @waitingWalks.
  ///
  /// In en, this message translates to:
  /// **'{count} more waiting on your walks. Every day has a new path.'**
  String waitingWalks(String count);

  /// No description provided for @waitingHarder.
  ///
  /// In en, this message translates to:
  /// **'{count} more waiting for hard days and for walks in the rain.'**
  String waitingHarder(String count);

  /// No description provided for @walkKmInAll.
  ///
  /// In en, this message translates to:
  /// **'Walk {km} km in all'**
  String walkKmInAll(String km);

  /// No description provided for @fromQuran.
  ///
  /// In en, this message translates to:
  /// **'From the Quran'**
  String get fromQuran;

  /// No description provided for @fromSunnah.
  ///
  /// In en, this message translates to:
  /// **'From the Sunnah'**
  String get fromSunnah;

  /// No description provided for @translationQuran.
  ///
  /// In en, this message translates to:
  /// **'Translation of the meaning (Saheeh International).'**
  String get translationQuran;

  /// No description provided for @translationSunnah.
  ///
  /// In en, this message translates to:
  /// **'Translation of the meaning (sunnah.com).'**
  String get translationSunnah;

  /// No description provided for @readQuran.
  ///
  /// In en, this message translates to:
  /// **'Read with Arabic on {site}'**
  String readQuran(String site);

  /// No description provided for @readSunnah.
  ///
  /// In en, this message translates to:
  /// **'Read with Arabic and grading on {site}'**
  String readSunnah(String site);

  /// No description provided for @couldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open {site}.'**
  String couldNotOpen(String site);

  /// No description provided for @reminder0.
  ///
  /// In en, this message translates to:
  /// **'The light is outside. A short walk?'**
  String get reminder0;

  /// No description provided for @reminder1.
  ///
  /// In en, this message translates to:
  /// **'Even ten minutes outside brightens the day.'**
  String get reminder1;

  /// No description provided for @reminder2.
  ///
  /// In en, this message translates to:
  /// **'So walk among its slopes (67:15). The door is right there.'**
  String get reminder2;

  /// No description provided for @reminder3.
  ///
  /// In en, this message translates to:
  /// **'With hardship will be ease (94:5). Step out for a moment.'**
  String get reminder3;

  /// No description provided for @reminder4.
  ///
  /// In en, this message translates to:
  /// **'A few steps today. Small and regular is beloved.'**
  String get reminder4;

  /// No description provided for @reminder5.
  ///
  /// In en, this message translates to:
  /// **'Whatever the weather, a little light is waiting.'**
  String get reminder5;

  /// No description provided for @reminder6.
  ///
  /// In en, this message translates to:
  /// **'Your body has a right over you. Two minutes outside?'**
  String get reminder6;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return LAr();
    case 'en':
      return LEn();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
