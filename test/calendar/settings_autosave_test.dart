import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_defaults.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/theme/theme_mode_controller.dart';
import 'package:suitestream/src/theme/theme_settings.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

const _tall = Size(1000, 1500);

/// The three ways of leaving a Settings page or Settings (UIC-45).
enum _Leave { pageChange, close, back }

CalendarController _controller(SharedPreferences prefs) => CalendarController(
  localZone: const LocalZone.system(zone),
  timeFormat: TimeFormat.twelveHour,
  prefs: prefs,
  clock: () => DateTime.utc(2026, 7, 15, 16),
);

Future<CalendarController> _open(
  WidgetTester tester,
  SharedPreferences prefs,
  String section,
) async {
  useWindow(tester, _tall);
  final c = _controller(prefs);
  await tester.pumpWidget(
    ThemeSettingsScope(
      settings: ThemeSettings(prefs: prefs),
      child: ThemeModeScope(
        controller: ThemeModeController(prefs: prefs),
        child: appFor(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => openSettingsDialog(context, c, prefs: prefs),
              child: const Text('open'),
            ),
          ),
          size: _tall,
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey(section)));
  await tester.pumpAndSettle();
  return c;
}

Future<void> _leave(WidgetTester tester, _Leave how) async {
  switch (how) {
    case _Leave.pageChange:
      await tester.tap(find.byKey(const ValueKey('settings-sources')));
    case _Leave.close:
      await tester.tap(find.byKey(const ValueKey('settings-close')));
    case _Leave.back:
      await tester.tap(find.byKey(const ValueKey('settings-back')));
  }
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String text) async {
  await tester.enterText(find.byKey(ValueKey(key)), text);
  await tester.pump();
}

void main() {
  setUpAll(initZones);

  testWidgets(
    'UIC-45: the back button is in the left zone of the Settings header and the panes have no Save buttons',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await _open(tester, prefs, 'settings-general');
      final back = tester.getCenter(
        find.byKey(const ValueKey('settings-back')),
      );
      final title = tester.getCenter(find.text('Settings'));
      expect(back.dx, lessThan(title.dx));
      expect(find.byTooltip('Back'), findsOneWidget);
      for (final section in [
        'settings-general',
        'settings-calendar',
        'settings-theme',
      ]) {
        await tester.tap(find.byKey(ValueKey(section)));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('settings-save')), findsNothing);
        expect(find.byKey(const ValueKey('settings-cancel')), findsNothing);
      }
      await tester.tap(find.byKey(const ValueKey('settings-back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('settings-dialog')), findsNothing);
    },
  );

  for (final how in _Leave.values) {
    testWidgets('UIC-45, SET-03.b: Theme stores the press delay at once and keeps it on ${how.name}', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = await _open(tester, prefs, 'settings-theme');
      await _type(tester, 'setting-press-delay', '0.8');
      expect(c.longPress, const Duration(milliseconds: 800)); // applied at once
      await _leave(tester, how);
      expect(c.longPress, const Duration(milliseconds: 800));
      expect(_controller(prefs).longPress, const Duration(milliseconds: 800));
    });

    testWidgets(
      'UIC-45, SET-03.b: Theme does not store an invalid press delay on ${how.name} and showed its note',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final c = await _open(tester, prefs, 'settings-theme');
        await _type(tester, 'setting-press-delay', '9');
        expect(find.text('Use a number from 0.2 to 1.5.'), findsOneWidget);
        await _leave(tester, how);
        expect(c.longPress, const Duration(milliseconds: 300));
        expect(_controller(prefs).longPress, const Duration(milliseconds: 300));
      },
    );

    testWidgets(
      'UIC-45: Calendar stores length, unit and time on ${how.name}',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final c = await _open(tester, prefs, 'settings-calendar');
        await _type(tester, 'setting-default-length', '2');
        await _type(tester, 'setting-default-time', '2:30 pm');
        expect(c.defaultLength, const Duration(hours: 1));
        await _leave(tester, how);
        expect(c.defaultLength, const Duration(hours: 2));
        expect(_controller(prefs).defaultLength, const Duration(hours: 2));
        expect(CalendarDefaults.load(prefs).startMinutes, 14 * 60 + 30);
      },
    );

    testWidgets(
      'UIC-45: Calendar does not store invalid values on ${how.name} and showed their notes',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final c = await _open(tester, prefs, 'settings-calendar');
        await _type(tester, 'setting-default-length', 'soon');
        await _type(tester, 'setting-default-time', '25:00');
        expect(
          find.text('Use a number with a unit (from 5 minutes to 24 hours).'),
          findsOneWidget,
        );
        expect(find.text('Use a time like 9:00 or 9:00 am.'), findsOneWidget);
        await _leave(tester, how);
        expect(c.defaultLength, const Duration(hours: 1));
        expect(prefs.getKeys(), isEmpty);
      },
    );

    testWidgets('UIC-45: Theme keeps a changed setting on ${how.name}', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await _open(tester, prefs, 'settings-theme');
      await _type(tester, 'setting-popup-shadow', '120');
      await _leave(tester, how);
      expect(ThemeSettings(prefs: prefs).popupShadow, 120);
    });

    testWidgets(
      'UIC-45: Theme does not store an invalid value on ${how.name} and showed its note',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        await _open(tester, prefs, 'settings-theme');
        await _type(tester, 'setting-popup-shadow', '9999');
        expect(find.text('Use a number from 0 to 200.'), findsOneWidget);
        await _leave(tester, how);
        expect(
          ThemeSettings(prefs: prefs).popupShadow,
          ThemeSettingsLimits.popupShadowDefault,
        );
      },
    );
  }
}
