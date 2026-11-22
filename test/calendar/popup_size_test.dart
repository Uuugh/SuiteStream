import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

const tall = Size(1000, 1400);

/// The popup's own size (the Dialog widget itself fills the window; its Material is the popup).
Size popup(WidgetTester tester) => tester.getSize(find.descendant(of: find.byType(Dialog).last, matching: find.byType(Material)).first);

void main() {
  labelTests();
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  Future<void> openNew(WidgetTester tester) async {
    useWindow(tester, tall);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
  }

  testWidgets('UIC-42: a popup is not resized once drawn: selecting or unselecting only shows or hides fields, adding or removing a row may grow or shrink it', (tester) async {
    await openNew(tester);
    final size = popup(tester);
    final title = tester.getTopLeft(find.byKey(const ValueKey('event-title')));
    final notes = tester.getRect(find.byKey(const ValueKey('event-notes')));
    final save = tester.getTopLeft(find.byKey(const ValueKey('event-save')));
    final reminders = tester.getTopLeft(find.byKey(const ValueKey('event-reminders')));
    final calendar = tester.getTopLeft(find.byKey(const ValueKey('event-calendar')));

    void expectSame(String why) {
      expect(popup(tester), size, reason: why);
      expect(tester.getTopLeft(find.byKey(const ValueKey('event-title'))), title, reason: why);
      expect(tester.getRect(find.byKey(const ValueKey('event-notes'))), notes, reason: why);
      expect(tester.getTopLeft(find.byKey(const ValueKey('event-save'))), save, reason: why);
      expect(tester.getTopLeft(find.byKey(const ValueKey('event-reminders'))), reminders, reason: why);
      expect(tester.getTopLeft(find.byKey(const ValueKey('event-calendar'))), calendar, reason: why);
    }

    // All-day hides the time fields and the zones; nothing moves or resizes.
    await tester.tap(find.byKey(const ValueKey('event-allday')));
    await tester.pumpAndSettle();
    expect(isHidden(tester, 'event-start-time'), isTrue);
    expectSame('all-day on');
    await tester.tap(find.byKey(const ValueKey('event-allday')));
    await tester.pumpAndSettle();
    expect(isHidden(tester, 'event-start-time'), isFalse);
    expectSame('all-day off');
    // A different end zone shows the end zone in the place kept for it.
    await tester.tap(find.byKey(const ValueKey('event-diffzone')));
    await tester.pumpAndSettle();
    expect(isHidden(tester, 'zone-end'), isFalse);
    expectSame('different end zone on');
    await tester.tap(find.byKey(const ValueKey('event-diffzone')));
    await tester.pumpAndSettle();
    expectSame('different end zone off');
  });

  testWidgets('a popup is not resized by an error line: it scrolls inside the popup', (tester) async {
    await openNew(tester);
    final size = popup(tester);
    await tester.enterText(find.byKey(const ValueKey('event-location')), 'Somewhere');
    await tester.enterText(find.byKey(const ValueKey('event-start-time')), 'soon');
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('event-save')));
    await tester.tap(find.byKey(const ValueKey('event-save')));
    await tester.pumpAndSettle();
    expect(find.text('The event needs a title.'), findsOneWidget);
    expect(popup(tester), size);
  });

  testWidgets('UIC-42: adding or removing a row (a reminder) may grow or shrink the popup, which is then held at the new size', (tester) async {
    await openNew(tester);
    final base = popup(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('reminder-add')));
    await tester.tap(find.byKey(const ValueKey('reminder-add')));
    await tester.pumpAndSettle();
    final one = popup(tester);
    expect(one.height, greaterThan(base.height)); // grew
    expect(one.width, base.width);
    await tester.ensureVisible(find.byKey(const ValueKey('reminder-add')));
    await tester.tap(find.byKey(const ValueKey('reminder-add')));
    await tester.pumpAndSettle();
    final two = popup(tester);
    expect(two.height, greaterThan(one.height));
    // Selecting something now does not change the new size.
    await tester.tap(find.byKey(const ValueKey('event-allday')));
    await tester.pumpAndSettle();
    expect(popup(tester), two);
    await tester.tap(find.byKey(const ValueKey('event-allday')));
    await tester.pumpAndSettle();
    // Removing shrinks it back.
    await tester.ensureVisible(find.byKey(const ValueKey('reminder-remove-1')));
    await tester.tap(find.byKey(const ValueKey('reminder-remove-1')));
    await tester.pumpAndSettle();
    expect(popup(tester).height, one.height);
    await tester.tap(find.byKey(const ValueKey('reminder-remove-0')));
    await tester.pumpAndSettle();
    expect(popup(tester).height, base.height);
  });

  testWidgets('the date picker is one size in days, months and years, and for months of five or six weeks', (tester) async {
    useWindow(tester, tall);
    final c = makeController(); // July 2026 spans five weeks
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
    await tester.tap(find.byKey(const ValueKey('title')));
    await tester.pumpAndSettle();
    final size = popup(tester);
    await tester.tap(find.byKey(const ValueKey('picker-prev-month'))); // June 2026: five weeks
    await tester.pump();
    expect(popup(tester), size);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const ValueKey('picker-next-month')));
      await tester.pump();
      expect(popup(tester), size, reason: 'month $i'); // includes months that need six weeks
    }
    await tester.tap(find.byKey(const ValueKey('picker-title'))); // months
    await tester.pumpAndSettle();
    expect(popup(tester), size);
    await tester.tap(find.byKey(const ValueKey('year-title'))); // years
    await tester.pumpAndSettle();
    expect(popup(tester), size);
  });

  testWidgets('the settings popup is not resized by an error', (tester) async {
    useWindow(tester, tall);
    final c = makeController();
    await tester.pumpWidget(appFor(Builder(builder: (context) => TextButton(onPressed: () => openSettingsDialog(context, c), child: const Text('open'))), size: tall));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final size = popup(tester);
    await tester.enterText(find.byKey(const ValueKey('setting-default-length')), 'soon');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('settings-save')));
    await tester.pumpAndSettle();
    expect(find.text('Use a length like 1:00 (from 5 minutes to 24 hours).'), findsOneWidget);
    expect(popup(tester), size);
  });

  testWidgets('the event details popup keeps its size when the event is hidden or shown', (tester) async {
    useWindow(tester);
    final theirs = makeEvent('t', 20, 9, title: 'Theirs').copyWith(custom: false);
    final c = makeController(events: [theirs]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    await tester.tap(find.byKey(const ValueKey('event-t')));
    await tester.pumpAndSettle();
    final size = popup(tester);
    c.setHidden('t', true); // adds a state line
    await tester.pumpAndSettle();
    expect(popup(tester), size);
  });
}

