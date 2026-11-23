import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/theme/theme_mode_controller.dart';
import 'package:suitestream/src/time/zones.dart';

import '../calendar/test_support.dart';

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  Future<SharedPreferences> prefsWith([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('SHL-03.a: with nothing saved the theme is Match system', () async {
    expect(ThemeModeController(prefs: await prefsWith()).mode, ThemeMode.system);
    expect(ThemeModeController().mode, ThemeMode.system);
  });

  test('SHL-03: the choice is stored on the device and the next start uses it', () async {
    final prefs = await prefsWith();
    final first = ThemeModeController(prefs: prefs);
    var notified = 0;
    first.addListener(() => notified++);
    first.mode = ThemeMode.dark;
    first.mode = ThemeMode.dark; // no change, no notification
    expect(notified, 1);
    expect(prefs.getString('theme.mode'), 'dark');
    expect(ThemeModeController(prefs: prefs).mode, ThemeMode.dark);
    first.mode = ThemeMode.light;
    expect(ThemeModeController(prefs: prefs).mode, ThemeMode.light);
    first.mode = ThemeMode.system;
    expect(ThemeModeController(prefs: prefs).mode, ThemeMode.system);
  });

  test('SHL-03: an unknown stored value falls back to Match system', () async {
    expect(ThemeModeController(prefs: await prefsWith({'theme.mode': 'sepia'})).mode, ThemeMode.system);
  });

  testWidgets('SHL-03.b: the header has one theme icon; its menu lists Light, Dark and Match system and marks the choice', (tester) async {
    final prefs = await prefsWith();
    final theme = ThemeModeController(prefs: prefs);
    useWindow(tester, const Size(1200, 900));
    await tester.pumpWidget(
      ThemeModeScope(
        controller: theme,
        child: appFor(CalendarPage(controller: makeController()), size: const Size(1200, 900)),
      ),
    );
    final menu = find.byKey(const ValueKey('theme-menu'));
    expect(menu, findsOneWidget);
    expect(find.byTooltip('Theme: Match system'), findsOneWidget);
    expect(find.descendant(of: menu, matching: find.byIcon(ThemeModeIcons.system)), findsOneWidget);

    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Match system'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(theme.mode, ThemeMode.dark);
    expect(prefs.getString('theme.mode'), 'dark');
    expect(find.byTooltip('Theme: Dark'), findsOneWidget);
    expect(find.descendant(of: menu, matching: find.byIcon(ThemeModeIcons.dark)), findsOneWidget);
  });

  testWidgets('SHL-03.a: Dark applies the dark theme and Light the light one, whatever the device says', (tester) async {
    final theme = ThemeModeController(prefs: await prefsWith({'theme.mode': 'dark'}));
    late BuildContext inner;
    await tester.pumpWidget(
      ListenableBuilder(
        listenable: theme,
        builder: (context, _) => MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: theme.mode,
          home: Builder(
            builder: (c) {
              inner = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(Theme.of(inner).brightness, Brightness.dark);
    theme.mode = ThemeMode.light;
    await tester.pumpAndSettle();
    expect(Theme.of(inner).brightness, Brightness.light);
  });

  test('SHL-03.a: the early script in web/index.html reads the saved choice before Flutter starts', () {
    final html = File('web/index.html').readAsStringSync();
    expect(html, contains("localStorage.getItem('flutter.theme.mode')"));
    expect(html, contains('data-theme'));
    // The script runs in the head, before the boot screen and the Flutter bootstrap.
    expect(html.indexOf('flutter.theme.mode'), lessThan(html.indexOf('<body>')));
    expect(html.indexOf('flutter.theme.mode'), lessThan(html.indexOf('flutter_bootstrap.js')));
    expect(ThemeModeController.prefsKey, 'theme.mode');
  });
}
