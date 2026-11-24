import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/ui/popup_motion.dart';

/// Displays one line at a readable size, and provides access to clipped text.
class OverflowInfoText extends StatelessWidget {
  const OverflowInfoText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textStyle = DefaultTextStyle.of(context).style.merge(style);
    final textScaler = MediaQuery.textScalerOf(context);
    final fontSize = textStyle.fontSize ?? 14;
    final compactSize = math.max(13.0, fontSize * 0.86);
    final compactStyle = fontSize > compactSize && textScaler.scale(14) <= 14
        ? textStyle.copyWith(fontSize: compactSize)
        : textStyle;

    bool fits(TextStyle style, double width) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        locale: Localizations.maybeLocaleOf(context),
        textDirection: Directionality.of(context),
        textScaler: textScaler,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: width);
      final fits = !painter.didExceedMaxLines;
      painter.dispose();
      return fits;
    }

    Widget line(TextStyle style, {TextOverflow? overflow}) =>
        Text(text, style: style, maxLines: 1, overflow: overflow);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth ||
            fits(textStyle, constraints.maxWidth)) {
          return line(textStyle);
        }
        if (compactStyle != textStyle &&
            fits(compactStyle, constraints.maxWidth)) {
          return line(compactStyle);
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            Flexible(child: line(compactStyle, overflow: TextOverflow.clip)),
            InfoPopoverButton(text: text),
          ],
        );
      },
    );
  }
}

/// A shared anchored popover for an ellipsis or an inline information marker.
/// It opens and closes with the one popup transition (UIC-47): after the close it
/// runs back over the animation time before it is removed; at once with reduced
/// motion.
class InfoPopoverButton extends StatefulWidget {
  const InfoPopoverButton({
    super.key,
    required this.text,
    this.icon = SuiteIcons.moreHoriz,
    this.tooltip,
  });

  final String text;
  final IconData icon;
  final String? tooltip;

  @override
  State<InfoPopoverButton> createState() => _InfoPopoverButtonState();
}

class _InfoPopoverButtonState extends State<InfoPopoverButton> {
  static const double _popoverMaxWidth = 360;
  static const double _windowMargin = 16;

  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final Object _group = Object();
  bool _open = false;
  bool _below = true;
  bool _alignLeft = true;
  double _maxHeight = 0;

  void _toggle() {
    if (_portal.isShowing && _open) {
      _close();
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    final viewport = MediaQuery.sizeOf(context);
    if (box != null) {
      final top = box.localToGlobal(Offset.zero);
      final roomBelow = viewport.height - (top.dy + box.size.height);
      final roomAbove = top.dy;
      // Above or below, wherever there is more room (UIC-07).
      _below = roomBelow >= roomAbove;
      _maxHeight = math.max(0.0, (_below ? roomBelow : roomAbove) - _windowMargin);
      _alignLeft = top.dx + math.min(_popoverMaxWidth, viewport.width - 2 * _windowMargin) <= viewport.width - _windowMargin;
    }
    setState(() => _open = true);
    if (!_portal.isShowing) _portal.show();
  }

  void _close() {
    if (!_portal.isShowing) return;
    if (suitePopupDuration(context) == Duration.zero) {
      _open = false;
      _portal.hide();
    } else if (_open) {
      setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final title = widget.tooltip ?? MaterialLocalizations.of(context).moreButtonTooltip;
    final scheme = Theme.of(context).colorScheme;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => CompositedTransformFollower(
          link: _link,
          targetAnchor: _below
              ? (_alignLeft ? Alignment.bottomLeft : Alignment.bottomRight)
              : (_alignLeft ? Alignment.topLeft : Alignment.topRight),
          followerAnchor: _below
              ? (_alignLeft ? Alignment.topLeft : Alignment.topRight)
              : (_alignLeft ? Alignment.bottomLeft : Alignment.bottomRight),
          child: Align(
            alignment: _below
                ? (_alignLeft ? Alignment.topLeft : Alignment.topRight)
                : (_alignLeft ? Alignment.bottomLeft : Alignment.bottomRight),
            child: TapRegion(
              groupId: _group,
              onTapOutside: (_) => _close(),
              child: Focus(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
                    _close();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: SuitePopupMotion(
                  open: _open,
                  onClosed: _portal.hide,
                  child: Material(
                    color: scheme.surfaceContainer,
                    elevation: popupElevationOf(context),
                    shadowColor: scheme.shadow,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(suitePanelRadius)),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: math.max(0.0, math.min(_popoverMaxWidth, viewport.width - 2 * _windowMargin)),
                        maxHeight: math.max(0.0, math.min(_maxHeight, viewport.height - 2 * _windowMargin)),
                      ),
                      child: SingleChildScrollView(
                        primary: false,
                        padding: const EdgeInsets.all(suiteDialogPadding),
                        child: Text(widget.text, softWrap: true),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: TapRegion(
          groupId: _group,
          child: SizedBox.square(
            dimension: 24,
            child: IconButton(
              tooltip: title,
              icon: Icon(widget.icon, size: 15),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _toggle,
            ),
          ),
        ),
      ),
    );
  }
}
