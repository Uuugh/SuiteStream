// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/suite_theme.dart' show defaultAnimationDuration;
import '../theme/event_colors.dart' show nextCalendarColor;
import '../time/length_input.dart';
import '../time/local_zone.dart';
import '../time/suite_event.dart';
import '../time/time_format.dart';
import '../time/zones.dart';
import 'event_drag.dart';
import 'event_filter.dart';
import 'event_store.dart';
import 'local_calendar_store.dart';

/// CAL-01.b: the calendar's views.
enum CalendarView { month, week, fiveDay, day, list }

/// DEF-01: supported calendar years, 2000 to 2100.
const int firstSupportedYear = 2000;
const int lastSupportedYear = 2100;

/// DEF-01: hourly density is saved as event lines per hour.
const int defaultHourLines = 2;
const int minHourLines = 1;
const int maxHourLines = 6;

/// The state of the main calendar. UIC-13: every change notifies at once.
class CalendarController extends ChangeNotifier {
  CalendarController({
    required LocalZone localZone,
    required TimeFormat timeFormat,
    List<SuiteEvent> events = const [],
    List<SuiteCalendar> calendars = const [],
    EventFilter? filter,
    EventStore? store,
    DateTime Function()? clock,
    DateTime? focused,
    CalendarView? view,
    SharedPreferences? prefs,
    LocalCalendarStore? localCalendarStore,
  })  : _prefs = prefs,
        _localCalendarStore = localCalendarStore,
        _localZone = localZone,
        _timeFormat = timeFormat,
        _store = store,
        _events = store == null ? List.of(events) : [...store.load(), ...events],
        _calendars = List.of(calendars),
        filter = filter ?? EventFilter(),
        _clock = clock ?? DateTime.now,
        _view = view ?? CalendarView.month,
        _viewChosen = view != null {
    _loadViewSettings(view == null);
    if (localCalendarStore != null) {
      final saved = localCalendarStore.load();
      if (saved != null && saved.calendars.isNotEmpty) {
        _calendars = saved.calendars;
        _defaultCalendarId = _calendars.any((c) => c.id == saved.defaultId)
            ? saved.defaultId
            : _calendars.first.id;
      } else {
        _defaultCalendarId = _calendars.firstOrNull?.id;
      }
    }
    _focused = _supported(focused ?? today) ? _dateOnly(focused ?? today) : today;
    this.filter.addListener(notifyListeners); // FLT-01.d: every view follows the filter
  }

  final DateTime Function() _clock;
  final EventFilter filter;
  final EventStore? _store;
  final SharedPreferences? _prefs;
  final LocalCalendarStore? _localCalendarStore;
  String? _defaultCalendarId;
  bool _savingCalendars = false;
  String? _viewZone;
  LocalZone _localZone;
  TimeFormat _timeFormat;
  List<SuiteEvent> _events;
  List<SuiteCalendar> _calendars;
  CalendarView _view;
  bool _viewChosen;
  bool _phone = false;
  late DateTime _focused;

  int _hourLines = defaultHourLines;

  int get hourLines => _hourLines;
  set hourLines(int value) {
    final lines = value.clamp(minHourLines, maxHourLines);
    if (lines == _hourLines) return;
    _hourLines = lines;
    _prefs?.setInt(_hourLinesKey, lines);
    notifyListeners();
  }


  /// TIM-03: the Local zone is the system zone or a fixed zone from Settings;
  /// CAL-02.a: the calendar's own time zone picker shows another zone for now.
  LocalZone get localZone =>
      _viewZone == null ? _localZone : LocalZone.fixed(_viewZone!, systemZone: _localZone.systemZoneName);

  /// The zone from Settings (SET-02): the system zone or a fixed zone.
  LocalZone get baseZone => _localZone;

  /// CAL-02.a: the zone chosen in the calendar's own picker, or null.
  String? get viewZone => _viewZone;
  set viewZone(String? z) {
    _viewZone = z;
    _prefs?.setString(_zoneKey, z ?? '');
    notifyListeners();
  }
  TimeFormat get timeFormat => _timeFormat;
  List<SuiteEvent> get events => List.unmodifiable(_events);
  List<SuiteCalendar> get calendars => List.unmodifiable(_calendars);
  String? get defaultCalendarId => _defaultCalendarId;

  bool canDeleteCalendar(String id) =>
      _calendars.length > 1 &&
      _events.every((event) => event.calendarId != id) &&
      _removed.every((event) => event.calendarId != id);

