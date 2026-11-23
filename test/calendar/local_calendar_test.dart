import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/event_store.dart';
import 'package:suitestream/src/calendar/local_calendar_store.dart';
import 'package:suitestream/src/calendar/local_calendars_dialog.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/theme/event_colors.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/suite_event.dart';
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

  test('UIC-10, EVT-03.i: a calendar color is kept by the store; a new calendar gets the next unused calendar color', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = LocalCalendarStore(prefs);
    final controller = CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      calendars: [SuiteCalendar(id: 'a', name: 'A', color: calendarPalette[0].argb)],
      localCalendarStore: store,
    );
    expect(await controller.saveCalendar('B'), isTrue);
    expect(controller.calendars.last.color, calendarPalette[1].argb);
    expect(await controller.saveCalendar('C', color: calendarPalette[9].argb), isTrue);
    expect(controller.calendars.last.color, calendarPalette[9].argb);
    expect(await controller.saveCalendar('B2', id: controller.calendars[1].id), isTrue);
    expect(controller.calendars[1].color, calendarPalette[1].argb); // a rename keeps its color
    expect(await controller.saveCalendar('B2', id: controller.calendars[1].id, color: calendarPalette[20].argb), isTrue);
    expect(LocalCalendarStore(prefs).load()!.calendars[1].color, calendarPalette[20].argb);
    expect(LocalCalendarStore(prefs).load()!.calendars.first.color, calendarPalette[0].argb);
  });

  testWidgets('UIC-10, UIC-20, CGOW-10: the calendar dialog picks one of 24 calendar colors with the shared picker', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      calendars: [const SuiteCalendar(id: 'work', name: 'Work', color: 0xFFAB725F)], // not in the palette
      localCalendarStore: LocalCalendarStore(prefs),
    );
    useWindow(tester, const Size(420, 780));
    await tester.pumpWidget(appFor(Builder(
      builder: (context) => TextButton(onPressed: () => openLocalCalendars(context, controller), child: const Text('Open')),
    )));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    // UIC-20: shown as the nearest palette color (Cocoa).
    expect((tester.widget<CircleAvatar>(find.byKey(const ValueKey('calendar-dot-work'))).backgroundColor), const Color(0xFFAC725E));
    await tester.tap(find.text('Add calendar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Travel');
    await tester.tap(find.byKey(const ValueKey('calendar-color-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('color-default')), findsNothing); // no "calendar default" for a calendar
    for (final p in calendarPalette) {
      expect(find.byKey(ValueKey('color-${p.key}')), findsOneWidget, reason: p.name);
    }
    expect(find.byKey(const ValueKey('color-tomato')), findsNothing); // not the event palette
    await tester.tap(find.byKey(const ValueKey('color-cal16')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(controller.calendars.last.name, 'Travel');
    expect(controller.calendars.last.color, 0xFF4986E7);
    expect(LocalCalendarStore(prefs).load()!.calendars.last.color, 0xFF4986E7);
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
