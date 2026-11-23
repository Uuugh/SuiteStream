import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/event_store.dart';
import 'package:suitestream/src/calendar/local_calendar_store.dart';
import 'package:suitestream/src/calendar/local_calendars_dialog.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

void main() {
  setUpAll(initZones);

  test('Local calendars retain their names, colors and default without orphaning events', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    CalendarController start() => CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      events: [makeEvent('held', 15, 9, calendarId: 'work').copyWith(color: 0xFF812345)],
      calendars: calendars,
      localCalendarStore: LocalCalendarStore(prefs),
    );

    final first = start();
    expect(first.defaultCalendarId, 'work');
    expect(await first.saveCalendar('Personal'), isTrue);
    final added = first.calendars.last.id;
    expect(await first.setDefaultCalendar(added), isTrue);
    expect(await first.saveCalendar('Family', id: added), isTrue);
    expect(await first.deleteCalendar('work'), isFalse);
    expect(first.events.single.color, 0xFF812345);

    final restarted = start();
    expect(restarted.defaultCalendarId, added);
    expect(restarted.calendars.last.name, 'Family');
    expect(restarted.calendars.first.color, first.calendars.first.color);
    expect(await restarted.deleteCalendar(added), isTrue);
    expect(start().defaultCalendarId, 'work');
    expect(start().calendars.any((calendar) => calendar.id == added), isFalse);
  });

  test('CLCL-01.e: clearing the last calendar keeps its identity and default', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final event = makeEvent('held', 15, 9, calendarId: 'work');
    final store = MemoryEventStore([event]);
    final controller = CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      calendars: [calendars.first],
      localCalendarStore: LocalCalendarStore(prefs),
      store: store,
    );
    controller.selectEvent(event.id);
    expect(await controller.deleteCalendar('work'), isFalse);
    expect(await controller.clearLastCalendar('work'), isTrue);
    expect(store.load(), isEmpty);
    expect(controller.events, isEmpty);
    expect(controller.selectedEvent, isNull);
    expect(controller.calendars.single.id, 'work');
    expect(controller.defaultCalendarId, 'work');
  });

  test('SET-02.a: fixed device zone persists independently of the calendar override', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    CalendarController start() => CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      prefs: prefs,
    );

    final first = start();
    first.localZone = const LocalZone.fixed('Europe/Paris', systemZone: zone);
    first.viewZone = 'Asia/Tokyo';
    final restarted = start();
    expect(restarted.baseZone.name, 'Europe/Paris');
    expect(restarted.localZone.name, 'Asia/Tokyo');
    restarted.viewZone = null;
    expect(restarted.localZone.name, 'Europe/Paris');
    restarted.localZone = const LocalZone.system(zone);
    expect(start().baseZone.name, zone);
  });

  testWidgets('CLCL-01.c: a local calendar can be added from the management dialog', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      calendars: [calendars.first],
      localCalendarStore: LocalCalendarStore(prefs),
    );
    useWindow(tester, const Size(420, 780));
    await tester.pumpWidget(appFor(Builder(
      builder: (context) => TextButton(
        onPressed: () => openLocalCalendars(context, controller),
        child: const Text('Open'),
      ),
    )));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsOneWidget);
    await tester.tap(find.text('Add calendar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Personal');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Personal'), findsOneWidget);
    expect(controller.calendars.length, 2);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets('SET-01.b: Settings groups the configuration sections and opens Sources directly', (tester) async {
    useWindow(tester, const Size(420, 780));
    final controller = makeController();
    await tester.pumpWidget(appFor(Builder(
      builder: (context) => TextButton(
        onPressed: () => openSettingsDialog(context, controller),
        child: const Text('Open'),
      ),
    )));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    for (final section in ['Sources', 'Feeds', 'All Rules', 'Event Templates', 'History']) {
      expect(find.text(section), findsOneWidget);
    }
    await tester.tap(find.byKey(const ValueKey('settings-sources')));
    await tester.pumpAndSettle();
    expect(find.text('Manage local calendars'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });
}
