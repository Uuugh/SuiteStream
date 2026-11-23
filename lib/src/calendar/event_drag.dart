import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../time/suite_event.dart';
import '../time/zones.dart';

/// DEF-01: the drag step in Week and Day is 15 minutes.
const int dragStepMinutes = 15;

/// DEF-01: the long-press time is 0.3 seconds (0.2 to 1.5 seconds, a device setting).
const Duration defaultLongPress = Duration(milliseconds: 300);
const Duration minLongPress = Duration(milliseconds: 200);
const Duration maxLongPress = Duration(milliseconds: 1500);

/// CAL-03.d: the long-press time stays within the limits in DEF-01.
Duration clampLongPress(Duration d) => d < minLongPress ? minLongPress : (d > maxLongPress ? maxLongPress : d);

/// CAL-03.b: snaps a minute of the day to the drag step in DEF-01.
int snapToDragStep(num minutes) => ((minutes / dragStepMinutes).round() * dragStepMinutes).toInt();

/// CAL-03.a: an event that can be edited can be moved. A deleted event cannot.
bool canMove(SuiteEvent e) => !e.deleted;

/// Moves [e] so that, seen in [zone], it starts on [day] at [minuteOfDay] (or at
/// its own time of day when null); the length and the recorded zones are kept.
SuiteEvent moveEvent(SuiteEvent e, Location zone, {required DateTime day, int? minuteOfDay}) {
  final s = e.startIn(zone);
  final minutes = minuteOfDay ?? (s.hour * 60 + s.minute);
  final newStart = TZDateTime(zone, day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
  final length = e.endUtc.difference(e.startUtc);
  return e.copyWith(
    startUtc: newStart.toUtc(),
    endUtc: newStart.toUtc().add(length),
    edited: !e.custom ? true : e.edited,
  );
}

/// CAL-03.a: a press that is held for the long-press time and then dragged moves
/// an event; a quick press is still a tap. While it is dragged the event follows
/// the pointer (a lifted copy) and the original is dimmed, so the user sees it move;
/// [onPreview] reports how far it has travelled so the view can show where it
/// would land, and [onMoved] gets the final distance when it is released.
class DragMovable extends StatefulWidget {
  const DragMovable({
    super.key,
    required this.child,
    required this.longPress,
    required this.onMoved,
    required this.onTap,
    this.onPreview,
    this.enabled = true,
  });

  final Widget child;
  final Duration longPress;
  final ValueChanged<Offset> onMoved;

  /// Called with the distance travelled while dragging, and with null when the drag ends.
  final ValueChanged<Offset?>? onPreview;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<DragMovable> createState() => _DragMovableState();
}

class _DragMovableState extends State<DragMovable> {
  Offset _origin = Offset.zero;
  OverlayEntry? _ghost;
  Offset _topLeft = Offset.zero;
  Size _size = Size.zero;
  final ValueNotifier<Offset> _delta = ValueNotifier(Offset.zero);
  bool _dragging = false;

  void _start(LongPressStartDetails d) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    _origin = d.globalPosition;
    _topLeft = box.localToGlobal(Offset.zero);
    _size = box.size;
    _delta.value = Offset.zero;
    setState(() => _dragging = true);
    _ghost = OverlayEntry(
      builder: (_) => ValueListenableBuilder<Offset>(
        valueListenable: _delta,
        builder: (_, delta, _) => Positioned(
          left: _topLeft.dx + delta.dx,
          top: _topLeft.dy + delta.dy,
          width: _size.width,
          height: _size.height,
          child: IgnorePointer(
            child: Material(
              key: const ValueKey('drag-ghost'),
              type: MaterialType.transparency,
              child: Opacity(
                opacity: 0.9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_ghost!);
    widget.onPreview?.call(Offset.zero);
  }

  void _update(LongPressMoveUpdateDetails d) {
    _delta.value = d.globalPosition - _origin;
    widget.onPreview?.call(_delta.value);
  }

  void _end(Offset delta, {required bool apply}) {
    _ghost?.remove();
    _ghost = null;
    widget.onPreview?.call(null);
    if (mounted) setState(() => _dragging = false);
    if (apply) widget.onMoved(delta);
  }

  @override
  void dispose() {
    _ghost?.remove();
    _delta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      // A new long-press time needs new recognizers (the duration is fixed when one is made).
      key: ValueKey(widget.longPress),
      behavior: HitTestBehavior.opaque,
      gestures: {
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          TapGestureRecognizer.new,
          (t) => t.onTap = widget.onTap,
        ),
        if (widget.enabled)
          LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(duration: widget.longPress),
            (l) {
              l.onLongPressStart = _start;
              l.onLongPressMoveUpdate = _update;
              l.onLongPressEnd = (d) => _end(d.globalPosition - _origin, apply: true);
              l.onLongPressCancel = () => _end(Offset.zero, apply: false);
            },
          ),
      },
      // The original stays in place, dimmed, while its copy is dragged.
      child: Opacity(opacity: _dragging ? 0.35 : 1, child: widget.child),
    );
  }
}
