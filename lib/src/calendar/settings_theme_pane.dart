import 'package:flutter/material.dart';

import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/theme_mode_controller.dart';
import '../theme/theme_settings.dart';
import '../theme/tokens.dart';
import '../time/length_input.dart';
import 'calendar_controller.dart';
import 'settings_dialog.dart';

/// Reads a typed percent (`100`, `125 %`, `87.5`) within [min] to [max]; null otherwise.
double? parsePercentInput(String input, double min, double max) {
  final s = input.trim().replaceAll(',', '.').replaceAll('%', '').trim();
  if (!RegExp(r'^\d{1,3}(\.\d{1,2})?$').hasMatch(s)) return null;
  final v = double.parse(s);
  return v < min || v > max ? null : v;
}

/// Reads a typed number of seconds (`2.4`, `2,4 s`) within [min] to [max]; null otherwise.
Duration? parseSecondsInput(String input, Duration min, Duration max) {
  final s = input.trim().toLowerCase().replaceAll(',', '.').replaceAll(RegExp(r'\s*s$'), '');
  if (!RegExp(r'^\d{1,2}(\.\d{1,3})?$').hasMatch(s)) return null;
  final d = Duration(milliseconds: (double.parse(s) * 1000).round());
  return d < min || d > max ? null : d;
}

