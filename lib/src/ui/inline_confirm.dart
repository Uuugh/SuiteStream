import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_theme.dart';

/// UIC-48: one inline confirm for every Reset or delete button that needs one.
/// Shows the original button built by [builder]; when that button calls `start`, it
/// turns in place into the text msg:areYouSure with Yes and No, in [color] and on the
/// plain background the Add notification button has (EVT-03.k). Yes calls [onConfirm];
/// No, Escape and losing focus put the original button back and do nothing.
///
/// Usage: `InlineConfirmButton(onConfirm: reset, color: scheme.error,
/// builder: (context, start) => ResetButton(label: ..., onPressed: start))`.
class InlineConfirmButton extends StatefulWidget {
  const InlineConfirmButton({
    super.key,
    required this.builder,
    required this.onConfirm,
    this.color,
  });

  /// Builds the original button; call `start` from its onPressed.
  final Widget Function(BuildContext context, VoidCallback start) builder;

  /// Called when the user answers Yes.
  final VoidCallback onConfirm;

  /// Font color of the question and the answers; the primary color when null (like the
  /// Add notification button).
  final Color? color;

  @override
  State<InlineConfirmButton> createState() => _InlineConfirmButtonState();
}

class _InlineConfirmButtonState extends State<InlineConfirmButton> {
  bool _asking = false;

  void _set(bool asking) {
    if (_asking != asking && mounted) setState(() => _asking = asking);
  }

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final style = TextButton.styleFrom(
      foregroundColor: color,
      minimumSize: const Size(0, suiteControlHeight),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(suiteControlRadius))),
    );
    final Widget content = _asking
        ? Focus(
            key: const ValueKey('inline-confirm-asking'),
            // Losing focus (nothing inside the confirm is focused any more) cancels.
            onFocusChange: (focused) {
              if (!focused) _set(false);
            },
            onKeyEvent: (_, event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
                _set(false);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: SizedBox(
              height: suiteControlHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(m('areYouSure'), style: TextStyle(color: color)),
                  TextButton(
                    key: const ValueKey('inline-confirm-yes'),
                    style: style,
                    onPressed: () {
                      _set(false);
                      widget.onConfirm();
                    },
                    child: Text(m('yes')),
                  ),
                  TextButton(
                    key: const ValueKey('inline-confirm-no'),
                    style: style,
                    autofocus: true,
                    onPressed: () => _set(false),
                    child: Text(m('no')),
                  ),
                ],
              ),
            ),
          )
        : KeyedSubtree(
            key: const ValueKey('inline-confirm-idle'),
            child: widget.builder(context, () => _set(true)),
          );
    return AnimatedSwitcher(
      duration: SuiteAnimationScope.of(context),
      child: content,
    );
  }
}
