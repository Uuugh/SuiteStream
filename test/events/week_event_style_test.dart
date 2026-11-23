import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/theme/event_colors.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/theme_settings.dart';
import 'package:suitestream/src/time/suite_event.dart';

import '../calendar/test_support.dart';

CalendarController _week(List<SuiteEvent> events) => makeController(events: events, view: CalendarView.week);

void main() {
  setUpAll(() => initializeDateFormatting('en'));
  testWidgets('CAL-10.d, THM-10.d: the opened event in Week is on the top layer with the popup shadow', (tester) async {
    useWindow(tester);
    final c = _week([makeEvent('a', 15, 9), makeEvent('b', 15, 9)]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.byKey(const ValueKey('opened-event')), findsNothing);
    c.selectEvent('a');
    await tester.pump();
    final opened = tester.widget<Material>(find.byKey(const ValueKey('opened-event')));
    expect(opened.elevation, suitePopupElevation);
    expect(find.descendant(of: find.byKey(const ValueKey('event-a')), matching: find.byKey(const ValueKey('opened-event'))), findsOneWidget);
    // Painted last: it is the last event block in the stack.
    final blocks = tester.widgetList<Positioned>(find.byWidgetPredicate((w) => w is Positioned && w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith('event-'))).toList();
    expect((blocks.last.key as ValueKey<String>).value, 'event-a');
  });

  testWidgets('SET-03.e: the Popup shadow setting scales the opened event and the hour-density menu', (tester) async {
    useWindow(tester);
    final c = _week([makeEvent('a', 15, 9)]);
    final s = ThemeSettings()..popupShadow = 50;
    await tester.pumpWidget(ThemeSettingsScope(settings: s, child: appFor(CalendarPage(controller: c))));
    c.selectEvent('a');
    await tester.pump();
    expect(tester.widget<Material>(find.byKey(const ValueKey('opened-event'))).elevation, suitePopupElevation / 2);
    expect(tester.widget<PopupMenuButton<int>>(find.byKey(const ValueKey('hour-density'))).elevation, suitePopupElevation / 2);
  });

  testWidgets('THM-09.b: a Week all-day chip uses the event color, else the default event color', (tester) async {
    useWindow(tester);
    final colored = SuiteEvent.allDay(id: 'x', title: 'Colored', year: 2026, month: 7, day: 15, zone: zone).copyWith(color: 0xFF112233);
    final plain = SuiteEvent.allDay(id: 'y', title: 'Plain', year: 2026, month: 7, day: 16, zone: zone);
    final c = _week([colored, plain]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    Color chip(String id) => tester.widget<Container>(find.descendant(of: find.byKey(ValueKey('event-$id')), matching: find.byType(Container)).first).color!;
    expect(chip('x'), const Color(0xFF112233));
    expect(chip('y'), Color(defaultEventColor));
  });
}
