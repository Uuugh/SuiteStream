import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/calendar/event_dialog.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

import '../calendar/test_support.dart';

const tall = Size(1000, 1500);

Future<CalendarController> pumpCalendar(WidgetTester tester, {List<SuiteEvent> events = const [], List<SuiteCalendar> cals = calendars, CalendarView? view}) async {
  useWindow(tester, tall);
  final c = makeController(events: events, cals: cals, view: view);
  await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
  return c;
}

Future<void> openDay(WidgetTester tester, int day) async {
  await tester.tap(find.byKey(ValueKey('day-2026-7-$day')));
  await tester.pumpAndSettle();
}

Future<void> typeIn(WidgetTester tester, String key, String text) async {
  await tester.enterText(find.byKey(ValueKey(key)), text);
  await tester.pump();
}

String fieldText(WidgetTester tester, String key) =>
    tester.widget<TextField>(find.byKey(ValueKey(key))).controller!.text;

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const ValueKey('event-save')));
  await tester.tap(find.byKey(const ValueKey('event-save')));
  await tester.pumpAndSettle();
}

void main() {
  deleteIconTests();
  errorNoteTests();
  reminderTests();
  duplicateTests();
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  testWidgets('EVT-01.a: clicking a day opens the new-event dialog for that date', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    expect(find.byKey(const ValueKey('event-dialog')), findsOneWidget);
    expect(find.text('Add event'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('event-start-date')), matching: find.text('Jul 20, 2026')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('event-end-date')), matching: find.text('Jul 20, 2026')), findsOneWidget);
    // Back closes it without adding anything.
    await tester.tap(find.byKey(const ValueKey('event-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-dialog')), findsNothing);
    expect(c.events, isEmpty);
  });

  testWidgets('EVT-01.m: a new event starts where the click is down the day in Month, or at 9:00 when no spot was clicked, and lasts the default length', (tester) async {
    await pumpCalendar(tester);
    // In Month the start time follows where the click is down the day's block.
    final cell = tester.getRect(find.byKey(const ValueKey('day-2026-7-20')));
    for (final (frac, start, end) in [(0.02, '12:30 am', '01:30 am'), (0.5, '12:00 pm', '01:00 pm'), (0.75, '06:00 pm', '07:00 pm'), (0.98, '11:30 pm', '12:30 am')]) {
      await tester.tapAt(Offset(cell.left + cell.width / 2, cell.top + cell.height * frac));
      await tester.pumpAndSettle();
      expect(fieldText(tester, 'event-start-time'), start, reason: '$frac');
      expect(fieldText(tester, 'event-end-time'), end, reason: '$frac');
      expect(find.descendant(of: find.byKey(const ValueKey('event-start-date')), matching: find.text('Jul 20, 2026')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('event-cancel')));
      await tester.pumpAndSettle();
    }
    final c = makeController();
    await tester.pumpWidget(appFor(Builder(builder: (context) => TextButton(onPressed: () => openEventDialog(context, c), child: const Text('go'))), size: tall));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('event-start-date')), matching: find.text('Jul 15, 2026')), findsOneWidget);
    expect(fieldText(tester, 'event-start-time'), '09:00 am');
  });

  testWidgets('EVT-02.a: times show in the page notation and accept typed forms', (tester) async {
    useWindow(tester, tall);
    final c24 = CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twentyFourHour,
      clock: () => DateTime.utc(2026, 7, 15, 16),
    );
    await tester.pumpWidget(appFor(CalendarPage(controller: c24), size: tall));
    await openDay(tester, 20);
    expect(fieldText(tester, 'event-start-time'), '12:00'); // clicked in the middle of the day
    expect(fieldText(tester, 'event-end-time'), '13:00');
    await typeIn(tester, 'event-start-time', '1:30 pm'); // read as 13:30
    expect(fieldText(tester, 'event-end-time'), '14:30');
    await typeIn(tester, 'event-start-time', '1505'); // read as 15:05
    expect(fieldText(tester, 'event-end-time'), '16:05');
    // An entry such as 13:00 pm or 25:00 is not valid and blocks saving.
    await typeIn(tester, 'event-title', 'Check');
    await typeIn(tester, 'event-start-time', '13:00 pm');
    await save(tester);
    expect(find.text('Type a time like 9:30, 9:30pm or 21:30.'), findsOneWidget);
    expect(c24.events, isEmpty);
    await typeIn(tester, 'event-start-time', '9:30');
    await typeIn(tester, 'event-end-time', '25:00');
    await save(tester);
    expect(find.text('Type a time like 9:30, 9:30pm or 21:30.'), findsOneWidget);
    expect(c24.events, isEmpty);
  });

  testWidgets('EVT-02.i: a time that cannot be read is marked at its field with a note', (tester) async {
    await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'T');
    await typeIn(tester, 'event-start-time', 'soon');
    await save(tester);
    // The note is on the field's label line, next to the label, not below the field.
    final note = find.text('Type a time like 9:30, 9:30pm or 21:30.');
    expect(note, findsOneWidget);
    final field = tester.getRect(find.byKey(const ValueKey('event-start-time')));
    expect(tester.getRect(note).bottom <= field.top + 1, isTrue);
    expect(fieldText(tester, 'event-end-time'), '01:00 pm'); // the other field's valid value is untouched
    expect(tester.widget<TextField>(find.byKey(const ValueKey('event-end-time'))).decoration!.enabledBorder!.borderSide.color, isNot(const Color(0xFFB4483C)));
    expect(fieldText(tester, 'event-end-time'), '01:00 pm');
    // Fixing it clears the note.
    await typeIn(tester, 'event-start-time', '9');
    expect(find.text('Type a time like 9:30, 9:30pm or 21:30.'), findsNothing);
  });

  testWidgets('EVT-02.b: changing the start keeps the duration, across midnight; changing the end sets the duration', (tester) async {
    await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-start-time', '10:00 am');
    expect(fieldText(tester, 'event-end-time'), '11:00 am');
    await typeIn(tester, 'event-start-time', '11:30 pm');
    expect(fieldText(tester, 'event-end-time'), '12:30 am');
    expect(find.descendant(of: find.byKey(const ValueKey('event-end-date')), matching: find.text('Jul 21, 2026')), findsOneWidget);
    // Changing the end sets the duration that later start changes keep.
    await typeIn(tester, 'event-start-time', '09:00 am');
    await typeIn(tester, 'event-end-time', '12:30 pm'); // 3 h 30 min
    await typeIn(tester, 'event-start-time', '10:00 am');
    expect(fieldText(tester, 'event-end-time'), '01:30 pm');
    expect(find.descendant(of: find.byKey(const ValueKey('event-end-date')), matching: find.text('Jul 20, 2026')), findsOneWidget);
  });

  testWidgets('EVT-01.b: a new event defaults to the system zone, or the calendar zone when a calendar is selected, and is saved into the chosen calendar', (tester) async {
    final c = await pumpCalendar(tester, cals: const [
      SuiteCalendar(id: 'work', name: 'Work', color: 0xFF5B6F9A, zone: 'Asia/Tokyo'),
      SuiteCalendar(id: 'home', name: 'Home', color: 0xFF2A9D8F),
    ]);
    await openDay(tester, 20);
    expect(find.descendant(of: find.byKey(const ValueKey('zone-start')), matching: find.textContaining(zone)), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('event-calendar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work').last);
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('zone-start')), matching: find.textContaining('Asia/Tokyo')), findsOneWidget);
    await typeIn(tester, 'event-title', 'Standup');
    await save(tester);
    final e = c.events.single;
    expect([e.calendarId, e.startZone, e.endZone], ['work', 'Asia/Tokyo', 'Asia/Tokyo']);
    // The custom event appears on its calendar.
    expect(find.byKey(ValueKey('event-${e.id}')), findsOneWidget);
    // With no calendar chosen it goes to the initial Local calendar (none).
    await openDay(tester, 21);
    await typeIn(tester, 'event-title', 'Solo');
    await save(tester);
    expect(c.events.last.calendarId, isNull);
    expect(c.events.last.startZone, zone);
  });

  testWidgets('EVT-02.d: the end may be in a different time zone; the event reopens with both zones', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Flight');
    await typeIn(tester, 'event-start-time', '10:00 am');
    await tester.tap(find.byKey(const ValueKey('event-diffzone')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('zone-end')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('zone-America/Los_Angeles')));
    await tester.pumpAndSettle();
    await typeIn(tester, 'event-end-time', '11:00 am'); // 11:00 am in Los Angeles
    await save(tester);
    final e = c.events.single;
    expect([e.startZone, e.endZone], [zone, 'America/Los_Angeles']);
    // 10:00 am New York to 11:00 am Los Angeles is 4 hours.
    expect(e.endUtc.difference(e.startUtc), const Duration(hours: 4));
    c.selectEvent(e.id);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'event-start-time'), '10:00 am');
    expect(fieldText(tester, 'event-end-time'), '11:00 am');
    expect(find.descendant(of: find.byKey(const ValueKey('zone-start')), matching: find.textContaining(zone)), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('zone-end')), matching: find.textContaining('America/Los_Angeles')), findsOneWidget);
    // Changing the start keeps the end in its own zone.
    await typeIn(tester, 'event-start-time', '11:00 am');
    expect(fieldText(tester, 'event-end-time'), '12:00 pm');
    // Unticking sets the end zone back to the start zone.
    await tester.tap(find.byKey(const ValueKey('event-diffzone')));
    await tester.pumpAndSettle();
    expect(isHidden(tester, 'zone-end'), isTrue);
  });

  testWidgets('EVT-02.e: an all-day event is entered without times', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Holiday');
    await tester.tap(find.byKey(const ValueKey('event-allday')));
    await tester.pumpAndSettle();
    expect(isHidden(tester, 'event-start-time'), isTrue);
    expect(isHidden(tester, 'event-end-time'), isTrue);
    await save(tester);
    final e = c.events.single;
    expect(e.allDay, isTrue);
    final s = e.startIn(zoneNamed(zone));
    expect([s.hour, s.minute], [0, 0]);
  });

  testWidgets('EVT-02.f: for an all-day event the end date is the last day, included', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Trip');
    await tester.tap(find.byKey(const ValueKey('event-allday')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('event-end-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pick-day-22')));
    await tester.pumpAndSettle();
    await save(tester);
    final e = c.events.single;
    final end = e.endIn(zoneNamed(zone));
    expect([end.month, end.day], [7, 23]); // the 22nd is included, so it ends at the next midnight
    // The time fields keep their values when hidden.
    c.selectEvent(e.id);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('event-end-date')), matching: find.text('Jul 22, 2026')), findsOneWidget);
  });

  testWidgets('EVT-02.f: an end date before the start date is not valid', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Odd');
    await tester.tap(find.byKey(const ValueKey('event-allday')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('event-end-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pick-day-18')));
    await tester.pumpAndSettle();
    await save(tester);
    expect(find.text('The last day is before the first day.'), findsOneWidget);
    expect(c.events, isEmpty);
  });

  testWidgets('EVT-02.g: changing the start date of an all-day event keeps its number of days', (tester) async {
    final c = await pumpCalendar(tester, events: [
      SuiteEvent.allDay(id: 'trip', title: 'Trip', year: 2026, month: 7, day: 20, zone: zone, days: 3),
    ]);
    c.selectEvent('trip');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('event-end-date')), matching: find.text('Jul 22, 2026')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('event-start-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pick-day-27')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('event-end-date')), matching: find.text('Jul 29, 2026')), findsOneWidget);
  });

  testWidgets('EVT-01.e: a custom event is deleted after asking and leaves its calendar; cancelling leaves it', (tester) async {
    final c = await pumpCalendar(tester, events: [makeEvent('mine', 20, 9, title: 'Mine')]);
    c.selectEvent('mine');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('event-delete')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Delete this event?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-no')));
    await tester.pumpAndSettle();
    expect(c.events.length, 1);
    expect(find.byKey(const ValueKey('event-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('event-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-yes')));
    await tester.pumpAndSettle();
    expect(c.events, isEmpty);
    expect(find.byKey(const ValueKey('event-dialog')), findsNothing);
    expect(c.canUndoDelete, isTrue); // CAP-02
  });

  testWidgets('UIC-06: hiding or deleting asks first with a No | Yes pair; cancelling changes nothing', (tester) async {
    final imported = makeEvent('theirs', 20, 9, title: 'Theirs').copyWith(custom: false);
    final c = await pumpCalendar(tester, events: [imported, makeEvent('mine', 21, 9, title: 'Mine')]);
    c.selectEvent('theirs');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-delete'))); // hide
    await tester.pumpAndSettle();
    expect(find.textContaining('Hide this event'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-no')));
    await tester.pumpAndSettle();
    expect(c.events.firstWhere((e) => e.id == 'theirs').hiddenFromGoogle, isFalse);
    await tester.tap(find.byKey(const ValueKey('details-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-yes')));
    await tester.pumpAndSettle();
    expect(c.events.firstWhere((e) => e.id == 'theirs').hiddenFromGoogle, isTrue);
    expect(c.events.length, 2); // hidden, never deleted
  });

  testWidgets('EVT-01.l: title, location, meeting address and notes are cut to their lengths; Notes is 10 lines; required fields carry an asterisk', (tester) async {
    await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'x' * 250);
    expect(fieldText(tester, 'event-title').length, 200);
    await typeIn(tester, 'event-location', 'y' * 250);
    expect(fieldText(tester, 'event-location').length, 200);
    await typeIn(tester, 'event-meeting', 'https://${'z' * 600}');
    expect(fieldText(tester, 'event-meeting').length, 500);
    await typeIn(tester, 'event-notes', 'n' * 4100);
    expect(fieldText(tester, 'event-notes').length, 4000);
    // Notes is at least 10 lines tall (DEF-01) and as tall as the fields beside it.
    expect(tester.getSize(find.byKey(const ValueKey('event-notes'))).height, greaterThanOrEqualTo(200));
    expect(find.text('Title'), findsOneWidget);
    expect(find.text(' *'), findsWidgets); // required fields carry an asterisk
    expect(find.text('Location'), findsOneWidget);
  });

  testWidgets('EVT-01.p: an online meeting address is empty or an http(s) link; otherwise it is not valid and its open button is off', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Call');
    expect(tester.widget<IconButton>(find.byKey(const ValueKey('event-open-meeting'))).onPressed, isNull);
    await typeIn(tester, 'event-meeting', 'meet.example.com');
    expect(tester.widget<IconButton>(find.byKey(const ValueKey('event-open-meeting'))).onPressed, isNull);
    await save(tester);
    expect(find.text('Online Meeting is a link starting with https://'), findsOneWidget);
    expect(c.events, isEmpty);
    await typeIn(tester, 'event-meeting', 'https://meet.example.com/abc');
    expect(tester.widget<IconButton>(find.byKey(const ValueKey('event-open-meeting'))).onPressed, isNotNull);
    await save(tester);
    expect(c.events.single.meetingUrl, 'https://meet.example.com/abc');
  });

  testWidgets('EVT-01.q: saving an event with no change records no edit', (tester) async {
    final imported = makeEvent('theirs', 20, 9, title: 'Theirs').copyWith(custom: false);
    final c = await pumpCalendar(tester, events: [imported]);
    c.selectEvent('theirs');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    // Nothing changed: Save is not available, so no edit can be recorded.
    await tester.tap(find.byKey(const ValueKey('event-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-dialog')), findsOneWidget);
    expect(c.events.single.edited, isFalse);
    await tester.tap(find.byKey(const ValueKey('event-cancel')));
    await tester.pumpAndSettle();
    // A real change on an event of a source marks it edited.
    c.selectEvent('theirs');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    await typeIn(tester, 'event-title', 'Theirs, moved');
    await save(tester);
    expect(c.events.single.edited, isTrue);
    expect(c.events.single.title, 'Theirs, moved');
  });

  testWidgets('EVT-03.b: an event color is one of the shared palette colors and shows on the calendar and in the dialog', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Colorful');
    await tester.tap(find.byKey(const ValueKey('event-color-button'))); // the palette opens from one button
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('color-Tomato')), findsOneWidget);
    expect(find.byKey(const ValueKey('color-Graphite')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('color-Tomato')));
    await tester.pumpAndSettle();
    await save(tester);
    expect(c.events.single.color, 0xFFD50000);
    final bar = find.descendant(
      of: find.byKey(ValueKey('event-${c.events.single.id}')),
      matching: find.byWidgetPredicate((w) => w is Container && w.color == const Color(0xFFD50000)),
    );
    expect(bar, findsOneWidget);
    c.selectEvent(c.events.single.id);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('event-color-button')), matching: find.text('Tomato')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('event-color-button')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('color-Tomato')), matching: find.byIcon(Icons.check)), findsOneWidget);
  });

  testWidgets('EVT-03.d: the default color follows the chosen calendar until a color is picked; a picked color survives a later calendar choice', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Follow');
    Color swatch() => ((tester.widget<Container>(find.byKey(const ValueKey('event-color-swatch')))).decoration! as BoxDecoration).color!;
    expect(find.descendant(of: find.byKey(const ValueKey('event-color-button')), matching: find.text('Default color')), findsOneWidget);
    expect(swatch(), const Color(0xFF1D4ED8)); // no calendar: the default color
    await tester.tap(find.byKey(const ValueKey('event-calendar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(swatch(), const Color(0xFF2A9D8F)); // it follows the calendar
    await tester.tap(find.byKey(const ValueKey('event-color-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('color-Grape')));
    await tester.pumpAndSettle();
    expect(swatch(), const Color(0xFF8E24AA));
    await tester.tap(find.byKey(const ValueKey('event-calendar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work').last);
    await tester.pumpAndSettle();
    expect(swatch(), const Color(0xFF8E24AA)); // a picked color survives a later calendar choice
    expect(find.descendant(of: find.byKey(const ValueKey('event-color-button')), matching: find.text('Grape')), findsOneWidget);
    await save(tester);
    expect(c.events.single.color, 0xFF8E24AA);
  });


  testWidgets('EVT-07.a: clicking an event opens its details in place; they stay open when the calendar is redrawn until Close', (tester) async {
    final e = makeEvent('a', 20, 10, title: 'Dentist', calendarId: 'work').copyWith(location: '12 Oak St', notes: 'Bring the form', edited: true);
    final c = await pumpCalendar(tester, events: [e]);
    expect(find.byKey(const ValueKey('event-details')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('event-a')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-dialog')), findsNothing); // the day's own dialog did not open
    final title = tester.widget<Text>(find.byKey(const ValueKey('details-title')));
    expect(title.data, 'Dentist');
    expect(title.style!.fontWeight, FontWeight.w700);
    expect(tester.widget<Text>(find.byKey(const ValueKey('details-range'))).data, 'Mon, Jul 20, 10:00 am–11:00 am');
    expect(tester.widget<Text>(find.byKey(const ValueKey('details-location'))).data, '12 Oak St');
    expect(find.byIcon(Icons.place_outlined), findsOneWidget); // the location has a pin
    expect(tester.widget<Text>(find.byKey(const ValueKey('details-notes'))).data, 'Bring the form');
    expect(find.text('Edited here'), findsOneWidget); // a state line
    // Redrawing the calendar (another view) keeps them open.
    c.view = CalendarView.week;
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-details')), findsOneWidget);
    c.view = CalendarView.list;
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-details')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('details-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-details')), findsNothing);
  });

  testWidgets('EVT-07.a: an event can be opened from every view', (tester) async {
    final e = makeEvent('a', 15, 10, title: 'Dentist');
    final c = await pumpCalendar(tester, events: [e]);
    for (final v in [CalendarView.month, CalendarView.week, CalendarView.fiveDay, CalendarView.day, CalendarView.list]) {
      c.view = v;
      c.selectEvent(null);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('event-a')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('event-details')), findsOneWidget, reason: '$v');
    }
  });

  testWidgets('EVT-07.h: the details name the event\'s calendar when there is more than one calendar', (tester) async {
    final e = makeEvent('a', 20, 10, calendarId: 'home');
    final c = await pumpCalendar(tester, events: [e]);
    c.selectEvent('a');
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const ValueKey('details-calendar'))).data, 'Home');
    c.selectEvent(null);
    await tester.pumpAndSettle();
    final one = await pumpCalendar(tester, events: [e], cals: const [SuiteCalendar(id: 'home', name: 'Home', color: 0xFF2A9D8F)]);
    one.selectEvent('a');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('details-calendar')), findsNothing);
  });

  testWidgets('EVT-07.k: Delete asks to delete and hide asks to hide', (tester) async {
    final mine = makeEvent('mine', 20, 9, title: 'Mine');
    final theirs = makeEvent('theirs', 21, 9, title: 'Theirs').copyWith(custom: false);
    final c = await pumpCalendar(tester, events: [mine, theirs]);
    c.selectEvent('mine');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-delete')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Delete this event?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-yes')));
    await tester.pumpAndSettle();
    expect(c.events.map((e) => e.id), ['theirs']);
    c.selectEvent('theirs');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-delete')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hide this event'), findsOneWidget);
  });

  testWidgets('title required: an event without a title is not valid and shows the note at its field', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-location', 'Somewhere'); // a change turns Save on, but the title is still missing
    await save(tester);
    expect(find.text('The event needs a title.'), findsOneWidget);
    final titleNote = tester.getRect(find.text('The event needs a title.'));
    expect(titleNote.bottom <= tester.getRect(find.byKey(const ValueKey('event-title'))).top + 1, isTrue); // on the label line
    expect(c.events, isEmpty);
    expect(find.byKey(const ValueKey('event-dialog')), findsOneWidget);
  });
}

