import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/suite_icons.dart';
import '../l10n/messages.dart';
import '../theme/event_colors.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/suite_event.dart';
import '../time/time_format.dart';
import '../time/time_input.dart';
import '../time/zones.dart';
import '../ui/cancel_save_pair.dart';
import '../ui/color_picker.dart';
import '../ui/confirm.dart';
import '../ui/error_note.dart';
import '../ui/popup_size_lock.dart';
import '../ui/suite_dialog.dart';
import '../ui/stepper_arrows.dart';
import '../ui/zone_picker.dart';
import 'calendar_controller.dart';
import 'calendar_defaults.dart';
import 'date_picker.dart';
import 'event_drag.dart';

/// DEF-01: the longest reminder lead is 1 week, in minutes before the start.
const int longestReminderLead = 10080;

/// The units a reminder is set in, with their length in minutes.
enum ReminderUnit {
  minutes(1, 'minutes'),
  hours(60, 'unitHours'),
  days(1440, 'unitDays'),
  weeks(10080, 'unitWeeks');

  const ReminderUnit(this.inMinutes, this.messageKey);
  final int inMinutes;
  final String messageKey;
}

/// A reminder of [minutes] as the largest unit it is a whole number of (90 min stays
/// 90 minutes, 120 min is 2 hours).
(int, ReminderUnit) splitReminder(int minutes) {
  if (minutes > 0) {
    for (final u in [
      ReminderUnit.weeks,
      ReminderUnit.days,
      ReminderUnit.hours,
    ]) {
      if (minutes % u.inMinutes == 0) return (minutes ~/ u.inMinutes, u);
    }
  }
  return (minutes, ReminderUnit.minutes);
}

/// DEF-01: a new event starts at 9:00 and lasts one hour.
const int newEventStartMinutes = 9 * 60;
const Duration newEventLength = Duration(hours: 1);

/// EVT-03.e: only valid reminders are stored (from the start back to the longest
/// lead, so 15, 60, 20000 stores 15, 60), at most [remindersPerEvent], each once,
/// soonest first.
List<int> normalizeReminders(Iterable<int> chosen) {
  final valid = {
    for (final r in chosen)
      if (r >= 0 && r <= longestReminderLead) r,
  }.toList()..sort();
  return valid.take(remindersPerEvent).toList();
}

/// The words of a reminder (EVT-03.l).
String reminderLabel(Messages m, int minutes) {
  if (minutes == 0) return m('reminderAtStart');
  if (minutes < 60) return m('reminderMinutesBefore', {'n': minutes});
  if (minutes == 60) return m('reminderHourBefore');
  if (minutes < 1440) return m('reminderHoursBefore', {'n': minutes ~/ 60});
  if (minutes == 1440) return m('reminderDayBefore');
  if (minutes < 10080) return m('reminderDaysBefore', {'n': minutes ~/ 1440});
  return m('reminderWeekBefore');
}

/// EVT-03.a: the map link for a location: the address is the URL-encoded location.
Uri mapUrl(String location) => Uri.parse(
  'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}',
);

/// EVT-01.p: empty, or a link starting with http:// or https:// with no spaces.
bool isValidMeetingUrl(String s) =>
    s.isEmpty || RegExp(r'^https?://\S+$').hasMatch(s);

/// Opens the event dialog: a new event on [day] (EVT-01.a), or [event] to edit.
Future<void> openEventDialog(
  BuildContext context,
  CalendarController c, {
  SuiteEvent? event,
  SuiteEvent? duplicateOf,
  DateTime? day,
  int? startMinute,
  bool allDay = false,
  SharedPreferences? prefs,
}) {
  final msgs = context.msg;
  final phone = MediaQuery.sizeOf(context).width <= phoneMaxWidth;
  return showSuiteDialog<void>(
    context: context,
    builder: (dialogContext) => MessagesScope(
      messages: msgs,
      child: Dialog(
        backgroundColor: dialogContext.tokens.card,
        insetPadding: phone
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        shape: phone ? const RoundedRectangleBorder() : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: phone ? double.infinity : 960),
          child: PopupSizeLock(
            child: EventDialog(
              controller: c,
              event: event,
              duplicateOf: duplicateOf,
              day: day,
              startMinute: startMinute,
              allDay: allDay,
              prefs: prefs,
            ),
          ),
        ),
      ),
    ),
  );
}

/// EVT-01: the dialog to add, edit and remove an event.
class EventDialog extends StatefulWidget {
  const EventDialog({
    super.key,
    required this.controller,
    this.event,
    this.duplicateOf,
    this.day,
    this.startMinute,
    this.allDay = false,
    this.prefs,
  });

  final CalendarController controller;
  final SuiteEvent? event;

  /// EVT-06.a: when set, the dialog holds a copy of this event to save as a new one.
  final SuiteEvent? duplicateOf;
  final DateTime? day;

  /// Where a click in an hourly view started a new event (minutes of the day).
  final int? startMinute;

