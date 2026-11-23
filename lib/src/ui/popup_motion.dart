import 'package:flutter/material.dart';

import 'package:suitestream/src/theme/suite_theme.dart';

/// UIC-47: the scale a popup starts from (and returns to on close).
const double suitePopupStartScale = 0.96;

/// UIC-47: the one transition curve of every popup.
const Curve suitePopupCurve = Curves.easeOut;

/// UIC-47: the one popup time: the animation time from Settings (SET-03.g), zero with
/// reduced motion.
Duration suitePopupDuration(BuildContext context) => SuiteAnimationScope.of(context);

/// UIC-47: the animation style for Flutter's own popups (`showDialog`, `showMenu`,
/// `PopupMenuButton.popUpAnimationStyle`, `showModalBottomSheet`): one time both ways, no
/// animation when the time is zero.
AnimationStyle suitePopupAnimationStyle(BuildContext context) {
  final time = suitePopupDuration(context);
  if (time == Duration.zero) return AnimationStyle.noAnimation;
  return AnimationStyle(
    duration: time,
    reverseDuration: time,
    curve: suitePopupCurve,
    reverseCurve: suitePopupCurve,
  );
}

/// The fade and the scale of a popup at [progress] (0 closed, 1 open).
Widget suitePopupTransition(double progress, Widget child) {
  final eased = suitePopupCurve.transform(progress.clamp(0.0, 1.0));
  return Opacity(
    opacity: eased,
    child: Transform.scale(scale: suitePopupStartScale + (1 - suitePopupStartScale) * eased, child: child),
  );
}

/// UIC-47: animates a popup that is built by an overlay (a dropdown, a menu anchor) in
/// and out. It fades and scales in over [suitePopupDuration] when first built. When
/// [open] turns false it runs back and then calls [onClosed] (at once with a zero time),
/// so the owner removes the popup only then.
class SuitePopupMotion extends StatefulWidget {
  const SuitePopupMotion({super.key, this.open = true, this.onClosed, required this.child});

  final bool open;
  final VoidCallback? onClosed;
  final Widget child;

  @override
  State<SuitePopupMotion> createState() => _SuitePopupMotionState();
}

class _SuitePopupMotionState extends State<SuitePopupMotion> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = suitePopupDuration(context);
    if (!_started) {
      _started = true;
      if (_controller.duration == Duration.zero) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void didUpdateWidget(SuitePopupMotion old) {
    super.didUpdateWidget(old);
    if (old.open && !widget.open) {
      if (_controller.duration == Duration.zero) {
        widget.onClosed?.call();
      } else {
        _controller.reverse().whenCompleteOrCancel(() {
          if (mounted && !widget.open) widget.onClosed?.call();
        });
      }
    } else if (!old.open && widget.open) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) => suitePopupTransition(_controller.value, child!),
  );
}
