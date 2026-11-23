import 'dart:async';

import 'package:flutter/material.dart';

import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_theme.dart';

/// THM-04.c: Cancel | Save buttons are 130 × 34 px (the pair together).
const double pairWidth = 130;
const double pairHeight = suiteControlHeight;


/// UIC-27: the Cancel | Save pair: two joined buttons that sit at the bottom of
/// what they save. The same pair carries a question's answers, No | Yes
/// (UIC-27.d, UIC-06), when given those words.
///
/// Every animation of the pair (hover, the Save pulse, the pressed side's slide
/// and its pulse) takes its time from the one animation setting
/// ([SuiteAnimationScope], THM-06.c); reduced motion makes it zero.
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
    this.holdDuration,
    this.savedWord,
    this.cancelledWord,
  });

  /// Test hook: when set, replaces the DEF-01 hold for every pair. It stays here because the
  /// pair is built deep inside dialogs that tests cannot pass a hold to; `test/flutter_test_config.dart`
  /// sets it to zero for the whole test run (a scope or constructor option would need every caller to forward it).
  @visibleForTesting
  static Duration? debugHold;

  /// Overrides the hold (default: the Settings Status word time, [SuiteStatusWordScope], DEF-01).
  final Duration? holdDuration;

  /// Word shown after Save is pressed. Default: "Saved" when the side is
  /// labelled Save, otherwise the side's own label (Print, Yes).
  final String? savedWord;

  /// Word shown after Cancel is pressed. Default: "Cancelled" when the side is
  /// labelled Cancel, otherwise the side's own label (No).
  final String? cancelledWord;

  final String cancelLabel;
  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final Key? cancelKey;
  final Key? saveKey;
  final bool cancelEnabled;

  /// False until something has changed; the side then uses the inactive look.
  final bool saveEnabled;

  @override
  State<CancelSavePair> createState() => _CancelSavePairState();
}

class _CancelSavePairState extends State<CancelSavePair> with TickerProviderStateMixin {
  /// The one animation time, from the setting (zero with reduced motion).
  Duration _time = defaultAnimationDuration;

  /// The idle Save pulse: five pulses, each two animation times long.
  late final _pulse = AnimationController(vsync: this, duration: defaultAnimationDuration * 10);

  /// The pressed side's slide over the pair.
  late final _cover = AnimationController(vsync: this, duration: defaultAnimationDuration);

  /// The pressed side's gentle pulse once it covers the pair.
  late final _coverPulse = AnimationController(vsync: this, duration: defaultAnimationDuration);

  Timer? _hold;

  /// The side whose word is showing, or null when the pair is idle.
  bool? _pressedSave;

