import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/suite_theme.dart';

/// Opens a Material dialog with the shared popup motion.
Future<T?> showSuiteDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useSafeArea = true,
  bool animate = true,
}) {
  final animatePopup = animate && !MediaQuery.disableAnimationsOf(context);
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useSafeArea: useSafeArea,
    animationStyle: animatePopup
        ? const AnimationStyle(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          )
        : AnimationStyle.noAnimation,
    builder: (context) {
      final width = MediaQuery.sizeOf(context).width;
      final theme = Theme.of(context);
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
          : builder(context);
      final transition = ModalRoute.of(context)?.animation;
      if (!animate || transition == null) return child;
      return AnimatedBuilder(
        animation: transition,
        child: child,
        builder: (context, child) {
          final progress = animatePopup
              ? Curves.easeOut.transform(transition.value)
              : 1.0;
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
              Transform.scale(scale: 0.96 + 0.04 * progress, child: child),
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
