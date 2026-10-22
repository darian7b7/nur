// Settings: your daily light, your stride, where steps come from, the one optional reminder.
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/light.dart';
import '../store.dart';
import 'step_access.dart';
import 'theme.dart';

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
  (name: 'Sakina', line: 'Quran verses for how you feel', id: 'app.sakina.sakina', icon: Icons.auto_stories_outlined, live: false),
  (name: 'Majlis', line: 'A quiz on the Quran and the Sunnah', id: 'app.majlis.majlis', icon: Icons.groups_outlined, live: false),
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
        style: TextStyle(color: muted, fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w700),
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            heading('Your daily light'),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final g in goals) chip(distanceText(g), store.goal == g, () => store.setGoal(g))]),
            const SizedBox(height: 6),
            Text('Full light when you reach it. Any step brightens the sky.', style: TextStyle(color: muted, fontSize: 13)),
            heading('Your height'),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: height.clamp(130, 210).toDouble(),
                    min: 130,
                    max: 210,
                    divisions: 80,
                    activeColor: gold,
                    label: '$height cm',
                    onChanged: (v) => store.setStride(strideFor(v.round())),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    '$height cm',
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: ink, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Text('For your stride: ${store.strideCm} cm a step.', style: TextStyle(color: muted, fontSize: 13)),
            heading('Your steps'),
            Material(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: StepAccess(ink: ink, muted: muted),
              ),
            ),
            heading('Daily walk reminder'),
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
                    title: const Text(
                      'Remind me to walk',
                      style: TextStyle(color: ink, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "One quiet notification a day (no sound), only on days you haven't reached your light yet.",
                      style: TextStyle(color: muted, height: 1.35),
                    ),
                  ),
                  if (store.reminderRefused)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('Notifications are off for Nūr in your phone\'s settings.', style: TextStyle(color: muted)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: gold),
                            onPressed: openAppSettings,
                            child: const Text('Open settings'),
                          ),
                        ],
                      ),
                    ),
                  if (store.remind) ...[
                    ListTile(
                      title: const Text('Time', style: TextStyle(color: ink)),
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
                        child: Text(store.reminderText(), style: TextStyle(color: muted, height: 1.35)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (familyApps.any((a) => a.live)) ...[
              heading('More from us'),
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
                        subtitle: Text(a.line, style: TextStyle(color: muted)),
                        trailing: Icon(Icons.open_in_new_rounded, color: muted, size: 18),
                        onTap: () =>
                            launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=${a.id}'), mode: LaunchMode.externalApplication),
                      ),
                  ],
                ),
              ),
            ],
            heading('Your data'),
            Text(
              'Everything stays on this phone. Nūr reads only your step count: no location, no account.',
              style: TextStyle(color: muted, height: 1.4),
            ),
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: gold, padding: EdgeInsets.zero),
              onPressed: () => launchUrl(Uri.parse(privacyUrl), mode: LaunchMode.externalApplication),
              child: const Text('Privacy policy'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: ink.withValues(alpha: 0.8), padding: EdgeInsets.zero),
              onPressed: () async {
                final yes = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: const Text('Forget all walks?'),
                    content: const Text('Your distances and the light you found. Your settings stay.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(d).pop(false), child: const Text('Keep')),
                      FilledButton(onPressed: () => Navigator.of(d).pop(true), child: const Text('Forget')),
                    ],
                  ),
                );
                if (yes == true) store.forgetAll();
              },
              child: const Text('Forget all walks'),
            ),
          ],
        ),
      ),
    );
  }
}

String _hhmm(int m) => '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
