import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/calendar/event_drag.dart';
import 'package:suitestream/src/calendar/week_view.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

const _handle = ValueKey('resize-a');

/// Pixels of one drag step (15 minutes) at the controller's hour height.
double _stepPx(CalendarController c) =>
    c.hourLines * eventLineHeight * dragStepMinutes / 60;

int _endMinute(CalendarController c, String id) {
  final e = c.events.firstWhere((x) => x.id == id);
  final en = e.endIn(zoneNamed(zone));
  return en.hour * 60 + en.minute;
}

int _startMinute(CalendarController c, String id) {
  final s = c.events.firstWhere((x) => x.id == id).startIn(zoneNamed(zone));
  return s.hour * 60 + s.minute;
}

Future<void> _pump(WidgetTester tester, CalendarController c) async {
  useWindow(tester);
  await tester.pumpWidget(appFor(CalendarPage(controller: c)));
  await tester.pumpAndSettle();
}

/// Starts a drag on the handle of event [id] with [kind] and moves it by [dy] pixels, in two moves.
Future<TestGesture> _grab(
  WidgetTester tester,
  double dy, {
  PointerDeviceKind kind = PointerDeviceKind.touch,
  String id = 'a',
}) async {
  final g = await tester.startGesture(
    tester.getCenter(find.byKey(ValueKey('resize-$id'))),
    kind: kind,
  );
  await g.moveBy(Offset(0, dy / 2));
  await g.moveBy(Offset(0, dy / 2));
  await tester.pump();
  return g;
}

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  for (final view in [
    CalendarView.week,
    CalendarView.fiveDay,
    CalendarView.day,
  ]) {
    testWidgets(
      'CAL-12.a: ${view.name} shows a handle on the bottom edge of an editable event',
      (tester) async {
        final c = makeController(
          events: [
            makeEvent('a', 15, 9),
            makeEvent('gone', 15, 12).copyWith(deleted: true),
          ],
          view: view,
        );
        addTearDown(c.dispose);
        await _pump(tester, c);
        expect(find.byKey(_handle), findsOneWidget);
        expect(find.byKey(const ValueKey('resize-gone')), findsNothing);
        final handle = tester.getRect(find.byKey(_handle));
        final block = tester.getRect(find.byKey(const ValueKey('event-a')));
        expect(handle.bottom, block.bottom);
        expect(handle.width, block.width);
      },
    );
  }

  for (final view in [CalendarView.month, CalendarView.list]) {
    testWidgets('CAL-12.a: ${view.name} has no handle', (tester) async {
      final c = makeController(events: [makeEvent('a', 15, 9)], view: view);
      addTearDown(c.dispose);
      await _pump(tester, c);
      expect(find.byKey(_handle), findsNothing);
    });
  }

  testWidgets(
    'CAL-12.b, CAL-12.c: the event grows live, shows its new end, and release saves it snapped to the drag step',
    (tester) async {
      final c = makeController(
        events: [makeEvent('a', 15, 9, title: 'Stretch')],
        view: CalendarView.week,
      );
      addTearDown(c.dispose);
      await _pump(tester, c);
      final before = tester.getRect(find.byKey(const ValueKey('event-a')));
      final g = await _grab(
        tester,
        _stepPx(c) * 6 + 2,
      ); // 90 minutes and a little: snaps to 90
      final during = tester.getRect(find.byKey(const ValueKey('event-a')));
      expect(during.height, closeTo(before.height + _stepPx(c) * 6, 0.01));
      expect(during.top, before.top);
      expect(
        find.textContaining('09:00 am - 11:30 am'),
        findsOneWidget,
      ); // the end it would have
      expect(_endMinute(c, 'a'), 10 * 60); // nothing saved while dragging
      await g.up();
      await tester.pumpAndSettle();
      expect(_endMinute(c, 'a'), 11 * 60 + 30);
      expect(_startMinute(c, 'a'), 9 * 60);
      expect(c.events.single.title, 'Stretch');
      expect(
        tester.getRect(find.byKey(const ValueKey('event-a'))).height,
        closeTo(before.height + _stepPx(c) * 6, 0.01),
      );
    },
  );

  testWidgets(
    'CAL-12.b: the end snaps to the drag step, and the event shrinks live',
    (tester) async {
      final c = makeController(
        events: [makeEvent('a', 15, 9, minutes: 120)],
        view: CalendarView.week,
      );
      addTearDown(c.dispose);
      await _pump(tester, c);
      final g = await _grab(
        tester,
        -(_stepPx(c) * 2 + _stepPx(c) * 0.3),
      ); // 30 minutes and a bit shorter
      expect(
        tester.getRect(find.byKey(const ValueKey('event-a'))).height,
        closeTo(_stepPx(c) * 6, 0.01),
      );
      await g.up();
      await tester.pumpAndSettle();
      expect(_endMinute(c, 'a'), 10 * 60 + 30);
      expect(_endMinute(c, 'a') % dragStepMinutes, 0);
    },
  );

  testWidgets(
    'CAL-12.c: an event of a source is marked edited, and its calendar and color stay',
    (tester) async {
      final c = makeController(
        events: [
          makeEvent(
            'a',
            15,
            9,
            calendarId: 'work',
          ).copyWith(custom: false, color: 0xFF112233),
        ],
        view: CalendarView.week,
      );
      addTearDown(c.dispose);
      await _pump(tester, c);
      await (await _grab(tester, _stepPx(c) * 2)).up();
      await tester.pumpAndSettle();
      final e = c.events.single;
      expect(e.edited, isTrue);
      expect(e.calendarId, 'work');
      expect(e.color, 0xFF112233);
      expect(_endMinute(c, 'a'), 10 * 60 + 30);
    },
  );

  testWidgets(
    'CAL-12.d: Escape during the drag cancels it; nothing is saved and releasing does nothing',
    (tester) async {
      final c = makeController(
        events: [makeEvent('a', 15, 9)],
        view: CalendarView.week,
      );
      addTearDown(c.dispose);
      await _pump(tester, c);
      final before = tester.getRect(find.byKey(const ValueKey('event-a')));
      final original = c.events.single;
      final g = await _grab(tester, _stepPx(c) * 4);
      expect(
        tester.getRect(find.byKey(const ValueKey('event-a'))).height,
        greaterThan(before.height),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(
        tester.getRect(find.byKey(const ValueKey('event-a'))).height,
        before.height,
      );
      await g.moveBy(Offset(0, _stepPx(c) * 2));
      await tester.pump();
      expect(
        tester.getRect(find.byKey(const ValueKey('event-a'))).height,
        before.height,
      );
      await g.up();
      await tester.pumpAndSettle();
      expect(c.events.single, original);
      expect(_endMinute(c, 'a'), 10 * 60);
    },
  );

  testWidgets(
    'CAL-12.e: works with a mouse, and dragging the handle never moves the event',
    (tester) async {
      final c = makeController(
        events: [makeEvent('a', 15, 9)],
        view: CalendarView.week,
      );
      addTearDown(c.dispose);
      await _pump(tester, c);
      final g = await _grab(
        tester,
        _stepPx(c) * 4,
        kind: PointerDeviceKind.mouse,
      );
      expect(c.dropTarget, isNull); // no move preview (CAL-03.a)
      await g.up();
      await tester.pumpAndSettle();
      expect(_endMinute(c, 'a'), 11 * 60);
      expect(_startMinute(c, 'a'), 9 * 60);
      expect(c.dropTarget, isNull);
    },
  );

  testWidgets(
    'CAL-12.e: held on the handle for the long-press time it still resizes, and a press-and-hold on the body still moves',
    (tester) async {
      final c = makeController(
        events: [makeEvent('a', 15, 9)],
        view: CalendarView.week,
      );
      addTearDown(c.dispose);
      await _pump(tester, c);
      var g = await tester.startGesture(tester.getCenter(find.byKey(_handle)));
      await tester.pump(const Duration(milliseconds: 650));
      await g.moveBy(Offset(0, _stepPx(c) * 4));
      await g.up();
      await tester.pumpAndSettle();
      expect(_startMinute(c, 'a'), 9 * 60);
      expect(_endMinute(c, 'a'), 11 * 60);
      // The body: press and hold, then drag down four steps: the whole event moves.
      final body =
          tester.getTopLeft(find.byKey(const ValueKey('event-a'))) +
          const Offset(10, 6);
      g = await tester.startGesture(body);
      await tester.pump(const Duration(milliseconds: 650));
      await g.moveBy(Offset(0, _stepPx(c) * 4));
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
      expect(_startMinute(c, 'a'), 10 * 60);
      expect(_endMinute(c, 'a'), 12 * 60);
    },
  );

  testWidgets(
    'CAL-12.f: the end stays at least one drag step after the start and within the day',
    (tester) async {
      final c = makeController(
        events: [makeEvent('a', 15, 9)],
        view: CalendarView.week,
      );
      addTearDown(c.dispose);
      await _pump(tester, c);
      await (await _grab(tester, -_stepPx(c) * 40)).up(); // far above the start
      await tester.pumpAndSettle();
      expect(_startMinute(c, 'a'), 9 * 60);
      expect(_endMinute(c, 'a'), 9 * 60 + dragStepMinutes);
      expect(c.events.single.endUtc.isAfter(c.events.single.startUtc), isTrue);
      // Far below: the end of the day, midnight, is the limit.
      await (await _grab(tester, _stepPx(c) * 4 * 20)).up();
      await tester.pumpAndSettle();
      final end = c.events.single.endIn(zoneNamed(zone));
      expect(
        DateTime(end.year, end.month, end.day, end.hour, end.minute),
        DateTime(2026, 7, 16),
      );
      expect(_startMinute(c, 'a'), 9 * 60);
    },
  );

  test(
    'CAL-12.f: resizedEndMinute snaps, keeps one step after the start, and stops at midnight',
    () {
      expect(
        resizedEndMinute(startMinute: 540, endMinute: 600, deltaMinutes: 20),
        615,
      );
      expect(
        resizedEndMinute(startMinute: 540, endMinute: 600, deltaMinutes: -500),
        555,
      );
      expect(
        resizedEndMinute(startMinute: 540, endMinute: 600, deltaMinutes: 5000),
        1440,
      );
      expect(
        resizedEndMinute(startMinute: 547, endMinute: 600, deltaMinutes: -500),
        570,
      ); // start off the grid: the grid line a step on
    },
  );

  test('CAL-12.c: resizeEventEnd changes only the end', () {
    final loc = zoneNamed(zone);
    final e = makeEvent('a', 15, 9);
    final r = resizeEventEnd(
      e,
      loc,
      day: DateTime(2026, 7, 15),
      endMinute: 11 * 60,
    );
    expect(r.startUtc, e.startUtc);
    expect(r.endUtc, e.startUtc.add(const Duration(hours: 2)));
    expect(r.title, e.title);
  });
}
