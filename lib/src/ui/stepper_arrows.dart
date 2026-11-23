import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/suite_icons.dart';
import '../theme/tokens.dart';

/// Every time or number text field offers up and down arrows that step its value:
/// two small arrows stacked at the field's right end ([StepperArrows], used as the
/// field's suffix) and the Up and Down keys while the field is focused
/// ([ArrowKeyStepper]).
class StepperArrows extends StatelessWidget {
  const StepperArrows({super.key, required this.onUp, required this.onDown, this.upKey, this.downKey});

  final VoidCallback onUp;
  final VoidCallback onDown;
  final Key? upKey;
  final Key? downKey;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget arrow(Key? key, IconData icon, VoidCallback onTap) => InkWell(
          key: key,
          onTap: onTap,
          child: SizedBox(width: 26, height: 16, child: Icon(icon, size: 18, color: t.muted)),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        arrow(upKey, SuiteIcons.keyboardArrowUp, onUp),
        arrow(downKey, SuiteIcons.keyboardArrowDown, onDown),
      ],
    );
  }
}

/// The Up and Down keys step the focused field, as the arrows do.
class ArrowKeyStepper extends StatelessWidget {
  const ArrowKeyStepper({super.key, required this.onUp, required this.onDown, required this.child});

  final VoidCallback onUp;
  final VoidCallback onDown;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyUpEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          onUp();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          onDown();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
