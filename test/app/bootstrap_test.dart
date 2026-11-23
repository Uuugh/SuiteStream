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

/// Preferences whose writes fail, to prove failures are not swallowed.
class _FailingPrefs extends Fake implements SharedPreferences {
  @override
  String? getString(String key) => null;
  @override
  bool? getBool(String key) => null;
  @override
  Set<String> getKeys() => {};
  @override
  bool containsKey(String key) => false;
  @override
  Future<bool> setBool(String key, bool value) async => throw StateError('disk full');
}

void main() {
  final messages = messagesFor('en');

  Future<SharedPreferences> prefsWith([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('first start shows the three sample events once and records it', () async {
    final prefs = await prefsWith();
    final first = await bootstrapCalendar(prefs: prefs, messages: messages, zone: zone);
    expect(first.events.map((e) => e.id), ['demo-1', 'demo-2', 'demo-3']);
    expect(first.events.every((e) => e.calendarId == localCalendarId), isTrue);
    expect(prefs.getBool(samplesShownKey), isTrue);

    final second = await bootstrapCalendar(prefs: prefs, messages: messages, zone: zone);
    expect(second.events, isEmpty);
  });

  test('samples are not shown when the user already has events', () async {
    final prefs = await prefsWith();
    await PrefsEventStore(prefs).save([event('mine', calendarId: localCalendarId)]);
    final controller = await bootstrapCalendar(prefs: prefs, messages: messages, zone: zone);
    expect(controller.events.map((e) => e.id), ['mine']); // no demo-* events
    expect(prefs.getBool(samplesShownKey), isTrue);
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
      throwsA(isA<BootstrapException>().having((e) => e.step, 'step', 'remember sample events')),
    );
  });
}
