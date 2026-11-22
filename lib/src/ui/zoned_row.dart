import 'package:flutter/material.dart';

/// UIC-14: every row of controls (a section's header, for one) has a left, a
/// center and a right zone. Their contents are aligned left, centered and right by
/// default, and each zone keeps its own alignment. The feature says what goes in
/// each zone and in what order.
///
/// A row that is too narrow stacks its zones: left on top, then center, then
/// right. [leftMinWidth], [centerMinWidth] and [rightMinWidth] say how much room
/// each zone needs to be on the one line.
class ZonedRow extends StatelessWidget {
  const ZonedRow({
    super.key,
    this.left = const [],
    this.center = const [],
    this.right = const [],
    this.leftMinWidth = 0,
    this.centerMinWidth = 0,
    this.rightMinWidth = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  final List<Widget> left;
  final List<Widget> center;
  final List<Widget> right;
  final double leftMinWidth;
  final double centerMinWidth;
  final double rightMinWidth;
  final EdgeInsets padding;

  Widget _zone(Key key, List<Widget> children, MainAxisAlignment align) =>
      Row(key: key, mainAxisSize: MainAxisSize.min, mainAxisAlignment: align, children: children);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final needed = leftMinWidth + centerMinWidth + rightMinWidth + padding.horizontal;
      final fits = box.maxWidth >= needed;
      final l = _zone(const ValueKey('zone-left'), left, MainAxisAlignment.start);
      final c = _zone(const ValueKey('zone-center'), center, MainAxisAlignment.center);
      final r = _zone(const ValueKey('zone-right'), right, MainAxisAlignment.end);
      if (fits) {
        return Padding(
          padding: padding,
          child: Row(
            children: [
              Expanded(child: Align(alignment: Alignment.centerLeft, child: l)),
              if (center.isNotEmpty) c,
              Expanded(child: Align(alignment: Alignment.centerRight, child: r)),
            ],
          ),
        );
      }
      // Too narrow: left on top, then center, then right, each keeping its alignment.
      return Padding(
        padding: padding,
        child: Column(
          key: const ValueKey('zones-stacked'),
          children: [
            if (left.isNotEmpty) Align(alignment: Alignment.centerLeft, child: l),
            if (center.isNotEmpty) Align(alignment: Alignment.center, child: c),
            if (right.isNotEmpty) Align(alignment: Alignment.centerRight, child: r),
          ],
        ),
      );
    });
  }
}
