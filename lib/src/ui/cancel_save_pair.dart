import 'package:flutter/material.dart';

import '../theme/suite_theme.dart';

/// THM-04.c: Cancel | Save buttons are 130 × 34 px (the pair together).
const double pairWidth = 130;
const double pairHeight = suiteControlHeight;

/// UIC-27: the Cancel | Save pair: two joined buttons that sit at the bottom of
/// what they save. The same pair carries a question's answers, No | Yes
/// (UIC-27.d, UIC-06), when given those words.
///
/// Cancel is the quiet side. The Save pilot uses the theme's normal accent look,
/// dims it while inactive, and fills with accent on hover
/// (THM-05.b, UIC-27.b-c).
class CancelSavePair extends StatefulWidget {
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
  State<CancelSavePair> createState() => _CancelSavePairState();
}

class _CancelSavePairState extends State<CancelSavePair>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  @override
  void didUpdateWidget(CancelSavePair oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.saveEnabled) {
      _pulse.reset();
    } else if (!oldWidget.saveEnabled &&
        !MediaQuery.disableAnimationsOf(context)) {
      _pulse.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _pulse.reset();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _activate(VoidCallback action) {
    _pulse.reset();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final quiet = _Look(
      background: scheme.surfaceContainerLow,
      hover: scheme.surfaceContainerHighest,
      foreground: scheme.primary,
    );
    final filledSave = _Look(
      background: scheme.primaryContainer,
      hover: scheme.primary,
      foreground: scheme.onPrimaryContainer,
      hoverForeground: scheme.onPrimary,
    );
    final inactiveSave = _Look(
      background: scheme.surfaceContainerLow,
      hover: scheme.surfaceContainerLow,
      foreground: scheme.onSurfaceVariant,
    );
    final activeSave = _Look(
      background: scheme.surfaceContainerLow,
      hover: scheme.primary,
      foreground: scheme.primary,
      hoverForeground: scheme.onPrimary,
    );
    const corners = BorderRadius.all(Radius.circular(suiteControlRadius));
    return ClipRRect(
      borderRadius: corners,
      child: Container(
        width: pairWidth,
        height: pairHeight,
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: corners,
        ),
        child: Row(
          children: [
            Expanded(
              child: _Side(
                key: widget.cancelKey,
                label: widget.cancelLabel,
                enabled: widget.cancelEnabled,
                look: quiet,
                onPressed: () => _activate(widget.onCancel),
              ),
            ),
            Expanded(
              child: _Side(
                key: widget.saveKey,
                label: widget.saveLabel,
                enabled: widget.saveEnabled,
                look: widget.saveEnabled
                    ? (widget.useThemedSaveStates ? activeSave : filledSave)
                    : inactiveSave,
                onPressed: () => _activate(widget.onSave),
                pulse: _pulse,
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
    this.pulse,
  });

  final String label;
  final bool enabled;
  final _Look look;
  final VoidCallback onPressed;

  final Animation<double>? pulse;

  @override
  State<_Side> createState() => _SideState();
}

class _SideState extends State<_Side> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    final look = widget.look;
    return Semantics(
      button: true,
      enabled: active,
      child: Opacity(
        opacity: active ? 1 : 0.45,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: AnimatedBuilder(
            animation: widget.pulse ?? const AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              final progress = (widget.pulse?.value ?? 0) * 5;
              final phase = progress % 1;
              final strength = active && !_hover
                  ? 0.12 * (1 - (2 * phase - 1).abs())
                  : 0.0;
              return Material(
                color: active && _hover
                    ? look.hover
                    : Color.alphaBlend(
                        look.foreground.withValues(alpha: strength),
                        look.background,
                      ),
                child: child,
              );
            },
            child: InkWell(
              onTap: active ? widget.onPressed : null,
              canRequestFocus: active,
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
      ),
    );
  }
}
