// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../time/local_zone.dart';
import '../time/suite_event.dart';
import '../time/time_format.dart';
import '../time/zones.dart';

/// CAL-01.b: the calendar's views. Month and Week are built; the others follow.
enum CalendarView { month, week, fiveDay, day, list }

/// The state of the main calendar. UIC-13: every change notifies at once.
class CalendarController extends ChangeNotifier {
  CalendarController({
    required LocalZone localZone,
    required TimeFormat timeFormat,
    List<SuiteEvent> events = const [],
    DateTime Function()? clock,
    DateTime? focused,
    CalendarView view = CalendarView.month,
  })  : _localZone = localZone,
        _timeFormat = timeFormat,
        _events = List.of(events),
        _clock = clock ?? DateTime.now,
        _view = view {
    _focused = _dateOnly(focused ?? today);
  }

  final DateTime Function() _clock;
  LocalZone _localZone;
  TimeFormat _timeFormat;
  List<SuiteEvent> _events;
  CalendarView _view;
  late DateTime _focused;

  LocalZone get localZone => _localZone;
  TimeFormat get timeFormat => _timeFormat;
  List<SuiteEvent> get events => List.unmodifiable(_events);
  CalendarView get view => _view;

  /// The date the calendar is on (a plain date, no time).
  DateTime get focused => _focused;

  /// Today's date in the Local zone.
  DateTime get today {
    final now = TZDateTime.from(_clock().toUtc(), _localZone.location);
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  set view(CalendarView v) {
    if (v == _view) return;
    _view = v;
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

  /// CAL-01.c: Week view covers Sunday to Saturday and moves a week at a time.
  DateTime get weekStart => _focused.subtract(Duration(days: _focused.weekday % 7));
  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  /// The first and last day shown in Month view (whole weeks).
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

  void _step(int dir) {
    switch (_view) {
      case CalendarView.week:
        _focused = DateTime(_focused.year, _focused.month, _focused.day + 7 * dir);
      case CalendarView.day:
        _focused = DateTime(_focused.year, _focused.month, _focused.day + dir);
      case CalendarView.fiveDay:
        _focused = DateTime(_focused.year, _focused.month, _focused.day + 7 * dir);
      case CalendarView.month:
      case CalendarView.list:
        _focused = DateTime(_focused.year, _focused.month + dir);
    }
    notifyListeners();
  }

  /// CAL-01.d: selecting a month and year navigates to it. The current month
  /// puts the calendar on today; any other month on its 1st.
  void goToMonth(int year, int month) {
    final t = today;
    _focused = (t.year == year && t.month == month) ? t : DateTime(year, month);
    notifyListeners();
  }

  void goToToday() {
    _focused = today;
    notifyListeners();
  }

  /// The events shown on [day] (a plain date), seen in the Local zone (TIM-03).
  /// An all-day event shows on the dates it covers in its own recorded zone.
  List<SuiteEvent> eventsOn(DateTime day) {
    final loc = _localZone.location;
    final start = TZDateTime(loc, day.year, day.month, day.day);
    final end = TZDateTime(loc, day.year, day.month, day.day + 1);
    final out = _events.where((e) {
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
}
