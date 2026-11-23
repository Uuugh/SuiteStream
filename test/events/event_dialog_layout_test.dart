import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/event_dialog.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/time/zones.dart';

import '../calendar/test_support.dart';

/// PBI-033: the Add/Edit event dialog is compact and aligned (THM-04.b).
Future<void> openAt(WidgetTester tester, Size size, {double textScale = 1}) async {
  useWindow(tester, size);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final c = makeController();
  await tester.pumpWidget(appFor(
    Builder(builder: (context) => TextButton(onPressed: () => openEventDialog(context, c), child: const Text('go'))),
    size: size,
  ));
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
}

Rect r(WidgetTester tester, Finder f) => tester.getRect(f);
Finder k(String key) => find.byKey(ValueKey(key));
Finder box(String key) => find.descendant(of: k(key), matching: find.byType(InputDecorator)).first;

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  testWidgets('wide dialog: 34 px boxes, one left edge, even row pitch, paired fields aligned', (tester) async {
    await openAt(tester, const Size(967, 700));
    final title = r(tester, box('event-title'));
    final loc = r(tester, box('event-location'));
    final meet = r(tester, box('event-meeting'));
    final cal = r(tester, box('event-calendar'));
    final color = r(tester, box('event-color-button'));
    final sd = r(tester, box('event-start-date'));
    final ed = r(tester, box('event-end-date'));
    final st = r(tester, box('event-start-time'));
    final et = r(tester, box('event-end-time'));
    final zone = r(tester, find.descendant(of: k('zone-start'), matching: find.byType(InputDecorator)));
    final notes = r(tester, box('event-notes'));
    final all = {'title': title, 'loc': loc, 'meet': meet, 'cal': cal, 'color': color, 'sd': sd, 'ed': ed, 'st': st, 'et': et, 'zone': zone};
    all.forEach((n, rect) => expect(rect.height, suiteControlHeight, reason: n));
    // Every single-line box in the dialog, reminders included, is the standard height.
    for (final d in tester.widgetList<InputDecorator>(find.descendant(of: k('event-dialog'), matching: find.byType(InputDecorator))).toList()) {
      if (d.decoration.constraints?.hasTightHeight != true) continue; // Notes (multi-line)
      final i = tester.widgetList(find.byType(InputDecorator)).toList().indexOf(d);
      expect(tester.getSize(find.byType(InputDecorator).at(i)).height, suiteControlHeight, reason: 'box #$i');
    }
    for (final rect in [title, loc, meet, cal, sd, st, zone]) {
      expect(rect.left, title.left);
    }
    // Rows are evenly spaced.
    final pitch = loc.top - title.top;
    expect(pitch, lessThanOrEqualTo(59));
    for (final (a, b) in [(title, loc), (loc, meet), (meet, cal), (cal, sd), (sd, st), (st, zone)]) {
      expect(b.top - a.top, pitch);
    }
    // Pairs are equal width and aligned.
    expect(cal.width, color.width);
    expect(sd.width, ed.width);
    expect(st.width, et.width);
    expect(ed.left, color.left);
    expect(et.left, ed.left);
    expect(sd.width, title.width / 2 - 5, reason: 'half the column less half the gap');
    expect(color.right, title.right);
    // Notes starts level with Title and ends at the Time zone bottom.
    expect(find.text('Notes'), findsOneWidget);
    expect(r(tester, find.text('Notes')).top, r(tester, find.text('Title')).top);
    expect(notes.top, title.top);
    expect(notes.left - title.right, 10);
    expect(notes.bottom, greaterThanOrEqualTo(zone.bottom));
  });

  for (final (size, scale) in [
    (const Size(320, 700), 1.0),
    (const Size(400, 800), 1.0),
    (const Size(400, 800), 2.0),
    (const Size(967, 700), 2.0),
  ]) {
    testWidgets('no overflow at ${size.width}x${size.height}, text scale $scale', (tester) async {
      await openAt(tester, size, textScale: scale);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('event-dialog')), findsOneWidget);
    });
  }
}
