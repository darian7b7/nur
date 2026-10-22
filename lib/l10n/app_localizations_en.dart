// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nūr';

  @override
  String get unitM => 'm';

  @override
  String get unitKm => 'km';

  @override
  String get todaysLight => 'TODAY\'S LIGHT';

  @override
  String get fullLightToday => 'FULL LIGHT TODAY';

  @override
  String get hardDayHeading => 'A HARD DAY · JUST STEP OUTSIDE';

  @override
  String ofGoal(String goal) {
    return 'of $goal';
  }

  @override
  String get cardHardDay => 'For a hard day';

  @override
  String cardFoundAt(String distance) {
    return 'Found today at $distance';
  }

  @override
  String get cardBeforeFirstStep => 'Before the first step';

  @override
  String get everyLightFound => 'Every light of today found.';

  @override
  String nextLightIn(String distance) {
    return 'Next light in $distance';
  }

  @override
  String get tooltipCollection => 'The light you found';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get tooltipAnotherWay => 'Another way';

  @override
  String get goOut => 'Go out';

  @override
  String get walkMore => 'Walk a little more';

  @override
  String get hardDay => 'Hard day';

  @override
  String get newWay => 'New way';

  @override
  String get weather => 'Weather';

  @override
  String get stepsOff => 'Steps are off';

  @override
  String get stepsOffBody =>
      'Nūr can\'t see your walk until step counting is allowed.';

  @override
  String get turnOn => 'Turn on';

  @override
  String get lightFound => 'Light found';

  @override
  String get lightFoundMore => 'Light found · more in your collection';

  @override
  String get weatherQuestion => 'What is it like outside?';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherCold => 'Cold';

  @override
  String get weatherHeat => 'Heat';

  @override
  String get weatherDark => 'Dark';

  @override
  String get weatherGrey => 'Grey';

  @override
  String get weatherRainTip =>
      'A rain jacket or an umbrella, and shoes that can get wet. Rain clears the air and the mind.';

  @override
  String get weatherColdTip =>
      'Layers, a hat and gloves. Walk briskly for the first five minutes and you will be warm.';

  @override
  String get weatherHeatTip =>
      'Go early or late, in the shade. Water with you, a cap, light clothes.';

  @override
  String get weatherDarkTip =>
      'Lit streets you know, something bright to wear, a light on your phone if you need it.';

  @override
  String get weatherGreyTip =>
      'Grey days need the light most. Even ten minutes outside lifts the day.';

  @override
  String get rainIsMercy => 'The rain is a mercy';

  @override
  String get goOutInRain => 'Go out in the rain';

  @override
  String get goOutAnyway => 'Go out anyway';

  @override
  String get newWay0 => 'Take a street you have never walked down.';

  @override
  String get newWay1 =>
      'At the first corner, turn the other way than you always do.';

  @override
  String get newWay2 =>
      'Walk until you have seen three trees, then choose a new direction.';

  @override
  String get newWay3 => 'Walk towards the brightest part of the sky.';

  @override
  String get newWay4 =>
      'Find a place you have never stood before, and stand there for a moment.';

  @override
  String get newWay5 => 'Walk to the nearest mosque, and back a different way.';

  @override
  String get newWay6 => 'Follow the first bird you see, as far as it goes.';

  @override
  String get newWay7 =>
      'Walk with the wind at your back, then turn into it on the way home.';

  @override
  String get newWay8 =>
      'Look up at every corner: notice a window, a roof, the sky.';

  @override
  String get newWay9 => 'Take every second turn to the right.';

  @override
  String get newWay10 =>
      'Walk to the edge of your neighbourhood, and look past it.';

  @override
  String get newWay11 => 'Choose the quietest street you can find.';

  @override
  String get walkingIntoLight => 'WALKING INTO THE LIGHT';

  @override
  String get walkingInRain => 'WALKING IN THE RAIN';

  @override
  String walkSteps(String steps, String time) {
    return '$steps steps · $time';
  }

  @override
  String walkNoSensor(String time) {
    return '$time · steps are counted by your phone';
  }

  @override
  String get pocket => 'The phone can go in your pocket.';

  @override
  String get finishWalk => 'Finish walk';

  @override
  String get wentOut => 'You went out.';

  @override
  String get steppedOut => 'You stepped out.';

  @override
  String get underMinute => 'under a minute';

  @override
  String minutes(String n) {
    return '$n min';
  }

  @override
  String get inTheRain => 'in the rain';

  @override
  String get lightsFound => 'Lights found';

  @override
  String get everyStepCounts => 'Every step counts, the small ones too.';

  @override
  String get done => 'Done';

  @override
  String get tagline => 'Walk into the light.';

  @override
  String get begin => 'Begin';

  @override
  String get everyStepBringsLight => 'Every step\nbrings light';

  @override
  String get welcomeBody =>
      'Your day starts at night. As you walk, the sun comes up over your path. Along the way you find verses and hadith about walking, hope and light.';

  @override
  String get welcomeHarder =>
      'Rain, cold, a hard day, a place with old memories: Nūr has a small way out for each.';

  @override
  String get next => 'Next';

  @override
  String get yourDailyLight => 'Your daily light';

  @override
  String get dailyLightQuestion =>
      'How far to full light each day? You can change it any time.';

  @override
  String get yourStepsFromPhone => 'Your steps, from your phone';

  @override
  String get onlyStepCount =>
      'Only the step count. No location, no battery drain, nothing leaves the phone.';

  @override
  String get start => 'Start';

  @override
  String get allowStepCounting => 'Allow step counting';

  @override
  String get oneMoment => 'One moment…';

  @override
  String get counterTitle => 'Step counter · needed';

  @override
  String get counterOn => 'Allowed. Every step counts while Nūr is open.';

  @override
  String get counterOff =>
      'Nūr needs Android\'s \"Physical activity\" permission to count your steps. Without it, nothing moves.';

  @override
  String get healthConnectTitle => 'Health Connect · recommended';

  @override
  String get healthConnectOn =>
      'Connected. Steps count also while Nūr is closed.';

  @override
  String get healthConnectOff =>
      'Lets Nūr see the steps you took while it was closed, too.';

  @override
  String get connectHealthConnect => 'Connect Health Connect';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languagePhone => 'Phone language';

  @override
  String get dailyLightNote =>
      'Full light when you reach it. Any step brightens the sky.';

  @override
  String get yourHeight => 'Your height';

  @override
  String cm(String n) {
    return '$n cm';
  }

  @override
  String strideNote(String cm) {
    return 'For your stride: $cm cm a step.';
  }

  @override
  String get yourSteps => 'Your steps';

  @override
  String get dailyReminder => 'Daily walk reminder';

  @override
  String get remindMe => 'Remind me to walk';

  @override
  String get remindNote =>
      'One quiet notification a day (no sound), only on days you haven\'t reached your light yet.';

  @override
  String get notificationsOff =>
      'Notifications are off for Nūr in your phone\'s settings.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get time => 'Time';

  @override
  String reminderToday(String time) {
    return 'Next: today around $time.';
  }

  @override
  String reminderPassed(String time) {
    return 'Next: tomorrow around $time. $time has passed today.';
  }

  @override
  String reminderFull(String time) {
    return 'Next: tomorrow around $time. Today\'s light is already full, so none today.';
  }

  @override
  String get moreFromUs => 'More from us';

  @override
  String get sakinaLine => 'Quran verses for how you feel';

  @override
  String get majlisLine => 'A quiz on the Quran and the Sunnah';

  @override
  String get yourData => 'Your data';

  @override
  String get dataNote =>
      'Everything stays on this phone. Nūr reads only your step count: no location, no account.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get forgetTitle => 'Forget all walks?';

  @override
  String get forgetBody =>
      'Your distances and the light you found. Your settings stay.';

  @override
  String get keep => 'Keep';

  @override
  String get forget => 'Forget';

  @override
  String get forgetAllWalks => 'Forget all walks';

  @override
  String get yourLight => 'Your light';

  @override
  String foundOf(String count, String total) {
    return '$count of $total found';
  }

  @override
  String totals(String all, String week) {
    return '$all in all · $week this week';
  }

  @override
  String get alongEachDay => 'ALONG EACH DAY';

  @override
  String get alongLongPath => 'ALONG THE LONG PATH';

  @override
  String get harderDays => 'ON THE HARDER DAYS';

  @override
  String get whyWeWalk => 'WHY WE WALK';

  @override
  String waitingWalks(String count) {
    return '$count more waiting on your walks. Every day has a new path.';
  }

  @override
  String waitingHarder(String count) {
    return '$count more waiting for hard days and for walks in the rain.';
  }

  @override
  String walkKmInAll(String km) {
    return 'Walk $km km in all';
  }

  @override
  String get fromQuran => 'From the Quran';

  @override
  String get fromSunnah => 'From the Sunnah';

  @override
  String get translationQuran =>
      'Translation of the meaning (Saheeh International).';

  @override
  String get translationSunnah => 'Translation of the meaning (sunnah.com).';

  @override
  String readQuran(String site) {
    return 'Read with Arabic on $site';
  }

  @override
  String readSunnah(String site) {
    return 'Read with Arabic and grading on $site';
  }

  @override
  String couldNotOpen(String site) {
    return 'Couldn\'t open $site.';
  }

  @override
  String get reminder0 => 'The light is outside. A short walk?';

  @override
  String get reminder1 => 'Even ten minutes outside brightens the day.';

  @override
  String get reminder2 =>
      'So walk among its slopes (67:15). The door is right there.';

  @override
  String get reminder3 =>
      'With hardship will be ease (94:5). Step out for a moment.';

  @override
  String get reminder4 => 'A few steps today. Small and regular is beloved.';

  @override
  String get reminder5 => 'Whatever the weather, a little light is waiting.';

  @override
  String get reminder6 =>
      'Your body has a right over you. Two minutes outside?';
}
