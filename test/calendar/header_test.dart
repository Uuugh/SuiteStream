import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

CalendarController withPrefs(SharedPreferences prefs, {List events = const []}) => CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      calendars: calendars,
      events: [for (final e in events) e],
      prefs: prefs,
      clock: () => DateTime.utc(2026, 7, 15, 16),
    );

void main() {
  zoneTests();
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  testWidgets('CAL-02.a: choosing a zone in the calendar\'s own picker shows event times in that zone and is kept on the device; the Time Zones setting is unchanged', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    useWindow(tester, const Size(1000, 900));
    final c = withPrefs(prefs, events: [makeEvent('a', 15, 22, title: 'Late')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(1000, 900)));
    expect(find.text('10:00 pm Late'), findsOneWidget);
    expect(find.byTooltip('times in America/New_York'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('zone-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('zone-filter')), 'tokyo');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('zone-Asia/Tokyo')));
    await tester.pumpAndSettle();
    // 22:00 on the 15th in New York is 11 am on the 16th in Tokyo.
    expect(find.text('11:00 am Late'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('day-2026-7-16')), matching: find.text('11:00 am Late')), findsOneWidget);
    expect(find.byTooltip('times in Asia/Tokyo'), findsOneWidget);
    // The Settings zone is unchanged, and the event itself is unchanged.
    expect(c.baseZone.name, zone);
    expect(c.events.single.startZone, zone);
    // Kept on the device: a new controller on the same storage starts in that zone.
    final again = withPrefs(prefs);
    expect(again.localZone.name, 'Asia/Tokyo');
    expect(again.baseZone.name, zone);
    // Choosing the default (the system zone) clears the stored choice.
    await tester.tap(find.byKey(const ValueKey('zone-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('zone-America/New_York')));
    await tester.pumpAndSettle();
    expect(c.viewZone, isNull);
    expect(find.text('10:00 pm Late'), findsOneWidget);
    expect(withPrefs(prefs).localZone.name, zone);
  });

  testWidgets('CAL-06.e: the 12h | 24h control sets 12-hour or 24-hour and never returns to the default', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    useWindow(tester, const Size(1000, 900));
    final c = withPrefs(prefs, events: [makeEvent('a', 15, 13, title: 'Lunch')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(1000, 900)));
    expect(find.text('01:00 pm Lunch'), findsOneWidget);
    expect(tester.widget<Text>(find.descendant(of: find.byKey(const ValueKey('clock-badge')), matching: find.byType(Text))).data, '12');
    expect(find.byTooltip('Time format: 12-hour (01:30 pm)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('clock-button')));
    await tester.pump();
    expect(find.text('13:00 Lunch'), findsOneWidget);
    expect(tester.widget<Text>(find.descendant(of: find.byKey(const ValueKey('clock-badge')), matching: find.byType(Text))).data, '24');
    expect(find.byTooltip('Time format: 24-hour (13:30)'), findsOneWidget);
    // The choice is kept: a new controller does not return to the default of TIM-10.
    expect(withPrefs(prefs).timeFormat, TimeFormat.twentyFourHour);
    await tester.tap(find.byKey(const ValueKey('clock-button')));
    await tester.pump();
    expect(find.text('01:00 pm Lunch'), findsOneWidget);
    expect(withPrefs(prefs).timeFormat, TimeFormat.twelveHour);
  });

  test('the view the user chose is kept on the device', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = withPrefs(prefs);
    expect(c.view, CalendarView.month);
    c.view = CalendarView.week;
    expect(withPrefs(prefs).view, CalendarView.week);
  });

  testWidgets('the right zone holds Time Zone, View and the 12/24 clock in order; when it does not fit it drops to a second line', (tester) async {
    useWindow(tester, const Size(1000, 900));
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(1000, 900)));
    final xs = [
      for (final k in ['zone-button', 'clock-button']) tester.getCenter(find.byKey(ValueKey(k))).dx,
      tester.getCenter(find.byIcon(viewIcon(CalendarView.month))).dx,
    ];
    expect(xs[0] < xs[2] && xs[2] < xs[1], isTrue); // Time Zone, View, then the clock
    expect(find.byKey(const ValueKey('zones-stacked')), findsNothing);
    final one = tester.getCenter(find.byKey(const ValueKey('clock-button'))).dy;
    expect(one, tester.getCenter(find.byKey(const ValueKey('today'))).dy);
    // Narrower than the controls need: the right group drops to a second line.
    useWindow(tester, const Size(520, 900));
    await tester.pumpWidget(appFor(CalendarPage(controller: makeController()), size: const Size(520, 900)));
    await tester.pump();
    expect(find.byKey(const ValueKey('zones-stacked')), findsOneWidget);
    expect(tester.getCenter(find.byKey(const ValueKey('clock-button'))).dy > tester.getCenter(find.byKey(const ValueKey('today'))).dy, isTrue);
    // And back on one line when the window is wide again.
    useWindow(tester, const Size(1000, 900));
    await tester.pumpWidget(appFor(CalendarPage(controller: makeController()), size: const Size(1000, 900)));
    await tester.pump();
    expect(find.byKey(const ValueKey('zones-stacked')), findsNothing);
  });
}

void zoneTests() {
  testWidgets('the header has left, center and right zones: dates and navigation left, the buttons in the right zone flush right', (tester) async {
    useWindow(tester, const Size(1000, 900));
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(1000, 900)));
    final card = tester.getRect(find.byType(CalendarPage));
    final left = tester.getRect(find.byKey(const ValueKey('zone-left')));
    final right = tester.getRect(find.byKey(const ValueKey('zone-right')));
    // Left zone: previous, next, Today and the title, aligned left.
    expect(left.left - card.left < 24, isTrue);
    for (final k in ['previous', 'next', 'today', 'title']) {
      expect(left.contains(tester.getCenter(find.byKey(ValueKey(k)))), isTrue, reason: k);
    }
    // Right zone: every button, aligned right.
    expect(card.right - right.right < 24, isTrue);
    for (final k in ['zone-button', 'clock-button', 'add-event-button']) {
      expect(right.contains(tester.getCenter(find.byKey(ValueKey(k)))), isTrue, reason: k);
    }
    expect(right.contains(tester.getCenter(find.byIcon(SuiteIcons.filterList))), isTrue);
    expect(right.contains(tester.getCenter(find.byIcon(viewIcon(c.view)))), isTrue);
    expect(left.right <= right.left, isTrue);
    expect(find.byKey(const ValueKey('zones-stacked')), findsNothing);
  });

  testWidgets('a dropdown near the right edge always fits in the window; long labels wrap', (tester) async {
    useWindow(tester, const Size(1000, 900));
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: const Size(1000, 900)));
    await tester.tap(find.byIcon(SuiteIcons.filterList));
    await tester.pumpAndSettle();
    final menu = tester.getRect(find.byKey(const ValueKey('dropdown-item-state:changedBySource')));
    expect(menu.right <= 1000, isTrue);
    expect(menu.left >= 0, isTrue);
    await tester.tapAt(const Offset(5, 880));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(viewIcon(c.view)).last);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(const ValueKey('dropdown-item-CalendarView.week'))).right <= 1000, isTrue);
  });
}