  bool canClearLastCalendar(String id) =>
      _calendars.length == 1 &&
      _calendars.single.id == id &&
      _events.any((event) => event.calendarId == id);

  /// Empty the only local calendar while retaining its identity and preferences.
  Future<bool> clearLastCalendar(String id) async {
    if (_savingCalendars || !canClearLastCalendar(id)) return false;
    final remaining = _events.where((event) => event.calendarId != id).toList();
    _savingCalendars = true;
    try {
      await _store?.save(remaining);
      _events = remaining;
      _removed.removeWhere((event) => event.calendarId == id);
      if (_selectedId != null && remaining.every((event) => event.id != _selectedId)) {
        _selectedId = null;
      }
      notifyListeners();
      return true;
    } on Exception {
      return false;
    } finally {
      _savingCalendars = false;
    }
  }

  /// A new calendar takes [color] or else the next unused calendar color; a rename keeps its color unless [color] is given.
  Future<bool> saveCalendar(String name, {String? id, int? color}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (id == null) {
      final calendar = SuiteCalendar(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        name: trimmed,
        color: color ?? nextCalendarColor(_calendars.map((c) => c.color)),
      );
      return _saveCalendars([..._calendars, calendar], _defaultCalendarId ?? calendar.id);
    }
    if (_calendars.every((c) => c.id != id)) return false;
    final updated = [
      for (final c in _calendars)
        if (c.id == id)
          SuiteCalendar(id: id, name: trimmed, color: color ?? c.color, zone: c.zone)
        else
          c,
    ];
    return _saveCalendars(updated, _defaultCalendarId ?? id);
  }

  Future<bool> setDefaultCalendar(String id) =>
      _calendars.any((c) => c.id == id) ? _saveCalendars(_calendars, id) : Future.value(false);

  Future<bool> deleteCalendar(String id) async {
    if (!canDeleteCalendar(id) || _calendars.every((c) => c.id != id)) return false;
    final remaining = _calendars.where((c) => c.id != id).toList();
    final defaultId = _defaultCalendarId == id ? remaining.first.id : _defaultCalendarId ?? remaining.first.id;
    return _saveCalendars(remaining, defaultId);
  }

  Future<bool> _saveCalendars(List<SuiteCalendar> calendars, String defaultId) async {
    final store = _localCalendarStore;
    if (_savingCalendars || store == null) return false;
    _savingCalendars = true;
    try {
      if (!await store.save(calendars, defaultId)) return false;
      _calendars = calendars;
      _defaultCalendarId = defaultId;
      notifyListeners();
      return true;
    } on Exception {
      return false;
    } finally {
      _savingCalendars = false;
    }
  }

  /// CAL-01.k, CAL-01.f: until the user chooses a view it is Month, except in a
  /// phone-width window (DEF-01), where it is List.
  CalendarView get view => _viewChosen ? _view : (_phone ? CalendarView.list : CalendarView.month);

  /// Tells the controller whether the window is phone-width. Silent: the page
  /// calls this while it builds, and reads [view] in the same build.
  void layout({required bool phone}) => _phone = phone;

  /// The date the calendar is on (a plain date, no time).
  DateTime get focused => _focused;

  /// Today's date in the Local zone.
  DateTime get today {
    final now = TZDateTime.from(_clock().toUtc(), localZone.location);
    return DateTime(now.year, now.month, now.day);
  }

  static const _lengthKey = 'event.defaultLength';
  static const _pressKey = 'view.longPressMs';
  static const _animationKey = 'view.animationMs';
  static const _zoneKey = 'view.zone';
  static const _deviceZoneKey = 'settings.fixedZone';
  static const _viewKey = 'view.mode';
  static const _formatKey = 'view.timeFormat';
  static const _hourLinesKey = 'view.hourLines';

