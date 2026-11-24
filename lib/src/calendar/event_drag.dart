import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/zones.dart';

/// DEF-01: the drag step in Week and Day is 15 minutes.
const int dragStepMinutes = 15;

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
              // A token elevation: no blur shadow and no Opacity layer, so the first lift
              // compiles no extra shader (PBI-058).
              color: Colors.transparent,
              elevation: suitePopupElevation,
              shadowColor: Theme.of(context).colorScheme.shadow,
              child: widget.child,
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

/// CAL-12: the end of [e] moved to [endMinute] (minutes of [day] in [zone], up to 24 * 60);
/// the start, the zones and every other field stay as they were.
SuiteEvent resizeEventEnd(SuiteEvent e, Location zone, {required DateTime day, required int endMinute}) {
  final newEnd = TZDateTime(zone, day.year, day.month, day.day, endMinute ~/ 60, endMinute % 60);
  return e.copyWith(endUtc: newEnd.toUtc(), edited: !e.custom ? true : e.edited);
}

/// CAL-12.f: the end minute a drag of [deltaMinutes] gives an event that starts at [startMinute]
/// and ended at [endMinute] (minutes of the day shown): snapped to the drag step, at least one
/// drag step after the start, and not past the end of the day.
int resizedEndMinute({required int startMinute, required int endMinute, required num deltaMinutes}) {
  final earliest = ((startMinute + dragStepMinutes) / dragStepMinutes).ceil() * dragStepMinutes;
  return snapToDragStep(endMinute + deltaMinutes).clamp(earliest, 24 * 60);
}

/// CAL-12: the resize handle on the bottom edge of an event. A vertical drag (mouse or touch)
/// reports its distance through [onPreview] (null when it ends or is cancelled) and, on release,
/// through [onResized]; Escape during the drag cancels it (CAL-12.d). It is a separate target
/// above the event, so a drag from it never starts the press-and-hold move (CAL-12.e).
class ResizeHandle extends StatefulWidget {
  const ResizeHandle({super.key, required this.onPreview, required this.onResized, required this.color});

  final ValueChanged<double?> onPreview;
  final ValueChanged<double> onResized;

  /// The color of the grip mark (readable on the event's fill).
  final Color color;

  @override
  State<ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<ResizeHandle> {
  double _dy = 0;
  bool _active = false;

  bool _onKey(KeyEvent e) {
    if (_active && e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.escape) {
      _finish(apply: false);
      return true;
    }
    return false;
  }

  void _start(DragStartDetails d) {
    _active = true;
    _dy = 0;
    HardwareKeyboard.instance.addHandler(_onKey);
    widget.onPreview(0);
  }

  void _update(DragUpdateDetails d) {
    if (!_active) return;
    _dy += d.delta.dy;
    widget.onPreview(_dy);
  }

  void _finish({required bool apply}) {
    if (!_active) return;
    _active = false;
    HardwareKeyboard.instance.removeHandler(_onKey);
    widget.onPreview(null);
    if (apply) widget.onResized(_dy);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down, // the distance counts from the press, not from the touch slop
        onVerticalDragStart: _start,
        onVerticalDragUpdate: _update,
        onVerticalDragEnd: (_) => _finish(apply: true),
        onVerticalDragCancel: () => _finish(apply: false),
        child: Center(
          child: Container(
            width: suiteResizeBarSize.width,
            height: suiteResizeBarSize.height / 4,
            decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(suiteResizeBarSize.height / 8)),
          ),
        ),
      ),
    );
  }
}
