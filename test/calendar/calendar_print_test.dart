import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/ui/cancel_save_pair.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  testWidgets(
    'CAL-05, PRT-01.a: day print uses the visible period, filter, zone and clock',
    (tester) async {
      useWindow(tester);
      final calendar = makeController(
        view: CalendarView.day,
        focused: DateTime(2026, 7, 16),
        events: [
          makeEvent(
            'included',
            15,
            22,
            title: 'Visible meeting',
            calendarId: 'work',
          ),
          makeEvent(
            'filtered',
            15,
            22,
            title: 'Filtered meeting',
            calendarId: 'home',
          ),
          makeEvent(
            'later',
            18,
            22,
            title: 'Outside print range',
            calendarId: 'work',
          ),
        ],
      );
      addTearDown(calendar.dispose);
      calendar.filter.toggleCalendar('home');
      calendar.viewZone = 'Asia/Tokyo';
      calendar.timeFormat = TimeFormat.twentyFourHour;
      await tester.pumpWidget(appFor(CalendarPage(controller: calendar)));
      await tester.tap(find.byKey(const ValueKey('calendar-print-button')));
      await tester.pumpAndSettle();

      final preview = find.byType(AlertDialog);
      Finder inPreview(String text) => find.descendant(
        of: preview,
        matching: find.text(text, findRichText: true),
      );
      expect(inPreview('Print preview'), findsOneWidget);
      expect(inPreview('Portrait'), findsOneWidget);
      expect(inPreview('times in Asia/Tokyo'), findsOneWidget);
      expect(inPreview('11:00 – 12:00 Visible meeting'), findsOneWidget);
      expect(inPreview('11:00 – 12:00 Filtered meeting'), findsNothing);
      expect(inPreview('11:00 – 12:00 Outside print range'), findsNothing);

      // UIC-27: Print uses the shared Cancel | Save pair, with Print as the save word.
      expect(find.descendant(of: preview, matching: find.byType(CancelSavePair)), findsOneWidget);
      expect(inPreview('Print'), findsWidgets);
      await tester.tap(inPreview('Cancel'));
      await tester.pumpAndSettle();
      expect(preview, findsNothing);
      expect(calendar.focused, DateTime(2026, 7, 16));
      expect(calendar.view, CalendarView.day);
      expect(calendar.viewZone, 'Asia/Tokyo');
    },
  );

  testWidgets(
    'CAL-05.a: week printing uses landscape and localizes the preview',
    (tester) async {
      useWindow(tester);
      final calendar = makeController(view: CalendarView.week);
      addTearDown(calendar.dispose);
      await tester.pumpWidget(
        appFor(CalendarPage(controller: calendar), locale: 'es'),
      );
      await tester.tap(find.byKey(const ValueKey('calendar-print-button')));
      await tester.pumpAndSettle();

      expect(find.text('Vista previa de impresión'), findsOneWidget);
      expect(find.text('Horizontal'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
