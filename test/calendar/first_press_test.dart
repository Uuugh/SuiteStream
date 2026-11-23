import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_defaults.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/time/zones.dart';

import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/time_format.dart';

import 'test_support.dart';

/// CAL-03.d, PBI-058: the very first press after the page opens uses the set delay
/// (0.2 s by default), not a longer one.
void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  Future<bool> ghostAfter(WidgetTester tester, Duration hold, {CalendarController? controller}) async {
    useWindow(tester);
    final c = controller ?? makeController(events: [makeEvent('a', 20, 9, title: 'Hold')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final g = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('event-a'))));
    await tester.pump(hold);
    final started = find.byKey(const ValueKey('drag-ghost')).evaluate().isNotEmpty;
    await g.up();
    await tester.pumpAndSettle();
    return started;
  }

  testWidgets('CAL-03.d: the first press held just over the default delay starts the drag', (tester) async {
    expect(await ghostAfter(tester, defaultLongPress + const Duration(milliseconds: 50)), isTrue);
  });

  testWidgets('CAL-03.d: the first press held less than the default delay does not start the drag', (tester) async {
    expect(await ghostAfter(tester, defaultLongPress - const Duration(milliseconds: 50)), isFalse);
  });

  testWidgets('CAL-03.d: a stored delay is used from the first press', (tester) async {
    SharedPreferences.setMockInitialValues({'view.longPressMs': 600});
    final prefs = await SharedPreferences.getInstance();
    final c = CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      events: [makeEvent('a', 20, 9, title: 'Hold')],
      calendars: calendars,
      prefs: prefs,
      clock: () => DateTime.utc(2026, 7, 15, 16),
    );
    expect(c.longPress, const Duration(milliseconds: 600));
    expect(await ghostAfter(tester, const Duration(milliseconds: 500), controller: c), isFalse);
  });
}
