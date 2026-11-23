import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/suite_icons.dart';
import '../theme/suite_theme.dart';

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
class InfoPopoverButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final title =
        tooltip ?? MaterialLocalizations.of(context).moreButtonTooltip;
    return MenuAnchor(
      useRootOverlay: true,
      style: const MenuStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(suitePanelRadius)),
          ),
        ),
      ),
      menuChildren: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.max(0.0, math.min(360.0, viewport.width - 32)),
            maxHeight: math.max(0.0, viewport.height - 32),
          ),
          child: SingleChildScrollView(
            primary: false,
            padding: const EdgeInsets.all(suiteDialogPadding),
            child: Text(text, softWrap: true),
          ),
        ),
      ],
      builder: (context, controller, child) => SizedBox.square(
        dimension: 24,
        child: IconButton(
          tooltip: title,
          icon: Icon(icon, size: 15),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        ),
      ),
    );
  }
}
