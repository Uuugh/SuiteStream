import 'package:flutter/material.dart';

import '../l10n/messages.dart';
import '../theme/event_colors.dart';
import '../theme/suite_icons.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import 'suite_dialog.dart';

/// What the picker returns when "calendar default" is chosen (UIC-10).
const int colorPickerDefault = -1;


/// The name of [color]: its arb message when merged, else its English name.
String paletteColorName(Messages m, PaletteColor color) => m.has(color.messageKey) ? m(color.messageKey) : color.name;

/// UIC-10, UIC-20: the one shared color picker. Shows [palette] (the eleven event
/// colors or the twenty-four calendar colors), marks [current] (mapped to its nearest
/// palette color), adds a "calendar default" choice when [defaultColor] is given, and
/// closes with the picked color (or [colorPickerDefault]); null when dismissed.
Future<int?> showColorPicker(
  BuildContext context, {
  required List<PaletteColor> palette,
  int? current,
  int? defaultColor,
}) {
  final messages = context.msg;
  return showSuiteDialog<int>(
    context: context,
    animate: false,
    builder: (_) => MessagesScope(
      messages: messages,
      child: ColorPickerDialog(palette: palette, current: current, defaultColor: defaultColor),
    ),
  );
}

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key, required this.palette, this.current, this.defaultColor});

  final List<PaletteColor> palette;
  final int? current;

  /// The color "calendar default" stands for; null hides that choice.
  final int? defaultColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    final selected = current == null ? null : nearestPaletteColor(current!, palette).argb;
    return Dialog(
      backgroundColor: t.card,
      child: Padding(
        padding: const EdgeInsets.all(suiteDialogPadding),
        child: SizedBox(
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (defaultColor != null) ...[
                ChoiceChip(
                  key: const ValueKey('color-default'),
                  label: Text(m('calendarDefault')),
                  avatar: CircleAvatar(backgroundColor: Color(defaultColor!), radius: 6),
                  selected: current == null,
                  onSelected: (_) => Navigator.of(context).pop(colorPickerDefault),
                ),
                const SizedBox(height: suitePartGap),
              ],
              Wrap(
                spacing: suiteSwatchGap,
                runSpacing: suiteSwatchGap,
                children: [
                  for (final p in palette)
                    Semantics(
                      label: paletteColorName(m, p),
                      selected: selected == p.argb,
                      button: true,
                      child: Tooltip(
                        message: paletteColorName(m, p),
                        child: InkWell(
                          key: ValueKey('color-${p.key}'),
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(p.argb),
                          child: Container(
                            width: suiteSwatchSize,
                            height: suiteSwatchSize,
                            decoration: BoxDecoration(
                              color: Color(p.argb),
                              shape: BoxShape.circle,
                              border: Border.all(color: selected == p.argb ? t.text : Colors.transparent, width: 2),
                            ),
                            child: selected == p.argb
                                ? Icon(
                                    SuiteIcons.check,
                                    size: suiteSwatchCheckSize,
                                    color: ThemeData.estimateBrightnessForColor(Color(p.argb)) == Brightness.dark
                                        ? t.scheme.surfaceBright
                                        : t.scheme.shadow,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
