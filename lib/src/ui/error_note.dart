import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// UIC-19: the note that says what is wrong with an entry. It sits on the field's
/// label line, next to the label, on one line and never wrapped. A note that is too
/// long for its room ends with "…", and hovering or clicking it shows the whole
/// message in a popover (UIC-07) that wraps inside the window.
class ErrorNote extends StatelessWidget {
  const ErrorNote(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = TextStyle(color: t.bad, fontWeight: FontWeight.w600, fontSize: 12);
    return LayoutBuilder(
      builder: (context, box) {
        final painter = TextPainter(
          text: TextSpan(text: message, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout();
        final oversized = painter.width > box.maxWidth;
        final text = Text(message, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis, style: style);
        if (!oversized) return text;
        return Tooltip(
          key: const ValueKey('error-note-info'),
          message: message,
          triggerMode: TooltipTriggerMode.tap, // a click or tap; hovering shows it too
          showDuration: const Duration(seconds: 8),
          constraints: const BoxConstraints(maxWidth: 360),
          child: MouseRegion(cursor: SystemMouseCursors.help, child: text),
        );
      },
    );
  }
}