void duplicateTests() {
  testWidgets('EVT-06.a: Duplicate, next to the calendar name, opens an editor holding a copy; a different calendar can be chosen before saving', (tester) async {
    final src = makeEvent('orig', 20, 9, title: 'Flight', calendarId: 'work').copyWith(location: 'Gate 4', notes: 'Bag', color: 0xFF33B679, reminders: [15]);
    final c = await pumpCalendar(tester, events: [src]);
    // A new event has no Duplicate.
    await openDay(tester, 21);
    expect(find.byKey(const ValueKey('event-duplicate')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('event-cancel')));
    await tester.pumpAndSettle();
    c.selectEvent('orig');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    // It sits on the Calendar label's line, right after the word.
    final dup = tester.getRect(find.byKey(const ValueKey('event-duplicate')));
    final label = tester.getRect(find.text('Calendar'));
    expect((dup.center.dy - label.center.dy).abs() < 12, isTrue);
    expect(dup.left >= label.right, isTrue);
    await tester.tap(find.byKey(const ValueKey('event-duplicate')));
    await tester.pumpAndSettle();
    expect(find.text('Duplicate event'), findsOneWidget);
    expect(fieldText(tester, 'event-title'), 'Flight');
    expect(fieldText(tester, 'event-location'), 'Gate 4');
    expect(fieldText(tester, 'event-notes'), 'Bag');
    expect(fieldText(tester, 'event-start-time'), '09:00 am');
    expect(find.byKey(const ValueKey('event-duplicate')), findsNothing); // a copy is a new event
    // Choose a different calendar and save.
    await tester.tap(find.byKey(const ValueKey('event-calendar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await save(tester);
    expect(c.events.length, 2);
    final copy = c.events.firstWhere((e) => e.id != 'orig');
    expect([copy.title, copy.calendarId, copy.location, copy.color, copy.reminders, copy.custom, copy.edited], ['Flight', 'home', 'Gate 4', 0xFF33B679, [15], true, false]);
    expect(copy.startUtc, src.startUtc);
    expect(c.events.firstWhere((e) => e.id == 'orig').calendarId, 'work'); // the original is untouched
  });

  testWidgets('EVT-06.a: a copy of an event in the same calendar is a separate event; Duplicate is also in the event tools', (tester) async {
    final src = makeEvent('orig', 20, 9, title: 'Same', calendarId: 'work');
    final c = await pumpCalendar(tester, events: [src]);
    c.selectEvent('orig');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-duplicate')));
    await tester.pumpAndSettle();
    expect(find.text('Duplicate event'), findsOneWidget);
    await save(tester);
    expect(c.events.length, 2);
    expect(c.events.map((e) => e.calendarId), ['work', 'work']);
    expect(c.events.map((e) => e.id).toSet().length, 2);
  });
}

void reminderTests() {
  Future<void> setRow(WidgetTester tester, int i, String number, String unitKey) async {
    await tester.ensureVisible(find.byKey(ValueKey('reminder-number-$i')));
    await typeIn(tester, 'reminder-number-$i', number);
    await tester.tap(find.byKey(ValueKey('reminder-unit-$i')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(unitKey).last);
    await tester.pumpAndSettle();
  }

  testWidgets('EVT-03.e: reminders are rows of method, number and unit, set from the start back to 1 week', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Remind');
    expect(find.byKey(const ValueKey('reminder-row-0')), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey('reminder-add')));
    await tester.tap(find.byKey(const ValueKey('reminder-add')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('reminder-method-0')), matching: find.text('Notification')), findsOneWidget);
    await setRow(tester, 0, '2', 'hours');
    await tester.ensureVisible(find.byKey(const ValueKey('reminder-add')));
    await tester.tap(find.byKey(const ValueKey('reminder-add')));
    await tester.pumpAndSettle();
    await setRow(tester, 1, '1', 'days');
    await save(tester);
    expect(c.events.single.reminders, [120, 1440]);
    // Reopened, each shows in the largest whole unit.
    c.selectEvent(c.events.single.id);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'reminder-number-0'), '2');
    expect(fieldText(tester, 'reminder-number-1'), '1');
    expect(find.descendant(of: find.byKey(const ValueKey('reminder-unit-0')), matching: find.text('hours')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('reminder-unit-1')), matching: find.text('days')), findsOneWidget);
  });

  testWidgets('EVT-03.e: a reminder past the longest lead is not valid and blocks saving', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Too far');
    await tester.ensureVisible(find.byKey(const ValueKey('reminder-add')));
    await tester.tap(find.byKey(const ValueKey('reminder-add')));
    await tester.pumpAndSettle();
    await setRow(tester, 0, '2', 'weeks');
    await save(tester);
    expect(find.textContaining('up to 1 week before the start'), findsOneWidget);
    expect(c.events, isEmpty);
    await setRow(tester, 0, '1', 'weeks'); // exactly 1 week is the longest allowed
    await save(tester);
    expect(c.events.single.reminders, [10080]);
  });

  testWidgets('EVT-03.k: a reminder row has a remove button; once the most reminders are set, adding another is disabled', (tester) async {
    final c = await pumpCalendar(tester);
    await openDay(tester, 20);
    await typeIn(tester, 'event-title', 'Many');
    for (var i = 0; i < 5; i++) {
      await tester.ensureVisible(find.byKey(const ValueKey('reminder-add')));
      await tester.tap(find.byKey(const ValueKey('reminder-add')));
      await tester.pumpAndSettle();
      await typeIn(tester, 'reminder-number-$i', '${(i + 1) * 5}');
    }
    expect(find.byKey(const ValueKey('reminder-row-4')), findsOneWidget);
    expect(tester.widget<TextButton>(find.byKey(const ValueKey('reminder-add'))).onPressed, isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('reminder-remove-1')));
    await tester.tap(find.byKey(const ValueKey('reminder-remove-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reminder-row-4')), findsNothing);
    expect(tester.widget<TextButton>(find.byKey(const ValueKey('reminder-add'))).onPressed, isNotNull);
    await save(tester);
    expect(c.events.single.reminders, [5, 15, 20, 25]);
  });

  testWidgets('reminders are in the left half with the other fields, above the Cancel | Save pair; Notes is as tall as the left half', (tester) async {
    await pumpCalendar(tester);
    await openDay(tester, 20);
    final reminders = tester.getRect(find.byKey(const ValueKey('event-reminders')));
    final title = tester.getRect(find.byKey(const ValueKey('event-title')));
    final notes = tester.getRect(find.byKey(const ValueKey('event-notes')));
    final pair = tester.getRect(find.byKey(const ValueKey('event-save')));
    expect(reminders.right <= notes.left, isTrue); // the left half
    expect((reminders.left - title.left).abs() < 2, isTrue); // lined up with the fields
    expect(reminders.top > title.bottom, isTrue);
    expect(reminders.bottom <= pair.top, isTrue); // above the buttons (and where Link to goes)
    expect((notes.top - title.top).abs() < 30, isTrue);
    expect((notes.bottom - reminders.bottom).abs() < 30, isTrue); // as tall as the left half
    // The Add notification button is in the left half.
    expect(tester.getRect(find.byKey(const ValueKey('reminder-add'))).right <= notes.left, isTrue);
  });

  testWidgets('a narrow window stacks the dialog; Notes comes after the reminders and never splits them from the other fields', (tester) async {
    useWindow(tester, const Size(620, 1800));
    final c = makeController(view: CalendarView.month);
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(620, 1800)));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    final title = tester.getRect(find.byKey(const ValueKey('event-title')));
    final reminders = tester.getRect(find.byKey(const ValueKey('event-reminders')));
    final notes = tester.getRect(find.byKey(const ValueKey('event-notes')));
    final pair = tester.getRect(find.byKey(const ValueKey('event-save')));
    expect(title.top < reminders.top && reminders.top < notes.top && notes.top < pair.top, isTrue);
    expect(reminders.bottom <= notes.top, isTrue);
  });
}