void labelTests() {
  testWidgets('UIC-40: a label fits its control without cutting a word: Different end time zone in a narrow dialog', (tester) async {
    for (final width in [1000.0, 800.0, 620.0]) {
      final size = Size(width, 1400);
      useWindow(tester, size);
      final c = makeController(view: CalendarView.month);
      await tester.pumpWidget(appFor(CalendarPage(controller: c), size: size));
      await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
      await tester.pumpAndSettle();
      final label = find.text('Different end time zone');
      expect(label, findsOneWidget, reason: '$width');
      // The text is shown whole (scaled down when needed), inside the dialog.
      final text = tester.widget<Text>(label);
      expect(text.overflow, isNot(TextOverflow.ellipsis));
      final scaled = tester.firstWidget<FittedBox>(find.ancestor(of: label, matching: find.byType(FittedBox)));
      expect(scaled.fit, BoxFit.scaleDown);
      final dialog = tester.getRect(find.byKey(const ValueKey('event-dialog')));
      final r = tester.getRect(label);
      expect(r.right <= dialog.right && r.left >= dialog.left, isTrue, reason: '$width');
      // It is not clipped by the end time field's column.
      final endField = tester.getRect(find.byKey(const ValueKey('event-end-time')));
      expect(r.right <= endField.right + 1, isTrue, reason: '$width');
      await tester.tap(find.byKey(const ValueKey('event-cancel')));
      await tester.pumpAndSettle();
    }
  });
}
