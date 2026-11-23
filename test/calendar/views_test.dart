import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/calendar/list_view.dart';
import 'package:suitestream/src/calendar/month_view.dart';
import 'package:suitestream/src/calendar/week_view.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

Future<void> pickView(WidgetTester tester, CalendarController c, CalendarView v) async {
  await tester.tap(find.byIcon(viewIcon(c.view)).last);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('dropdown-item-$v')));
  await tester.pumpAndSettle();
}

void main() {
  datePickerTests();
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  testWidgets('CAL-01.b: Month, Week, 5-day, Day and List can be chosen from the shared dropdown', (tester) async {
    useWindow(tester);
    final c = makeController(events: [makeEvent('a', 15, 10, title: 'Dentist')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.byType(MonthView), findsOneWidget);

    await pickView(tester, c, CalendarView.week);
    expect(c.view, CalendarView.week);
    expect(find.byType(HourlyView), findsOneWidget);
    expect(c.hourlyDays.length, 7);

    await pickView(tester, c, CalendarView.fiveDay);
    expect(find.byType(HourlyView), findsOneWidget);
    expect(c.hourlyDays, [for (var d = 13; d <= 17; d++) DateTime(2026, 7, d)]); // Monday through Friday

    await pickView(tester, c, CalendarView.day);
    expect(find.byType(HourlyView), findsOneWidget);
    expect(c.hourlyDays, [DateTime(2026, 7, 15)]);
    expect(find.textContaining('Dentist'), findsOneWidget);

    await pickView(tester, c, CalendarView.list);
    expect(find.byType(AgendaView), findsOneWidget);
    expect(find.text('Dentist'), findsOneWidget);

    await pickView(tester, c, CalendarView.month);
    expect(find.byType(MonthView), findsOneWidget);
  });

  testWidgets('CAL-01.e: Today returns the calendar to the current month', (tester) async {
    useWindow(tester);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    c.goToMonth(2030, 1);
    await tester.pump();
    expect(find.text('January 2030'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('today')));
    await tester.pump();
    expect(c.focused, DateTime(2026, 7, 15));
    expect(find.text('July 2026'), findsOneWidget);
  });

  testWidgets('CAL-01.f: before the user chooses a view, a phone-width window opens List view', (tester) async {
    useWindow(tester, const Size(600, 800));
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(600, 800)));
    expect(c.view, CalendarView.list);
    expect(find.byType(AgendaView), findsOneWidget);
    // Once the user chooses a view it stays, whatever the width.
    c.view = CalendarView.month;
    await tester.pump();
    expect(find.byType(MonthView), findsOneWidget);
    // A phone-width window is 700 px or narrower.
    useWindow(tester, const Size(701, 800));
    final c2 = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c2), size: const Size(701, 800)));
    expect(c2.view, CalendarView.month);
  });

  testWidgets('CAL-01.g: a day cell shows how many of its visible events do not fit', (tester) async {
    useWindow(tester);
    final events = [for (var i = 0; i < 10; i++) makeEvent('$i', 15, 9, title: 'Evt$i')];
    final c = makeController(events: events);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final cell = find.byKey(const ValueKey('day-2026-7-15'));
    final shown = find.descendant(of: cell, matching: find.textContaining('Evt')).evaluate().length;
    final more = find.byKey(const ValueKey('more-2026-7-15'));
    expect(more, findsOneWidget);
    final n = int.parse(tester.widget<Text>(find.descendant(of: more, matching: find.byType(Text))).data!.replaceAll(RegExp(r'\D'), ''));
    expect(n, greaterThan(0));
    expect(shown + n, 10);
    // A day whose events all fit shows no count.
    final c2 = makeController(events: [makeEvent('x', 16, 9, title: 'Solo')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c2)));
    await tester.pump();
    expect(find.byKey(const ValueKey('more-2026-7-16')), findsNothing);
  });

  testWidgets('CAL-01.j: a horizontal touch swipe turns the page; short, vertical, multi-finger and mouse swipes do not', (tester) async {
    useWindow(tester);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final spot = tester.getCenter(find.byType(MonthView));

    Future<void> swipe(Offset by, {PointerDeviceKind kind = PointerDeviceKind.touch}) async {
      final g = await tester.startGesture(spot, kind: kind);
      await g.moveBy(by);
      await g.up();
      await tester.pump();
    }

    await swipe(const Offset(-120, 0)); // left: next
    expect(c.focused, DateTime(2026, 8, 1));
    await swipe(const Offset(120, 0)); // right: previous
    expect(c.focused, DateTime(2026, 7, 31));
    final before = c.focused;
    await swipe(const Offset(-30, 0)); // too short
    await swipe(const Offset(-60, -100)); // mostly vertical
    await swipe(const Offset(-120, 0), kind: PointerDeviceKind.mouse);
    expect(c.focused, before);
    // Two fingers are ignored.
    final a = await tester.startGesture(spot, pointer: 1);
    final b = await tester.startGesture(spot + const Offset(40, 0), pointer: 2);
    await a.moveBy(const Offset(-120, 0));
    await a.up();
    await b.up();
    await tester.pump();
    expect(c.focused, before);
  });

  test('CAL-01.k: until the user chooses a view, the calendar is in Month view', () {
    final c = makeController();
    expect(c.view, CalendarView.month);
    c.layout(phone: true);
    expect(c.view, CalendarView.list);
    c.view = CalendarView.week;
    c.layout(phone: false);
    expect(c.view, CalendarView.week);
  });

  testWidgets('CAL-01.l: the header holds previous, next, Today and then the title', (tester) async {
    useWindow(tester);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final xs = [
      for (final k in ['previous', 'next', 'today', 'title']) tester.getTopLeft(find.byKey(ValueKey(k))).dx,
    ];
    expect(xs, orderedEquals([...xs]..sort()));
    expect(xs.toSet().length, 4);
    expect(find.text('Today'), findsOneWidget);
  });

  test('CAL-01.m: previous and next move a month in Month and List, a week in Week, a day in Day', () {
    final month = makeController(view: CalendarView.month);
    month.previous();
    expect(month.focused, DateTime(2026, 6, 30)); // the last day of the previous month
    final m2 = makeController(view: CalendarView.month);
    m2.next();
    expect(m2.focused, DateTime(2026, 8, 1)); // the first day of the next
    final list = makeController(view: CalendarView.list)..next();
    expect(list.focused, DateTime(2026, 8, 1));
    final week = makeController(view: CalendarView.week)..next();
    expect(week.focused, DateTime(2026, 7, 22));
    week.previous();
    week.previous();
    expect(week.focused, DateTime(2026, 7, 8));
    final day = makeController(view: CalendarView.day)..next();
    expect(day.focused, DateTime(2026, 7, 16));
    day.previous();
    day.previous();
    expect(day.focused, DateTime(2026, 7, 14));
  });

  testWidgets('CAL-01.n: previous and next are named for the step of the view', (tester) async {
    useWindow(tester);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.byTooltip('Previous month'), findsOneWidget);
    expect(find.byTooltip('Next month'), findsOneWidget);
    c.view = CalendarView.week;
    await tester.pump();
    expect(find.byTooltip('Previous week'), findsOneWidget);
    expect(find.byTooltip('Next week'), findsOneWidget);
    c.view = CalendarView.day;
    await tester.pump();
    expect(find.byTooltip('Previous day'), findsOneWidget);
    expect(find.byTooltip('Next day'), findsOneWidget);
    c.view = CalendarView.list;
    await tester.pump();
    expect(find.byTooltip('Previous month'), findsOneWidget);
  });

  test('CAL-01.o: only dates in the supported years are shown; others put the calendar on today', () {
    expect(makeController(focused: DateTime(1999, 12, 31)).focused, DateTime(2026, 7, 15));
    expect(makeController(focused: DateTime(2101, 1, 1)).focused, DateTime(2026, 7, 15));
    expect(makeController(focused: DateTime(2000, 1, 1)).focused, DateTime(2000, 1, 1));
    final c = makeController(focused: DateTime(2100, 12, 15))..next();
    expect(c.focused, DateTime(2026, 7, 15));
    final d = makeController(focused: DateTime(2000, 1, 15))..previous();
    expect(d.focused, DateTime(2026, 7, 15));
    c.goToMonth(2101, 3);
    expect(c.focused, DateTime(2026, 7, 15));
  });

  test('goToMonth: a month puts the calendar on the 1st, or on today for the current month', () {
    final c = makeController();
    c.goToMonth(2026, 11);
    expect(c.focused, DateTime(2026, 11, 1));
    c.goToMonth(2026, 7);
    expect(c.focused, DateTime(2026, 7, 15));
  });

  testWidgets('CAL-01.q: titles use the page language, first letter capitalised', (tester) async {
    useWindow(tester);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.text('July 2026'), findsOneWidget);
    c.view = CalendarView.day;
    await tester.pump();
    expect(find.text('Wednesday, July 15, 2026'), findsOneWidget);
    final fr = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: fr), locale: 'fr'));
    await tester.pump();
    expect(find.text('Juillet 2026'), findsOneWidget);
  });

  testWidgets('CAL-01.r: the year row has previous and next year buttons with no limit, starting at the displayed year', (tester) async {
    useWindow(tester);
    final c = makeController(focused: DateTime(2100, 12, 1));
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('picker-title'))); // the title opens the month list
    await tester.pumpAndSettle();
    expect(find.byTooltip('Previous year'), findsOneWidget);
    expect(find.byTooltip('Next year'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('year-title')), matching: find.text('2100')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('year-next')));
    await tester.tap(find.byKey(const ValueKey('year-next')));
    await tester.pump();
    expect(find.descendant(of: find.byKey(const ValueKey('year-title')), matching: find.text('2102')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('month-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pick-day-15')));
    await tester.pumpAndSettle();
    // Out of the supported years: the calendar goes to today.
    expect(c.focused, DateTime(2026, 7, 15));
    // The year starts at the displayed month's year each time the picker opens.
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('picker-title'))); // the title opens the month list
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('year-title')), matching: find.text('2026')), findsOneWidget);
  });

  testWidgets('CAL-01.s: the month picker shows the twelve abbreviated month names in order, with the displayed month marked', (tester) async {
    useWindow(tester);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('picker-title'))); // the title opens the month list
    await tester.pumpAndSettle();
    final names = [
      for (var m = 1; m <= 12; m++) (tester.widget<Text>(find.descendant(of: find.byKey(ValueKey('month-$m')), matching: find.byType(Text))).data),
    ];
    expect(names, ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']);
    final xs = [for (var m = 1; m <= 4; m++) tester.getTopLeft(find.byKey(ValueKey('month-$m'))).dx];
    expect(xs, orderedEquals([...xs]..sort()));
    final marked = tester.widget<TextButton>(find.byKey(const ValueKey('month-7')));
    final other = tester.widget<TextButton>(find.byKey(const ValueKey('month-8')));
    expect(marked.style, isNotNull);
    expect(other.style, isNull);
    await tester.tap(find.byKey(const ValueKey('month-8'))); // a month goes back down to its days
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('month-8')), findsNothing);
    expect(find.text('August 2026'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pick-day-3')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pick-day-3')), findsNothing);
    expect(c.focused, DateTime(2026, 8, 3));
    // In French the names are French.
    final fr = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: fr), locale: 'fr'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('picker-title'))); // the title opens the month list
    await tester.pumpAndSettle();
    final fr1 = tester.widget<Text>(find.descendant(of: find.byKey(const ValueKey('month-1')), matching: find.byType(Text))).data!;
    expect(fr1.toLowerCase(), startsWith('janv'));
  });

  testWidgets('view picker: shows only the current view icon closed; each choice shows its icon left of its word; the tooltip names the view', (tester) async {
    useWindow(tester);
    final c = makeController(view: CalendarView.week);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.byIcon(SuiteIcons.viewWeek), findsOneWidget);
    expect(find.byIcon(SuiteIcons.calendarMonth), findsNothing);
    expect(find.byTooltip('View: Week'), findsOneWidget);
    await tester.tap(find.byIcon(SuiteIcons.viewWeek));
    await tester.pumpAndSettle();
    for (final v in CalendarView.values) {
      final item = find.byKey(ValueKey('dropdown-item-$v'));
      final icon = find.descendant(of: item, matching: find.byIcon(viewIcon(v)));
      final word = find.descendant(of: item, matching: find.byType(Text));
      expect(icon, findsOneWidget);
      expect(tester.getCenter(icon).dx < tester.getCenter(word).dx, isTrue);
    }
  });
}

