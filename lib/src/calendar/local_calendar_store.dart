import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../time/suite_event.dart';

class LocalCalendarStore {
  LocalCalendarStore(this.prefs);

  final SharedPreferences prefs;
  static const _key = 'localCalendars.v1';

  ({List<SuiteCalendar> calendars, String defaultId})? load() {
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return (
        calendars: [
          for (final item in data['calendars'] as List)
            SuiteCalendar(
              id: item['id'] as String,
              name: item['name'] as String,
              color: item['color'] as int?,
              zone: item['zone'] as String?,
            ),
        ],
        defaultId: data['defaultId'] as String,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<bool> save(List<SuiteCalendar> calendars, String defaultId) => prefs.setString(
    _key,
    jsonEncode({
      'defaultId': defaultId,
      'calendars': [
        for (final calendar in calendars)
          {
            'id': calendar.id,
            'name': calendar.name,
            'color': calendar.color,
            'zone': calendar.zone,
          },
      ],
    }),
  );
}
