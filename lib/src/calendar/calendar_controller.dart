// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../time/local_zone.dart';
import '../time/suite_event.dart';
import '../time/time_format.dart';
import '../time/zones.dart';
import 'event_filter.dart';

/// CAL-01.b: the calendar's views.
enum CalendarView { month, week, fiveDay, day, list }

/// DEF-01: supported calendar years, 2000 to 2100.
const int firstSupportedYear = 2000;
const int lastSupportedYear = 2100;

/// The state of the main calendar. UIC-13: every change notifies at once.
class CalendarController extends ChangeNotifier {
  CalendarController({
    required LocalZone localZone,
    required TimeFormat timeFormat,
    List<SuiteEvent> events = const [],
    List<SuiteCalendar> calendars = const [],
    EventFilter? filter,
    DateTime Function()? clock,
    DateTime? focused,
    CalendarView? view,
  })  : _localZone = localZone,
        _timeFormat = timeFormat,
        _events = List.of(events),
        _calendars = List.of(calendars),
        filter = filter ?? EventFilter(),
        _clock = clock ?? DateTime.now,
        _view = view ?? CalendarView.month,
        _viewChosen = view != null {
    _focused = _supported(focused ?? today) ? _dateOnly(focused ?? today) : today;
    this.filter.addListener(notifyListeners); // FLT-01.d: every view follows the filter
  }

  final DateTime Function() _clock;
  final EventFilter filter;
  LocalZone _localZone;
  TimeFormat _timeFormat;
  List<SuiteEvent> _events;
  List<SuiteCalendar> _calendars;
  CalendarView _view;
  bool _viewChosen;
  bool _phone = false;
  late DateTime _focused;

  LocalZone get localZone => _localZone;
  TimeFormat get timeFormat => _timeFormat;
  List<SuiteEvent> get events => List.unmodifiable(_events);
  List<SuiteCalendar> get calendars => List.unmodifiable(_calendars);

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
    final now = TZDateTime.from(_clock().toUtc(), _localZone.location);
    return DateTime(now.year, now.month, now.day);
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
    notifyListeners();
  }

  set localZone(LocalZone z) {
    _localZone = z;
    notifyListeners();
  }

  set timeFormat(TimeFormat f) {
    _timeFormat = f;
    notifyListeners();
  }

  void setEvents(List<SuiteEvent> events) {
    _events = List.of(events);
    notifyListeners();
  }

  void addEvent(SuiteEvent e) {
    _events = [..._events, e];
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
    final loc = _localZone.location;
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

  /// The color of an event's calendar, or null.
  int? colorOf(SuiteEvent e) {
    for (final c in _calendars) {
      if (c.id == e.calendarId) return c.color;
    }
    return null;
  }
}
