// What Nūr may use to count steps, in plain words, with a button for what is still off.
import 'package:flutter/material.dart';

import '../store.dart';
import 'theme.dart';
import 'words.dart';

class StepAccess extends StatefulWidget {
  const StepAccess({super.key, required this.ink, required this.muted, this.accent = gold});

  final Color ink;
  final Color muted;
  final Color accent;

  @override
  State<StepAccess> createState() => _StepAccessState();
}

class _StepAccessState extends State<StepAccess> {
  var _busy = false;

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _busy = true);
    await f();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    Widget row({
      required bool on,
      required String title,
      required String onText,
      required String offText,
      required String button,
      required VoidCallback onTap,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(on ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 22, color: on ? widget.accent : widget.muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: widget.ink, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(on ? onText : offText, style: TextStyle(color: widget.muted, height: 1.35)),
                if (!on) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _busy ? null : onTap,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: widget.ink,
                      side: BorderSide(color: widget.ink.withValues(alpha: 0.5)),
                    ),
                    child: Text(_busy ? context.l.oneMoment : button),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(
          on: store.counterOk == true,
          title: context.l.counterTitle,
          onText: context.l.counterOn,
          offText: context.l.counterOff,
          button: context.l.allowStepCounting,
          onTap: () => _run(store.allowCounter),
        ),
        row(
          on: store.connected,
          title: context.l.healthConnectTitle,
          onText: context.l.healthConnectOn,
          offText: context.l.healthConnectOff,
          button: context.l.connectHealthConnect,
          onTap: () => _run(store.connectSteps),
        ),
      ],
    );
  }
}
