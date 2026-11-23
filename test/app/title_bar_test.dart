import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/main.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/theme/theme_mode_controller.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

import '../calendar/test_support.dart';

/// SHL-01.h, PBI-061: the title bar has no color of its own; it shows the page color.
void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('SHL-01.h: the title bar shows the page color, untinted, in ${mode.name}', (tester) async {
      SharedPreferences.setMockInitialValues({'theme.mode': mode.name});
      final prefs = await SharedPreferences.getInstance();
      final controller = CalendarController(
        localZone: const LocalZone.system(zone),
        timeFormat: TimeFormat.twelveHour,
        events: const [],
        calendars: calendars,
        prefs: prefs,
        clock: () => DateTime.utc(2026, 7, 15, 16),
      );
      useWindow(tester, const Size(1200, 900));
      await tester.pumpWidget(SuiteStreamApp(
        controller: controller,
        messages: messagesFor('en'),
        themeMode: ThemeModeController(prefs: prefs),
      ));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(AppBar));
      expect(Theme.of(context).brightness, mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
      final page = Theme.of(context).scaffoldBackgroundColor;
      final bar = tester.widget<Material>(
        find.descendant(of: find.byType(AppBar), matching: find.byType(Material)).first,
      );
      expect(bar.color, page, reason: 'the bar color is the page color');
      // A tint (Material 3 surface tint) must not be mixed in, whatever the elevation.
      expect(bar.surfaceTintColor == null || bar.surfaceTintColor == Colors.transparent || bar.elevation == 0, isTrue);
      expect(bar.elevation, 0);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.scrolledUnderElevation, 0);
      expect(appBar.surfaceTintColor, Colors.transparent);
    });
  }
}
