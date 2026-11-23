import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';
import 'package:timezone/timezone.dart' as tz;

import '../calendar/test_support.dart';

/// 14 July 18:00 to 16 July 04:00 in New York: three dates (first, middle, last).
SuiteEvent _trip({int day = 14, int hour = 18, int hours = 34}) => SuiteEvent.zoned(
      id: 'trip',
      title: 'Trip',
      year: 2026,
      month: 7,
      day: day,
      hour: hour,
      minute: 0,
      length: Duration(hours: hours),
      zone: zone,
    );

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  group('CAL-09.c: multiDayLabel', () {
    late tz.Location loc;
    late tz.TZDateTime start, end;
    setUp(() {
      initZones();
      loc = tz.getLocation(zone);
      start = tz.TZDateTime(loc, 2026, 7, 14, 18);
      end = tz.TZDateTime(loc, 2026, 7, 16, 4);
    });
    String? label(DateTime day, TimeFormat f, {DateTime? s, DateTime? e}) =>
        multiDayLabel(start: s ?? start, end: e ?? end, day: day, format: f, cont: 'cont.');

    test('first day 18:00-, middle cont., last -04:00 in 24-hour', () {
      expect(label(DateTime(2026, 7, 14), TimeFormat.twentyFourHour), '18:00-');
      expect(label(DateTime(2026, 7, 15), TimeFormat.twentyFourHour), 'cont.');
      expect(label(DateTime(2026, 7, 16), TimeFormat.twentyFourHour), '-04:00');
    });

    test('the same labels in the 12-hour page format', () {
      expect(label(DateTime(2026, 7, 14), TimeFormat.twelveHour), '06:00 pm-');
      expect(label(DateTime(2026, 7, 16), TimeFormat.twelveHour), '-04:00 am');
    });

    test('a two-date event has a first and a last day and no middle', () {
      final e = tz.TZDateTime(loc, 2026, 7, 15, 9);
      expect(label(DateTime(2026, 7, 14), TimeFormat.twentyFourHour, e: e), '18:00-');
      expect(label(DateTime(2026, 7, 15), TimeFormat.twentyFourHour, e: e), '-09:00');
    });

    test('an event ending at 00:00 belongs to its start date only (no label)', () {
      final e = tz.TZDateTime(loc, 2026, 7, 15, 0);
      expect(label(DateTime(2026, 7, 14), TimeFormat.twentyFourHour, e: e), isNull);
    });

    test('an event within one date has no multi-day label', () {
      final e = tz.TZDateTime(loc, 2026, 7, 14, 20);
      expect(label(DateTime(2026, 7, 14), TimeFormat.twelveHour, e: e), isNull);
    });
  });

  testWidgets('CAL-09.c: Month shows the labels on the first, middle and last day', (tester) async {
    useWindow(tester);
    final c = makeController(events: [_trip()], view: CalendarView.month);
    addTearDown(c.dispose);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    String textIn(int d) => tester.widget<Text>(find.descendant(of: find.byKey(ValueKey('day-2026-7-$d')), matching: find.byType(Text)).last).data!;
    expect(find.text('06:00 pm- Trip'), findsOneWidget);
    expect(find.text('cont. Trip'), findsOneWidget);
    expect(find.text('-04:00 am Trip'), findsOneWidget);
    expect(textIn(14), '06:00 pm- Trip');
    expect(textIn(15), 'cont. Trip');
    expect(textIn(16), '-04:00 am Trip');
  });

  testWidgets('CAL-09.c: Month uses the 24-hour page format', (tester) async {
    useWindow(tester);
    final c = makeController(events: [_trip()], view: CalendarView.month);
    addTearDown(c.dispose);
    c.timeFormat = TimeFormat.twentyFourHour;
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.text('18:00- Trip'), findsOneWidget);
    expect(find.text('-04:00 Trip'), findsOneWidget);
  });

  testWidgets('CAL-09.c: a narrow Month cell clips the label with an ellipsis, without overflow', (tester) async {
    useWindow(tester, const Size(420, 800));
    final c = makeController(events: [_trip()], view: CalendarView.month);
    addTearDown(c.dispose);
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(420, 800)));
    final text = tester.widget<Text>(find.text('06:00 pm- Trip'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CAL-09.c: an event ending at 00:00 keeps its start label and is not shown on the next day', (tester) async {
    useWindow(tester);
    final e = SuiteEvent.zoned(id: 'late', title: 'Late', year: 2026, month: 7, day: 15, hour: 18, minute: 0, length: const Duration(hours: 6), zone: zone);
    final c = makeController(events: [e], view: CalendarView.month);
    addTearDown(c.dispose);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.text('06:00 pm Late'), findsOneWidget);
    expect(find.textContaining('Late'), findsOneWidget);
  });

  testWidgets('CAL-09.c: Week and Day show the labels', (tester) async {
    useWindow(tester);
    final c = makeController(events: [_trip()], view: CalendarView.week);
    addTearDown(c.dispose);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.text('06:00 pm- Trip'), findsOneWidget);
    expect(find.text('cont. Trip'), findsOneWidget);
    expect(find.text('-04:00 am Trip'), findsOneWidget);
    c.view = CalendarView.day;
    c.goToDate(DateTime(2026, 7, 16));
    await tester.pump();
    expect(find.text('-04:00 am Trip'), findsOneWidget);
    expect(find.text('06:00 pm- Trip'), findsNothing);
  });

  testWidgets('CAL-09.c: List shows the labels', (tester) async {
    useWindow(tester);
    final c = makeController(events: [_trip()], view: CalendarView.list);
    addTearDown(c.dispose);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.text('06:00 pm-'), findsOneWidget);
    expect(find.text('cont.'), findsOneWidget);
    expect(find.text('-04:00 am'), findsOneWidget);
  });

  testWidgets('CAL-09.c: a Day print shows the label of its day', (tester) async {
    useWindow(tester);
    final c = makeController(events: [_trip()], view: CalendarView.day, focused: DateTime(2026, 7, 16));
    addTearDown(c.dispose);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    await tester.tap(find.byKey(const ValueKey('calendar-print-button')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('-04:00 am Trip', findRichText: true)), findsOneWidget);
  });
}
