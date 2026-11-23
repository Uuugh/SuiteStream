import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/tokens.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/time_input.dart';
import 'package:suitestream/src/ui/zone_picker.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_defaults.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';

/// SET-08.a: Settings > Calendar: what a new event starts with: its length (a number and a
/// unit of time), its time of day and its time zone. User settings kept on the device
/// (DEF-01); events already made are not changed.
class SettingsCalendarPane extends StatefulWidget {
  const SettingsCalendarPane({
    super.key,
    required this.controller,
    this.prefs,
    required this.leave,
  });

  final CalendarController controller;
  final SharedPreferences? prefs;
  final SettingsLeaveHook leave;

  @override
  State<SettingsCalendarPane> createState() => _SettingsCalendarPaneState();
}

class _SettingsCalendarPaneState extends State<SettingsCalendarPane> {
  late SharedPreferences? _prefs = widget.prefs;

  @override
  void initState() {
    super.initState();
    if (_prefs == null) _loadDevicePrefs();
  }

  /// Without given preferences the device's own are read; until they arrive (or if they
  /// cannot be read) the form shows the defaults and keeps them only while the dialog is open.
  Future<void> _loadDevicePrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (mounted) setState(() => _prefs = p);
    } on Object {
      // keep the defaults
    }
  }

  @override
  Widget build(BuildContext context) => _CalendarForm(
    key: ValueKey(_prefs),
    controller: widget.controller,
    prefs: _prefs,
    leave: widget.leave,
  );
}

class _CalendarForm extends StatefulWidget {
  const _CalendarForm({
    super.key,
    required this.controller,
    required this.prefs,
    required this.leave,
  });

  final CalendarController controller;
  final SharedPreferences? prefs;
  final SettingsLeaveHook leave;

  @override
  State<_CalendarForm> createState() => _CalendarFormState();
}

class _CalendarFormState extends State<_CalendarForm> {
  late final CalendarDefaults _saved = CalendarDefaults.load(widget.prefs);
  late LengthUnit _unit =
      widget.prefs?.getString(CalendarDefaults.unitKey) == null
      ? unitFor(widget.controller.defaultLength)
      : _saved.unit;
  late final LengthUnit _initialUnit = _unit;
  late final TextEditingController _length = TextEditingController(
    text: formatLengthIn(widget.controller.defaultLength, _unit),
  );
  late final TextEditingController _time = TextEditingController(
    text: _formatTime(_saved.startMinutes),
  );
  late final String _initialLength;
  late final String _initialTime;
  late String? _fixedZone = widget.controller.baseZone.fixedZoneName;
  String? _lengthError;
  String? _timeError;

  String _formatTime(int minutes) => formatTimeOfDay(
    minutes ~/ 60,
    minutes % 60,
    widget.controller.timeFormat,
  );

  @override
  void initState() {
    super.initState();
    // The initial texts are lazy: read them before the user types.
    _initialLength = _length.text;
    _initialTime = _time.text;
    widget.leave.register(_save);
  }

  @override
  void dispose() {
    widget.leave.unregister(_save);
    _length.dispose();
    _time.dispose();
    super.dispose();
  }

  bool get _changed =>
      _length.text.trim() != _initialLength ||
      _unit != _initialUnit ||
      _time.text.trim() != _initialTime ||
      _fixedZone != widget.controller.baseZone.fixedZoneName;

  /// UIC-45: saves on its own when Settings or the page is left. Each valid value is
  /// stored; an invalid one is not (its note stays shown while the pane is open).
  void _save() {
    if (!_changed) return;
    final length = parseLengthIn(_length.text, _unit);
    final time = parseTimeInput(_time.text);
    if (length != null) widget.controller.defaultLength = length;
    if (length != null || time != null) {
      CalendarDefaults(
        unit: length != null ? _unit : _saved.unit,
        startMinutes: time?.minutes ?? _saved.startMinutes,
      ).save(widget.prefs);
    }
    final fixed = _fixedZone;
    final system = widget.controller.baseZone.systemZoneName;
    widget.controller.localZone = fixed == null
        ? LocalZone.system(system)
        : LocalZone.fixed(fixed, systemZone: system);
  }

  /// The notes show as soon as a typed value is not valid.
  void _validate() {
    final m = context.msg;
    setState(() {
      _lengthError = parseLengthIn(_length.text, _unit) == null
          ? m('lengthInvalid')
          : null;
      _timeError = parseTimeInput(_time.text) == null
          ? m('defaultTimeInvalid')
          : null;
    });
  }

  Duration get _currentLength =>
      parseLengthIn(_length.text, _unit) ?? widget.controller.defaultLength;

  /// UIC-41: the arrows step a length by 15 minutes (one hour in hours).
  void _stepLength(int dir) {
    _length.text = formatLengthIn(
      stepLengthIn(_currentLength, _unit, dir),
      _unit,
    );
    _validate();
  }

  /// UIC-41: the arrows step a time by 15 minutes.
  void _stepTime(int dir) {
    final now = parseTimeInput(_time.text)?.minutes ?? _saved.startMinutes;
    final next = (now + 15 * dir).clamp(0, 24 * 60 - 1);
    _time.text = _formatTime(next);
    _validate();
  }

  /// Changing the unit keeps the length and shows it in the new unit.
  void _changeUnit(LengthUnit? unit) {
    if (unit == null || unit == _unit) return;
    final d = _currentLength;
    setState(() {
      _unit = unit;
      _length.text = formatLengthIn(d, unit);
      _lengthError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SettingsField(
                        label: m('defaultEventLength'),
                        fieldKey: 'setting-default-length',
                        controller: _length,
                        error: _lengthError,
                        step: _stepLength,
                        onChanged: _validate,
                      ),
                    ),
                    const SizedBox(width: suiteColumnGap),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: suiteLabelGap,
                            ),
                            child: Text(
                              m('lengthUnit'),
                              style: SuiteText.label(
                                t,
                              ).copyWith(color: t.muted),
                            ),
                          ),
                          DropdownButtonFormField<LengthUnit>(
                            key: const ValueKey('setting-default-length-unit'),
                            initialValue: _unit,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: suiteDialogPadding,
                                vertical: suiteDropdownVerticalPadding,
                              ),
                            ),
                            items: [
                              for (final u in LengthUnit.values)
                                DropdownMenuItem(
                                  value: u,
                                  child: Text(m(u.messageKey)),
                                ),
                            ],
                            onChanged: _changeUnit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: suitePartGap),
                SettingsField(
                  label: m('defaultEventTime'),
                  fieldKey: 'setting-default-time',
                  controller: _time,
                  error: _timeError,
                  step: _stepTime,
                  onChanged: _validate,
                ),
                const SizedBox(height: suitePartGap),
                Text(m('defaultTimeZone'), style: SuiteText.label(t)),
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
                        final system =
                            widget.controller.baseZone.systemZoneName;
                        final result = await pickZone(
                          context,
                          current: _fixedZone ?? system,
                          defaultZone: system,
                        );
                        if (mounted && result != null) {
                          setState(() => _fixedZone = result);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
