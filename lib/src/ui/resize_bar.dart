import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/theme/suite_theme.dart';

/// A keyboard- and pointer-operable resize handle in feature-defined units.
class ResizeBar extends StatefulWidget {
  const ResizeBar({
    super.key,
    required this.value,
    required this.minimum,
    required this.unitExtent,
    required this.onChanged,
    required this.expanded,
    required this.onToggle,
    required this.sliderLabel,
    required this.collapseLabel,
    required this.expandLabel,
  }) : assert(unitExtent > 0);

  final int value;
  final int minimum;
  final double unitExtent;
  final ValueChanged<int> onChanged;
  final bool expanded;
  final VoidCallback onToggle;
  final String sliderLabel;
  final String collapseLabel;
  final String expandLabel;

  @override
  State<ResizeBar> createState() => _ResizeBarState();
}

class _ResizeBarState extends State<ResizeBar> {
  final _focusNode = FocusNode();
  late int _dragStartValue;
  late double _dragStartY;
  late int _lastDragValue;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final next = math.max(widget.minimum, widget.value + delta);
    if (next != widget.value) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canDecrease = widget.value > widget.minimum;
    final toggleLabel = widget.expanded
        ? widget.collapseLabel
        : widget.expandLabel;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: [
        const SizedBox(width: 48),
        Semantics(
          label: widget.sliderLabel,
          slider: true,
          value: '${widget.value}',
          increasedValue: '${widget.value + 1}',
          decreasedValue: canDecrease ? '${widget.value - 1}' : null,
          onIncrease: () => _step(1),
          onDecrease: canDecrease ? () => _step(-1) : null,
          child: Focus(
            focusNode: _focusNode,
            onFocusChange: (_) => setState(() {}),
            onKeyEvent: (_, event) {
              if (event is KeyUpEvent) return KeyEventResult.ignored;
              switch (event.logicalKey) {
                case LogicalKeyboardKey.arrowUp:
                  _step(-1);
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.arrowDown:
                  _step(1);
                  return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeUpDown,
              child: GestureDetector(
                excludeFromSemantics: true,
                behavior: HitTestBehavior.opaque,
                onTap: _focusNode.requestFocus,
                dragStartBehavior: DragStartBehavior.down,
                onVerticalDragStart: (details) {
                  _focusNode.requestFocus();
                  _dragStartValue = widget.value;
                  _lastDragValue = widget.value;
                  _dragStartY = details.globalPosition.dy;
                },
                onVerticalDragUpdate: (details) {
                  final delta = details.globalPosition.dy - _dragStartY;
                  final next = math.max(
                    widget.minimum,
                    _dragStartValue + (delta / widget.unitExtent).round(),
                  );
                  if (next == _lastDragValue) return;
                  _lastDragValue = next;
                  widget.onChanged(next);
                },
                child: Container(
                  width: 48,
                  height: suiteControlHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(suiteControlRadius),
                    border: _focusNode.hasFocus
                        ? Border.all(color: scheme.primary, width: 2)
                        : null,
                  ),
                  child: CustomPaint(
                    size: suiteResizeBarSize,
                    painter: _GripPainter(scheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Center(
            child: IconButton(
              style: suiteIconButtonStyle(),
              tooltip: toggleLabel,
              onPressed: widget.onToggle,
              icon: AnimatedRotation(
                turns: widget.expanded ? 0 : 0.5,
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 150),
                child: const Icon(SuiteIcons.keyboardArrowUp),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GripPainter extends CustomPainter {
  const _GripPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var column = 0; column < 6; column++) {
      for (var row = 0; row < 2; row++) {
        canvas.drawCircle(Offset(2 + column * 5, 2 + row * 4), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GripPainter oldDelegate) => oldDelegate.color != color;
}
