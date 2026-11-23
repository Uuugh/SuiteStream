import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:suitestream/src/time/suite_event.dart';

/// Where the user's events are kept between visits (TIM-01: in UTC with their zones).
abstract class EventStore {
  List<SuiteEvent> load();
  Future<void> save(List<SuiteEvent> events);
}

/// Keeps events only while the app runs (tests, first start).
class MemoryEventStore implements EventStore {
  MemoryEventStore([List<SuiteEvent> events = const []]) : _events = List.of(events);
  List<SuiteEvent> _events;

  @override
  List<SuiteEvent> load() => List.of(_events);

  @override
  Future<void> save(List<SuiteEvent> events) async => _events = List.of(events);
}

/// Keeps events on the device, as JSON.
class PrefsEventStore implements EventStore {
  PrefsEventStore(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'events.v1';

  @override
  List<SuiteEvent> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return [for (final e in list) SuiteEvent.fromJson((e as Map).cast<String, Object?>())];
    } on Exception {
      return []; // an unreadable store starts empty rather than crashing the app
    } on TypeError {
      return []; // a store of the wrong shape starts empty too
    }
  }

  @override
  Future<void> save(List<SuiteEvent> events) async {
    if (!await _prefs.setString(_key, jsonEncode([for (final e in events) e.toJson()]))) {
      throw Exception('Could not persist calendar events.');
    }
  }
}
