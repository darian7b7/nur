import 'package:family_reminders/family_reminders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/light.dart';
import 'l10n/app_localizations.dart';
import 'reminder.dart';
import 'steps.dart';
import 'store.dart';
import 'ui/theme.dart';
import 'ui/today.dart';
import 'ui/welcome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  loadContent(await rootBundle.loadString(contentAsset)); // the verses and hadith
  final reminder = LocalReminder();
  try {
    await initLocalTimezone();
    await reminder.init();
  } catch (e) {
    debugPrint('Reminders unavailable: $e');
  }
  runApp(
    NurApp(
      store: await Store.load(steps: PhoneSteps(), reminder: reminder),
    ),
  );
}

class NurApp extends StatefulWidget {
  const NurApp({super.key, required this.store});

  final Store store;

  @override
  State<NurApp> createState() => _NurAppState();
}

class _NurAppState extends State<NurApp> {
  late String _language = widget.store.language;

  // The app is rebuilt only when the language changes, not with every step.
  void _onStore() {
    if (widget.store.language != _language) setState(() => _language = widget.store.language);
  }

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStore);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StoreScope(
    notifier: widget.store,
    child: MaterialApp(
      onGenerateTitle: (context) => L.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.dark), // the sky is the page; sheets are always night
      // English and Arabic (right to left); the phone's language unless one is chosen in Settings.
      // Any other phone language falls back to English.
      localizationsDelegates: const [
        L.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L.supportedLocales,
      locale: _language == 'system' ? null : Locale(_language),
      localeListResolutionCallback: (locales, supported) {
        for (final l in locales ?? const <Locale>[]) {
          if (supported.any((s) => s.languageCode == l.languageCode)) return Locale(l.languageCode);
        }
        return const Locale('en');
      },
      home: const _Home(),
    ),
  );
}

/// Follows the step counter while Nūr is open, and lets it be while Nūr is in the background (the
/// phone keeps counting; the steps are picked up on return).
class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> with WidgetsBindingObserver {
  late final Store _store = StoreScope.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.startLive());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      _store.startLive();
    } else if (s == AppLifecycleState.paused) {
      _store.stopLive();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 900),
      child: store.welcomed ? const Today(key: ValueKey('today')) : const Welcome(key: ValueKey('welcome')),
    );
  }
}
