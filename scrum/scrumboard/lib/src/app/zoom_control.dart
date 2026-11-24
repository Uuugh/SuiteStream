import 'package:flutter/material.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// SCB-20, SCB-20.a: the one zoom icon. A magnifier with a minus as subscript
/// (lower left) and a plus as superscript (upper right); no Material icon has
/// this, so it is drawn. The left half is the zoom-out hit area (key
/// `scbZoomOut`, msg:scbZoomOut) and the right half the zoom-in one (key
/// `scbZoomIn`, msg:scbZoomIn). A half at its limit is disabled and drawn in
/// the disabled color; the other half still works.
class ScbZoomControl extends StatelessWidget {
  const ScbZoomControl({super.key, required this.zoomPercent, this.onZoomChanged});

  final int zoomPercent;
  final ValueChanged<int>? onZoomChanged;

  @override
  Widget build(BuildContext context) {
    final onZoom = onZoomChanged;
    final canOut = onZoom != null && zoomPercent > scrumZoomMin;
    final canIn = onZoom != null && zoomPercent < scrumZoomMax;
    final scheme = Theme.of(context).colorScheme;
    final on = IconTheme.of(context).color ?? scheme.onSurfaceVariant;
    final off = scheme.onSurface.withValues(alpha: 0.38);
    return SizedBox(
      key: const ValueKey('scbZoom'),
      width: scrumZoomIconWidth,
      height: scrumZoomIconHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ZoomGlyphPainter(
                glass: canOut || canIn ? on : off,
                minus: canOut ? on : off,
                plus: canIn ? on : off,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _Half(
                  hitKey: const ValueKey('scbZoomOut'),
                  label: context.msg('scbZoomOut'),
                  onTap: canOut ? () => onZoom(zoomPercent - scrumZoomStep) : null,
                ),
              ),
              Expanded(
                child: _Half(
                  hitKey: const ValueKey('scbZoomIn'),
                  label: context.msg('scbZoomIn'),
                  onTap: canIn ? () => onZoom(zoomPercent + scrumZoomStep) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Half extends StatelessWidget {
  const _Half({required this.hitKey, required this.label, required this.onTap});

  final Key hitKey;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: label,
        child: Semantics(
          button: true,
          enabled: onTap != null,
          child: InkWell(
            key: hitKey,
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const SizedBox.expand(),
          ),
        ),
      );
}

/// Draws the magnifier in the middle, the minus at the lower left and the plus
/// at the upper right.
class _ZoomGlyphPainter extends CustomPainter {
  const _ZoomGlyphPainter({required this.glass, required this.minus, required this.plus});

  final Color glass;
  final Color minus;
  final Color plus;

  Paint _pen(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = scrumZoomStroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const r = scrumZoomGlyphSize * 0.3;
    final lens = center.translate(-scrumZoomStroke, -scrumZoomStroke);
    canvas.drawCircle(lens, r, _pen(glass));
    const handle = r * 0.72;
    canvas.drawLine(
      lens.translate(handle, handle),
      lens.translate(handle + r * 0.75, handle + r * 0.75),
      _pen(glass),
    );
    const half = scrumZoomMarkSize / 2;
    final m = Offset(half + scrumZoomStroke, size.height - half - scrumZoomStroke);
    canvas.drawLine(m.translate(-half, 0), m.translate(half, 0), _pen(minus));
    final p = Offset(size.width - half - scrumZoomStroke, half + scrumZoomStroke);
    canvas.drawLine(p.translate(-half, 0), p.translate(half, 0), _pen(plus));
    canvas.drawLine(p.translate(0, -half), p.translate(0, half), _pen(plus));
  }

  @override
  bool shouldRepaint(_ZoomGlyphPainter old) =>
      old.glass != glass || old.minus != minus || old.plus != plus;
}
