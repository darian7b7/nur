// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class LAr extends L {
  LAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نور';

  @override
  String get unitM => 'م';

  @override
  String get unitKm => 'كم';

  @override
  String get todaysLight => 'نور اليوم';

  @override
  String get fullLightToday => 'اكتمل نور اليوم';

  @override
  String get hardDayHeading => 'يوم صعب · اخرج من الباب فقط';

  @override
  String ofGoal(String goal) {
    return 'من $goal';
  }

  @override
  String get cardHardDay => 'ليوم صعب';

  @override
  String cardFoundAt(String distance) {
    return 'وجدته اليوم عند $distance';
  }

  @override
  String get cardBeforeFirstStep => 'قبل الخطوة الأولى';

  @override
  String get everyLightFound => 'وجدت كل أنوار اليوم.';

  @override
  String nextLightIn(String distance) {
    return 'النور التالي بعد $distance';
  }

  @override
  String get tooltipCollection => 'النور الذي وجدته';

  @override
  String get tooltipSettings => 'الإعدادات';

  @override
  String get tooltipAnotherWay => 'طريق آخر';

  @override
  String get goOut => 'اخرج';

  @override
  String get walkMore => 'امشِ قليلًا بعد';

  @override
  String get hardDay => 'يوم صعب';

  @override
  String get newWay => 'طريق جديد';

  @override
  String get weather => 'الطقس';

  @override
  String get stepsOff => 'عدّ الخطوات متوقف';

  @override
  String get stepsOffBody => 'لا يرى نور مشيك حتى تسمح بعدّ الخطوات.';

  @override
  String get turnOn => 'تشغيل';

  @override
  String get lightFound => 'وجدت نورًا';

  @override
  String get lightFoundMore => 'وجدت نورًا · والمزيد في مجموعتك';

  @override
  String get weatherQuestion => 'كيف الجو في الخارج؟';

  @override
  String get weatherRain => 'مطر';

  @override
  String get weatherCold => 'برد';

  @override
  String get weatherHeat => 'حر';

  @override
  String get weatherDark => 'ظلام';

  @override
  String get weatherGrey => 'غائم';

  @override
  String get weatherRainTip =>
      'سترة للمطر أو مظلة، وحذاء لا يضره البلل. المطر يصفّي الهواء والذهن.';

  @override
  String get weatherColdTip =>
      'طبقات من الملابس، وقبعة وقفازان. امشِ بخطى سريعة في الدقائق الخمس الأولى وستدفأ.';

  @override
  String get weatherHeatTip =>
      'اخرج باكرًا أو متأخرًا، وفي الظل. خذ معك ماء، وقبعة، والبس ثيابًا خفيفة.';

  @override
  String get weatherDarkTip =>
      'شوارع مضاءة تعرفها، وشيء فاتح اللون تلبسه، ومصباح الهاتف إن احتجت إليه.';

  @override
  String get weatherGreyTip =>
      'الأيام الغائمة أحوج ما تكون إلى النور. عشر دقائق في الخارج ترفع اليوم كله.';

  @override
  String get rainIsMercy => 'المطر رحمة';

  @override
  String get goOutInRain => 'اخرج تحت المطر';

  @override
  String get goOutAnyway => 'اخرج على كل حال';

  @override
  String get newWay0 => 'اسلك شارعًا لم تمشِ فيه من قبل.';

  @override
  String get newWay1 =>
      'عند أول منعطف، انعطف إلى غير الجهة التي تنعطف إليها دائمًا.';

  @override
  String get newWay2 => 'امشِ حتى ترى ثلاث أشجار، ثم اختر اتجاهًا جديدًا.';

  @override
  String get newWay3 => 'امشِ نحو أشد أجزاء السماء ضياءً.';

  @override
  String get newWay4 => 'ابحث عن مكان لم تقف فيه من قبل، وقف فيه لحظة.';

  @override
  String get newWay5 => 'امشِ إلى أقرب مسجد، وارجع من طريق آخر.';

  @override
  String get newWay6 => 'اتبع أول طائر تراه، ما استطعت.';

  @override
  String get newWay7 => 'امشِ والريح خلفك، ثم استقبلها في طريق العودة.';

  @override
  String get newWay8 => 'ارفع بصرك عند كل منعطف: نافذة، سقف، السماء.';

  @override
  String get newWay9 => 'انعطف يمينًا عند كل منعطف ثانٍ.';

  @override
  String get newWay10 => 'امشِ إلى طرف حيّك، وانظر إلى ما بعده.';

  @override
  String get newWay11 => 'اختر أهدأ شارع تجده.';

  @override
  String get walkingIntoLight => 'تمشي نحو النور';

  @override
  String get walkingInRain => 'تمشي تحت المطر';

  @override
  String walkSteps(String steps, String time) {
    return '$steps خطوة · $time';
  }

  @override
  String walkNoSensor(String time) {
    return '$time · هاتفك يعدّ الخطوات';
  }

  @override
  String get pocket => 'يمكنك وضع الهاتف في جيبك.';

  @override
  String get finishWalk => 'إنهاء المشي';

  @override
  String get wentOut => 'لقد خرجت.';

  @override
  String get steppedOut => 'خطوت إلى الخارج.';

  @override
  String get underMinute => 'أقل من دقيقة';

  @override
  String minutes(String n) {
    return '$n دقيقة';
  }

  @override
  String get inTheRain => 'تحت المطر';

  @override
  String get lightsFound => 'وجدت أنوارًا';

  @override
  String get everyStepCounts => 'كل خطوة تُحسب، حتى الصغيرة.';

  @override
  String get done => 'تم';

  @override
  String get tagline => 'امشِ نحو النور.';

  @override
  String get begin => 'ابدأ';

  @override
  String get everyStepBringsLight => 'كل خطوة\nتجلب نورًا';

  @override
  String get welcomeBody =>
      'يبدأ يومك في الليل. وكلما مشيت، أشرقت الشمس على طريقك. وفي الطريق تجد آيات وأحاديث عن المشي والأمل والنور.';

  @override
  String get welcomeHarder =>
      'مطر، برد، يوم صعب، مكان فيه ذكريات قديمة: لكلٍّ منها في نور مخرج صغير.';

  @override
  String get next => 'التالي';

  @override
  String get yourDailyLight => 'نورك اليومي';

  @override
  String get dailyLightQuestion =>
      'كم تمشي كل يوم حتى يكتمل النور؟ يمكنك تغييره متى شئت.';

  @override
  String get yourStepsFromPhone => 'خطواتك، من هاتفك';

  @override
  String get onlyStepCount =>
      'عدد الخطوات فقط. لا موقع، ولا استنزاف للبطارية، ولا شيء يغادر هاتفك.';

  @override
  String get start => 'لنبدأ';

  @override
  String get allowStepCounting => 'السماح بعدّ الخطوات';

  @override
  String get oneMoment => 'لحظة…';

  @override
  String get counterTitle => 'عدّ الخطوات · ضروري';

  @override
  String get counterOn => 'مسموح. كل خطوة تُحسب ما دام نور مفتوحًا.';

  @override
  String get counterOff =>
      'يحتاج نور إلى إذن «النشاط البدني» في أندرويد ليعدّ خطواتك. وبدونه لا يتحرك شيء.';

  @override
  String get healthConnectTitle => 'Health Connect · مُستحسن';

  @override
  String get healthConnectOn => 'متصل. تُحسب الخطوات حتى ونور مغلق.';

  @override
  String get healthConnectOff =>
      'يتيح لنور أن يرى الخطوات التي مشيتها وهو مغلق أيضًا.';

  @override
  String get connectHealthConnect => 'ربط Health Connect';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get languagePhone => 'لغة الهاتف';

  @override
  String get dailyLightNote => 'يكتمل النور حين تبلغه، وكل خطوة تُضيء السماء.';

  @override
  String get yourHeight => 'طولك';

  @override
  String cm(String n) {
    return '$n سم';
  }

  @override
  String strideNote(String cm) {
    return 'لطول خطوتك: $cm سم للخطوة.';
  }

  @override
  String get yourSteps => 'خطواتك';

  @override
  String get dailyReminder => 'تذكير يومي بالمشي';

  @override
  String get remindMe => 'ذكّرني بالمشي';

  @override
  String get remindNote =>
      'إشعار هادئ واحد في اليوم (بلا صوت)، فقط في الأيام التي لم تبلغ فيها نورك بعد.';

  @override
  String get notificationsOff => 'الإشعارات متوقفة لنور في إعدادات هاتفك.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get time => 'الوقت';

  @override
  String reminderToday(String time) {
    return 'التالي: اليوم نحو الساعة $time.';
  }

  @override
  String reminderPassed(String time) {
    return 'التالي: غدًا نحو الساعة $time، فقد مضى هذا الوقت اليوم.';
  }

  @override
  String reminderFull(String time) {
    return 'التالي: غدًا نحو الساعة $time. اكتمل نور اليوم، فلا تذكير اليوم.';
  }

  @override
  String get moreFromUs => 'المزيد منّا';

  @override
  String get sakinaLine => 'آيات من القرآن لما تشعر به';

  @override
  String get majlisLine => 'مسابقة في القرآن والسنة';

  @override
  String get yourData => 'بياناتك';

  @override
  String get dataNote =>
      'كل شيء يبقى على هذا الهاتف. لا يقرأ نور إلا عدد خطواتك: لا موقع، ولا حساب.';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get forgetTitle => 'حذف كل المشي؟';

  @override
  String get forgetBody => 'مسافاتك والنور الذي وجدته. وتبقى إعداداتك.';

  @override
  String get keep => 'إبقاء';

  @override
  String get forget => 'حذف';

  @override
  String get forgetAllWalks => 'حذف كل المشي';

  @override
  String get yourLight => 'نورك';

  @override
  String foundOf(String count, String total) {
    return 'وجدت $count من $total';
  }

  @override
  String totals(String all, String week) {
    return '$all إجمالًا · $week هذا الأسبوع';
  }

  @override
  String get alongEachDay => 'في طريق كل يوم';

  @override
  String get alongLongPath => 'في الطريق الطويل';

  @override
  String get harderDays => 'في الأيام الأصعب';

  @override
  String get whyWeWalk => 'لماذا نمشي';

  @override
  String waitingWalks(String count) {
    return '$count أخرى تنتظرك في مشيك. لكل يوم طريق جديد.';
  }

  @override
  String waitingHarder(String count) {
    return '$count أخرى تنتظرك في الأيام الصعبة وفي المشي تحت المطر.';
  }

  @override
  String walkKmInAll(String km) {
    return 'امشِ $km كم إجمالًا';
  }

  @override
  String get fromQuran => 'من القرآن';

  @override
  String get fromSunnah => 'من السنة';

  @override
  String get translationQuran => 'ترجمة المعنى (Saheeh International).';

  @override
  String get translationSunnah => 'ترجمة المعنى (sunnah.com).';

  @override
  String readQuran(String site) {
    return 'اقرأ الآية على $site';
  }

  @override
  String readSunnah(String site) {
    return 'اقرأ الحديث ودرجته على $site';
  }

  @override
  String couldNotOpen(String site) {
    return 'تعذّر فتح $site.';
  }

  @override
  String get reminder0 => 'النور في الخارج. مشيٌ قصير؟';

  @override
  String get reminder1 => 'حتى عشر دقائق في الخارج تُضيء اليوم.';

  @override
  String get reminder2 => '﴿فَٱمْشُوا۟ فِى مَنَاكِبِهَا﴾ الملك ١٥. الباب قريب.';

  @override
  String get reminder3 =>
      '﴿فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا﴾ الشرح ٥. اخرج قليلًا.';

  @override
  String get reminder4 =>
      'خطوات قليلة اليوم. «أحبّ الأعمال أدومها إلى الله وإن قلّ».';

  @override
  String get reminder5 => 'مهما كان الطقس، ثمة نور ينتظرك.';

  @override
  String get reminder6 => '«إن لجسدك عليك حقًّا». دقيقتان في الخارج؟';
}
