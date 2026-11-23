import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/app/bootstrap.dart';
import 'package:suitestream/src/calendar/event_store.dart';
import 'package:suitestream/src/time/suite_event.dart';

import '../calendar/test_support.dart';

SuiteEvent event(String id, {String? calendarId}) => SuiteEvent.zoned(
      id: id,
      title: id,
      year: 2026,
      month: 7,
      day: 15,
      hour: 9,
      minute: 0,
      length: const Duration(hours: 1),
      zone: zone,
      calendarId: calendarId,
    );

/// Preferences that hold a stored event with no calendar but whose writes fail, to prove failures are not swallowed.
class _FailingPrefs extends Fake implements SharedPreferences {
  @override
  String? getString(String key) => key == 'events.v1' ? jsonEncode([event('old').toJson()]) : null;
  @override
  bool? getBool(String key) => null;
  @override
  int? getInt(String key) => null;
  @override
  Set<String> getKeys() => {};
  @override
  bool containsKey(String key) => false;
  @override
  Future<bool> setString(String key, String value) async => throw StateError('disk full');
}

void main() {
  final messages = messagesFor('en');

  Future<SharedPreferences> prefsWith([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('PBI-041: a first start has no automatic sample events and stores nothing extra', () async {
    final prefs = await prefsWith();
    final first = await bootstrapCalendar(prefs: prefs, messages: messages, zone: zone);
    expect(first.events, isEmpty);
    expect(first.calendars.map((c) => c.id), [localCalendarId]);
    expect(prefs.containsKey('demo.samplesShown'), isFalse);
  });

  test('the user own events are kept and none are added', () async {
    final prefs = await prefsWith();
    await PrefsEventStore(prefs).save([event('mine', calendarId: localCalendarId)]);
    final controller = await bootstrapCalendar(prefs: prefs, messages: messages, zone: zone);
    expect(controller.events.map((e) => e.id), ['mine']);
  });

  test('migration assigns the default calendar to events without one and persists it', () async {
    final prefs = await prefsWith();
    final store = PrefsEventStore(prefs);
    await store.save([event('old'), event('kept', calendarId: 'work')]);
    await bootstrapCalendar(prefs: prefs, messages: messages, zone: zone);
    final saved = {for (final e in PrefsEventStore(prefs).load()) e.id: e.calendarId};
    expect(saved, {'old': localCalendarId, 'kept': 'work'});
  });

  test('work and home calendars are synthesized only when events use them', () async {
    final prefs = await prefsWith();
    await PrefsEventStore(prefs).save([event('a', calendarId: 'work'), event('b', calendarId: 'home')]);
    final controller = await bootstrapCalendar(prefs: prefs, messages: messages, zone: zone);
    expect(controller.calendars.map((c) => c.id), [localCalendarId, 'work', 'home']);

    final plain = await bootstrapCalendar(prefs: await prefsWith(), messages: messages, zone: zone);
    expect(plain.calendars.map((c) => c.id), [localCalendarId]);
  });

  test('a failing step surfaces as a BootstrapException naming the step', () async {
    await expectLater(
      bootstrapCalendar(prefs: _FailingPrefs(), messages: messages, zone: zone),
      throwsA(isA<BootstrapException>().having((e) => e.step, 'step', 'migrate stored events')),
    );
  });
}
