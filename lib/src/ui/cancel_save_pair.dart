import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// THM-04.c: Cancel | Save buttons are 130 × 34 px (the pair together).
const double pairWidth = 130;
const double pairHeight = 34;

/// UIC-27: the Cancel | Save pair: two joined buttons that sit at the bottom of
/// what they save. The same pair carries a question's answers, No | Yes
/// (UIC-27.d, UIC-06), when given those words.
///
/// Cancel is the quiet side. The Save pilot uses the theme's normal accent look,
/// dims it while inactive, and fills with accent on hover
/// (THM-05.b, UIC-27.b-c).
class CancelSavePair extends StatelessWidget {
  const CancelSavePair({
    super.key,
    required this.cancelLabel,
    required this.saveLabel,
    required this.onCancel,
    required this.onSave,
    this.cancelKey,
    this.saveKey,
    this.cancelEnabled = true,
    this.saveEnabled = true,
    this.useThemedSaveStates = false,
  });

  final String cancelLabel;
  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final Key? cancelKey;
  final Key? saveKey;
  final bool cancelEnabled;

  /// False until something has changed; the side then uses the inactive look.
  final bool saveEnabled;

  /// Enables the theme-matched active/inactive Save pilot.
  final bool useThemedSaveStates;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final quiet = _Look(
      background: t.card,
      hover: t.soft,
      foreground: t.accent,
    );
    final legacySave = _Look(
      background: Color.alphaBlend(t.accent.withValues(alpha: 0.5), t.card),
      hover: t.accent,
      foreground: t.onAccent,
    );
    final inactiveSave = _Look(
      background: t.card,
      hover: t.card,
      foreground: t.accent.withValues(alpha: 0.33),
    );
    final activeSave = _Look(
      background: t.card,
      hover: t.accent,
      foreground: t.accent,
      hoverForeground: t.onAccent,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        8,
      ), // THM-04.a: controls have 8 px corners
      child: Container(
        width: pairWidth,
        height: pairHeight,
        decoration: BoxDecoration(
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: _Side(
                key: cancelKey,
                label: cancelLabel,
                enabled: cancelEnabled,
                look: quiet,
                onPressed: onCancel,
              ),
            ),
            Expanded(
              child: _Side(
                key: saveKey,
                label: saveLabel,
                enabled: saveEnabled,
                look: useThemedSaveStates
                    ? (saveEnabled ? activeSave : inactiveSave)
                    : (saveEnabled ? legacySave : quiet),
                onPressed: onSave,
                inert: !saveEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Look {
  const _Look({
    required this.background,
    required this.hover,
    required this.foreground,
    this.hoverForeground,
  });
  final Color background;
  final Color hover;
  final Color foreground;
  final Color? hoverForeground;
}

class _Side extends StatefulWidget {
  const _Side({
    super.key,
    required this.label,
    required this.enabled,
    required this.look,
    required this.onPressed,
    this.inert = false,
  });

  final String label;
  final bool enabled;
  final _Look look;
  final VoidCallback onPressed;

  /// A disabled Save: it uses the inactive look and does nothing.
  final bool inert;

  @override
  State<_Side> createState() => _SideState();
}

class _SideState extends State<_Side> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && !widget.inert;
    final look = widget.look;
    return Opacity(
      opacity: widget.enabled || widget.inert ? 1 : 0.4,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Material(
          color: active && _hover ? look.hover : look.background,
          child: InkWell(
            onTap: active ? widget.onPressed : null,
            hoverColor: Colors.transparent,
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: active && _hover
                      ? look.hoverForeground ?? look.foreground
                      : look.foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
