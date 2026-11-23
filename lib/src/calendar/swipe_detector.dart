import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// DEF-01: a swipe that turns the page is at least this many px sideways and
/// at least 1.5 times its height.
const double swipeMinDistance = 50;
const double swipeSidewaysRatio = 1.5;

/// CAL-01.j: on a touch screen a horizontal swipe turns the page (left: next,
/// right: previous); a vertical swipe still scrolls. A swipe with more than one
/// finger is ignored.
class SwipeDetector extends StatefulWidget {
  const SwipeDetector({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.child,
    required this.holdTime,
  });

  /// A press held still this long before it moves is a long-press drag (CAL-03.a),
  /// not a swipe.
  final Duration holdTime;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Widget child;

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector> {
  final Map<int, Offset> _start = {};
  int _mostFingers = 0;
  bool _touch = true;
  Offset _delta = Offset.zero;
  int? _tracked;
  Timer? _hold;
  bool _held = false;
  bool _moved = false;

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        if (_start.isEmpty) {
          _mostFingers = 0;
          _touch = true;
          _delta = Offset.zero;
          _tracked = e.pointer;
          _held = false;
          _moved = false;
          _hold?.cancel();
          _hold = Timer(widget.holdTime, () => _held = !_moved);
        }
        _start[e.pointer] = e.position;
        _mostFingers = _start.length > _mostFingers ? _start.length : _mostFingers;
        if (e.kind != PointerDeviceKind.touch) _touch = false;
      },
      onPointerMove: (e) {
        if (e.pointer == _tracked) {
          _delta = e.position - _start[e.pointer]!;
          if (_delta.distance > 18) _moved = true;
        }
      },
      onPointerUp: (e) {
        if (e.pointer == _tracked) _delta = e.position - _start[e.pointer]!;
        _start.remove(e.pointer);
        if (_start.isNotEmpty) return;
        _hold?.cancel();
        final dx = _delta.dx;
        final dy = _delta.dy;
        final counts = _touch &&
            !_held &&
            _mostFingers == 1 &&
            dx.abs() >= swipeMinDistance &&
            dx.abs() >= swipeSidewaysRatio * dy.abs();
        if (counts) {
          if (dx < 0) {
            widget.onNext();
          } else {
            widget.onPrevious();
          }
        }
      },
      onPointerCancel: (e) {
        _start.remove(e.pointer);
        _hold?.cancel();
      },
      child: widget.child,
    );
  }
}
