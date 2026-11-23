import 'package:flutter/material.dart';

import 'package:suitestream/src/theme/suite_theme.dart';

/// UIC-46: the one Reset look. A text button in the theme's error role (the same
/// role as the trash and remove controls): error color for text and icon, the error
/// container as the hover and focus fill, the one control height.
ButtonStyle suiteResetButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return TextButton.styleFrom(
    foregroundColor: scheme.error,
    iconColor: scheme.error,
    minimumSize: const Size(0, suiteControlHeight),
    padding: const EdgeInsets.symmetric(horizontal: suiteDialogPadding),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(suiteControlRadius))),
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith(
      (states) => states.any({WidgetState.hovered, WidgetState.focused, WidgetState.pressed}.contains)
          ? scheme.errorContainer
          : null,
    ),
  );
}

/// UIC-46: every Reset button in the app. [label] is the message text (an arb key
/// resolved by the caller).
class ResetButton extends StatelessWidget {
  const ResetButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      TextButton(style: suiteResetButtonStyle(context), onPressed: onPressed, child: Text(label));
}
