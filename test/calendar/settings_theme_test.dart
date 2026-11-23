import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/calendar/settings_theme_pane.dart';
import 'package:suitestream/src/theme/theme_mode_controller.dart';
import 'package:suitestream/src/theme/theme_settings.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

const _tall = Size(1000, 1500);

String _text(WidgetTester tester, String key) => tester.widget<TextField>(find.byKey(ValueKey(key))).controller!.text;

class _Rig {
  _Rig(this.controller, this.settings, this.mode);
  final CalendarController controller;
  final ThemeSettings settings;
  final ThemeModeController mode;
}

Future<_Rig> _open(WidgetTester tester, SharedPreferences prefs) async {
  useWindow(tester, _tall);
  final c = CalendarController(
    localZone: const LocalZone.system(zone),
    timeFormat: TimeFormat.twelveHour,
    prefs: prefs,
    clock: () => DateTime.utc(2026, 7, 15, 16),
  );
  final settings = ThemeSettings(prefs: prefs);
  final mode = ThemeModeController(prefs: prefs);
  await tester.pumpWidget(
    ThemeSettingsScope(
      settings: settings,
      child: ThemeModeScope(
        controller: mode,
        child: appFor(
          Builder(builder: (context) => TextButton(onPressed: () => openSettingsDialog(context, c, prefs: prefs), child: const Text('open'))),
          size: _tall,
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('settings-theme')));
  await tester.pumpAndSettle();
  return _Rig(c, settings, mode);
}

void main() {
  setUpAll(initZones);

  test('SET-03.e to SET-03.j: a typed percent or number of seconds is read within its range', () {
    expect(parsePercentInput('125 %', 0, 200), 125);
    expect(parsePercentInput('87,5', 75, 150), 87.5);
    expect(parsePercentInput('201', 0, 200), isNull);
    expect(parsePercentInput('49', 50, 200), isNull);
    expect(parsePercentInput('big', 0, 200), isNull);
    const lo = Duration(milliseconds: 500);
    const hi = Duration(seconds: 10);
    expect(parseSecondsInput('2.4 s', lo, hi), const Duration(milliseconds: 2400));
    expect(parseSecondsInput('0,5', lo, hi), lo);
    expect(parseSecondsInput('0.4', lo, hi), isNull);
    expect(parseSecondsInput('11', lo, hi), isNull);
  });

  testWidgets('SET-03.e to SET-03.k, UIC-44: Settings > Theme has a control for each common UI element, with its DEF-01 default', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final rig = await _open(tester, await SharedPreferences.getInstance());
    expect(_text(tester, 'setting-animation'), '0.5 s');
    expect(_text(tester, 'setting-popup-shadow'), '100 %');
    expect(_text(tester, 'setting-resize-bar'), '100 %');
    expect(_text(tester, 'setting-dropdown-text'), '100 %');
    expect(_text(tester, 'setting-date-picker'), '100 %');
    expect(_text(tester, 'setting-status-chip'), '2.4 s');
    expect(find.byKey(const ValueKey('setting-theme-reset')), findsOneWidget);
    expect(rig.settings.isDefault, isTrue);
  });

  testWidgets('SET-03.g: the animation time is in Theme, applies at once, is kept on the device and is the controller time', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final rig = await _open(tester, prefs);
    await tester.enterText(find.byKey(const ValueKey('setting-animation')), '3');
    await tester.pump();
    expect(find.text('Use a number from 0 to 2.'), findsOneWidget);
    expect(rig.controller.animationDuration, const Duration(milliseconds: 500));
    await tester.enterText(find.byKey(const ValueKey('setting-animation')), '0');
    await tester.pump();
    expect(rig.controller.animationDuration, Duration.zero);
    expect(rig.settings.animationTime, Duration.zero);
    final again = CalendarController(localZone: const LocalZone.system(zone), timeFormat: TimeFormat.twelveHour, prefs: prefs);
    expect(again.animationDuration, Duration.zero);
    await tester.tap(find.byKey(const ValueKey('setting-animation-up')));
    await tester.pump();
    expect(_text(tester, 'setting-animation'), '0.1 s');
    expect(rig.controller.animationDuration, const Duration(milliseconds: 100));
  });

  testWidgets('SET-03.e, SET-03.f, SET-03.h, SET-03.i, SET-03.j: each setting changes its element setting, within its range', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final rig = await _open(tester, prefs);
    await tester.enterText(find.byKey(const ValueKey('setting-popup-shadow')), '150');
    await tester.enterText(find.byKey(const ValueKey('setting-resize-bar')), '60 %');
    await tester.enterText(find.byKey(const ValueKey('setting-dropdown-text')), '120');
    await tester.enterText(find.byKey(const ValueKey('setting-date-picker')), '80');
    await tester.enterText(find.byKey(const ValueKey('setting-status-chip')), '5');
    await tester.pump();
    expect(rig.settings.popupShadow, 150);
    expect(rig.settings.resizeBar, 60);
    expect(rig.settings.dropdownText, 120);
    expect(rig.settings.datePicker, 80);
    expect(rig.settings.statusChipTime, const Duration(seconds: 5));
    // A value outside the range shows it and changes nothing.
    await tester.enterText(find.byKey(const ValueKey('setting-popup-shadow')), '500');
    await tester.pump();
    expect(find.text('Use a number from 0 to 200.'), findsOneWidget);
    expect(rig.settings.popupShadow, 150);
    // The arrows step 5 percent, within the range.
    await tester.enterText(find.byKey(const ValueKey('setting-popup-shadow')), '200');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('setting-popup-shadow-up')));
    await tester.pump();
    expect(rig.settings.popupShadow, 200);
    await tester.tap(find.byKey(const ValueKey('setting-popup-shadow-down')));
    await tester.pump();
    expect(rig.settings.popupShadow, 195);
    // Kept on the device.
    expect(ThemeSettings(prefs: prefs).dropdownText, 120);
  });

  testWidgets('UIC-44, SET-03.k: Reset restores every Theme setting to its default', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final rig = await _open(tester, prefs);
    await tester.enterText(find.byKey(const ValueKey('setting-popup-shadow')), '150');
    await tester.enterText(find.byKey(const ValueKey('setting-animation')), '1.5');
    await tester.enterText(find.byKey(const ValueKey('setting-status-chip')), '7');
    await tester.pump();
    expect(rig.settings.isDefault, isFalse);
    await tester.tap(find.byKey(const ValueKey('setting-theme-reset')));
    await tester.pump();
    expect(rig.settings.isDefault, isTrue);
    expect(rig.controller.animationDuration, const Duration(milliseconds: 500));
    expect(_text(tester, 'setting-popup-shadow'), '100 %');
    expect(_text(tester, 'setting-animation'), '0.5 s');
    expect(_text(tester, 'setting-status-chip'), '2.4 s');
    expect(ThemeSettings(prefs: prefs).isDefault, isTrue);
  });

  testWidgets('SET-03.l, SHL-03: the default theme is Match system and Settings > Theme changes it at once and keeps it on the device', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final rig = await _open(tester, prefs);
    expect(rig.mode.mode, ThemeMode.system);
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('setting-theme-system'))).selected, isTrue);
    await tester.tap(find.byKey(const ValueKey('setting-theme-dark')));
    await tester.pump();
    expect(rig.mode.mode, ThemeMode.dark);
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('setting-theme-dark'))).selected, isTrue);
    expect(ThemeModeController(prefs: prefs).mode, ThemeMode.dark);
    await tester.tap(find.byKey(const ValueKey('setting-theme-light')));
    await tester.pump();
    expect(rig.mode.mode, ThemeMode.light);
  });
}
