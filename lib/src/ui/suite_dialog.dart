import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/ui/popup_motion.dart';

/// UIC-47: opens a Material dialog with the shared popup transition (fade, scale from 96 %,
/// backdrop blur) over the one animation time (SET-03.g); no motion with reduced motion or a
/// zero time. Every dialog in the app opens through this.
Future<T?> showSuiteDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useSafeArea = true,
  bool animate = true,
}) {
  final animatePopup = animate && suitePopupDuration(context) > Duration.zero;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useSafeArea: useSafeArea,
    animationStyle: animatePopup ? suitePopupAnimationStyle(context) : AnimationStyle.noAnimation,
    builder: (context) {
      final width = MediaQuery.sizeOf(context).width;
      // UIC-43: the popup shadow, scaled by the Popup shadow setting.
      final theme = Theme.of(context).copyWith(
        dialogTheme: popupDialogTheme(context, Theme.of(context).dialogTheme),
      );
      final child = width <= phoneMaxWidth
          ? Theme(
              data: theme.copyWith(
                dialogTheme: theme.dialogTheme.copyWith(
                  constraints: BoxConstraints(minWidth: width),
                  insetPadding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(),
                ),
              ),
              child: Builder(builder: builder),
            )
          : Theme(data: theme, child: Builder(builder: builder));
      final transition = ModalRoute.of(context)?.animation;
      if (!animate || transition == null) return child;
      return AnimatedBuilder(
        animation: transition,
        child: child,
        builder: (context, child) {
          final progress = animatePopup ? suitePopupCurve.transform(transition.value) : 1.0;
          final sigma = 2 * progress;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (sigma > 0)
                IgnorePointer(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              Transform.scale(scale: suitePopupStartScale + (1 - suitePopupStartScale) * progress, child: child),
            ],
          );
        },
      );
    },
  );
}

/// An alert-style dialog with the theme's padding (not Material's 24 px defaults), so
/// every dialog keeps the same rhythm and its action pair sits at the bottom right.
class SuiteAlertDialog extends StatelessWidget {
  const SuiteAlertDialog({super.key, this.title, required this.content, this.actions});

  final Widget? title;
  final Widget content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: actions,
      titlePadding: const EdgeInsets.fromLTRB(
        suiteDialogPadding,
        suiteDialogPadding,
        suiteDialogPadding,
        suitePartGap,
      ),
      contentPadding: title == null
          ? const EdgeInsets.all(suiteDialogPadding)
          : const EdgeInsets.fromLTRB(
              suiteDialogPadding,
              0,
              suiteDialogPadding,
              suiteDialogPadding,
            ),
      actionsPadding: const EdgeInsets.fromLTRB(
        suiteDialogPadding,
        0,
        suiteDialogPadding,
        suiteDialogPadding,
      ),
      actionsAlignment: MainAxisAlignment.end,
      buttonPadding: EdgeInsets.zero,
    );
  }
}
