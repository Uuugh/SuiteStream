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

Future<_Rig> _open(WidgetTester tester, SharedPreferences prefs, [Size size = _tall]) async {
  useWindow(tester, size);
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
          size: size,
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
    await tester.enterText(find.byKey(const ValueKey('setting-press-delay')), '1.2');
    await tester.pump();
    expect(rig.settings.isDefault, isFalse);
    await tester.tap(find.byKey(const ValueKey('setting-theme-reset')));
    await tester.pump();
    expect(rig.settings.isDefault, isTrue);
    expect(rig.controller.animationDuration, const Duration(milliseconds: 500));
    expect(rig.controller.longPress, const Duration(milliseconds: 300));
    expect(_text(tester, 'setting-press-delay'), '0.3 s');
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
  testWidgets('SET-03.b: the press-and-hold delay is in Settings > Theme, 0.3 s until changed, applies at once, steps 0.1 s within 0.2 to 1.5 s', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final rig = await _open(tester, prefs);
    expect(_text(tester, 'setting-press-delay'), '0.3 s');
    await tester.enterText(find.byKey(const ValueKey('setting-press-delay')), '0.8');
    await tester.pump();
    expect(rig.controller.longPress, const Duration(milliseconds: 800));
    await tester.tap(find.byKey(const ValueKey('setting-press-delay-up')));
    await tester.pump();
    expect(rig.controller.longPress, const Duration(milliseconds: 900));
    expect(CalendarController(localZone: const LocalZone.system(zone), timeFormat: TimeFormat.twelveHour, prefs: prefs).longPress, const Duration(milliseconds: 900));
    await tester.enterText(find.byKey(const ValueKey('setting-press-delay')), '2');
    await tester.pump();
    expect(find.text('Use a number from 0.2 to 1.5.'), findsOneWidget);
    expect(rig.controller.longPress, const Duration(milliseconds: 900));
    // General no longer holds it.
    await tester.tap(find.byKey(const ValueKey('settings-general')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('setting-press-delay')), findsNothing);
  });

  for (final width in [320.0, 400.0, 800.0]) {
    testWidgets('UIC-44, SET-03.b: at $width px the Theme pane has titled groups, ${width >= 800 ? 'two columns' : 'one column'} and no overflow', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await _open(tester, await SharedPreferences.getInstance(), Size(width, 900));
      // Each type of setting is a group with its name written on a rule.
      for (final (id, name) in [('theme', 'Default theme'), ('times', 'Times'), ('scales', 'Sizes and strength')]) {
        expect(find.descendant(of: find.byKey(ValueKey('theme-group-$id')), matching: find.text(name)), findsOneWidget);
        expect(find.descendant(of: find.byKey(ValueKey('theme-group-$id')), matching: find.byType(Divider)), findsOneWidget);
      }
      final two = width >= 800;
      expect(find.byKey(ValueKey('theme-columns-${two ? 2 : 1}')), findsOneWidget);
      final a = tester.getTopLeft(find.text('Animation time'));
      final b = tester.getTopLeft(find.text('Press and hold delay'));
      if (two) {
        expect(a.dy, b.dy);
        expect(a.dx, lessThan(b.dx));
      } else {
        expect(a.dx, b.dx);
        expect(a.dy, lessThan(b.dy));
      }
      // The pane is never wider than the window (nothing overflows).
      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.byKey(const ValueKey('setting-date-picker'))).right, lessThanOrEqualTo(width));
    });
  }
}
