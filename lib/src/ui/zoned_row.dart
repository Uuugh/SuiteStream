import 'package:flutter/material.dart';

import '../theme/suite_theme.dart';

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
    this.padding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: suitePartGap,
    ),
  });

  final List<Widget> left;
  final List<Widget> center;
  final List<Widget> right;
  final double leftMinWidth;
  final double centerMinWidth;
  final double rightMinWidth;
  final EdgeInsets padding;

  Widget _zone(
    Key key,
    List<Widget> children,
    double minWidth, {
    bool reverseScroll = false,
  }) => LayoutBuilder(
    builder: (context, box) {
      final row = Row(
        textDirection: TextDirection.ltr,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
      final needsFlex = children.any((child) => child is Flexible);
      // Give flexible labels a real width so their ellipsis can take effect.
      final compressedWidth = minWidth * 0.8;
      final width = box.maxWidth < compressedWidth
          ? compressedWidth
          : box.maxWidth;
      return SingleChildScrollView(
        key: key,
        scrollDirection: Axis.horizontal,
        reverse: reverseScroll,
        child: needsFlex && width.isFinite
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width),
                child: row,
              )
            : row,
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final outsideWidth = leftMinWidth > rightMinWidth
            ? leftMinWidth
            : rightMinWidth;
        final needed = centerMinWidth + 2 * outsideWidth + padding.horizontal;
        final fits = box.maxWidth >= needed;
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final l = _zone(
          const ValueKey('zone-left'),
          left,
          leftMinWidth,
          reverseScroll: isRtl,
        );
        final c = _zone(const ValueKey('zone-center'), center, centerMinWidth);
        final r = _zone(
          const ValueKey('zone-right'),
          right,
          rightMinWidth,
          reverseScroll: !isRtl,
        );
        if (fits) {
          return Padding(
            padding: padding,
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: Align(alignment: Alignment.centerLeft, child: l),
                ),
                if (center.isNotEmpty) c,
                Expanded(
                  child: Align(alignment: Alignment.centerRight, child: r),
                ),
              ],
            ),
          );
        }
        // Too narrow: left on top, then center, then right, each keeping its alignment.
        return Padding(
          padding: padding,
          child: Column(
            key: const ValueKey('zones-stacked'),
            spacing: suiteStackedZoneGap,
            children: [
              if (left.isNotEmpty)
                Align(alignment: Alignment.centerLeft, child: l),
              if (center.isNotEmpty)
                Align(alignment: Alignment.center, child: c),
              if (right.isNotEmpty)
                Align(alignment: Alignment.centerRight, child: r),
            ],
          ),
        );
      },
    );
  }
}
