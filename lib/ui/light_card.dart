// A light (verse or hadith) on glass over the sky, and the sheet to read it in full.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/light.dart';
import 'sky.dart';
import 'theme.dart';
import 'words.dart';

/// The words of [light] in [language] ('ar' or 'en'), in the right script and font: the Quran in
/// Amiri Quran, hadith in Amiri, a little larger and right to left; English as it is.
class LightWords extends StatelessWidget {
  const LightWords({super.key, required this.light, required this.language, required this.style, this.maxLines});

  final Light light;
  final String language;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final arabic = language == 'ar';
    return Text(
      light.textIn(language),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textDirection: arabic ? TextDirection.rtl : null,
      style: arabic
          ? style.copyWith(
              fontFamily: light.isQuran ? 'AmiriQuran' : 'Amiri',
              fontSize: (style.fontSize ?? 17) * 1.25,
              height: 1.9,
              fontStyle: FontStyle.normal,
            )
          : style,
    );
  }
}

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
                    style: TextStyle(
                      color: mutedOn(progress),
                      fontSize: 12,
                      letterSpacing: context.lang == 'ar' ? 0 : 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          LightWords(
            light: light,
            language: context.lang,
            maxLines: maxLines,
            style: TextStyle(color: ink, fontSize: 17, height: 1.45),
          ),
          const SizedBox(height: 8),
          Text(
            light.sourceIn(context.lang),
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

/// The whole verse or hadith, calm and large: the Arabic, and in English its translation under it.
void showLight(BuildContext context, Light l, {String? label}) {
  showModalBottomSheet<void>(
    useSafeArea: true, // the handle stays below the status bar, so it can be pulled
    context: context,
    isScrollControlled: true,
    backgroundColor: night,
    builder: (sheet) {
      const ink = Color(0xFFF4F1EA);
      final words = sheet.l;
      final english = sheet.lang != 'ar';
      return SafeArea(
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
                    (label ?? (l.isQuran ? words.fromQuran : words.fromSunnah)).toUpperCase(),
                    style: TextStyle(color: gold, fontSize: 12, letterSpacing: english ? 1.2 : 0, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: LightWords(
                  light: l,
                  language: 'ar',
                  style: const TextStyle(color: ink, fontSize: 22),
                ),
              ),
              if (english) ...[
                const SizedBox(height: 14),
                LightWords(
                  light: l,
                  language: 'en',
                  style: TextStyle(color: ink.withValues(alpha: 0.9), fontSize: 18, height: 1.5),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                l.sourceIn(sheet.lang),
                style: TextStyle(color: ink.withValues(alpha: 0.7), fontSize: 15, fontWeight: FontWeight.w600),
              ),
              if (english) ...[
                const SizedBox(height: 6),
                Text(l.isQuran ? words.translationQuran : words.translationSunnah, style: TextStyle(color: ink.withValues(alpha: 0.5), fontSize: 12)),
              ],
              const SizedBox(height: 18),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: gold, padding: EdgeInsets.zero),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final failed = words.couldNotOpen(l.sourceSite);
                  if (!await openSource(l)) messenger.showSnackBar(SnackBar(content: Text(failed)));
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(l.isQuran ? words.readQuran(l.sourceSite) : words.readSunnah(l.sourceSite)),
              ),
            ],
          ),
        ),
      );
    },
  );
}
