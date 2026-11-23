import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

const _keys = [
  'previous',
  'next',
  'today',
  'zone-button',
  'clock-button',
  'calendar-print-button',
  'add-event-button',
];

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  for (final width in [320.0, 360.0, 400.0, 700.0]) {
    testWidgets(
      'UIC-14: the calendar header fits at ${width.toInt()} px: no overflow, zones stack, every control is on screen and at least 24x24',
      (tester) async {
        final size = Size(width, 700);
        useWindow(tester, size);
        await tester.pumpWidget(
          appFor(CalendarPage(controller: makeController()), size: size),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final card = tester.getRect(find.byType(CalendarPage));
        for (final k in _keys) {
          final r = tester.getRect(find.byKey(ValueKey(k)));
          expect(
            r.width >= 24 && r.height >= 24,
            isTrue,
            reason: '$k is ${r.size}',
          );
          expect(
            r.left >= card.left - 0.5 && r.right <= card.right + 0.5,
            isTrue,
            reason: '$k at $r is outside $card',
          );
        }
        // The title is shown or ends in the triple dot's info button (UIC-14 step 3).
        expect(find.byKey(const ValueKey('title')), findsOneWidget);
        final title = tester.getRect(find.byKey(const ValueKey('title')));
        expect(
          title.left >= card.left - 0.5 && title.right <= card.right + 0.5,
          isTrue,
          reason: 'title $title',
        );
      },
    );
  }

  testWidgets(
    'UIC-14: at 400 px with text scaled up 1.5 times the header still fits without overflow',
    (tester) async {
      const size = Size(400, 700);
      useWindow(tester, size);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(1.5),
          ),
          child: appFor(CalendarPage(controller: makeController()), size: size),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
