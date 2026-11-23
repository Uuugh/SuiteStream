import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/suite_icons.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';

/// The trigger is an icon button: a 48 px target with a 24 px icon centered in it.
const double triggerIconSize = 24;
const double triggerIconInset = suiteDialogPadding;

/// One item of a [SuiteDropdown].
class DropdownItem<T> {
  const DropdownItem({required this.value, required this.label, this.icon, this.leading});
  final T value;
  final String label;
  final IconData? icon;

  /// A widget shown where the icon goes (for example a color swatch); it is
  /// [triggerIconSize] wide so it lines up with the trigger icon.
  final Widget? leading;
}

/// A command at the top of a dropdown (for example Select all); it does not close the menu.
class DropdownAction {
  const DropdownAction({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
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
    this.active = false,
    this.actions = const [],
  });

  final IconData icon;
  final List<DropdownItem<T>> items;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final bool multi;
  final String? tooltip;

  /// UIC-21: shown in the accent color when a filter is active.
  final bool active;

  /// Commands above the items (UIC-21: Select all, Select none).
  final List<DropdownAction> actions;

  @override
  State<SuiteDropdown<T>> createState() => _SuiteDropdownState<T>();
}

class _SuiteDropdownState<T> extends State<SuiteDropdown<T>> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  int? _anchor;

  double _maxMenuWidth = 480;

  void _toggleOpen() {
    if (!_portal.isShowing) {
      // The menu hangs from the trigger's left edge; it is never wider than the room to the
      // right of it (long labels wrap), so it always fits in the window.
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final left = box.localToGlobal(Offset.zero).dx;
        _maxMenuWidth = (MediaQuery.sizeOf(context).width - left - 8).clamp(140.0, 480.0);
      }
    }
    _portal.toggle();
  }

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
          offset: const Offset(-(triggerIconInset - (suiteControlHeight - triggerIconSize) / 2), 0),
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
                    borderRadius: BorderRadius.circular(suitePanelRadius),
                    side: BorderSide(color: t.line),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 140, maxWidth: _maxMenuWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: suiteDialogPadding),
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final a in widget.actions) _actionRow(context, a),
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
        ),
        child: IconButton(
          style: suiteIconButtonStyle(),
          tooltip: widget.tooltip,
          icon: Icon(widget.icon, size: triggerIconSize, color: widget.active ? t.accent : null),
          onPressed: _toggleOpen,
        ),
      ),
    );
  }

  Widget _actionRow(BuildContext context, DropdownAction a) => _actionRowImpl(context, a);

  Widget _row(BuildContext context, int i) {
    final t = context.tokens;
    final item = widget.items[i];
    final selected = widget.selected.contains(item.value);
    return InkWell(
      key: ValueKey('dropdown-item-${item.value}'),
      onTap: () => _choose(i),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        // The menu hangs from the trigger's left edge, and the trigger's icon sits
        // [triggerIconInset] inside it, so every item icon (same size) lines up
        // vertically with the trigger icon.
        padding: const EdgeInsets.only(left: triggerIconInset, right: suiteDialogPadding),
        color: selected ? t.soft : null,
        child: Row(
          children: [
            if (item.leading != null) ...[SizedBox(width: triggerIconSize, height: triggerIconSize, child: Center(child: item.leading)), const SizedBox(width: 12)]
            else if (item.icon != null) ...[Icon(item.icon, size: triggerIconSize), const SizedBox(width: 12)],
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(item.label, maxLines: 2, overflow: TextOverflow.ellipsis))),
            // The check's place is always reserved, so choosing or clearing an item never resizes the menu.
            SizedBox(width: 18, child: selected ? Icon(SuiteIcons.check, size: 18, color: t.accent, semanticLabel: 'selected') : null),
          ],
        ),
      ),
    );
  }
}

extension on _SuiteDropdownState {
  Widget _actionRowImpl(BuildContext context, DropdownAction a) {
    final t = context.tokens;
    return InkWell(
      key: ValueKey('dropdown-action-${a.label}'),
      onTap: a.onPressed,
      child: Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: triggerIconInset, right: suiteDialogPadding),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.line))),
        child: Text(a.label, style: TextStyle(color: t.accent, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