  /// A click in the all-day row starts an all-day event.
  final bool allDay;

  /// EVT-01.m: where the default start time of a new event is read; without it the device's own.
  final SharedPreferences? prefs;

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _meeting;
  late final TextEditingController _notes;
  late final TextEditingController _startTime;
  late final TextEditingController _endTime;
  String? _calendarId;
  bool _allDay = false;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _startZone;
  late String _endZone;
  bool _differentEnd = false;
  int? _color;
  final List<_ReminderRow> _reminders = [];
  late Duration _duration;
  int _span = 0; // days an all-day event spans beyond its first day (EVT-02.g)
  late String _initialSig;
  final FocusNode _startFocus = FocusNode();
  final FocusNode _endFocus = FocusNode();
  final Map<String, String> _errors = {};

  CalendarController get c => widget.controller;
  bool get _editing => widget.event != null;
  TimeFormat get _format => c.timeFormat;

  @override
  void initState() {
    super.initState();
    final e = widget.event ?? widget.duplicateOf;
    _title = TextEditingController(text: e?.title ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _meeting = TextEditingController(text: e?.meetingUrl ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _startTime = TextEditingController();
    _endTime = TextEditingController();
    // A time is accepted in 12-hour or 24-hour form and shown in the chosen notation once the
    // user leaves the field.
    _startFocus.addListener(() {
      if (!_startFocus.hasFocus) _normalizeTime(true);
    });
    _endFocus.addListener(() {
      if (!_endFocus.hasFocus) _normalizeTime(false);
    });
    for (final r in e?.reminders ?? const <int>[]) {
      _reminders.add(_ReminderRow.fromMinutes(r));
    }
    _color = e?.color;
    if (e != null) {
      _calendarId = e.calendarId;
      _allDay = e.allDay;
      _startZone = e.startZone;
      _endZone = e.endZone;
      _differentEnd = e.startZone != e.endZone;
      final s = e.startIn(zoneNamed(_startZone));
      var en = e.endIn(zoneNamed(_endZone));
      _startDate = DateTime(s.year, s.month, s.day);
      if (_allDay) {
        en = en.subtract(
          const Duration(days: 1),
        ); // the last day is included (EVT-02.f)
      }
      _endDate = DateTime(en.year, en.month, en.day);
      _startTime.text = _fmt(s.hour, s.minute);
      final e2 = e.endIn(zoneNamed(_endZone));
      _endTime.text = _fmt(e2.hour, e2.minute);
      _duration = e.endUtc.difference(e.startUtc);
      _span = _endDate.difference(_startDate).inDays;
    } else {
      // EVT-01.b: the calendar zone or the saved device zone preference.
      _calendarId = c.defaultCalendarId;
      _startZone = _defaultEventZone;
      _endZone = _startZone;
      // EVT-01.m: a new event starts at 9:00 for an hour on the day clicked, or today.
      final d = widget.day ?? c.today;
      _allDay = widget.allDay;
      final startMin = widget.startMinute ?? _defaultStart();
      final endTotal =
          startMin +
          c
              .defaultLength
              .inMinutes; // EVT-02.n: the default length is a user setting
      _startDate = DateTime(d.year, d.month, d.day);
      _endDate = DateTime(d.year, d.month, d.day + endTotal ~/ 1440);
      _startTime.text = _fmt(startMin ~/ 60, startMin % 60);
      _endTime.text = _fmt((endTotal % 1440) ~/ 60, endTotal % 60);
      _duration = c.defaultLength;
    }
    // A copy is a change in itself (it is saved as a new event); otherwise Save waits for an edit.
    _initialSig = widget.duplicateOf != null ? '0000copy' : _signature();
    if (widget.event == null && widget.duplicateOf == null && widget.startMinute == null && !widget.allDay && widget.prefs == null) {
      _loadDeviceStart();
    }
  }

  int _defaultStart() => CalendarDefaults.load(widget.prefs).startMinutes;

  /// EVT-01.m: without given preferences the device's own are read; the default start replaces 9:00
  /// only while the form is untouched (and never if they cannot be read).
  Future<void> _loadDeviceStart() async {
    try {
      final start = CalendarDefaults.load(await SharedPreferences.getInstance()).startMinutes;
      if (!mounted || start == standardEventStartMinutes || _signature() != _initialSig) return;
      final endTotal = start + c.defaultLength.inMinutes;
      final d = _startDate;
      setState(() {
        _endDate = DateTime(d.year, d.month, d.day + endTotal ~/ 1440);
        _startTime.text = _fmt(start ~/ 60, start % 60);
        _endTime.text = _fmt((endTotal % 1440) ~/ 60, endTotal % 60);
        _initialSig = _signature();
      });
    } on Object {
      // keep 9:00
    }
  }

  @override
  void dispose() {
    for (final t in [
      _title,
      _location,
      _meeting,
      _notes,
      _startTime,
      _endTime,
    ]) {
      t.dispose();
    }
    _startFocus.dispose();
    _endFocus.dispose();
    for (final r in _reminders) {
      r.number.dispose();
    }
    super.dispose();
  }

  /// Everything the user can change, as one string: Save is available only when it differs
  /// from how the dialog opened (UIC-27.b).
  String _signature() => [
    _title.text,
    _calendarId,
    _allDay,
    _startDate,
    _endDate,
    _startTime.text,
    _endTime.text,
    _startZone,
    _endZone,
    _differentEnd,
    _color,
    _location.text,
    _meeting.text,
    _notes.text,
    for (final r in _reminders) '${r.number.text}${r.unit.name}',
  ].join('|');

  String _fmt(int h, int m) => formatTimeOfDay(h, m, _format);

  String? _calendarZone() {
    for (final cal in c.calendars) {
      if (cal.id == _calendarId) return cal.zone;
    }
    return null;
  }

  String get _defaultEventZone {
    final zone = _calendarZone();
    return zone != null && isKnownZone(zone) ? zone : c.baseZone.name;
  }

  // ---- instants -----------------------------------------------------------

  TZDateTime? _instant(DateTime date, String timeText, String zone) {
    // EVT-02.n: an empty time is not read here; saving fills it in.
    if (timeText.trim().isEmpty) return null;
    final t = parseTimeInput(timeText);
    if (t == null) return null;
    return TZDateTime(
      zoneNamed(zone),
      date.year,
      date.month,
      date.day,
      t.hour,
      t.minute,
    );
  }

  TZDateTime? get _startInstant => _allDay
      ? TZDateTime(
          zoneNamed(_startZone),
          _startDate.year,
          _startDate.month,
          _startDate.day,
        )
      : _instant(_startDate, _startTime.text, _startZone);

  TZDateTime? get _endInstant => _allDay
      ? TZDateTime(
          zoneNamed(_endZone),
          _endDate.year,
          _endDate.month,
          _endDate.day + 1,
        )
      : _instant(
          _endDate,
          _endTime.text,
          _differentEnd ? _endZone : _startZone,
        );

  /// EVT-02.b: changing the start keeps the duration, across midnight if needed.
  void _startChanged() {
    final s = _startInstant;
    if (s == null) return;
    if (_allDay) {
      _endDate = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day + _span,
      );
      return;
    }
    final endZone = zoneNamed(_differentEnd ? _endZone : _startZone);
    final end = TZDateTime.from(s.toUtc().add(_duration), endZone);
    _endDate = DateTime(end.year, end.month, end.day);
    _endTime.text = _fmt(end.hour, end.minute);
  }

  /// EVT-02.b: changing the end sets the duration later start changes keep.
  void _endChanged() {
    if (_allDay) {
      final d = _endDate.difference(_startDate).inDays;
      if (d >= 0) _span = d;
      return;
    }
    final s = _startInstant;
    final e = _endInstant;
    if (s == null || e == null || !e.isAfter(s)) return;
    _duration = e.difference(s);
  }

  // ---- actions ------------------------------------------------------------

  Future<void> _pickStart() async {
    final d = await pickDay(context, initial: _startDate, today: c.today);
    if (d == null) return;
    setState(() {
      _startDate = d;
      _startChanged();
    });
  }

  Future<void> _pickEnd() async {
    final d = await pickDay(context, initial: _endDate, today: c.today);
    if (d == null) return;
    setState(() {
      _endDate = d;
      _endChanged();
    });
  }

  /// EVT-02.n: leaving the start time empty uses the time now; leaving the end
  /// time empty uses one default event length (a user setting) after the start.
  void _fillEmptyTimes() {
    if (_allDay) return;
    if (_startTime.text.trim().isEmpty) {
      final now = TZDateTime.from(c.nowUtc, zoneNamed(_startZone));
      _startTime.text = _fmt(now.hour, now.minute);
    }
    if (_endTime.text.trim().isEmpty) {
      final s = _startInstant;
      if (s != null) {
        final end = TZDateTime.from(
          s.toUtc().add(c.defaultLength),
          zoneNamed(_differentEnd ? _endZone : _startZone),
        );
        _endDate = DateTime(end.year, end.month, end.day);
        _endTime.text = _fmt(end.hour, end.minute);
        _duration = c.defaultLength;
      }
    }
  }

  void _save() {
    final m = context.msg;
    _normalizeTime(true);
    _normalizeTime(false);
    _fillEmptyTimes();
    final errors = <String, String>{};
    if (_title.text.trim().isEmpty) errors['title'] = m('theEventNeedsATitle');
    final s = _startInstant;
    final e = _endInstant;
    if (_allDay) {
      if (_endDate.isBefore(_startDate)) {
        errors['end'] = m('theLastDayIsBefore');
      }
    } else {
      if (s == null) errors['start'] = m('typeATimeLike9');
      if (e == null) errors['end'] = m('typeATimeLike9');
      if (s != null && e != null && !e.isAfter(s)) {
        errors['end'] = m('theEndHasToBe');
      }
    }
    if (!isValidMeetingUrl(_meeting.text.trim())) {
      errors['meeting'] = m('onlineMeetingNeedsLink');
    }
    // A reminder with a number that is not a whole number up to the longest lead is not valid.
    if (_reminders.any(
      (r) => r.number.text.trim().isNotEmpty && r.minutes == null,
    )) {
      errors['reminders'] = m('reminderRange');
    }
    if (errors.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(errors);
      });
      return;
    }
    final old = widget.event;
    final endZone = _differentEnd ? _endZone : _startZone;
    final built = SuiteEvent(
      id: old?.id ?? 'ev-${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      startUtc: s!.toUtc(),
      endUtc: e!.toUtc(),
      startZone: _startZone,
      endZone: endZone,
      allDay: _allDay,
      calendarId: old == null ? _calendarId ?? c.defaultCalendarId : _calendarId,
      edited: old?.edited ?? false,
      changedBySource: old?.changedBySource ?? false,
      hiddenFromGoogle: old?.hiddenFromGoogle ?? false,
      deleted: old?.deleted ?? false,
      custom: old?.custom ?? true,
      location: _location.text.trim(),
      notes: _notes.text,
      color: _color,
      reminders: normalizeReminders([
        for (final r in _reminders)
          if (r.minutes != null) r.minutes!,
      ]),
      meetingUrl: _meeting.text.trim(),
    );
    if (old != null && _sameContent(old, built)) {
      Navigator.of(context).pop(); // EVT-01.q: no change, no edit recorded
      return;
    }
    c.upsertEvent(
      old != null && !old.custom ? built.copyWith(edited: true) : built,
    );
    Navigator.of(context).pop();
  }

  bool _sameContent(SuiteEvent a, SuiteEvent b) {
    final x = a.toJson()..remove('edited');
    final y = b.toJson()..remove('edited');
    return x.toString() == y.toString();
  }

  Future<bool> _confirm(String question) => confirmYesNo(context, question);

  Future<void> _delete() async {
    final m = context.msg;
    final e = widget.event!;
    if (e.custom) {
      // EVT-01.e: a custom event is deleted (asking first, UIC-06) and leaves its calendar.
      if (!await _confirm(m('deleteEventAsk'))) return;
      c.deleteEvent(e.id);
    } else {
      // CAP-02: an event from a source is hidden, never deleted.
      if (!e.hiddenFromGoogle && !await _confirm(m('hideEventAsk'))) return;
      c.setHidden(e.id, !e.hiddenFromGoogle);
    }
    if (mounted) Navigator.of(context).pop();
  }

  // ---- build --------------------------------------------------------------

  /// A field's label sits over it (THM-07.b), with a red asterisk when required.
  Widget _labeled(
    String label,
    Widget field, {
    bool required = false,
    bool fill = false,
    Widget? trailing,
    bool prioritizeTrailing = false,
    String? error,
  }) {
    final t = context.tokens;
    final title = Text(
      label,
      maxLines: 1,
      style: TextStyle(
        color: t.muted,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: suiteLabelGap),
          child: SizedBox(
            height: suiteLabelHeight,
            child: Row(
              children: [
                if (prioritizeTrailing)
                  title
                else
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: title,
                    ),
                  ),
                if (required)
                  Text(
                    ' *',
                    style: TextStyle(
                      color: t.bad,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                if (trailing != null) ...[
                  const SizedBox(width: suiteColumnGap),
                  Flexible(child: trailing),
                ],
                // The note says what is wrong, on this line, next to the label (UIC-19).
                if (error != null) ...[
                  const SizedBox(width: suiteColumnGap),
                  Expanded(child: ErrorNote(error)),
                ],
              ],
            ),
          ),
        ),
        if (fill) Expanded(child: field) else field,
      ],
    );
  }

  /// Every single-line box (text, time, date, dropdown, color) is exactly
  /// [suiteControlHeight] tall; only the multi-line Notes box passes [multiline].
  InputDecoration _decoration({String? error, Widget? suffix, bool dropdown = false, bool multiline = false}) {
    final t = context.tokens;
    return InputDecoration(
      isDense: true,
      constraints: multiline ? const BoxConstraints() : const BoxConstraints.tightFor(height: suiteControlHeight),
      errorText:
          null, // the note is on the label line (ErrorNote), not below the field
      errorMaxLines: 3,
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: suiteControlHeight, minHeight: suiteControlHeight),
      contentPadding: EdgeInsets.symmetric(horizontal: suiteDialogPadding, vertical: dropdown ? suiteDropdownVerticalPadding : suiteFieldVerticalPadding),
      filled: true,
      fillColor: t.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: error != null ? t.bad : t.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: error != null ? t.bad : t.line),
      ),
      focusedBorder: error != null
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.bad),
            )
          : null,
    );
  }

  Widget _checkbox(
    String key,
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    String? shortLabel,
  }) {
    final t = context.tokens;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: suiteLabelHeight,
            height: suiteLabelHeight,
            child: Checkbox(
              key: ValueKey(key),
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final style = DefaultTextStyle.of(context).style.copyWith(
                  color: t.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                );
                final painter = TextPainter(
                  text: TextSpan(text: label, style: style),
                  maxLines: 1,
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout();
                final fits = painter.width <= constraints.maxWidth;
                painter.dispose();
                return Text(
                  fits ? label : shortLabel ?? label,
                  key: ValueKey('$key-label'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    final heading = widget.duplicateOf != null
        ? m('duplicateEvent')
        : (_editing ? m('editEvent') : m('addEvent'));
    final old = widget.event;
    final phone = MediaQuery.sizeOf(context).width <= phoneMaxWidth;
    final notes = _labeled(
      m('notes'),
      TextField(
        key: const ValueKey('event-notes'),
        groupId: _notes,
        controller: _notes,
        maxLines: phone ? 10 : null,
        minLines: phone ? 10 : null,
        expands: !phone,
        textAlignVertical: TextAlignVertical.top,
        inputFormatters: [LengthLimitingTextInputFormatter(eventNotesLength)],
        decoration: _decoration(multiline: true),
        onChanged: (_) => setState(() => _errors.remove('notes')),
      ),
      fill: !phone,
    );
    return Padding(
      key: const ValueKey('event-dialog'),
      padding: const EdgeInsets.all(suiteDialogPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // The back arrow closes the dialog (UIC-02).
              SizedBox(
                width: 34,
                height: 34,
                child: OutlinedButton(
                  key: const ValueKey('event-back'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: t.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Tooltip(
                    message: m('cancel'),
                    child: Icon(SuiteIcons.arrowBack, size: 20, color: t.muted),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  heading,
                  style: SuiteText.moduleKind(
                    t,
                    windowWidth: MediaQuery.sizeOf(context).width,
                  ),
                ),
              ),
              if (c.calendars.isEmpty) ?_duplicateButton(m),
            ],
          ),
          const SizedBox(height: suitePartGap),
          if (phone) ...[
            _leftColumn(m),
            const SizedBox(height: suitePartGap),
            notes,
          ] else
            // The fields set the height during layout, and Notes fills the
            // space beside them in the same frame (EVT-01.i).
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = suiteColumnGap;
                final columnWidth = (constraints.maxWidth - gap) / 2;
                return Stack(
                  children: [
                    SizedBox(width: columnWidth, child: _leftColumn(m)),
                    Positioned(
                      left: columnWidth + gap,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: notes,
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (old != null)
                // Delete uses the theme error role and a trash icon.
                // Hide and Show for an event of a source have an eye.
                TextButton.icon(
                  key: const ValueKey('event-delete'),
                  onPressed: _delete,
                  icon: Icon(
                    old.custom
                        ? SuiteIcons.delete
                        : (old.hiddenFromGoogle
                              ? SuiteIcons.visibility
                              : SuiteIcons.visibilityOff),
                    size: 18,
                    color: old.custom ? t.bad : t.muted,
                  ),
                  label: Text(
                    old.custom
                        ? m('deleteEvent')
                        : (old.hiddenFromGoogle
                              ? m('showButton')
                              : m('hideButton')),
                    style: TextStyle(color: old.custom ? t.bad : t.text),
                  ),
                ),
              const Spacer(),
              // UIC-27: the shared Cancel | Save pair, at the bottom right.
              CancelSavePair(
                cancelKey: const ValueKey('event-cancel'),
                saveKey: const ValueKey('event-save'),
                cancelLabel: m('cancel'),
                saveLabel: m('save'),
                onCancel: () => Navigator.of(context).pop(),
                saveEnabled: _signature() != _initialSig,
                onSave: _save,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leftColumn(Messages m) {
    const gap = SizedBox(height: suitePartGap);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _labeled(
          m('title'),
          _textField('title', _title, max: eventTitleLength),
          required: true,
          error: _errors['title'],
        ),
        gap,
        _labeled(
          m('location'),
          _textField(
            'location',
            _location,
            max: eventLocationLength,
            suffix: IconButton(
              style: suiteIconButtonStyle(compact: true),
              key: const ValueKey('event-map'),
              tooltip: m('openMap'),
              icon: const Icon(SuiteIcons.map, size: 18),
              onPressed: _location.text.trim().isEmpty
                  ? null
                  : () => launchUrl(mapUrl(_location.text.trim())),
            ),
          ),
        ),
        gap,
        _labeled(
          m('onlineMeeting'),
          _textField(
            'meeting',
            _meeting,
            max: eventMeetingLength,
            suffix: IconButton(
              style: suiteIconButtonStyle(compact: true),
              key: const ValueKey('event-open-meeting'),
              tooltip: m('openLink'),
              icon: const Icon(SuiteIcons.link, size: 18),
              onPressed:
                  (_meeting.text.trim().isEmpty ||
                      !isValidMeetingUrl(_meeting.text.trim()))
                  ? null
                  : () => launchUrl(Uri.parse(_meeting.text.trim())),
            ),
          ),
          error: _errors['meeting'],
        ),
        gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.calendars.isNotEmpty)
              Expanded(
                child: _labeled(
                  m('calendarWord'),
                  trailing: _duplicateButton(m),
                  DropdownButtonFormField<String?>(
                    key: const ValueKey('event-calendar'),
                    initialValue: _calendarId,
                    isExpanded: true,
                    decoration: _decoration(dropdown: true),
                    items: [
                      if (c.defaultCalendarId == null)
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(m('local')),
                        ),
                      for (final cal in c.calendars)
                        DropdownMenuItem<String?>(
                          value: cal.id,
                          child: Text(cal.name),
                        ),
                    ],
                    onChanged: (v) => setState(() {
                      final previousDefault = _defaultEventZone;
                      _calendarId = v;
                      if (!_editing &&
                          widget.duplicateOf == null &&
                          _startZone == previousDefault) {
                        _startZone = _defaultEventZone;
                        if (!_differentEnd) _endZone = _startZone;
                      }
                    }),
                  ),
                ),
              ),
            if (c.calendars.isNotEmpty) const SizedBox(width: suiteColumnGap),
            Expanded(
              child: _labeled(
                m('changeColor'),
                _colorButton(m),
                error: _errors['color'],
              ),
            ),
          ],
        ),
        gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _labeled(
                m('starts'),
                _dateButton(start: true),
                required: true,
              ),
            ),
            const SizedBox(width: suiteColumnGap),
            Expanded(
              child: _labeled(
                m('ends'),
                _dateButton(start: false),
                required: true,
                error: _allDay ? _errors['end'] : null,
                trailing: _checkbox(
                  'event-allday',
                  m('allDay'),
                  _allDay,
                  (v) => setState(() {
                    _allDay = v;
                    if (_allDay && _endDate.isBefore(_startDate)) {
                      _endDate = _startDate;
                    }
                    if (_allDay) _span = _endDate.difference(_startDate).inDays;
                  }),
                ),
              ),
            ),
          ],
        ),
        gap,
        // All-day hides the time fields and zones; it never removes them, so the dialog
        // keeps its size and nothing moves (popups are not resized once drawn).
        Stack(
          children: [
            Visibility(
              visible: !_allDay,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _labeled(
                          m('time'),
                          _timeField(start: true),
                          required: true,
                          error: _allDay ? null : _errors['start'],
                        ),
                      ),
                      const SizedBox(width: suiteColumnGap),
                      Expanded(
                        child: _labeled(
                          m('time'),
                          _timeField(start: false),
                          required: true,
                          error: _allDay ? null : _errors['end'],
                          prioritizeTrailing: true,
                          trailing: _checkbox(
                            'event-diffzone',
                            m('differentEndZone'),
                            _differentEnd,
                            (v) => setState(() {
                              _differentEnd = v;
                              if (!_differentEnd) {
                                _endZone =
                                    _startZone; // unticking sets the end zone back
                              }
                            }),
                            shortLabel: m('differentEndZoneShort'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  gap,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _labeled(
                          _differentEnd ? m('startTimeZone') : m('timeZone'),
                          _fixedHeight(ZoneField(
                            key: const ValueKey('zone-start'),
                            value: _startZone,
                            defaultZone: _defaultEventZone,
                            onChanged: (z) => setState(() {
                              _startZone = z;
                              if (!_differentEnd) _endZone = z;
                              _startChanged();
                            }),
                          )),
                        ),
                      ),
                      const SizedBox(width: suiteColumnGap),
                      Expanded(
                        // The end zone's place is always kept; it is only shown when the end is in a
                        // different zone.
                        child: Visibility(
                          visible: _differentEnd,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: _labeled(
                            m('endTimeZone'),
                            _fixedHeight(ZoneField(
                              key: const ValueKey('zone-end'),
                              value: _endZone,
                              defaultZone: _defaultEventZone,
                              onChanged: (z) => setState(() {
                                _endZone = z;
                                _startChanged();
                              }),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        gap,
        // Reminders belong to the left half with the other fields (and above Link to), so Notes
        // never separates them from the fields when the window is narrow.
        _remindersBlock(m),
      ],
    );
  }

  /// A field of a shared widget (the zone picker) drawn exactly one control tall (THM-04.b).
  Widget _fixedHeight(Widget field) => SizedBox(height: suiteControlHeight, child: field);

  /// EVT-06.a: Duplicate opens an editor holding a copy of the event (in the same
  /// calendar; the calendar dropdown can change it before saving). It sits next to
  /// the calendar's name.
  Widget? _duplicateButton(Messages m) {
    final e = widget.event;
    if (e == null) return null;
    return IconButton(
      key: const ValueKey('event-duplicate'),
      tooltip: m('duplicateEvent'),
      iconSize: 18,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
      icon: const Icon(SuiteIcons.contentCopy),
      onPressed: () {
        final nav = Navigator.of(context);
        nav.pop();
        openEventDialog(nav.context, c, duplicateOf: e);
      },
    );
  }

  Widget _textField(
    String key,
    TextEditingController ctl, {
    int? max,
    Widget? suffix,
  }) {
    return TextField(
      key: ValueKey('event-$key'),
      controller: ctl,
      inputFormatters: [if (max != null) LengthLimitingTextInputFormatter(max)],
      decoration: _decoration(error: _errors[key], suffix: suffix),
      onChanged: (_) => setState(() => _errors.remove(key)),
    );
  }

  /// A date shows as a field with a calendar icon; it opens the date picker.
  Widget _dateButton({required bool start}) {
    final t = context.tokens;
    final locale = context.msg.locale;
    final date = start ? _startDate : _endDate;
    return InkWell(
      key: ValueKey('event-${start ? 'start' : 'end'}-date'),
      borderRadius: BorderRadius.circular(8),
      onTap: start ? _pickStart : _pickEnd,
      child: SizedBox(height: suiteControlHeight, child: InputDecorator(
        decoration: _decoration(),
        child: Row(
          children: [
            Expanded(child: Text(DateFormat.yMMMd(locale).format(date), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Icon(SuiteIcons.calendarToday, size: 16, color: t.muted),
          ],
        ),
      )),
    );
  }

  /// Rewrites a readable time in the chosen notation (hh:mm am, or hh:mm); an unreadable or
  /// empty one is left as typed.
  void _normalizeTime(bool start) {
    final ctl = start ? _startTime : _endTime;
    final t = parseTimeInput(ctl.text);
    if (t == null) return;
    final s = _fmt(t.hour, t.minute);
    if (ctl.text != s) setState(() => ctl.text = s);
  }

  /// The up and down arrows (and keys) step a time by the drag step in DEF-01 (15 minutes),
  /// to the next or previous step; an empty field starts from the time now.
  void _stepTime(bool start, int dir) {
    final ctl = start ? _startTime : _endTime;
    final zone = zoneNamed(start || !_differentEnd ? _startZone : _endZone);
    final base =
        parseTimeInput(ctl.text) ??
        (() {
          final n = TZDateTime.from(c.nowUtc, zone);
          return TimeOfDayValue(n.hour, n.minute);
        })();
    final stepped = dir > 0
        ? (base.minutes ~/ dragStepMinutes + 1) * dragStepMinutes
        : ((base.minutes + dragStepMinutes - 1) ~/ dragStepMinutes - 1) *
              dragStepMinutes;
    final next = stepped.clamp(0, 24 * 60 - 1);
    ctl.text = _fmt(next ~/ 60, next % 60);
    setState(() {
      _errors.remove(start ? 'start' : 'end');
      if (start) {
        _startChanged();
      } else {
        _endChanged();
      }
    });
  }

  Widget _timeField({required bool start}) {
    final errKey = start ? 'start' : 'end';
    final name = start ? 'start' : 'end';
    return ArrowKeyStepper(
      onUp: () => _stepTime(start, 1),
      onDown: () => _stepTime(start, -1),
      child: TextField(
        key: ValueKey('event-$name-time'),
        controller: start ? _startTime : _endTime,
        focusNode: start ? _startFocus : _endFocus,
        onSubmitted: (_) => _normalizeTime(start),
        decoration: _decoration(
          error: _allDay ? null : _errors[errKey],
          suffix: StepperArrows(
            upKey: ValueKey('event-$name-time-up'),
            downKey: ValueKey('event-$name-time-down'),
            onUp: () => _stepTime(start, 1),
            onDown: () => _stepTime(start, -1),
          ),
        ),
        onChanged: (_) => setState(() {
          _errors.remove(errKey);
          if (start) {
            _startChanged();
          } else {
            _endChanged();
          }
        }),
      ),
    );
  }

  /// UIC-10: the shared color palette opens from one button that shows the chosen
  /// color; the event editor adds a "calendar default" choice. A picked color
  /// shows and closes the palette.
  Widget _colorButton(Messages m) {
    final t = context.tokens;
    final cal = c.calendars.where((x) => x.id == _calendarId).firstOrNull;
    final fallback = cal?.color ?? defaultEventColor;
    // UIC-20: a color outside the palette is shown as the nearest palette color.
    final shown = _color == null ? fallback : nearestEventColor(_color!);
    final name = _color == null ? m('defaultColor') : paletteColorName(m, nearestPaletteColor(_color!, eventPalette));
    return InkWell(
      key: const ValueKey('event-color-button'),
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final picked = await showColorPicker(
          context,
          palette: eventPalette,
          current: _color,
          defaultColor: fallback,
        );
        if (!mounted || picked == null) return;
        setState(() => _color = picked == colorPickerDefault ? null : picked);
      },
      child: InputDecorator(
        decoration: _decoration(dropdown: true),
        child: Row(
          children: [
            Container(
              key: const ValueKey('event-color-swatch'),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Color(shown),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
            Icon(SuiteIcons.arrowDropDown, color: t.muted),
          ],
        ),
      ),
    );
  }

  /// The arrows step a reminder's number by one, from 0 up to the longest lead in its unit.
  void _stepReminder(int i, int dir) {
    final row = _reminders[i];
    final max = longestReminderLead ~/ row.unit.inMinutes;
    final n = ((int.tryParse(row.number.text.trim()) ?? 0) + dir).clamp(0, max);
    row.number.text = '$n';
    setState(() => _errors.remove('reminders'));
  }

  /// EVT-03.e: reminders are rows of method, number and unit (Notification, 1,
  /// hours) with a remove button, from the start back to the longest lead in DEF-01;
  /// once the most reminders in DEF-01 are set, adding another is disabled (EVT-03.k).
  Widget _remindersBlock(Messages m) {
    final t = context.tokens;
    final full = _reminders.length >= remindersPerEvent;
    InputDecoration box() => _decoration();
    return Column(
      key: const ValueKey('event-reminders'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: suiteLabelGap),
          child: Row(
            children: [
              Text(
                m('reminders'),
                style: TextStyle(
                  color: t.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (_errors['reminders'] != null) ...[
                const SizedBox(width: suiteColumnGap),
                Expanded(child: ErrorNote(_errors['reminders']!)),
              ],
            ],
          ),
        ),
        for (var i = 0; i < _reminders.length; i++)
          Padding(
            key: ValueKey('reminder-row-$i'),
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                // The method: a notification (the only one so far).
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('reminder-method-$i'),
                    initialValue: 'notification',
                    isExpanded: true,
                    decoration: box(),
                    items: [
                      DropdownMenuItem(
                        value: 'notification',
                        child: Text(m('notification')),
                      ),
                    ],
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 84,
                  child: ArrowKeyStepper(
                    onUp: () => _stepReminder(i, 1),
                    onDown: () => _stepReminder(i, -1),
                    child: TextField(
                      key: ValueKey('reminder-number-$i'),
                      controller: _reminders[i].number,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      decoration: box().copyWith(
                        suffixIcon: StepperArrows(
                          upKey: ValueKey('reminder-number-$i-up'),
                          downKey: ValueKey('reminder-number-$i-down'),
                          onUp: () => _stepReminder(i, 1),
                          onDown: () => _stepReminder(i, -1),
                        ),
                      ),
                      onChanged: (_) =>
                          setState(() => _errors.remove('reminders')),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<ReminderUnit>(
                    key: ValueKey('reminder-unit-$i'),
                    initialValue: _reminders[i].unit,
                    isExpanded: true,
                    decoration: box(),
                    items: [
                      for (final u in ReminderUnit.values)
                        DropdownMenuItem(
                          value: u,
                          child: Text(m(u.messageKey)),
                        ),
                    ],
                    onChanged: (u) => setState(() {
                      _reminders[i].unit = u ?? _reminders[i].unit;
                      _errors.remove('reminders');
                    }),
                  ),
                ),
                TextFieldTapRegion(
                  groupId: _notes,
                  child: IconButton(
                    key: ValueKey('reminder-remove-$i'),
                    tooltip: m('remove'),
                    icon: Icon(SuiteIcons.close, size: 20, color: t.muted),
                    onPressed: () {
                      setState(() {
                        _reminders.removeAt(i).number.dispose();
                        _errors.remove('reminders');
                      });
                      relockPopupSize(context); // removing one may shrink it
                    },
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextFieldTapRegion(
            groupId: _notes,
            child: TextButton.icon(
              key: const ValueKey('reminder-add'),
              // EVT-03.k: once the most reminders are set, the button is disabled.
              onPressed: full
                  ? null
                  : () {
                      setState(() {
                        _reminders.add(_ReminderRow.fromMinutes(10));
                      });
                      relockPopupSize(context); // adding a reminder may grow it
                    },
              icon: const Icon(SuiteIcons.add, size: 18),
              label: Text(m('addReminder')),
            ),
          ),
        ),
      ],
    );
  }
}

/// One reminder row: a number and the unit it is in.
class _ReminderRow {
  _ReminderRow(int number, this.unit)
    : number = TextEditingController(text: '$number');

  factory _ReminderRow.fromMinutes(int minutes) {
    final (n, u) = splitReminder(minutes);
    return _ReminderRow(n, u);
  }

  final TextEditingController number;
  ReminderUnit unit;

  /// The reminder in minutes before the start, or null when the number is not a
  /// whole number or is past the longest lead.
  int? get minutes {
    final n = int.tryParse(number.text.trim());
    if (n == null || n < 0) return null;
    final m = n * unit.inMinutes;
    return m > longestReminderLead ? null : m;
  }
}