  @override
  void initState() {
    super.initState();
    _cover.addStatusListener((status) {
      if (status == AnimationStatus.completed && _pressedSave != null && _time > Duration.zero) {
        _coverPulse.repeat(reverse: true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _time = SuiteAnimationScope.of(context);
    _pulse.duration = _time * 10;
    _cover.duration = _time;
    _coverPulse.duration = _time;
    if (_time == Duration.zero) _pulse.reset();
  }

  @override
  void didUpdateWidget(CancelSavePair oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.saveEnabled) {
      _pulse.reset();
    } else if (!oldWidget.saveEnabled && _time > Duration.zero) {
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _hold?.cancel();
    _pulse.dispose();
    _cover.dispose();
    _coverPulse.dispose();
    super.dispose();
  }

  /// UIC-27.a: slide the pressed side over the pair, show its word for the hold,
  /// then run [action] and return to idle. A press during the hold is ignored.
  void _activate(bool save, VoidCallback action) {
    if (_pressedSave != null) return;
    _pulse.reset();
    setState(() => _pressedSave = save);
    if (_time == Duration.zero) {
      _cover.value = 1;
    } else {
      _cover.forward(from: 0);
    }
    final given = CancelSavePair.debugHold;
    var hold = given ?? widget.holdDuration ?? SuiteStatusWordScope.of(context);
    if (given == null && hold < _time) hold = _time;
    _hold = Timer(hold, () {
      _hold = null;
      if (!mounted) return;
      _cover.reset();
      _coverPulse.reset();
      setState(() => _pressedSave = null);
      action();
    });
  }

  String _word(BuildContext context, bool save) {
    final given = save ? widget.savedWord : widget.cancelledWord;
    if (given != null) return given;
    final label = save ? widget.saveLabel : widget.cancelLabel;
    final m = context.dependOnInheritedWidgetOfExactType<MessagesScope>()?.messages;
    final standard = m?.call(save ? 'save' : 'cancel') ?? (save ? 'Save' : 'Cancel');
    if (label != standard) return label;
    return m?.call(save ? 'pairSaved' : 'pairCancelled') ?? (save ? 'Saved' : 'Cancelled');
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
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: _Side(
                    key: widget.cancelKey,
                    label: widget.cancelLabel,
                    enabled: widget.cancelEnabled,
                    look: quiet,
                    time: _time,
                    onPressed: () => _activate(false, widget.onCancel),
                  ),
                ),
                Expanded(
                  child: _Side(
                    key: widget.saveKey,
                    label: widget.saveLabel,
                    enabled: widget.saveEnabled,
                    look: widget.saveEnabled ? filledSave : inactiveSave,
                    time: _time,
                    onPressed: () => _activate(true, widget.onSave),
                    pulse: _pulse,
                  ),
                ),
              ],
            ),
            if (_pressedSave != null) Positioned.fill(child: _coverLayer(context, scheme, _pressedSave!)),
          ],
        ),
      ),
    );
  }

  /// THM-06.c: the pressed side's fill slides from its own half (Cancel from the
  /// left, Save from the right) to cover the whole pair, then pulses gently while
  /// its word is held. It covers the sides, so nothing underneath can be pressed.
  Widget _coverLayer(BuildContext context, ColorScheme scheme, bool save) {
    final base = save ? scheme.primary : scheme.surfaceContainerHighest;
    final peak = save ? scheme.primaryContainer : scheme.surfaceContainer;
    return AbsorbPointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_cover, _coverPulse]),
        builder: (context, _) {
          final slide = Curves.easeInOut.transform(_cover.value);
          return Align(
            alignment: save ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5 + 0.5 * slide,
              heightFactor: 1,
              child: ColoredBox(
                key: const ValueKey('pair-word'),
                color: Color.lerp(base, peak, 0.35 * Curves.easeInOut.transform(_coverPulse.value))!,
                child: OverflowBox(
                  maxWidth: pairWidth,
                  child: Center(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _word(context, save),
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: save ? scheme.onPrimary : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// How far the Save pulse travels toward the hover look (0 = rest, 1 = hover).
const _pulsePeak = 0.5;

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
    required this.time,
    required this.onPressed,
    this.pulse,
  });

  final String label;
  final bool enabled;
  final _Look look;

  /// The one animation time; the hover fades over it.
  final Duration time;
  final VoidCallback onPressed;

  final Animation<double>? pulse;

  @override
  State<_Side> createState() => _SideState();
}

class _SideState extends State<_Side> with SingleTickerProviderStateMixin {
  late final _hover = AnimationController(vsync: this, duration: widget.time);

  @override
  void didUpdateWidget(_Side oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hover.duration = widget.time;
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  void _setHover(bool on) {
    if (widget.time == Duration.zero) {
      _hover.value = on ? 1 : 0;
    } else if (on) {
      _hover.forward();
    } else {
      _hover.reverse();
    }
  }

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
          onEnter: (_) => _setHover(true),
          onExit: (_) => _setHover(false),
          cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: AnimatedBuilder(
            animation: Listenable.merge([_hover, widget.pulse ?? const AlwaysStoppedAnimation(0.0)]),
            builder: (context, child) {
              final progress = (widget.pulse?.value ?? 0) * 5;
              final phase = progress % 1;
              // The pulse is a dimmer hover: it fades toward the hover look and
              // peaks at half strength.
              final strength = active ? _pulsePeak * (1 - (2 * phase - 1).abs()) : 0.0;
              final h = active ? _hover.value : 0.0;
              final hoverText = look.hoverForeground ?? look.foreground;
              final restBackground = Color.lerp(look.background, look.hover, strength)!;
              final restText = Color.lerp(look.foreground, hoverText, strength)!;
              return Material(
                animationDuration: Duration.zero,
                color: Color.lerp(restBackground, look.hover, h),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: Color.lerp(restText, hoverText, h)),
                  child: child!,
                ),
              );
            },
            child: InkWell(
              onTap: active ? widget.onPressed : null,
              canRequestFocus: active,
              hoverColor: Colors.transparent,
              child: Center(
                child: Builder(
                  builder: (context) => Text(
                    widget.label,
                    style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
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