void datePickerTests() {
  testWidgets('CAL-01.t: the date picker is a small month calendar; picking a day goes to that date and closes it', (tester) async {
    useWindow(tester);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    // It opens on the displayed month, with the days of that month.
    expect(find.text('July 2026'), findsWidgets);
    expect(find.byKey(const ValueKey('pick-day-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('pick-day-31')), findsOneWidget);
    expect(find.byKey(const ValueKey('pick-day-32')), findsNothing);
    // Previous and next month change the days shown without closing it.
    await tester.tap(find.byKey(const ValueKey('picker-next-month')));
    await tester.pump();
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.byKey(const ValueKey('pick-day-31')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('picker-next-month')));
    await tester.pump();
    expect(find.byKey(const ValueKey('pick-day-31')), findsNothing); // September has 30 days
    // Picking a day goes to that date and closes the picker.
    await tester.tap(find.byKey(const ValueKey('pick-day-9')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pick-day-9')), findsNothing);
    expect(c.focused, DateTime(2026, 9, 9));
    expect(find.text('September 2026'), findsOneWidget);
  });

  testWidgets('CAL-01.t: the date picker offers Today, and the week and day views follow the picked date', (tester) async {
    useWindow(tester);
    final c = makeController(view: CalendarView.week, focused: DateTime(2026, 1, 20));
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('picker-today')));
    await tester.pumpAndSettle();
    expect(c.focused, DateTime(2026, 7, 15));
    expect(find.text('Jul 12 – 18, 2026'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pick-day-26')));
    await tester.pumpAndSettle();
    expect(c.focused, DateTime(2026, 7, 26));
    expect(find.text('Jul 26 – Aug 1, 2026'), findsOneWidget);
  });

  testWidgets('CAL-01.t: the picked date is marked, today has an outline, and days follow the page language', (tester) async {
    useWindow(tester);
    final c = makeController(focused: DateTime(2026, 7, 20));
    await tester.pumpWidget(appFor(CalendarPage(controller: c), locale: 'fr'));
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    expect(find.text('Juillet 2026'), findsWidgets);
    final picked = tester.widget<TextButton>(find.byKey(const ValueKey('pick-day-20')));
    final other = tester.widget<TextButton>(find.byKey(const ValueKey('pick-day-21')));
    expect(picked.style!.backgroundColor!.resolve({}), isNotNull);
    expect(other.style!.backgroundColor?.resolve({}), isNull);
  });
}
