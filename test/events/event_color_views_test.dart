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

  // EVT-03.b, THM-10.h: in every view the event fills with its own color (never gray or a pale
  // tint) and its text reaches 4.5:1 on that fill, in light and dark.
  for (final brightness in Brightness.values) {
    void check(String name, CalendarView view, Color Function(WidgetTester, String) fillOf, Color Function(WidgetTester, String) textOf) {
      testWidgets('EVT-03.b: $name fills with the event color, readable text (${brightness.name})', (tester) async {
        useWindow(tester);
        final c = makeController(events: [_colored(), _plain()], view: view);
        addTearDown(c.dispose);
        await tester.pumpWidget(appFor(CalendarPage(controller: c), brightness: brightness));
        expect(fillOf(tester, 'c'), const Color(_color));
        expect(fillOf(tester, 'p'), const Color(defaultEventColor));
        for (final id in ['c', 'p']) {
          expect(eventContrastRatio(fillOf(tester, id), textOf(tester, id)), greaterThanOrEqualTo(eventTextMinContrast));
        }
      });
    }

    Text title(WidgetTester tester, String id, String word) =>
        tester.widget<Text>(find.descendant(of: find.byKey(ValueKey('event-$id')), matching: find.textContaining(word)).first);

    check('Month', CalendarView.month, (t, id) => (_first<Container>(t, id).decoration! as BoxDecoration).color!, (t, id) => title(t, id, id == 'c' ? 'Colored' : 'Plain').style!.color!);
    for (final view in [CalendarView.week, CalendarView.fiveDay, CalendarView.day]) {
      check(view.name, view, (t, id) => t.widget<Material>(find.descendant(of: find.byKey(ValueKey('event-$id')), matching: find.byType(Material)).first).color!, (t, id) => title(t, id, id == 'c' ? 'Colored' : 'Plain').style!.color!);
    }
    check('List', CalendarView.list, (t, id) => _first<Container>(t, id).color!, (t, id) => title(t, id, id == 'c' ? 'Colored' : 'Plain').style!.color!);
  }

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

T _first<T extends Widget>(WidgetTester tester, String id) =>
    tester.widget<T>(find.descendant(of: find.byKey(ValueKey('event-$id')), matching: find.byType(T)).first);
