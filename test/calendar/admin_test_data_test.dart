import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/app/bootstrap.dart';
import 'package:suitestream/src/app/test_data.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/event_store.dart';
import 'package:suitestream/src/calendar/settings_admin_pane.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  Future<CalendarController> start({List<SuiteEvent> mine = const []}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (mine.isNotEmpty) await PrefsEventStore(prefs).save(mine);
    return bootstrapCalendar(prefs: prefs, messages: messagesFor('en'), zone: zone);
  }

  SuiteEvent own(String id) => makeEvent(id, 3, 9, calendarId: localCalendarId);

  test('PBI-041: three calendars Work, Family and Travel with about 8 events each across November 2026', () {
    expect(testCalendars.map((c) => c.name), ['Work', 'Family', 'Travel']);
    expect({for (final c in testCalendars) c.color}.length, 3);
    final events = buildTestEvents(zone);
    for (final c in testCalendars) {
      final mine = events.where((e) => e.calendarId == c.id).toList();
      expect(mine.length, inInclusiveRange(7, 9), reason: c.name);
      for (final e in mine) {
        final s = e.startIn(zoneNamed(zone));
        expect([s.year, s.month], [2026, 11], reason: e.id);
      }
    }
    expect({for (final e in events) e.id}.length, events.length, reason: 'ids are unique');
  });

  test('PBI-041: the data mixes timed, all-day, multi-day and overlapping events and has reminders', () {
    final events = buildTestEvents(zone);
    expect(events.any((e) => !e.allDay), isTrue);
    expect(events.any((e) => e.allDay), isTrue);
    expect(events.any((e) => e.allDay && e.endUtc.difference(e.startUtc) > const Duration(days: 1, hours: 2)), isTrue, reason: 'multi-day');
    expect(events.any((e) => e.reminders.isNotEmpty), isTrue);
    expect(events.every((e) => e.reminders.length <= remindersPerEvent), isTrue);
    var overlaps = 0;
    for (var i = 0; i < events.length; i++) {
      for (var j = i + 1; j < events.length; j++) {
        final a = events[i], b = events[j];
        if (!a.allDay && !b.allDay && a.startUtc.isBefore(b.endUtc) && b.startUtc.isBefore(a.endUtc)) overlaps++;
      }
    }
    expect(overlaps, greaterThanOrEqualTo(2));
  });

  test('PBI-041: adding twice does not duplicate calendars or events', () async {
    final c = await start(mine: [own('mine')]);
    expect(await c.addCalendarData(testCalendars, buildTestEvents(zone)), isTrue);
    final calendarCount = c.calendars.length;
    final eventCount = c.events.length;
    expect(calendarCount, 1 + 3);
    expect(await c.addCalendarData(testCalendars, buildTestEvents(zone)), isTrue);
    expect(c.calendars.length, calendarCount);
    expect(c.events.length, eventCount);
    expect(c.events.map((e) => e.id).toSet().length, eventCount);
  });

  test('PBI-041: test data is kept on the device', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = await bootstrapCalendar(prefs: prefs, messages: messagesFor('en'), zone: zone);
    await c.addCalendarData(testCalendars, buildTestEvents(zone));
    final again = await bootstrapCalendar(prefs: prefs, messages: messagesFor('en'), zone: zone);
    expect(again.calendars.map((x) => x.name), containsAll(['Work', 'Family', 'Travel']));
    expect(again.events.length, buildTestEvents(zone).length);
  });

  test('PBI-041: removing deletes the test calendars and their events and nothing of the user', () async {
    final c = await start(mine: [own('mine-1'), own('mine-2')]);
    await c.addCalendarData(testCalendars, buildTestEvents(zone));
    // A calendar of the user with the same name as a test one: only ids decide.
    await c.saveCalendar('Work');
    final ownWork = c.calendars.firstWhere((x) => x.name == 'Work' && !isTestCalendarId(x.id));
    c.addEvent(makeEvent('mine-work', 5, 10, calendarId: ownWork.id));

    expect(await c.removeCalendarData({for (final x in testCalendars) x.id}, isRemovedEvent: isTestEvent), isTrue);
    expect(c.calendars.map((x) => x.id), [localCalendarId, ownWork.id]);
    expect(c.events.map((e) => e.id).toSet(), {'mine-1', 'mine-2', 'mine-work'});
    expect(c.defaultCalendarId, localCalendarId);
  });

  test('PBI-041: remove also deletes the old automatic samples, found by their ids, and keeps similar user events', () async {
    final sample = SuiteEvent.zoned(
      id: 'demo-1',
      title: 'Sample event',
      year: 2026,
      month: 7,
      day: 15,
      hour: 10,
      minute: 0,
      length: const Duration(hours: 1),
      zone: zone,
      calendarId: localCalendarId,
    );
    final c = await start(mine: [sample, own('mine'), own('demo-10')]);
    await c.removeCalendarData({for (final x in testCalendars) x.id}, isRemovedEvent: isTestEvent);
    expect(c.events.map((e) => e.id).toSet(), {'mine', 'demo-10'});
  });

  test('PBI-041: removing when nothing was added changes nothing', () async {
    final c = await start(mine: [own('mine')]);
    expect(await c.removeCalendarData({for (final x in testCalendars) x.id}, isRemovedEvent: isTestEvent), isTrue);
    expect(c.events.map((e) => e.id), ['mine']);
    expect(c.calendars.map((x) => x.id), [localCalendarId]);
  });

  testWidgets('PBI-041: the Admin pane adds the test calendars, and Remove asks No | Yes first', (tester) async {
    final c = await start(mine: [own('mine')]);
    useWindow(tester);
    await tester.pumpWidget(appFor(SettingsAdminPane(controller: c)));
    await tester.tap(find.byKey(const ValueKey('admin-add-test-data')));
    await tester.pumpAndSettle();
    expect(c.calendars.length, 4);
    expect(find.byKey(const ValueKey('admin-status')), findsOneWidget);

    // No keeps everything.
    await tester.tap(find.byKey(const ValueKey('admin-remove-test-data')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('confirm-no')), findsOneWidget);
    expect(find.byKey(const ValueKey('confirm-yes')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-no')));
    await tester.pumpAndSettle();
    expect(c.calendars.length, 4);

    // Yes removes only the test data.
    await tester.tap(find.byKey(const ValueKey('admin-remove-test-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-yes')));
    await tester.pumpAndSettle();
    expect(c.calendars.map((x) => x.id), [localCalendarId]);
    expect(c.events.map((e) => e.id), ['mine']);
  });

  testWidgets('UIC-45: leaving the Admin pane changes nothing (it holds no value to save)', (tester) async {
    final c = await start(mine: [own('mine')]);
    useWindow(tester);
    await tester.pumpWidget(appFor(SettingsAdminPane(controller: c)));
    final calendars = c.calendars.map((x) => x.id).toList();
    final events = c.events.map((e) => e.id).toList();
    expect(find.byType(TextField), findsNothing);
    // Leaving = the pane is disposed (page change, close or back button).
    await tester.pumpWidget(appFor(const SizedBox()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(c.calendars.map((x) => x.id).toList(), calendars);
    expect(c.events.map((e) => e.id).toList(), events);
  });
}
