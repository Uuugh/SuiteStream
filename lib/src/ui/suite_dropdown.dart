import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// The trigger is an icon button: a 48 px target with a 24 px icon centered in it.
const double triggerIconSize = 24;
const double triggerIconInset = 12;

/// One item of a [SuiteDropdown].
class DropdownItem<T> {
  const DropdownItem({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

/// UIC-12: the one shared dropdown. It opens from a single icon. The feature
/// says whether it selects one item ([multi] false) or several. A single click
/// or tap chooses or toggles an item and takes effect at once (UIC-13); where
/// several can be selected, Ctrl and Shift select several on a keyboard (Ctrl
/// toggles an item, Shift selects the range from the last item chosen).
/// Choosing outside the dropdown (losing focus) closes it.
class SuiteDropdown<T> extends StatefulWidget {
  const SuiteDropdown({
    super.key,
    required this.icon,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.multi = false,
    this.tooltip,
  });

  final IconData icon;
  final List<DropdownItem<T>> items;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final bool multi;
  final String? tooltip;

  @override
  State<SuiteDropdown<T>> createState() => _SuiteDropdownState<T>();
}

class _SuiteDropdownState<T> extends State<SuiteDropdown<T>> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  int? _anchor;

  void _toggleOpen() => _portal.toggle();

  void _choose(int index) {
    final item = widget.items[index];
    final keys = HardwareKeyboard.instance;
    if (!widget.multi) {
      widget.onChanged({item.value});
      _portal.hide(); // a single choice closes the menu
      return;
    }
    final next = {...widget.selected};
    if (keys.isShiftPressed && _anchor != null) {
      final lo = _anchor! < index ? _anchor! : index;
      final hi = _anchor! < index ? index : _anchor!;
      for (var i = lo; i <= hi; i++) {
        next.add(widget.items[i].value);
      }
    } else if (!next.remove(item.value)) {
      next.add(item.value);
    }
    _anchor = index;
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          child: Align(
            alignment: Alignment.topLeft,
            child: TapRegion(
              onTapOutside: (_) => _portal.hide(),
              child: Focus(
                autofocus: true,
                onFocusChange: (focused) {
                  if (!focused) _portal.hide();
                },
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
                    _portal.hide();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Material(
                  color: t.card,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: t.line),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 140),
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < widget.items.length; i++) _row(context, i),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: IconButton(
          tooltip: widget.tooltip,
          icon: Icon(widget.icon, size: triggerIconSize),
          onPressed: _toggleOpen,
        ),
      ),
    );
  }

  Widget _row(BuildContext context, int i) {
    final t = context.tokens;
    final item = widget.items[i];
    final selected = widget.selected.contains(item.value);
    return InkWell(
      key: ValueKey('dropdown-item-${item.value}'),
      onTap: () => _choose(i),
      child: Container(
        height: 40,
        // The menu hangs from the trigger's left edge, and the trigger's icon sits
        // [triggerIconInset] inside it, so every item icon (same size) lines up
        // vertically with the trigger icon.
        padding: const EdgeInsets.only(left: triggerIconInset, right: 12),
        color: selected ? t.soft : null,
        child: Row(
          children: [
            if (item.icon != null) ...[Icon(item.icon, size: triggerIconSize), const SizedBox(width: 12)],
            Expanded(child: Text(item.label)),
            if (selected) Icon(Icons.check, size: 18, color: t.accent, semanticLabel: 'selected'),
          ],
        ),
      ),
    );
  }
}
