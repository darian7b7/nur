import 'package:family_reminders/family_reminders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class NurApp extends StatelessWidget {
  const NurApp({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) => StoreScope(
    notifier: store,
    child: MaterialApp(
      title: 'Nūr',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.dark), // the sky is the page; sheets are always night
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
