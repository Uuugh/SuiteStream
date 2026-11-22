import 'package:flutter/material.dart';

/// A popup is never resized once it is drawn. This measures [child] the first time it is
/// laid out and then holds the popup at that height: anything that would make it
/// taller (an error line, another row) scrolls inside it instead, and a field that
/// is not needed is hidden, not removed, so the rest stays where it is. If the
/// window is shorter than the popup, the popup shrinks to fit and scrolls.
class PopupSizeLock extends StatefulWidget {
  const PopupSizeLock({super.key, required this.child});

  final Widget child;

  @override
  State<PopupSizeLock> createState() => _PopupSizeLockState();
}

class _PopupSizeLockState extends State<PopupSizeLock> {
  final GlobalKey _content = GlobalKey();
  double? _height;

  /// Forget the held height: the next draw is the natural size, which is then held.
  void _relock() {
    if (mounted) setState(() => _height = null);
  }

  void _measure() {
    final box = _content.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !mounted) return;
    if (_height != box.size.height) setState(() => _height = box.size.height);
  }

  @override
  Widget build(BuildContext context) {
    final content = KeyedSubtree(key: _content, child: widget.child);
    if (_height == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
      // First draw: the natural size, which is then kept.
      return Column(mainAxisSize: MainAxisSize.min, children: [content]);
    }
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight.isFinite && box.maxHeight < _height! ? box.maxHeight : _height!;
        return SizedBox(
          key: const ValueKey('popup-locked'),
          height: h,
          child: SingleChildScrollView(child: content),
        );
      },
    );
  }
}

/// Lets the popup grow or shrink once, on purpose: adding or removing a row of
/// things the user lists (a reminder) changes the popup's size, and it is measured
/// again and held at that size. Call it right after the rows change.
void relockPopupSize(BuildContext context) {
  context.findAncestorStateOfType<_PopupSizeLockState>()?._relock();
}