void errorNoteTests() {
  testWidgets('UIC-19: an error note sits on the label line, on one line; a note that is too long ends with … and its whole message shows on hover or click', (tester) async {
    useWindow(tester, const Size(620, 1500));
    final c = makeController(view: CalendarView.month);
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(620, 1500)));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    await typeIn(tester, 'event-title', 'Call');
    await tester.ensureVisible(find.byKey(const ValueKey('event-meeting')));
    await typeIn(tester, 'event-meeting', 'meet.example.com');
    await save(tester);
    const message = 'Online Meeting is a link starting with https://';
    final note = find.text(message);
    expect(note, findsOneWidget);
    final text = tester.widget<Text>(note);
    expect(text.maxLines, 1);
    expect(text.softWrap, isFalse);
    expect(text.overflow, TextOverflow.ellipsis);
    // It is next to the label, above the field.
    final label = tester.getRect(find.text('Online Meeting'));
    final r = tester.getRect(note);
    expect(r.left >= label.right, isTrue);
    expect((r.center.dy - label.center.dy).abs() < 8, isTrue);
    expect(r.bottom <= tester.getRect(find.byKey(const ValueKey('event-meeting'))).top + 1, isTrue);
    // Too long for its room in a narrow dialog: the whole message is offered on click.
    final tip = find.ancestor(of: note, matching: find.byKey(const ValueKey('error-note-info')));
    if (tip.evaluate().isNotEmpty) {
      await tester.tap(tip);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(message), findsNWidgets(2)); // the note and the popover
    }
  });

  testWidgets('UIC-19: a long error note is cut with … and shows its whole message in a popover', (tester) async {
    useWindow(tester, const Size(520, 1500));
    final c = makeController(view: CalendarView.month);
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(520, 1500)));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    await typeIn(tester, 'event-title', 'x');
    await typeIn(tester, 'event-start-time', 'soon');
    await save(tester);
    const message = 'Type a time like 9:30, 9:30pm or 21:30.';
    final info = find.ancestor(of: find.text(message), matching: find.byKey(const ValueKey('error-note-info')));
    expect(info, findsOneWidget); // too long for the narrow Time label line
    final t = tester.widget<Text>(find.text(message));
    expect(t.overflow, TextOverflow.ellipsis);
    expect(t.softWrap, isFalse);
    await tester.tap(info);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(message), findsNWidgets(2)); // the note and its popover
    await tester.tapAt(const Offset(5, 5)); // choosing outside closes it
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a time is accepted in 12-hour or 24-hour form and shown in the chosen notation when the field is left', (tester) async {
    useWindow(tester, tall);
    final c12 = makeController(); // 12-hour
    await tester.pumpWidget(appFor(CalendarPage(controller: c12), size: tall));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('event-start-time')), '2130'); // 24-hour form
    await tester.enterText(find.byKey(const ValueKey('event-end-time')), '11 pm'); // 12-hour form
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(fieldText(tester, 'event-end-time'), '11:00 pm');
    await tester.tap(find.byKey(const ValueKey('event-title'))); // leaving the start field
    await tester.pump();
    expect(fieldText(tester, 'event-start-time'), '09:30 pm');
    await tester.tap(find.byKey(const ValueKey('event-cancel')));
    await tester.pumpAndSettle();
    // And the other way round in 24-hour.
    c12.timeFormat = TimeFormat.twentyFourHour;
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('event-start-time')), '9:30pm'); // 12-hour form
    await tester.tap(find.byKey(const ValueKey('event-title')));
    await tester.pump();
    expect(fieldText(tester, 'event-start-time'), '21:30');
    await tester.enterText(find.byKey(const ValueKey('event-end-time')), '930');
    await tester.tap(find.byKey(const ValueKey('event-title')));
    await tester.pump();
    expect(fieldText(tester, 'event-end-time'), '09:30');
    // What cannot be read is left as typed.
    await tester.enterText(find.byKey(const ValueKey('event-end-time')), 'later');
    await tester.tap(find.byKey(const ValueKey('event-title')));
    await tester.pump();
    expect(fieldText(tester, 'event-end-time'), 'later');
  });
}

void deleteIconTests() {
  testWidgets('Delete event has a trash icon before the word; Hide and Show have an eye', (tester) async {
    final mine = makeEvent('mine', 20, 9, title: 'Mine');
    final theirs = makeEvent('theirs', 21, 9, title: 'Theirs').copyWith(custom: false);
    final c = await pumpCalendar(tester, events: [mine, theirs]);
    c.selectEvent('mine');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    final del = find.byKey(const ValueKey('event-delete'));
    final icon = find.descendant(of: del, matching: find.byIcon(Icons.delete_outline));
    final word = find.descendant(of: del, matching: find.text('Delete event'));
    expect(icon, findsOneWidget);
    expect(tester.getCenter(icon).dx < tester.getCenter(word).dx, isTrue); // before the word
    await tester.tap(find.byKey(const ValueKey('event-cancel')));
    await tester.pumpAndSettle();
    c.selectEvent('theirs');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('details-edit')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('event-delete')), matching: find.byIcon(Icons.visibility_off_outlined)), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('event-delete')), matching: find.text('Hide')), findsOneWidget);
  });
}
