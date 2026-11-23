import 'package:flutter/material.dart';

import '../theme/suite_theme.dart';

/// Places a decorative badge over an aligned point of a control.
///
/// The control supplies the accessible label. [offset] is expressed as a
/// fraction of the control's width and height.
class AnchoredBadge extends StatelessWidget {
  const AnchoredBadge({
    super.key,
    required this.child,
    required this.badge,
    this.anchor = suiteBadgeAnchor,
    this.offset = suiteBadgeOffset,
  });

  final Widget child;
  final Widget badge;
  final Alignment anchor;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, bounds) => IgnorePointer(
              child: ExcludeSemantics(
                child: Align(
                  alignment: anchor,
                  child: Transform.translate(
                    offset: Offset(
                      bounds.maxWidth * offset.dx,
                      bounds.maxHeight * offset.dy,
                    ),
                    child: badge,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
