// Settings: your daily light, your stride, where steps come from, the one optional reminder.
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/light.dart';
import '../store.dart';
import 'step_access.dart';
import 'theme.dart';
import 'words.dart';

void showSettings(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true, // the handle stays below the status bar, so it can be pulled
  isScrollControlled: true,
  backgroundColor: night,
  builder: (_) => const _Settings(),
);

const goals = [1000, 2000, 3000, 5000, 8000];

/// Also in android/…/PrivacyActivity.kt (Health Connect opens it).
const privacyUrl = 'https://darian7b7.github.io/nur/privacy.html';

/// The family's other apps for Nūr's people. Shown only once [live]: switch each on when it is on
/// Google Play (and keep its id the same as the one published).
const familyApps = [
  (name: 'Sakina', id: 'app.sakina.sakina', icon: Icons.auto_stories_outlined, live: false),
  (name: 'Majlis', id: 'app.majlis.majlis', icon: Icons.groups_outlined, live: false),
];

class _Settings extends StatelessWidget {
  const _Settings();

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    const ink = Color(0xFFF4F1EA);
    final muted = ink.withValues(alpha: 0.65);
    Widget heading(String s) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        s.toUpperCase(),
        style: TextStyle(color: muted, fontSize: 12, letterSpacing: context.lang == 'ar' ? 0 : 1.6, fontWeight: FontWeight.w700),
      ),
    );
    Widget chip(String label, bool on, VoidCallback onTap) => ChoiceChip(
      label: Text(label),
      selected: on,
      onSelected: (_) => onTap(),
      selectedColor: gold,
      labelStyle: TextStyle(color: on ? night : ink, fontWeight: FontWeight.w600),
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      showCheckmark: false,
    );
    final height = (store.strideCm / 0.415).round();
    final l = context.l;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.settings,
              style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            heading(l.language),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                chip(l.languagePhone, store.language == 'system', () => store.setLanguage('system')),
                chip('English', store.language == 'en', () => store.setLanguage('en')),
                chip('العربية', store.language == 'ar', () => store.setLanguage('ar')),
              ],
            ),
            heading(l.yourDailyLight),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final g in goals) chip(context.dist(g), store.goal == g, () => store.setGoal(g))]),
            const SizedBox(height: 6),
            Text(l.dailyLightNote, style: TextStyle(color: muted, fontSize: 13)),
            heading(l.yourHeight),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: height.clamp(130, 210).toDouble(),
                    min: 130,
                    max: 210,
                    divisions: 80,
                    activeColor: gold,
                    label: l.cm('$height'),
                    onChanged: (v) => store.setStride(strideFor(v.round())),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    l.cm('$height'),
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: ink, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Text(l.strideNote('${store.strideCm}'), style: TextStyle(color: muted, fontSize: 13)),
            heading(l.yourSteps),
            Material(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: StepAccess(ink: ink, muted: muted),
              ),
            ),
            heading(l.dailyReminder),
            Material(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: [
                  SwitchListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    value: store.remind,
                    activeThumbColor: gold,
                    onChanged: (v) => store.setReminder(on: v),
                    title: Text(
                      l.remindMe,
                      style: const TextStyle(color: ink, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(l.remindNote, style: TextStyle(color: muted, height: 1.35)),
                  ),
                  if (store.reminderRefused)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(l.notificationsOff, style: TextStyle(color: muted)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: gold),
                            onPressed: openAppSettings,
                            child: Text(l.openSettings),
                          ),
                        ],
                      ),
                    ),
                  if (store.remind) ...[
                    ListTile(
                      title: Text(l.time, style: const TextStyle(color: ink)),
                      trailing: Text(
                        _hhmm(store.remindAt),
                        style: const TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: store.remindAt ~/ 60, minute: store.remindAt % 60),
                        );
                        if (t != null) await store.setReminder(at: t.hour * 60 + t.minute);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_reminderText(context, store), style: TextStyle(color: muted, height: 1.35)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (familyApps.any((a) => a.live)) ...[
              heading(l.moreFromUs),
              Material(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final a in familyApps.where((a) => a.live))
                      ListTile(
                        leading: Icon(a.icon, color: gold),
                        title: Text(
                          a.name,
                          style: const TextStyle(color: ink, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(a.name == 'Sakina' ? l.sakinaLine : l.majlisLine, style: TextStyle(color: muted)),
                        trailing: Icon(Icons.open_in_new_rounded, color: muted, size: 18),
                        onTap: () =>
                            launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=${a.id}'), mode: LaunchMode.externalApplication),
                      ),
                  ],
                ),
              ),
            ],
            heading(l.yourData),
            Text(l.dataNote, style: TextStyle(color: muted, height: 1.4)),
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: gold, padding: EdgeInsets.zero),
              onPressed: () => launchUrl(Uri.parse(privacyUrl), mode: LaunchMode.externalApplication),
              child: Text(l.privacyPolicy),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: ink.withValues(alpha: 0.8), padding: EdgeInsets.zero),
              onPressed: () async {
                final yes = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: Text(l.forgetTitle),
                    content: Text(l.forgetBody),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l.keep)),
                      FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l.forget)),
                    ],
                  ),
                );
                if (yes == true) store.forgetAll();
              },
              child: Text(l.forgetAllWalks),
            ),
          ],
        ),
      ),
    );
  }
}

String _hhmm(int m) => '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

/// "Next: today around 17:00." and, when not today, why not.
String _reminderText(BuildContext context, Store store) {
  final time = _hhmm(store.remindAt);
  return switch (store.reminderNext()) {
    null => '',
    ReminderNext.today => context.l.reminderToday(time),
    ReminderNext.passed => context.l.reminderPassed(time),
    ReminderNext.full => context.l.reminderFull(time),
  };
}
