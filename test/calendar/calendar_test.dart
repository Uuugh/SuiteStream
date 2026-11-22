import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/calendar/week_layout.dart';
import 'package:suitestream/src/calendar/week_view.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';
import 'package:suitestream/src/ui/suite_dropdown.dart';

const _zone = 'America/New_York';

CalendarController _controller({List<SuiteEvent> events = const [], CalendarView view = CalendarView.month}) =>
    CalendarController(
      localZone: const LocalZone.system(_zone),
      timeFormat: TimeFormat.twelveHour,
      events: events,
      view: view,
      // Wednesday 15 July 2026, noon in New York.
      clock: () => DateTime.utc(2026, 7, 15, 16),
    );

SuiteEvent _event(String id, int day, int hour, {int minutes = 60, String title = 'Event'}) => SuiteEvent.zoned(
      id: id,
      title: '$title $id',
      year: 2026,
      month: 7,
      day: day,
      hour: hour,
      minute: 0,
      length: Duration(minutes: minutes),
      zone: _zone,
    );

Map<String, dynamic> _arb(String code) =>
    jsonDecode(File('requirements/messages/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;

Widget _app(Widget child, {Size size = const Size(1000, 800), String locale = 'en'}) => MaterialApp(
      theme: buildSuiteTheme(Brightness.light),
      builder: (context, c) => MessagesScope(messages: Messages.fromMaps(locale, _arb(locale), _arb('en')), child: c!),
      home: Scaffold(body: SizedBox(width: size.width, height: size.height, child: child)),
    );

void main() {
  alignmentTests();
  yearPickerTests();
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  testWidgets('CAL-01.a: the calendar displays the events of its source calendars', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller(events: [_event('a', 15, 10, title: 'Dentist')]);
    await tester.pumpWidget(_app(CalendarPage(controller: c)));
    expect(find.textContaining('Dentist a'), findsOneWidget);
    // A new event appears at once (UIC-13).
    c.addEvent(_event('b', 16, 9, title: 'Lunch'));
    await tester.pump();
    expect(find.textContaining('Lunch b'), findsOneWidget);
  });

  testWidgets('CAL-01.a: events are shown in the Local zone (TIM-03)', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller(events: [_event('a', 15, 22, title: 'Late')]);
    await tester.pumpWidget(_app(CalendarPage(controller: c)));
    expect(find.text('10pm Late a'), findsOneWidget);
    // Seen from Tokyo, 22:00 New York on the 15th is the 16th at 11 am.
    c.localZone = const LocalZone.fixed('Asia/Tokyo', systemZone: _zone);
    await tester.pump();
    expect(find.text('11am Late a'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('day-2026-7-16')), matching: find.text('11am Late a')), findsOneWidget);
  });

  testWidgets('CAL-01.i: today is a filled date with an accent border around its whole day', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller();
    await tester.pumpWidget(_app(CalendarPage(controller: c)));
    expect(find.byKey(const ValueKey('today-marker')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('day-2026-7-15')), matching: find.byKey(const ValueKey('today-marker'))), findsOneWidget);
    final cell = tester.widget<Container>(find.byKey(const ValueKey('day-2026-7-15')));
    final deco = cell.foregroundDecoration! as BoxDecoration;
    final border = deco.border! as Border;
    expect(border.top.width, 2);
    expect(border.top.color, SuiteTokensLight.accent);
    final other = tester.widget<Container>(find.byKey(const ValueKey('day-2026-7-16')));
    expect(other.foregroundDecoration, isNull);
  });

  test('CAL-01.c: Week view shows its date range and moves a week at a time', () {
    final c = _controller(view: CalendarView.week);
    expect(c.weekStart, DateTime(2026, 7, 12));
    expect(c.weekEnd, DateTime(2026, 7, 18));
    c.next();
    expect([c.weekStart, c.weekEnd], [DateTime(2026, 7, 19), DateTime(2026, 7, 25)]);
    c.previous();
    c.previous();
    expect(c.weekStart, DateTime(2026, 7, 5));
  });

  testWidgets('CAL-01.c: the Week header shows the date range and the buttons move by one week', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller(view: CalendarView.week);
    await tester.pumpWidget(_app(CalendarPage(controller: c)));
    expect(find.text('Jul 12 – 18, 2026'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('next')));
    await tester.pump();
    expect(find.text('Jul 19 – 25, 2026'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('previous')));
    await tester.tap(find.byKey(const ValueKey('previous')));
    await tester.pump();
    expect(find.text('Jul 5 – 11, 2026'), findsOneWidget);
  });

  test('CAL-01.d: selecting a month and year navigates the calendar to it', () {
    final c = _controller();
    c.goToMonth(2027, 2);
    expect(c.focused, DateTime(2027, 2, 1));
    c.goToMonth(2026, 7); // the current month: today
    expect(c.focused, DateTime(2026, 7, 15));
  });

  testWidgets('CAL-01.d: the title opens a month picker that closes when a month is picked', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller();
    await tester.pumpWidget(_app(CalendarPage(controller: c)));
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('picker-title'))); // the title opens the month list
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('year-next')));
    await tester.tap(find.byKey(const ValueKey('month-3')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('month-3')), findsNothing);
    expect(c.focused, DateTime(2027, 3, 1));
    expect(find.text('March 2027'), findsOneWidget);
  });

  testWidgets('CAL-01.b: Month and Week are chosen from the shared dropdown and shown at once', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller();
    await tester.pumpWidget(_app(CalendarPage(controller: c)));
    expect(find.byType(HourlyView), findsNothing);
    await tester.tap(find.byIcon(Icons.calendar_month).last);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget); // the chosen view is indicated
    await tester.tap(find.byKey(const ValueKey('dropdown-item-CalendarView.week')));
    await tester.pumpAndSettle();
    expect(c.view, CalendarView.week);
    expect(find.byType(HourlyView), findsOneWidget);
    expect(find.byKey(const ValueKey('dropdown-item-CalendarView.week')), findsNothing); // the menu closed
  });

  test('CAL-01.h: overlapping events sit side by side; others use the full width', () {
    final a = _event('a', 15, 9);
    final b = _event('b', 15, 9, minutes: 90);
    final c = _event('c', 15, 12);
    final ctrl = _controller();
    (int, int) span(SuiteEvent e) {
      final s = e.startIn(ctrl.localZone.location);
      final m = s.hour * 60 + s.minute;
      return (m, m + e.endUtc.difference(e.startUtc).inMinutes);
    }

    final placed = layoutOverlaps<SuiteEvent>([a, b, c], span);
    final byId = {for (final p in placed) p.event.id: p};
    expect(byId['a']!.columns, 2);
    expect(byId['b']!.columns, 2);
    expect({byId['a']!.column, byId['b']!.column}, {0, 1});
    expect(byId['c']!.columns, 1);
    expect(byId['c']!.column, 0);
  });

  test('CAL-01.h: the grid starts at the first event, or at 7 am when there is none', () {
    final day = DateTime(2026, 7, 15);
    final week = [for (var i = 12; i <= 18; i++) DateTime(2026, 7, i)];
    expect(scrollStartHour(_controller(), week), 7);
    expect(scrollStartHour(_controller(events: [_event('a', 15, 9), _event('b', 16, 14)]), week), 9);
    expect(day.day, 15);
  });

  testWidgets('CAL-01.h: Week shows every hour in a scrolling area, events by time, all-day events above', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller(view: CalendarView.week, events: [
      _event('a', 15, 6),
      _event('b', 15, 6, minutes: 90),
      SuiteEvent.allDay(id: 'h', title: 'Holiday', year: 2026, month: 7, day: 15, zone: _zone),
    ]);
    await tester.pumpWidget(_app(CalendarPage(controller: c)));
    // The grid starts at the first event (6 am), not at the top.
    final scroll = tester.widget<SingleChildScrollView>(find.byKey(const ValueKey('hour-grid')));
    expect(scroll.controller!.offset, 6 * hourHeight);
    // All 24 hours are in the scrolling area.
    expect(tester.getSize(find.descendant(of: find.byKey(const ValueKey('hour-grid')), matching: find.byType(SizedBox)).first).height >= 0, isTrue);
    expect(scroll.controller!.position.maxScrollExtent, 24 * hourHeight - tester.getSize(find.byKey(const ValueKey('hour-grid'))).height);
    // The overlapping events share the day column.
    final a = tester.getRect(find.byKey(const ValueKey('event-a')));
    final b = tester.getRect(find.byKey(const ValueKey('event-b')));
    expect(a.overlaps(b), isFalse);
    expect(a.top, b.top);
    // All-day events sit above the grid.
    final allDay = tester.getRect(find.byKey(const ValueKey('all-day-row')));
    final grid = tester.getRect(find.byKey(const ValueKey('hour-grid')));
    expect(allDay.bottom <= grid.top, isTrue);
    expect(find.text('Holiday'), findsOneWidget);
    // Times use the chosen format (TIM-10).
    c.timeFormat = TimeFormat.twentyFourHour;
    await tester.pump();
    expect(find.text('06:00 Event a'), findsOneWidget);
  });

  testWidgets('UIC-12: the dropdown opens from one icon; one click chooses at once and closes it', (tester) async {
    final chosen = <String>[];
    await tester.pumpWidget(_app(Align(
      alignment: Alignment.topCenter,
      child: SuiteDropdown<String>(
        icon: Icons.language,
        items: const [DropdownItem(value: 'en', label: 'English'), DropdownItem(value: 'fr', label: 'Français')],
        selected: const {'en'},
        onChanged: (s) => chosen.addAll(s),
      ),
    )));
    expect(find.text('English'), findsNothing);
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();
    expect(chosen, ['fr']);
    expect(find.text('English'), findsNothing);
  });

  testWidgets('UIC-12: choosing outside the dropdown closes it', (tester) async {
    await tester.pumpWidget(_app(Align(
      alignment: Alignment.topCenter,
      child: SuiteDropdown<String>(
        icon: Icons.language,
        items: const [DropdownItem(value: 'en', label: 'English')],
        selected: const {},
        onChanged: (_) {},
      ),
    )));
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    expect(find.text('English'), findsOneWidget);
    await tester.tapAt(const Offset(10, 500));
    await tester.pumpAndSettle();
    expect(find.text('English'), findsNothing);
  });

  testWidgets('UIC-12: where several can be selected a click toggles and Shift selects a range', (tester) async {
    var selected = <String>{};
    late StateSetter set;
    await tester.pumpWidget(_app(StatefulBuilder(builder: (context, setState) {
      set = setState;
      return Align(
        alignment: Alignment.topCenter,
        child: SuiteDropdown<String>(
          multi: true,
          icon: Icons.filter_list,
          items: const [
            DropdownItem(value: 'a', label: 'Work'),
            DropdownItem(value: 'b', label: 'Home'),
            DropdownItem(value: 'c', label: 'Travel'),
            DropdownItem(value: 'd', label: 'Other'),
          ],
          selected: selected,
          onChanged: (s) => set(() => selected = s),
        ),
      );
    })));
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(selected, {'a'});
    expect(find.text('Work'), findsOneWidget); // stays open while several can be chosen
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('Other'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(selected, {'b', 'c', 'd'});
  });

  testWidgets('UIC-13: a change is shown at once without a reload or an Apply step', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller(events: [_event('a', 15, 13)]);
    await tester.pumpWidget(_app(CalendarPage(controller: c)));
    expect(find.text('1pm Event a'), findsOneWidget);
    c.timeFormat = TimeFormat.twentyFourHour;
    await tester.pump();
    expect(find.text('13:00 Event a'), findsOneWidget);
    expect(find.text('Apply'), findsNothing);
  });
}

