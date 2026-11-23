import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_defaults.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

const _tall = Size(1000, 1500);

String _text(WidgetTester tester, String key) => tester.widget<TextField>(find.byKey(ValueKey(key))).controller!.text;

Future<CalendarController> _open(WidgetTester tester, SharedPreferences prefs, {String? section}) async {
  useWindow(tester, _tall);
  final c = CalendarController(
    localZone: const LocalZone.system(zone),
    timeFormat: TimeFormat.twelveHour,
    prefs: prefs,
    clock: () => DateTime.utc(2026, 7, 15, 16),
  );
  await tester.pumpWidget(
    appFor(
      Builder(builder: (context) => TextButton(onPressed: () => openSettingsDialog(context, c, prefs: prefs), child: const Text('open'))),
      size: _tall,
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  if (section != null) {
    await tester.tap(find.byKey(ValueKey(section)));
    await tester.pumpAndSettle();
  }
  return c;
}

void main() {
  setUpAll(initZones);

  test('SET-08.b: a default length is a number in minutes or hours, 5 minutes to 24 hours', () {
    expect(parseLengthIn('90', LengthUnit.minutes), const Duration(minutes: 90));
    expect(parseLengthIn('1,5', LengthUnit.hours), const Duration(minutes: 90));
    expect(parseLengthIn('24', LengthUnit.hours), const Duration(hours: 24));
    expect(parseLengthIn('25', LengthUnit.hours), isNull);
    expect(parseLengthIn('4', LengthUnit.minutes), isNull);
    expect(parseLengthIn('soon', LengthUnit.hours), isNull);
    expect(formatLengthIn(const Duration(hours: 1), LengthUnit.hours), '1');
    expect(formatLengthIn(const Duration(minutes: 90), LengthUnit.hours), '1.5');
    expect(formatLengthIn(const Duration(minutes: 90), LengthUnit.minutes), '90');
    expect(formatLengthIn(const Duration(minutes: 75), LengthUnit.hours), '1.25');
    expect(unitFor(const Duration(hours: 2)), LengthUnit.hours);
    expect(unitFor(const Duration(minutes: 90)), LengthUnit.minutes);
    // UIC-41: the arrows step 15 minutes, never past the limits.
    expect(stepLengthIn(const Duration(hours: 1), LengthUnit.hours, 1), const Duration(minutes: 75));
    expect(stepLengthIn(const Duration(minutes: 5), LengthUnit.minutes, -1), const Duration(minutes: 5));
    expect(stepLengthIn(const Duration(hours: 24), LengthUnit.hours, 1), const Duration(hours: 24));
  });

  test('SET-08.a: the calendar defaults are 9:00 and hours until changed, and are read back from the device', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final fresh = CalendarDefaults.load(prefs);
    expect(fresh.unit, LengthUnit.hours);
    expect(fresh.startMinutes, 9 * 60);
    await const CalendarDefaults(unit: LengthUnit.minutes, startMinutes: 8 * 60 + 30).save(prefs);
    final again = CalendarDefaults.load(prefs);
    expect(again.unit, LengthUnit.minutes);
    expect(again.startTime.minutes, 510);
    SharedPreferences.setMockInitialValues({CalendarDefaults.startKey: 99999, CalendarDefaults.unitKey: 'weeks'});
    final bad = CalendarDefaults.load(await SharedPreferences.getInstance());
    expect(bad.startMinutes, 9 * 60);
    expect(bad.unit, LengthUnit.hours);
  });

  testWidgets('SET-08.a: Settings > Calendar offers default length with its unit, default time and default time zone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await _open(tester, prefs, section: 'settings-calendar');
    expect(_text(tester, 'setting-default-length'), '1');
    expect(find.byKey(const ValueKey('setting-default-length-unit')), findsOneWidget);
    expect(find.text('hours'), findsWidgets);
    expect(_text(tester, 'setting-default-time'), '09:00 am');
    expect(find.text('Default time zone'), findsOneWidget);
    expect(find.byKey(const ValueKey('setting-zone-system')), findsOneWidget);
    // The animation time is not in General or Calendar any more (it is in Theme).
    expect(find.byKey(const ValueKey('setting-animation')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('settings-general')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('setting-animation')), findsNothing);
    expect(find.byKey(const ValueKey('setting-default-length')), findsNothing);
    // SET-03.b: the press-and-hold delay is in Theme, not in General.
    expect(find.byKey(const ValueKey('setting-press-delay')), findsNothing);
  });

  testWidgets('SET-08.b: the default length is saved in the chosen unit and kept on the device; an invalid length is not saved', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = await _open(tester, prefs, section: 'settings-calendar');
    expect(c.defaultLength, const Duration(hours: 1));
    await tester.enterText(find.byKey(const ValueKey('setting-default-length')), 'soon');
    await tester.pump();
    expect(find.text('Use a number with a unit (from 5 minutes to 24 hours).'), findsOneWidget);
    expect(c.defaultLength, const Duration(hours: 1));
    // Changing the unit keeps the length and shows it in the new unit.
    await tester.tap(find.byKey(const ValueKey('setting-default-length-unit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('minutes').last);
    await tester.pumpAndSettle();
    expect(_text(tester, 'setting-default-length'), '60');
    await tester.enterText(find.byKey(const ValueKey('setting-default-length')), '90');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('settings-close')));
    await tester.pumpAndSettle();
    expect(c.defaultLength, const Duration(minutes: 90));
    expect(find.byKey(const ValueKey('settings-dialog')), findsNothing);
    expect(CalendarDefaults.load(prefs).unit, LengthUnit.minutes);
    // Reopened: shown in minutes; an invalid length is not saved.
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-calendar')));
    await tester.pumpAndSettle();
    expect(_text(tester, 'setting-default-length'), '90');
    await tester.enterText(find.byKey(const ValueKey('setting-default-length')), 'soon');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('settings-close')));
    await tester.pumpAndSettle();
    expect(c.defaultLength, const Duration(minutes: 90));
  });

  testWidgets('SET-08.c, UIC-41: the default time is read like any time, saved on the device, and its arrows step 15 minutes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await _open(tester, prefs, section: 'settings-calendar');
    await tester.tap(find.byKey(const ValueKey('setting-default-time-up')));
    await tester.pump();
    expect(_text(tester, 'setting-default-time'), '09:15 am');
    await tester.tap(find.byKey(const ValueKey('setting-default-length-up')));
    await tester.pump();
    expect(_text(tester, 'setting-default-length'), '1.25');
    await tester.enterText(find.byKey(const ValueKey('setting-default-time')), '25:00');
    await tester.pump();
    expect(find.text('Use a time like 9:00 or 9:00 am.'), findsOneWidget);
    expect(CalendarDefaults.load(prefs).startMinutes, 9 * 60);
    await tester.enterText(find.byKey(const ValueKey('setting-default-time')), '2:30 pm');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('settings-close')));
    await tester.pumpAndSettle();
    expect(CalendarDefaults.load(prefs).startMinutes, 14 * 60 + 30);
  });

  testWidgets('SET-08.d: the default time zone is the system zone until a fixed zone is chosen; leaving with nothing changed stores nothing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = await _open(tester, prefs, section: 'settings-calendar');
    expect(c.baseZone.fixedZoneName, isNull);
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('setting-zone-system'))).selected, isTrue);
    await tester.tap(find.byKey(const ValueKey('settings-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('settings-dialog')), findsNothing);
    expect(prefs.getKeys(), isEmpty);
  });

  testWidgets('SET-14: Admin is the last entry of the Settings menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await _open(tester, prefs);
    final keys = tester
        .widgetList<ListTile>(find.descendant(of: find.byKey(const ValueKey('settings-dialog')), matching: find.byType(ListTile)))
        .map((t) => (t.key! as ValueKey).value)
        .toList();
    expect(keys.last, 'settings-admin');
    expect(keys, containsAllInOrder(['settings-general', 'settings-calendar', 'settings-theme']));
    await tester.tap(find.byKey(const ValueKey('settings-admin')));
    await tester.pumpAndSettle();
    expect(find.text('Add test calendars'), findsOneWidget);
  });
}
