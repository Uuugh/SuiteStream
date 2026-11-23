import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_defaults.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/calendar/event_drag.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

Future<void> longPressDrag(WidgetTester tester, Offset from, Offset by, {Duration hold = const Duration(milliseconds: 650)}) async {
  final g = await tester.startGesture(from);
  await tester.pump(hold);
  await g.moveBy(by);
  await tester.pump();
  await g.up();
  await tester.pumpAndSettle();
}

DateTime localStart(CalendarController c, String id) {
  final e = c.events.firstWhere((x) => x.id == id);
  final s = e.startIn(zoneNamed(zone));
  return DateTime(s.year, s.month, s.day, s.hour, s.minute);
}

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  test('CAL-03.b: the start snaps to the drag step of 15 minutes', () {
    expect(dragStepMinutes, 15);
    expect(snapToDragStep(0), 0);
    expect(snapToDragStep(7), 0);
    expect(snapToDragStep(8), 15);
    expect(snapToDragStep(684), 690); // 11:24 -> 11:30
    expect(snapToDragStep(-20), -15);
  });

  testWidgets('CAL-03.c: in Month the event moves to the day it is dropped on and keeps its time', (tester) async {
    useWindow(tester);
    final c = makeController(events: [makeEvent('a', 20, 9, title: 'Move me')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final cell = tester.getSize(find.byKey(const ValueKey('day-2026-7-20')));
    await longPressDrag(tester, tester.getCenter(find.byKey(const ValueKey('event-a'))), Offset(cell.width * 2, 0));
    expect(localStart(c, 'a'), DateTime(2026, 7, 22, 9, 0));
    expect(find.descendant(of: find.byKey(const ValueKey('day-2026-7-22')), matching: find.textContaining('Move me')), findsOneWidget);
    // A row down moves it a week.
    await longPressDrag(tester, tester.getCenter(find.byKey(const ValueKey('event-a'))), Offset(0, cell.height));
    expect(localStart(c, 'a'), DateTime(2026, 7, 29, 9, 0));
    // Its length is kept.
    expect(c.events.single.endUtc.difference(c.events.single.startUtc), const Duration(hours: 1));
  });

  testWidgets('CAL-03.a: a long-press-drag moves an event that can be edited; a deleted event stays', (tester) async {
    useWindow(tester);
    final gone = makeEvent('gone', 20, 9, title: 'Gone').copyWith(deleted: true);
    final c = makeController(events: [makeEvent('a', 20, 10, title: 'Mine'), gone]);
    expect(canMove(c.events[0]), isTrue);
    expect(canMove(gone), isFalse);
    expect(c.move('gone', day: DateTime(2026, 7, 22)), isFalse);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final cell = tester.getSize(find.byKey(const ValueKey('day-2026-7-20')));
    await longPressDrag(tester, tester.getCenter(find.byKey(const ValueKey('event-a'))), Offset(cell.width, 0));
    expect(localStart(c, 'a'), DateTime(2026, 7, 21, 10, 0));
    expect(localStart(c, 'gone'), DateTime(2026, 7, 20, 9, 0));
    // Moving an event of a source marks it edited.
    final theirs = makeEvent('t', 14, 9).copyWith(custom: false);
    final c2 = makeController(events: [theirs]);
    c2.move('t', day: DateTime(2026, 7, 16));
    expect(c2.events.single.edited, isTrue);
  });

  testWidgets('CAL-03.b: in Week and Day the start snaps to the drag step; the length and the day column are kept or moved with the drag', (tester) async {
    useWindow(tester);
    final c = makeController(view: CalendarView.week, events: [makeEvent('a', 15, 10, minutes: 90, title: 'Block')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final block = tester.getRect(find.byKey(const ValueKey('event-a')));
    // The block is 40 px per hour: 1.4 hours down is 11:24, which snaps to 11:30.
    await longPressDrag(tester, block.center, const Offset(0, 40 * 1.4));
    expect(localStart(c, 'a'), DateTime(2026, 7, 15, 11, 30));
    expect(c.events.single.endUtc.difference(c.events.single.startUtc), const Duration(minutes: 90));
    // A day column to the right moves it a day.
    final col = tester.getSize(find.byKey(const ValueKey('hour-grid'))).width / 8;
    await longPressDrag(tester, tester.getRect(find.byKey(const ValueKey('event-a'))).center, Offset(col, 0));
    expect(localStart(c, 'a'), DateTime(2026, 7, 16, 11, 30));
    // Day view too.
    c.view = CalendarView.day;
    c.goToDate(DateTime(2026, 7, 16));
    await tester.pumpAndSettle();
    await longPressDrag(tester, tester.getRect(find.byKey(const ValueKey('event-a'))).center, const Offset(0, -40 * 2));
    expect(localStart(c, 'a'), DateTime(2026, 7, 16, 9, 30));
  });

  testWidgets('CAL-03.d: the press must be held for the long-press time', (tester) async {
    useWindow(tester);
    expect(defaultLongPress, const Duration(milliseconds: 200));
    final c = makeController(events: [makeEvent('a', 20, 9, title: 'Hold')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final cell = tester.getSize(find.byKey(const ValueKey('day-2026-7-20')));
    final from = tester.getCenter(find.byKey(const ValueKey('event-a')));
    // Released too soon: no move.
    await longPressDrag(tester, from, Offset(0, cell.height), hold: const Duration(milliseconds: 150));
    expect(localStart(c, 'a'), DateTime(2026, 7, 20, 9, 0));
    // A longer long-press time is honoured.
    c.longPress = const Duration(milliseconds: 1000);
    await longPressDrag(tester, from, Offset(0, cell.height), hold: const Duration(milliseconds: 700));
    expect(localStart(c, 'a'), DateTime(2026, 7, 20, 9, 0));
    await longPressDrag(tester, from, Offset(0, cell.height), hold: const Duration(milliseconds: 1100));
    expect(localStart(c, 'a'), DateTime(2026, 7, 27, 9, 0));
  });

  test('CAL-03.d: the long-press time stays within 0.2 to 1.5 seconds', () {
    final c = makeController();
    c.longPress = const Duration(milliseconds: 100);
    expect(c.longPress, const Duration(milliseconds: 200));
    c.longPress = const Duration(seconds: 5);
    expect(c.longPress, const Duration(milliseconds: 1500));
    c.longPress = const Duration(milliseconds: 800);
    expect(c.longPress, const Duration(milliseconds: 800));
  });

  testWidgets('a quick tap on an event still opens its details', (tester) async {
    useWindow(tester);
    final c = makeController(events: [makeEvent('a', 20, 9, title: 'Tap me')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    await tester.tap(find.byKey(const ValueKey('event-a')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-details')), findsOneWidget);
  });
}