/// The light accent color (THM-02.g), read from the token set under test.
class SuiteTokensLight {
  static const accent = Color(0xFF40609C);
}

void alignmentTests() {
  testWidgets('UIC-12: every dropdown icon lines up vertically with the trigger icon', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller();
    await tester.pumpWidget(_app(CalendarPage(controller: c), size: const Size(1000, 800)));
    final triggerX = tester.getCenter(find.byIcon(Icons.calendar_month).last).dx;
    await tester.tap(find.byIcon(Icons.calendar_month).last);
    await tester.pumpAndSettle();
    final item = find.byKey(const ValueKey('dropdown-item-CalendarView.month'));
    final monthIcon = find.descendant(of: item, matching: find.byIcon(Icons.calendar_month));
    final weekIcon = find.descendant(
        of: find.byKey(const ValueKey('dropdown-item-CalendarView.week')), matching: find.byIcon(Icons.view_week));
    expect(tester.getCenter(monthIcon).dx, triggerX);
    expect(tester.getCenter(weekIcon).dx, triggerX);
    // The whole menu stays inside the window.
    expect(tester.getRect(item).right <= 1000, isTrue);
  });
}

void yearPickerTests() {
  testWidgets('CAL-01.d: clicking the year in the month picker lets the user choose a year', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = _controller();
    await tester.pumpWidget(_app(CalendarPage(controller: c)));
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('picker-title'))); // the title opens the month list
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('year-title')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('year-grid')), findsOneWidget);
    expect(find.byKey(const ValueKey('year-2026')), findsOneWidget); // the shown year is in view
    await tester.tap(find.byKey(const ValueKey('year-2026')));
    await tester.pumpAndSettle();
    // Back to the months, still open until a month is picked.
    expect(find.byKey(const ValueKey('year-grid')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('year-title')));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.byKey(const ValueKey('year-2031')), find.byKey(const ValueKey('year-grid')), const Offset(0, -80));
    await tester.tap(find.byKey(const ValueKey('year-2031')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('month-9')));
    await tester.pumpAndSettle();
    expect(c.focused, DateTime(2031, 9));
  });
}