  /// CAL-06.b: the time zone, the view and the time format are kept on the device.
  void _loadViewSettings(bool loadView) {
    final p = _prefs;
    if (p == null) return;
    _hourLines = (p.getInt(_hourLinesKey) ?? defaultHourLines)
        .clamp(minHourLines, maxHourLines);
    final press = p.getInt(_pressKey);
    if (press != null) _longPress = clampLongPress(Duration(milliseconds: press));
    final anim = p.getInt(_animationKey);
    if (anim != null) _animation = clampAnimation(Duration(milliseconds: anim));
    final len = p.getInt(_lengthKey);
    if (len != null) _defaultLength = clampEventLength(Duration(minutes: len));
    final z = p.getString(_zoneKey);
    if (z != null && z.isNotEmpty && isKnownZone(z)) _viewZone = z;
    final fixed = p.getString(_deviceZoneKey);
    if (fixed != null && isKnownZone(fixed)) {
      _localZone = LocalZone.fixed(fixed, systemZone: _localZone.systemZoneName);
    }
    final f = p.getString(_formatKey);
    if (f != null) _timeFormat = f == '24' ? TimeFormat.twentyFourHour : TimeFormat.twelveHour;
    final v = p.getString(_viewKey);
    if (loadView && v != null) {
      for (final x in CalendarView.values) {
        if (x.name == v) {
          _view = x;
          _viewChosen = true;
        }
      }
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _supported(DateTime d) => d.year >= firstSupportedYear && d.year <= lastSupportedYear;

  /// CAL-01.o: the calendar shows only dates in the supported years; a date
  /// outside them puts the calendar on today.
  void _focus(DateTime d) {
    _focused = _supported(d) ? _dateOnly(d) : today;
  }

  /// A view the user chose; it replaces the default.
  set view(CalendarView v) {
    if (_viewChosen && v == _view) return;
    _view = v;
    _viewChosen = true;
    _prefs?.setString(_viewKey, v.name);
    notifyListeners();
  }

  set localZone(LocalZone z) {
    _localZone = z;
    final fixed = z.fixedZoneName;
    if (fixed == null) {
      _prefs?.remove(_deviceZoneKey);
    } else {
      _prefs?.setString(_deviceZoneKey, fixed);
    }
    notifyListeners();
  }

  set timeFormat(TimeFormat f) {
    _timeFormat = f;
    _prefs?.setString(_formatKey, f == TimeFormat.twentyFourHour ? '24' : '12');
    notifyListeners();
  }

  void setEvents(List<SuiteEvent> events) {
    _events = List.of(events);
    notifyListeners();
  }

  void addEvent(SuiteEvent e) => upsertEvent(e);

  /// EVT-01: adds an event, or replaces the one with the same id; it is kept
  /// at once (UIC-13).
  void upsertEvent(SuiteEvent e) {
    final i = _events.indexWhere((x) => x.id == e.id);
    _events = i < 0 ? [..._events, e] : [for (final x in _events) x.id == e.id ? e : x];
    _changed();
  }

  /// PBI-041: adds [calendars] and [events] by their ids; one already present is
  /// replaced, so adding the same data twice never duplicates. Kept at once.
  Future<bool> addCalendarData(List<SuiteCalendar> calendars, List<SuiteEvent> events) async {
    final newCalendars = [
      for (final c in _calendars) calendars.where((n) => n.id == c.id).firstOrNull ?? c,
      for (final c in calendars)
        if (_calendars.every((x) => x.id != c.id)) c,
    ];
    final ids = {for (final e in events) e.id};
    final newEvents = [..._events.where((e) => !ids.contains(e.id)), ...events];
    try {
      final store = _localCalendarStore;
      if (store != null && !await store.save(newCalendars, _defaultCalendarId ?? newCalendars.first.id)) return false;
      await _store?.save(newEvents);
    } on Exception {
      return false;
    }
    _calendars = newCalendars;
    _defaultCalendarId ??= newCalendars.first.id;
    _events = newEvents;
    notifyListeners();
    return true;
  }

  /// PBI-041: removes the calendars with [calendarIds] and every event sitting in
  /// them or matching [isRemovedEvent], and nothing else. The last remaining
  /// calendar is never removed (its matching events still are).
  Future<bool> removeCalendarData(Set<String> calendarIds, {bool Function(SuiteEvent event)? isRemovedEvent}) async {
    bool gone(SuiteEvent e) => calendarIds.contains(e.calendarId) || (isRemovedEvent?.call(e) ?? false);
    var newCalendars = _calendars.where((c) => !calendarIds.contains(c.id)).toList();
    if (newCalendars.isEmpty) newCalendars = List.of(_calendars);
    final newDefault = newCalendars.any((c) => c.id == _defaultCalendarId) ? _defaultCalendarId! : newCalendars.first.id;
    final newEvents = _events.where((e) => !gone(e)).toList();
    try {
      final store = _localCalendarStore;
      if (store != null && !await store.save(newCalendars, newDefault)) return false;
      await _store?.save(newEvents);
    } on Exception {
      return false;
    }
    _calendars = newCalendars;
    _defaultCalendarId = newDefault;
    _events = newEvents;
    _removed.removeWhere(gone);
    if (_selectedId != null && newEvents.every((e) => e.id != _selectedId)) _selectedId = null;
    notifyListeners();
    return true;
  }

  /// DEF-02: how many deletions can be undone.
  static const int undoLimit = 100;
  final List<SuiteEvent> _removed = [];

  bool get canUndoDelete => _removed.isNotEmpty;

  /// CAP-02: a custom event is deleted and leaves its calendar; an event from a
  /// calendar source cannot be deleted (use [setHidden]). Returns whether it was deleted.
  bool deleteEvent(String id) {
    final e = _events.where((x) => x.id == id).firstOrNull;
    if (e == null || !e.custom) return false;
    _events = [for (final x in _events) if (x.id != id) x];
    _removed.add(e);
    if (_removed.length > undoLimit) _removed.removeAt(0);
    if (_selectedId == id) _selectedId = null;
    _changed();
    return true;
  }

  /// The current instant (UTC), from the calendar's clock.
  DateTime get nowUtc => _clock().toUtc();

  /// EVT-02.n: the length of an event whose end is left open; a user setting kept
  /// on the device (5 minutes to 24 hours, one hour until changed).
  Duration _defaultLength = standardEventLength;
  Duration get defaultLength => _defaultLength;
  set defaultLength(Duration d) {
    _defaultLength = clampEventLength(d);
    _prefs?.setInt(_lengthKey, _defaultLength.inMinutes);
    notifyListeners();
  }

  /// Where a dragged event would land if it were released now (CAL-03).
  DropTarget? _drop;
  DropTarget? get dropTarget => _drop;
  void setDropTarget(DropTarget? t) {
    if (_drop == t) return;
    _drop = t;
    notifyListeners();
  }

  /// CAL-03.d: how long a press is held before it drags an event.
  Duration _longPress = defaultLongPress;
  Duration get longPress => _longPress;
  set longPress(Duration d) {
    _longPress = clampLongPress(d);
    _prefs?.setInt(_pressKey, _longPress.inMilliseconds);
    notifyListeners();
  }

  /// SET-03.g: the one animation time (0 to 2 seconds, DEF-01), kept on the device.
  Duration _animation = defaultAnimationDuration;
  Duration get animationDuration => _animation;
  set animationDuration(Duration d) {
    _animation = clampAnimation(d);
    _prefs?.setInt(_animationKey, _animation.inMilliseconds);
    notifyListeners();
  }

  /// CAL-03: moves an event to start on [day] (at [minuteOfDay], or keeping its
  /// time of day), in the Local zone; its length and zones are kept.
  bool move(String id, {required DateTime day, int? minuteOfDay}) {
    final e = _events.where((x) => x.id == id).firstOrNull;
    if (e == null || !canMove(e)) return false;
    upsertEvent(moveEvent(e, localZone.location, day: day, minuteOfDay: minuteOfDay));
    return true;
  }

  /// CAP-02: undoes the last deletion.
  bool undoDelete() {
    if (_removed.isEmpty) return false;
    _events = [..._events, _removed.removeLast()];
    _changed();
    return true;
  }

  /// CAP-02: an event from a calendar source is hidden and shown again, never deleted.
  void setHidden(String id, bool hidden) {
    _events = [for (final x in _events) x.id == id ? x.copyWith(hiddenFromGoogle: hidden) : x];
    _changed();
  }

  void _changed() {
    _store?.save(_events);
    notifyListeners();
  }

  /// EVT-07: the event whose details are open on the calendar, until Close.
  String? _selectedId;
  SuiteEvent? get selectedEvent => _selectedId == null ? null : _events.where((x) => x.id == _selectedId).firstOrNull;

  void selectEvent(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  /// FLT-01.e: a calendar's name and color follow its source and show at once.
  void setCalendars(List<SuiteCalendar> calendars) {
    _calendars = List.of(calendars);
    notifyListeners();
  }

  @override
  void dispose() {
    filter.removeListener(notifyListeners);
    super.dispose();
  }

  /// CAL-01.c: Week view covers Sunday to Saturday.
  DateTime get weekStart => _focused.subtract(Duration(days: _focused.weekday % 7));
  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  /// CAL-01.b: the 5-day view is Monday through Friday of the focused week.
  DateTime get fiveDayStart => _focused.subtract(Duration(days: _focused.weekday - 1));

  /// The days an hourly view shows.
  List<DateTime> get hourlyDays {
    switch (view) {
      case CalendarView.day:
        return [_focused];
      case CalendarView.fiveDay:
        final s = fiveDayStart;
        return [for (var i = 0; i < 5; i++) DateTime(s.year, s.month, s.day + i)];
      default:
        final s = weekStart;
        return [for (var i = 0; i < 7; i++) DateTime(s.year, s.month, s.day + i)];
    }
  }

  /// The first day shown in Month view (whole weeks).
  DateTime get monthGridStart {
    final first = DateTime(_focused.year, _focused.month);
    return first.subtract(Duration(days: first.weekday % 7));
  }

  int get monthGridWeeks {
    final first = DateTime(_focused.year, _focused.month);
    final last = DateTime(_focused.year, _focused.month + 1, 0);
    final lead = first.weekday % 7;
    return ((lead + last.day) / 7).ceil();
  }

  void next() => _step(1);
  void previous() => _step(-1);

  /// CAL-01.m: previous and next move by one month in Month and List (to the
  /// last day of the previous month, or the first day of the next), by one week
  /// in Week (and 5-day) and by one day in Day.
  void _step(int dir) {
    switch (view) {
      case CalendarView.day:
        _focus(DateTime(_focused.year, _focused.month, _focused.day + dir));
      case CalendarView.week:
      case CalendarView.fiveDay:
        _focus(DateTime(_focused.year, _focused.month, _focused.day + 7 * dir));
      case CalendarView.month:
      case CalendarView.list:
        _focus(dir < 0
            ? DateTime(_focused.year, _focused.month, 0)
            : DateTime(_focused.year, _focused.month + 1, 1));
    }
    notifyListeners();
  }

  /// CAL-01.d, CAL-01.p: selecting a month and year navigates to it. The
  /// current month puts the calendar on today; any other month on its 1st.
  void goToMonth(int year, int month) {
    final t = today;
    _focus((t.year == year && t.month == month) ? t : DateTime(year, month));
    notifyListeners();
  }

  /// CAL-01.t: picking a day in the date picker goes to that date (a date outside
  /// the supported years puts the calendar on today, CAL-01.o).
  void goToDate(DateTime d) {
    _focus(d);
    notifyListeners();
  }

  /// CAL-01.e: Today returns the calendar to today (the current month).
  void goToToday() {
    _focused = today;
    notifyListeners();
  }

  /// The events shown on [day] (a plain date), seen in the Local zone (TIM-03),
  /// after the Calendar filter (FLT-01.d). An all-day event shows on the dates
  /// it covers in its own recorded zone.
  List<SuiteEvent> eventsOn(DateTime day) {
    final loc = localZone.location;
    final start = TZDateTime(loc, day.year, day.month, day.day);
    final end = TZDateTime(loc, day.year, day.month, day.day + 1);
    final out = _events.where(filter.shows).where((e) {
      if (e.allDay) {
        final z = zoneNamed(e.startZone);
        final s = e.startIn(z);
        final en = e.endIn(z);
        final d0 = DateTime(day.year, day.month, day.day);
        return !DateTime(s.year, s.month, s.day).isAfter(d0) && DateTime(en.year, en.month, en.day).isAfter(d0);
      }
      return e.startUtc.isBefore(end.toUtc()) && e.endUtc.isAfter(start.toUtc()) ||
          (e.startUtc == e.endUtc && !e.startUtc.isBefore(start.toUtc()) && e.startUtc.isBefore(end.toUtc()));
    }).toList()
      ..sort((a, b) {
        if (a.allDay != b.allDay) return a.allDay ? -1 : 1;
        return a.startUtc.compareTo(b.startUtc);
      });
    return out;
  }

  /// EVT-03.i: an event's own color, else its calendar's color, or null (the
  /// caller then uses the default event color).
  int? colorOf(SuiteEvent e) {
    if (e.color != null) return e.color;
    for (final c in _calendars) {
      if (c.id == e.calendarId) return c.color;
    }
    return null;
  }
}

/// The day (and, in Week and Day, the minute of the day) a dragged event is over.
class DropTarget {
  const DropTarget({required this.eventId, required this.day, this.minute});
  final String eventId;
  final DateTime day;
  final int? minute;

  @override
  bool operator ==(Object other) =>
      other is DropTarget && other.eventId == eventId && other.day == day && other.minute == minute;

  @override
  int get hashCode => Object.hash(eventId, day, minute);
}
