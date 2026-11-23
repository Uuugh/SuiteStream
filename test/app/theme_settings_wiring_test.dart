import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/main.dart';
import 'package:suitestream/src/theme/theme_mode_controller.dart';
import 'package:suitestream/src/theme/theme_settings.dart';
import 'package:suitestream/src/time/zones.dart';

import '../calendar/test_support.dart';

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  testWidgets('UIC-44: the app offers one ThemeSettings to every page and its animation time is the controller time', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = ThemeSettings(prefs: prefs);
    final controller = makeController();
    useWindow(tester, const Size(1200, 900));
    await tester.pumpWidget(
      SuiteStreamApp(
        controller: controller,
        messages: messagesFor('en'),
        themeMode: ThemeModeController(prefs: prefs),
        themeSettings: settings,
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(const ValueKey('settings-button')));
    expect(ThemeSettingsScope.of(context), same(settings));

    settings.popupShadow = 150;
    await tester.pump();
    expect(ThemeSettingsScope.of(tester.element(find.byKey(const ValueKey('settings-button')))).popupShadow, 150);

    // The calendar controller and the Theme settings share the key view.animationMs.
    controller.animationDuration = const Duration(milliseconds: 300);
    expect(prefs.getInt(ThemeSettings.keyAnimationMs), 300);
    expect(ThemeSettings(prefs: prefs).animationTime, const Duration(milliseconds: 300));
  });
}
