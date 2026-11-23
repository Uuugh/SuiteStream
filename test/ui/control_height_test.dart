import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/date_picker.dart';
import 'package:suitestream/src/calendar/event_dialog.dart';
import 'package:suitestream/src/calendar/local_calendars_dialog.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/time/zones.dart';
import 'package:suitestream/src/ui/zone_picker.dart';

import '../calendar/test_support.dart';

/// PBI-043, THM-04.b, THM-01.e: every single-line text box and dropdown on the site, in
/// every dialog, is [suiteControlHeight] (34 px) high. The test opens each dialog, measures
/// every [InputDecorator] and fails on any that is not 34 px, naming the dialog.
void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  test('THM-04.b: the one control height token is 34 px and the theme input uses it', () {
    expect(suiteControlHeight, 34);
    final theme = buildSuiteTheme(Brightness.light);
    expect(theme.inputDecorationTheme.constraints, const BoxConstraints.tightFor(height: suiteControlHeight));
    expect(theme.inputDecorationTheme.constraints, buildSuiteTheme(Brightness.dark).inputDecorationTheme.constraints);
  });

  /// Heights of every single-line box (multi-line text fields are exempt) under [root].
  List<double> heights(WidgetTester tester, Finder root, String where) {
    final boxes = find.descendant(of: root, matching: find.byType(InputDecorator));
    final out = <double>[];
    for (final e in boxes.evaluate()) {
      final multiline = find.ancestor(of: find.byWidget(e.widget), matching: find.byType(TextField)).evaluate().any((t) {
        final f = t.widget as TextField;
        return f.maxLines != 1;
      });
      if (multiline) continue;
      final h = tester.getSize(find.byWidget(e.widget)).height;
      expect(h, suiteControlHeight, reason: '$where: ${e.widget.runtimeType} at ${tester.getTopLeft(find.byWidget(e.widget))}');
      out.add(h);
    }
    return out;
  }

  Future<void> open(WidgetTester tester, Size size, Future<void> Function(BuildContext, CalendarController) opener) async {
    useWindow(tester, size);
    final c = makeController();
    await tester.pumpWidget(appFor(
      Builder(builder: (context) => TextButton(onPressed: () => opener(context, c), child: const Text('go'))),
      size: size,
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(1000, 1200), const Size(420, 1200)]) {
    final tag = '${size.width.toInt()} px wide';

    testWidgets('event dialog, with reminders and a Calendar dropdown ($tag)', (tester) async {
      await open(tester, size, (context, c) => openEventDialog(context, c));
      // Two reminder rows: the number box, the unit and method dropdowns.
      final add = find.byKey(const ValueKey('reminder-add'));
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('reminder-row-1')), findsOneWidget);
      final seen = heights(tester, find.byKey(const ValueKey('event-dialog')), 'event dialog');
      expect(seen.length, greaterThan(10), reason: 'the dialog has many boxes');
      final rows = heights(tester, find.byKey(const ValueKey('reminder-row-0')), 'reminder row');
      expect(rows.length, greaterThanOrEqualTo(3), reason: 'method, number and unit');
    });

    testWidgets('settings dialog, every section ($tag)', (tester) async {
      await open(tester, size, (context, c) => openSettingsDialog(context, c));
      heights(tester, find.byKey(const ValueKey('settings-dialog')), 'settings');
      for (final key in ['settings-general', 'settings-sources', 'settings-calendar', 'settings-theme', 'settings-admin']) {
        final entry = find.byKey(ValueKey(key));
        if (entry.evaluate().isEmpty) continue;
        await tester.tap(entry);
        await tester.pumpAndSettle();
        heights(tester, find.byKey(const ValueKey('settings-dialog')), key);
        final back = find.byTooltip('Back');
        if (back.evaluate().isNotEmpty) {
          await tester.tap(back.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('local calendars dialog and its add form ($tag)', (tester) async {
      await open(tester, size, (context, c) => openLocalCalendars(context, c));
      heights(tester, find.byType(Dialog), 'local calendars');
      final add = find.text('Add');
      if (add.evaluate().isNotEmpty) {
        await tester.tap(add.first);
        await tester.pumpAndSettle();
        heights(tester, find.byType(Dialog).last, 'local calendar form');
      }
    });

    testWidgets('time zone picker ($tag)', (tester) async {
      await open(tester, size, (context, c) => pickZone(context, current: 'America/New_York', defaultZone: 'America/New_York'));
      expect(find.byKey(const ValueKey('zone-filter')), findsOneWidget);
      expect(heights(tester, find.byType(Dialog), 'zone picker'), isNotEmpty);
    });

    testWidgets('date picker has no text boxes ($tag)', (tester) async {
      await open(tester, size, (context, c) => pickDate(context, c));
      expect(find.byKey(const ValueKey('picker-title')), findsOneWidget);
      heights(tester, find.byType(Dialog), 'date picker');
    });
  }
}