String _formatPercent(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();
String _plainSeconds(Duration d) => _formatPercent(d.inMilliseconds / 1000);
String _percentText(double v) => '${_formatPercent(v)} %';
String _secondsText(Duration d) => '${formatPressDelay(d)} s';

/// One control of the pane: a number with its range, how to read and show it, and where it goes.
class _Setting {
  const _Setting({required this.id, required this.labelKey, required this.apply, required this.show, required this.step, required this.rangeMin, required this.rangeMax});

  final String id;
  final String labelKey;

  /// Applies a typed text; false when the text is not valid.
  final bool Function(ThemeSettings s, CalendarController c, String text) apply;

  /// The current value as the field shows it.
  final String Function(ThemeSettings s) show;

  /// The text after one arrow press (dir is 1 or -1) from the typed text.
  final String Function(ThemeSettings s, String text, int dir) step;
  final String rangeMin;
  final String rangeMax;
}

const double _percentStep = 5;
const Duration _secondsStep = Duration(milliseconds: 100);

_Setting _percent(String id, String labelKey, double min, double max, double Function(ThemeSettings) get, void Function(ThemeSettings, double) set) =>
    _Setting(
      id: id,
      labelKey: labelKey,
      rangeMin: _formatPercent(min),
      rangeMax: _formatPercent(max),
      apply: (s, c, text) {
        final v = parsePercentInput(text, min, max);
        if (v == null) return false;
        set(s, v);
        return true;
      },
      show: (s) => _percentText(get(s)),
      step: (s, text, dir) => _percentText((( parsePercentInput(text, min, max) ?? get(s)) + _percentStep * dir).clamp(min, max).toDouble()),
    );

_Setting _seconds(String id, String labelKey, Duration min, Duration max, Duration Function(ThemeSettings) get, void Function(ThemeSettings, CalendarController, Duration) set) =>
    _Setting(
      id: id,
      labelKey: labelKey,
      rangeMin: _plainSeconds(min),
      rangeMax: _plainSeconds(max),
      apply: (s, c, text) {
        final v = parseSecondsInput(text, min, max);
        if (v == null) return false;
        set(s, c, v);
        return true;
      },
      show: (s) => _secondsText(get(s)),
      step: (s, text, dir) {
        final next = (parseSecondsInput(text, min, max) ?? get(s)) + _secondsStep * dir;
        return _secondsText(next < min ? min : (next > max ? max : next));
      },
    );

/// SET-03.e to SET-03.k, UIC-44: the settings of the common UI elements; the order of the pane.
final List<_Setting> _settings = [
  _seconds('animation', 'themeSettingAnimationTime', Duration.zero, ThemeSettingsLimits.animationMax, (s) => s.animationTime, (s, c, v) {
    s.animationTime = v;
    c.animationDuration = v; // the calendar's animation scope reads the controller (SET-03.g)
  }),
  _percent('popup-shadow', 'themeSettingPopupShadow', ThemeSettingsLimits.popupShadowMin, ThemeSettingsLimits.popupShadowMax, (s) => s.popupShadow, (s, v) => s.popupShadow = v),
  _percent('resize-bar', 'themeSettingResizeBar', ThemeSettingsLimits.resizeBarMin, ThemeSettingsLimits.resizeBarMax, (s) => s.resizeBar, (s, v) => s.resizeBar = v),
  _percent('dropdown-text', 'themeSettingDropdownText', ThemeSettingsLimits.dropdownTextMin, ThemeSettingsLimits.dropdownTextMax, (s) => s.dropdownText, (s, v) => s.dropdownText = v),
  _percent('date-picker', 'themeSettingDatePicker', ThemeSettingsLimits.datePickerMin, ThemeSettingsLimits.datePickerMax, (s) => s.datePicker, (s, v) => s.datePicker = v),
  _seconds('status-chip', 'themeSettingStatusChipTime', ThemeSettingsLimits.statusChipMin, ThemeSettingsLimits.statusChipMax, (s) => s.statusChipTime, (s, c, v) => s.statusChipTime = v),
];

/// Settings > Theme: the default theme (Light, Dark or Match system, SHL-03) and one
/// setting for each common UI element (UIC-44, SET-03.c, SET-03.e to SET-03.k), with Reset.
/// Every change takes effect at once (UIC-13); an invalid text shows its range and changes nothing.
class SettingsThemePane extends StatefulWidget {
  const SettingsThemePane({super.key, required this.controller});

  final CalendarController controller;

  @override
  State<SettingsThemePane> createState() => _SettingsThemePaneState();
}

class _SettingsThemePaneState extends State<SettingsThemePane> {
  ThemeSettings? _own;
  final Map<String, TextEditingController> _fields = {};
  final Map<String, String?> _errors = {};

  /// The settings in effect (the scope above the app), or a private set when there is none.
  ThemeSettings get _theme =>
      context.getInheritedWidgetOfExactType<ThemeSettingsScope>()?.notifier ?? (_own ??= ThemeSettings());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The controller owns the animation time the app reads; the model follows it.
    if (_fields.isEmpty) _theme.animationTime = widget.controller.animationDuration;
    for (final s in _settings) {
      _fields.putIfAbsent(s.id, () => TextEditingController(text: s.show(_theme)));
    }
  }

  @override
  void dispose() {
    for (final f in _fields.values) {
      f.dispose();
    }
    _own?.dispose();
    super.dispose();
  }

  void _typed(_Setting s) {
    final m = context.msg;
    final ok = s.apply(_theme, widget.controller, _fields[s.id]!.text);
    setState(() => _errors[s.id] = ok ? null : m('rangeInvalid', {'min': s.rangeMin, 'max': s.rangeMax}));
  }

  void _step(_Setting s, int dir) {
    final field = _fields[s.id]!;
    field.text = s.step(_theme, field.text, dir);
    _typed(s);
  }

  void _reset() {
    _theme.reset();
    widget.controller.animationDuration = ThemeSettingsLimits.animationDefault;
    setState(() {
      for (final s in _settings) {
        _fields[s.id]!.text = s.show(_theme);
        _errors[s.id] = null;
      }
    });
  }

  Widget _themeChoice(BuildContext context, ThemeModeController mode) {
    final t = context.tokens;
    final m = context.msg;
    final choices = <(ThemeMode, String, String)>[
      (ThemeMode.light, 'setting-theme-light', 'light'),
      (ThemeMode.dark, 'setting-theme-dark', 'dark'),
      (ThemeMode.system, 'setting-theme-system', 'matchSystem'),
    ];
    return ListenableBuilder(
      listenable: mode,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(m('defaultTheme'), style: SuiteText.label(t).copyWith(color: t.muted)),
          const SizedBox(height: suiteLabelGap),
          Wrap(
            spacing: suitePartGap,
            children: [
              for (final (value, key, label) in choices)
                ChoiceChip(
                  key: ValueKey(key),
                  avatar: Icon(ThemeModeIcons.of(value), size: 18),
                  label: Text(m(label)),
                  selected: mode.mode == value,
                  onSelected: (_) => mode.mode = value,
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    final mode = ThemeModeScope.maybeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (mode != null) ...[
                  _themeChoice(context, mode),
                  const SizedBox(height: suitePartGap),
                ],
                for (final s in _settings) ...[
                  SettingsField(
                    label: m(s.labelKey),
                    fieldKey: 'setting-${s.id}',
                    controller: _fields[s.id]!,
                    error: _errors[s.id],
                    step: (dir) => _step(s, dir),
                    onChanged: () => _typed(s),
                  ),
                  const SizedBox(height: suitePartGap),
                ],
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            key: const ValueKey('setting-theme-reset'),
            onPressed: _reset,
            child: Text(m('themeSettingsReset')),
          ),
        ),
      ],
    );
  }
}
