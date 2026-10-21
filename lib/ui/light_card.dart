// A light (verse or hadith) on glass over the sky, and the sheet to read it in full.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/light.dart';
import 'sky.dart';
import 'theme.dart';

class LightCard extends StatelessWidget {
  const LightCard({super.key, required this.light, required this.progress, this.label, this.maxLines = 4, this.onTap});

  final Light light;
  final double progress;
  final String? label; // e.g. "Found at 1 km"
  final int maxLines;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ink = inkOn(progress);
    return Glass(
      progress: progress,
      onTap: onTap ?? () => showLight(context, light),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 15, color: progress < 0.6 ? gold : const Color(0xFFB07A1E)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label!.toUpperCase(),
                    style: TextStyle(color: mutedOn(progress), fontSize: 12, letterSpacing: 1.1, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(
            light.text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: ink, fontSize: 17, height: 1.45),
          ),
          const SizedBox(height: 8),
          Text(
            light.source,
            style: TextStyle(color: mutedOn(progress), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Opens the light at its source in the browser (or the quran.com app, if installed).
Future<bool> openSource(Light l) async {
  try {
    return await launchUrl(l.sourceUrl, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// The whole verse or hadith, calm and large.
void showLight(BuildContext context, Light l, {String? label}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: night,
    builder: (sheet) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 4, 28, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: gold, size: 18),
                const SizedBox(width: 8),
                Text(
                  (label ?? (l.isQuran ? 'From the Quran' : 'From the Sunnah')).toUpperCase(),
                  style: const TextStyle(color: gold, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l.text,
              style: const TextStyle(color: Color(0xFFF4F1EA), fontSize: 22, height: 1.5, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 14),
            Text(
              l.source,
              style: TextStyle(color: const Color(0xFFF4F1EA).withValues(alpha: 0.7), fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              l.isQuran ? 'Translation of the meaning (Saheeh International).' : 'Translation of the meaning (sunnah.com).',
              style: TextStyle(color: const Color(0xFFF4F1EA).withValues(alpha: 0.5), fontSize: 12),
            ),
            const SizedBox(height: 18),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: gold, padding: EdgeInsets.zero),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                if (!await openSource(l)) messenger.showSnackBar(SnackBar(content: Text("Couldn't open ${l.sourceSite}.")));
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(l.isQuran ? 'Read with Arabic on ${l.sourceSite}' : 'Read with Arabic and grading on ${l.sourceSite}'),
            ),
          ],
        ),
      ),
    ),
  );
}
