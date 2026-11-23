import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/theme/event_colors.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/zones.dart';

import '../calendar/test_support.dart';

const _color = 0xFF112233;

SuiteEvent _colored() => makeEvent('c', 15, 9, title: 'Colored').copyWith(color: _color);
SuiteEvent _plain() => makeEvent('p', 15, 11, title: 'Plain');

/// Finds the first Container under [root] whose decoration passes [test].
Finder _box(Finder root, bool Function(BoxDecoration) test) => find.descendant(
      of: root,
      matching: find.byWidgetPredicate((w) => w is Container && w.decoration is BoxDecoration && test(w.decoration! as BoxDecoration)),
    );

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  testWidgets('EVT-03.b: Month shows the event color in its chip, else the default event color', (tester) async {
    useWindow(tester);
    final c = makeController(events: [_colored(), _plain()], view: CalendarView.month);
    addTearDown(c.dispose);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final surface = Theme.of(tester.element(find.byKey(const ValueKey('event-c')))).colorScheme.surface;
    Color fill(String id) => tester.widget<Container>(find.descendant(of: find.byKey(ValueKey('event-$id')), matching: find.byType(Container)).first).decoration!.let((d) => (d as BoxDecoration).color!);
    expect(fill('c'), Color.alphaBlend(const Color(_color).withValues(alpha: 0.18), surface));
    expect(fill('p'), Color.alphaBlend(const Color(defaultEventColor).withValues(alpha: 0.18), surface));
  });

  for (final view in [CalendarView.week, CalendarView.fiveDay, CalendarView.day]) {
    testWidgets('EVT-03.b: ${view.name} shows the event color on the block edge, else the default', (tester) async {
      useWindow(tester);
      final c = makeController(events: [_colored(), _plain()], view: view);
      addTearDown(c.dispose);
      await tester.pumpWidget(appFor(CalendarPage(controller: c)));
      bool edge(BoxDecoration d, int argb) => d.border is Border && (d.border! as Border).left.color == Color(argb);
      expect(_box(find.byKey(const ValueKey('event-c')), (d) => edge(d, _color)), findsOneWidget);
      expect(_box(find.byKey(const ValueKey('event-p')), (d) => edge(d, defaultEventColor)), findsOneWidget);
    });
  }

  testWidgets('EVT-03.b: List shows the event color in its bar, else the default', (tester) async {
    useWindow(tester);
    final c = makeController(events: [_colored(), _plain()], view: CalendarView.list);
    addTearDown(c.dispose);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    Color bar(String id) => tester.widget<Container>(find.descendant(of: find.byKey(ValueKey('event-$id')), matching: find.byType(Container)).first).color!;
    expect(bar('c'), const Color(_color));
    expect(bar('p'), const Color(defaultEventColor));
  });

  for (final view in [CalendarView.month, CalendarView.week, CalendarView.day, CalendarView.list]) {
    testWidgets('EVT-03.b: ${view.name} print shows the event color on the printed event', (tester) async {
      useWindow(tester);
      final c = makeController(events: [_colored(), _plain()], view: view);
      addTearDown(c.dispose);
      await tester.pumpWidget(appFor(CalendarPage(controller: c)));
      await tester.tap(find.byKey(const ValueKey('calendar-print-button')));
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      bool edge(BoxDecoration d, int argb) => d.border is BorderDirectional && (d.border! as BorderDirectional).start.color == Color(argb);
      expect(_box(dialog, (d) => edge(d, _color)), findsOneWidget);
      expect(_box(dialog, (d) => edge(d, defaultEventColor)), findsOneWidget);
    });
  }
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
