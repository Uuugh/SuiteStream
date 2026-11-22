import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../time/suite_event.dart';

/// FLT-01.a: the event states the Calendar filter can show or hide.
enum EventState { edited, changedBySource, hiddenFromGoogle, deleted }

/// UIC-21: the one shared filter. It holds what the user chose to hide; by
/// default everything is shown. A change applies at once (UIC-13) and is saved
/// (kept across visits) when [prefs] is given.
class EventFilter extends ChangeNotifier {
  EventFilter({SharedPreferences? prefs}) : _prefs = prefs {
    final p = prefs;
    if (p != null) {
      _hiddenCalendars.addAll(p.getStringList(_calKey) ?? const []);
      for (final name in p.getStringList(_stateKey) ?? const <String>[]) {
        for (final s in EventState.values) {
          if (s.name == name) _hiddenStates.add(s);
        }
      }
    }
  }

  static const _calKey = 'filter.hiddenCalendars';
  static const _stateKey = 'filter.hiddenStates';

  final SharedPreferences? _prefs;
  final Set<String> _hiddenCalendars = {};
  final Set<EventState> _hiddenStates = {};

  Set<String> get hiddenCalendars => Set.unmodifiable(_hiddenCalendars);
  Set<EventState> get hiddenStates => Set.unmodifiable(_hiddenStates);

  /// UIC-21: the filter shows when it is active (anything is hidden).
  bool get active => _hiddenCalendars.isNotEmpty || _hiddenStates.isNotEmpty;

  bool calendarShown(String id) => !_hiddenCalendars.contains(id);
  bool stateShown(EventState s) => !_hiddenStates.contains(s);

  /// FLT-01.k, FLT-01.l, FLT-01.m: whether the calendar shows [e].
  bool shows(SuiteEvent e) {
    final cal = e.calendarId;
    if (cal != null && _hiddenCalendars.contains(cal)) return false;
    if (e.deleted) return stateShown(EventState.deleted);
    // The other states hide only events that are not deleted.
    if (e.hiddenFromGoogle && !stateShown(EventState.hiddenFromGoogle)) return false;
    if (e.changedBySource && !stateShown(EventState.changedBySource)) return false;
    if (e.edited && !e.changedBySource && !stateShown(EventState.edited)) return false;
    return true;
  }

  void toggleCalendar(String id) {
    if (!_hiddenCalendars.remove(id)) _hiddenCalendars.add(id);
    _changed();
  }

  void toggleState(EventState s) {
    if (!_hiddenStates.remove(s)) _hiddenStates.add(s);
    _changed();
  }

  /// Sets exactly which calendars and states are shown (one, several, all or none).
  void setShown({required Iterable<String> calendarIds, required Set<String> shownCalendars, required Set<EventState> shownStates}) {
    _hiddenCalendars
      ..clear()
      ..addAll(calendarIds.where((id) => !shownCalendars.contains(id)));
    _hiddenStates
      ..clear()
      ..addAll(EventState.values.where((s) => !shownStates.contains(s)));
    _changed();
  }

  /// UIC-21: Select all shows everything.
  void selectAll() {
    _hiddenCalendars.clear();
    _hiddenStates.clear();
    _changed();
  }

  /// UIC-21: Select none shows nothing.
  void selectNone(Iterable<String> calendarIds) {
    _hiddenCalendars
      ..clear()
      ..addAll(calendarIds);
    _hiddenStates
      ..clear()
      ..addAll(EventState.values);
    _changed();
  }

  void _changed() {
    final p = _prefs;
    if (p != null) {
      p.setStringList(_calKey, _hiddenCalendars.toList());
      p.setStringList(_stateKey, _hiddenStates.map((s) => s.name).toList());
    }
    notifyListeners();
  }
}
