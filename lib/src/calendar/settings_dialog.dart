import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/length_input.dart';
import '../time/local_zone.dart';
import '../ui/cancel_save_pair.dart';
import '../ui/popup_size_lock.dart';
import '../ui/stepper_arrows.dart';
import '../ui/suite_dialog.dart';
import '../ui/zone_picker.dart';
import 'calendar_controller.dart';
import 'event_drag.dart';
import 'local_calendars_dialog.dart';

/// Opens the user's settings (view settings, kept on the device).
Future<void> openSettingsDialog(BuildContext context, CalendarController c) {
  final msgs = context.msg;
  return showSuiteDialog<void>(
    context: context,
    builder: (dialogContext) => MessagesScope(
      messages: msgs,
      child: Dialog(
        backgroundColor: dialogContext.tokens.card,
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: PopupSizeLock(child: SettingsDialog(controller: c))),
      ),
    ),
  );
}

enum _Section { general, sources, feeds, rules, templates, history }

/// SET-08, SET-09: the user's own settings: the default length of an event and the
/// press-and-hold delay before an event can be dragged.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, required this.controller});

  final CalendarController controller;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late final TextEditingController _length = TextEditingController(text: formatLength(widget.controller.defaultLength));
  late final TextEditingController _press = TextEditingController(text: formatPressDelay(widget.controller.longPress));
  late final String _initialLength = _length.text;
  late final TextEditingController _anim = TextEditingController(text: formatPressDelay(widget.controller.animationDuration));
  late final String _initialPress = _press.text;
  late final String _initialAnim = _anim.text;
  String? _animError;
  _Section _section = _Section.general;
  String? _lengthError;
  String? _pressError;
  late String? _fixedZone = widget.controller.baseZone.fixedZoneName;

  @override
  void dispose() {
    _length.dispose();
    _press.dispose();
    _anim.dispose();
    super.dispose();
  }

  bool get _changed =>
      _length.text.trim() != _initialLength ||
      _press.text.trim() != _initialPress ||
      _anim.text.trim() != _initialAnim ||
      _fixedZone != widget.controller.baseZone.fixedZoneName;

  void _save() {
    final m = context.msg;
    final length = parseLengthInput(_length.text);
    final press = parsePressDelayInput(_press.text);
    final anim = parseAnimationInput(_anim.text);
    if (length == null || press == null || anim == null) {
      setState(() {
        _animError = anim == null ? m('animationDurationInvalid') : null;
        _lengthError = length == null ? m('lengthInvalid') : null;
        _pressError = press == null ? m('pressDelayInvalid') : null;
      });
      return;
    }
    widget.controller.defaultLength = length;
    widget.controller.longPress = press;
    widget.controller.animationDuration = anim;
    final fixed = _fixedZone;
    final system = widget.controller.baseZone.systemZoneName;
    widget.controller.localZone = fixed == null
        ? LocalZone.system(system)
        : LocalZone.fixed(fixed, systemZone: system);
    Navigator.of(context).pop();
  }

  /// The arrows step the default length by 15 minutes.
  void _stepLength(int dir) {
    final d = parseLengthInput(_length.text) ?? widget.controller.defaultLength;
    _length.text = formatLength(clampEventLength(d + Duration(minutes: 15 * dir)));
    setState(() => _lengthError = null);
  }

  /// The arrows step the press-and-hold delay by 0.1 seconds.
  void _stepPress(int dir) {
    final d = parsePressDelayInput(_press.text) ?? widget.controller.longPress;
    _press.text = formatPressDelay(clampLongPress(d + Duration(milliseconds: 100 * dir)));
    setState(() => _pressError = null);
  }

  /// The arrows step the animation time by 0.1 seconds (0 = none).
  void _stepAnim(int dir) {
    final d = parseAnimationInput(_anim.text) ?? widget.controller.animationDuration;
    _anim.text = formatPressDelay(clampAnimation(d + Duration(milliseconds: 100 * dir)));
    setState(() => _animError = null);
  }

  Widget _field(String label, String key, TextEditingController ctl, String? error, VoidCallback onChanged, void Function(int) step) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: suiteLabelGap),
          child: Text(label, style: TextStyle(color: t.muted, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
        ArrowKeyStepper(
          onUp: () => step(1),
          onDown: () => step(-1),
          child: TextField(
          key: ValueKey(key),
          controller: ctl,
          inputFormatters: [LengthLimitingTextInputFormatter(8)],
          decoration: InputDecoration(
            suffixIcon: StepperArrows(upKey: ValueKey('$key-up'), downKey: ValueKey('$key-down'), onUp: () => step(1), onDown: () => step(-1)),
            isDense: true,
            errorText: error,
            errorMaxLines: 2,
            filled: true,
            fillColor: t.bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: t.line)),
          ),
          onChanged: (_) => setState(onChanged),
        ),
        ),
      ],
    );
  }

  Widget _menu(BuildContext context, {required bool vertical}) {
    final m = context.msg;
    final entries = <(_Section, String, String)>[
      (_Section.general, 'settings-general', 'settingsGeneral'),
      (_Section.sources, 'settings-sources', 'settingsSources'),
      (_Section.feeds, 'settingsFeeds', 'settingsFeeds'),
      (_Section.rules, 'settingsRules', 'settingsRules'),
      (_Section.templates, 'settingsTemplates', 'settingsTemplates'),
      (_Section.history, 'settingsHistory', 'settingsHistory'),
    ];
    if (vertical) {
      return ListView(
        children: [
          for (final (section, key, label) in entries)
            ListTile(
              key: ValueKey(key),
              dense: true,
              selected: _section == section,
              title: Text(m(label)),
              onTap: () => setState(() => _section = section),
            ),
        ],
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (section, key, label) in entries)
            Padding(
              padding: const EdgeInsets.only(right: suitePartGap),
              child: ChoiceChip(
                key: ValueKey(key),
                label: Text(m(label)),
                selected: _section == section,
                onSelected: (_) => setState(() => _section = section),
              ),
            ),
        ],
      ),
    );
  }

  /// The user's own view settings, with their own Cancel | Save (SET-01.d).
  Widget _general(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(m('defaultEventLength'), 'setting-default-length', _length, _lengthError, () => _lengthError = null, _stepLength),
                const SizedBox(height: suitePartGap),
                _field(m('pressDelay'), 'setting-press-delay', _press, _pressError, () => _pressError = null, _stepPress),
                const SizedBox(height: suitePartGap),
                _field(m('animationDuration'), 'setting-animation', _anim, _animError, () => _animError = null, _stepAnim),
                const SizedBox(height: suitePartGap),
                Text(m('timeZones'), style: SuiteText.label(t)),
                Wrap(
                  spacing: suitePartGap,
                  children: [
                    ChoiceChip(
                      key: const ValueKey('setting-zone-system'),
                      label: Text(m('followSystemTimeZone')),
                      selected: _fixedZone == null,
                      onSelected: (_) => setState(() => _fixedZone = null),
                    ),
                    ChoiceChip(
                      key: const ValueKey('setting-zone-fixed'),
                      label: Text(_fixedZone ?? m('fixedTimeZone')),
                      selected: _fixedZone != null,
                      onSelected: (_) async {
                        final system = widget.controller.baseZone.systemZoneName;
                        final result = await pickZone(context, current: _fixedZone ?? system, defaultZone: system);
                        if (mounted && result != null) setState(() => _fixedZone = result);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: suitePartGap),
        Align(
          alignment: Alignment.centerRight,
          // UIC-27: Save is available once something has changed.
          child: CancelSavePair(
            cancelKey: const ValueKey('settings-cancel'),
            saveKey: const ValueKey('settings-save'),
            cancelLabel: m('cancel'),
            saveLabel: m('save'),
            onCancel: () => Navigator.of(context).pop(),
            saveEnabled: _changed,
            onSave: _save,
          ),
        ),
      ],
    );
  }

  Widget _pane(BuildContext context) {
    final m = context.msg;
    switch (_section) {
      case _Section.general:
        return _general(context);
      case _Section.sources:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(m('manageLocalCalendars'), style: SuiteText.label(context.tokens)),
            const SizedBox(height: suitePartGap),
            Expanded(child: LocalCalendarsPanel(controller: widget.controller)),
          ],
        );
      case _Section.feeds:
      case _Section.rules:
      case _Section.templates:
      case _Section.history:
        return Center(child: Text(m('settingsUnavailable'), style: SuiteText.label(context.tokens)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 640;
    final height = (size.height - 96).clamp(360.0, 600.0);
    return Padding(
      key: const ValueKey('settings-dialog'),
      padding: const EdgeInsets.all(suiteDialogPadding),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(m('settings'), style: SuiteText.moduleKind(t, windowWidth: size.width)),
            const SizedBox(height: suitePartGap),
            Expanded(
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 200, child: _menu(context, vertical: true)),
                        VerticalDivider(width: 2 * suiteDialogPadding, color: t.line),
                        Expanded(child: _pane(context)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _menu(context, vertical: false),
                        const SizedBox(height: suitePartGap),
                        Expanded(child: _pane(context)),
                      ],
                    ),
            ),
            if (_section != _Section.general)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(m('closeButton'))),
              ),
          ],
        ),
      ),
    );
  }
}
