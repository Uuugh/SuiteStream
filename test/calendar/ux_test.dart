import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/calendar/month_view.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/calendar/week_view.dart';
import 'package:suitestream/src/time/length_input.dart';
import 'package:suitestream/src/ui/cancel_save_pair.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

const tall = Size(1000, 1500);

String fieldText(WidgetTester tester, String key) =>
    tester.widget<TextField>(find.byKey(ValueKey(key))).controller!.text;

void main() {
  stepperTests();
  pressDelayTests();
  pairBehaviorTests();
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  test(
    'SET-08: a length is read as H:MM, hours or minutes, from 5 minutes to 24 hours',
    () {
    expect(parseLengthInput('1:30'), const Duration(minutes: 90));
    expect(parseLengthInput('1:00'), const Duration(hours: 1));
    expect(parseLengthInput('2'), const Duration(hours: 2));
    expect(parseLengthInput('1.5'), const Duration(minutes: 90));
    expect(parseLengthInput('1.5h'), const Duration(minutes: 90));
    expect(parseLengthInput('45m'), const Duration(minutes: 45));
    expect(parseLengthInput('90 min'), const Duration(minutes: 90));
    expect(parseLengthInput('24:00'), const Duration(hours: 24));
    expect(parseLengthInput('0:04'), isNull);
    expect(parseLengthInput('25:00'), isNull);
    expect(parseLengthInput('1:75'), isNull);
    expect(parseLengthInput('abc'), isNull);
    expect(parseLengthInput(''), isNull);
    expect(formatLength(const Duration(minutes: 90)), '1:30');
    expect(formatLength(const Duration(hours: 1)), '1:00');
    },
  );

  testWidgets(
    'SET-08: the default event length is a setting the user edits, kept on the device, one hour until changed',
    (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    useWindow(tester, tall);
    final c = CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      prefs: prefs,
      clock: () => DateTime.utc(2026, 7, 15, 16),
    );
    expect(c.defaultLength, const Duration(hours: 1));
      await tester.pumpWidget(
        appFor(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => openSettingsDialog(context, c),
              child: const Text('open'),
            ),
          ),
          size: tall,
        ),
      );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-calendar')));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'setting-default-length'), '1');
      await tester.enterText(
        find.byKey(const ValueKey('setting-default-length')),
        'soon',
      );
    await tester.pump();
      expect(
        find.text('Use a number with a unit (from 5 minutes to 24 hours).'),
        findsOneWidget,
      );
    expect(c.defaultLength, const Duration(hours: 1));
      await tester.enterText(
        find.byKey(const ValueKey('setting-default-length')),
        '1.5',
      );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('settings-close')));
    await tester.pumpAndSettle();
    expect(c.defaultLength, const Duration(minutes: 90));
    expect(find.byKey(const ValueKey('settings-dialog')), findsNothing);
      final again = CalendarController(
        localZone: const LocalZone.system(zone),
        timeFormat: TimeFormat.twelveHour,
        prefs: prefs,
      );
    expect(again.defaultLength, const Duration(minutes: 90));
    // An invalid length is not saved on leaving.
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-calendar')));
    await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('setting-default-length')),
        'soon',
      );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('settings-close')));
    await tester.pumpAndSettle();
    expect(c.defaultLength, const Duration(minutes: 90));
    },
  );

  testWidgets(
    'EVT-02.n: an empty start time uses the time now; an empty end time uses the default event length after the start',
    (tester) async {
    useWindow(tester, tall);
    final c = makeController();
    c.defaultLength = const Duration(minutes: 90);
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    // Clicked in the middle of the day: 12:00 to 1:30 (the default length).
    expect(fieldText(tester, 'event-start-time'), '12:00 pm');
    expect(fieldText(tester, 'event-end-time'), '01:30 pm');
      await tester.enterText(
        find.byKey(const ValueKey('event-title')),
        'Open times',
      );
      await tester.enterText(
        find.byKey(const ValueKey('event-start-time')),
        '',
      );
    await tester.enterText(find.byKey(const ValueKey('event-end-time')), '');
    await tester.ensureVisible(find.byKey(const ValueKey('event-save')));
    await tester.tap(find.byKey(const ValueKey('event-save')));
    await tester.pumpAndSettle();
    final e = c.events.single;
    // "Now" is 12:00 in New York (16:00 UTC); the end is 90 minutes later.
    final s = e.startIn(zoneNamed(zone));
    expect([s.year, s.month, s.day, s.hour, s.minute], [2026, 7, 20, 12, 0]);
    expect(e.endUtc.difference(e.startUtc), const Duration(minutes: 90));
    },
  );

  testWidgets(
    'EVT-02.n: an empty end time alone is one default length after the start, across midnight',
    (tester) async {
    useWindow(tester, tall);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('event-title')), 'Late');
      await tester.enterText(
        find.byKey(const ValueKey('event-start-time')),
        '11:30 pm',
      );
    await tester.enterText(find.byKey(const ValueKey('event-end-time')), '');
    await tester.ensureVisible(find.byKey(const ValueKey('event-save')));
    await tester.tap(find.byKey(const ValueKey('event-save')));
    await tester.pumpAndSettle();
    final e = c.events.single;
    final end = e.endIn(zoneNamed(zone));
      expect(
        [end.day, end.hour, end.minute],
        [21, 0, 30],
      ); // one hour later, the next day
    },
  );

  testWidgets(
    'EVT-01.a: clicking an empty spot in Week, 5-day and Day opens the new-event dialog with the start time where the click occurred',
    (tester) async {
    useWindow(tester, tall);
    final c = makeController(view: CalendarView.week);
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
      for (final v in [
        CalendarView.week,
        CalendarView.fiveDay,
        CalendarView.day,
      ]) {
      c.view = v;
      await tester.pumpAndSettle();
      final slot = find.byKey(const ValueKey('slot-2026-7-15'));
      final top = tester.getTopLeft(slot);
      // 10.6 hours down is 10:36, which starts the event at 10:30 (the drag step).
      await tester.tapAt(top + const Offset(12, hourHeight * 10.6));
      await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('event-dialog')),
          findsOneWidget,
          reason: '$v',
        );
      expect(fieldText(tester, 'event-start-time'), '10:30 am', reason: '$v');
        expect(
          fieldText(tester, 'event-end-time'),
          '11:30 am',
          reason: '$v',
        ); // the default length later
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('event-start-date')),
            matching: find.text('Jul 15, 2026'),
          ),
          findsOneWidget,
        );
      await tester.tap(find.byKey(const ValueKey('event-cancel')));
      await tester.pumpAndSettle();
    }
    },
  );

  testWidgets(
    'EVT-01.a: clicking an all-day cell adds an all-day event; clicking a List day and the + button add on that day',
    (tester) async {
    useWindow(tester, tall);
    final c = makeController(view: CalendarView.week);
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
    await tester.tap(find.byKey(const ValueKey('allday-slot-2026-7-16')));
    await tester.pumpAndSettle();
      expect(
        tester
            .widget<Checkbox>(find.byKey(const ValueKey('event-allday')))
            .value,
        isTrue,
      );
    expect(isHidden(tester, 'event-start-time'), isTrue);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('event-start-date')),
          matching: find.text('Jul 16, 2026'),
        ),
        findsOneWidget,
      );
    await tester.tap(find.byKey(const ValueKey('event-cancel')));
    await tester.pumpAndSettle();
    // List: a day's title adds an event on that day.
      final list = makeController(
        view: CalendarView.list,
        events: [makeEvent('a', 22, 9)],
      );
      await tester.pumpWidget(
        appFor(CalendarPage(controller: list), size: tall),
      );
    await tester.tap(find.byKey(const ValueKey('list-day-22')));
    await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('event-start-date')),
          matching: find.text('Jul 22, 2026'),
        ),
        findsOneWidget,
      );
    await tester.tap(find.byKey(const ValueKey('event-cancel')));
    await tester.pumpAndSettle();
    // The + button works in every view and adds on the day the calendar is on.
    for (final v in CalendarView.values) {
      list.view = v;
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add-event-button')));
      await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('event-dialog')),
          findsOneWidget,
          reason: '$v',
        );
      await tester.tap(find.byKey(const ValueKey('event-cancel')));
      await tester.pumpAndSettle();
    }
    },
  );

  testWidgets(
    'the shared dropdown never resizes once opened: choosing or clearing items keeps its width and height',
    (tester) async {
    useWindow(tester, const Size(1000, 900));
    final c = makeController();
      await tester.pumpWidget(
        appFor(CalendarPage(controller: c), size: const Size(1000, 900)),
      );
    await tester.tap(find.byIcon(SuiteIcons.filterList));
    await tester.pumpAndSettle();
    Size menu() => tester.getSize(find.byType(IntrinsicWidth).last);
    final before = menu();
    // The longest item is the event state "Changed by the source since the edit".
      final first = tester.getTopLeft(
        find.byKey(const ValueKey('dropdown-item-cal:work')),
      );
      await tester.tap(
        find.byKey(const ValueKey('dropdown-item-state:changedBySource')),
      );
    await tester.pumpAndSettle();
    expect(menu(), before);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('dropdown-item-cal:work'))),
        first,
      );
    // The checks stay where they are for every other item.
      final checkX = tester
          .getTopRight(find.byKey(const ValueKey('dropdown-item-cal:work')))
          .dx;
    await tester.tap(find.byKey(const ValueKey('dropdown-item-cal:work')));
    await tester.pumpAndSettle();
      expect(
        tester
            .getTopRight(find.byKey(const ValueKey('dropdown-item-cal:work')))
            .dx,
        checkX,
      );
    expect(menu(), before);
    // The view dropdown too.
    await tester.tapAt(const Offset(5, 880));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(viewIcon(c.view)).last);
    await tester.pumpAndSettle();
    final view = tester.getSize(find.byType(IntrinsicWidth).last);
      await tester.tap(
        find.byKey(const ValueKey('dropdown-item-CalendarView.day')),
      );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(viewIcon(c.view)).last);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(IntrinsicWidth).last), view);
    },
  );

  testWidgets(
    'EVT-07: opening an event shows its details in a popup and the calendar is not resized',
    (tester) async {
    useWindow(tester);
    final c = makeController(events: [makeEvent('a', 20, 9, title: 'Popup')]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final before = tester.getSize(find.byType(MonthView));
    await tester.tap(find.byKey(const ValueKey('event-a')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-details')), findsOneWidget);
    expect(tester.getSize(find.byType(MonthView)), before);
    // It floats over the calendar, inside a dialog.
      expect(
        find.ancestor(
          of: find.byKey(const ValueKey('event-details')),
          matching: find.byType(Dialog),
        ),
        findsOneWidget,
      );
    // Tapping outside closes it and clears the choice.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-details')), findsNothing);
    expect(c.selectedEvent, isNull);
    },
  );

  testWidgets(
    'EVT-07.l: editing or duplicating an event closes its details popup after save or cancel',
    (tester) async {
      useWindow(tester, const Size(1000, 900));
      for (final action in ['details-edit', 'details-duplicate']) {
        for (final save in [false, true]) {
          final c = makeController(
            events: [makeEvent('a', 20, 9, title: 'Popup')],
          );
          await tester.pumpWidget(appFor(CalendarPage(controller: c)));
          await tester.tap(find.byKey(const ValueKey('event-a')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(ValueKey(action)));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('event-dialog')), findsOneWidget);
          expect(find.byKey(const ValueKey('event-details')), findsOneWidget);

          if (save) {
            await tester.enterText(
              find.byKey(const ValueKey('event-title')),
              action == 'details-edit' ? 'Updated' : 'Copy',
            );
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const ValueKey('event-save')));
          } else {
            await tester.tap(find.byKey(const ValueKey('event-cancel')));
          }
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('event-dialog')), findsNothing);
          expect(find.byKey(const ValueKey('event-details')), findsNothing);
          expect(c.selectedEvent, isNull);
          if (save && action == 'details-duplicate') {
            expect(c.events, hasLength(2));
            expect(c.events.any((event) => event.title == 'Copy'), isTrue);
          } else {
            expect(c.events, hasLength(1));
            expect(c.events.single.title, save ? 'Updated' : 'Popup');
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        }
      }
    },
  );

  testWidgets(
    'CAL-03.a: while an event is dragged it follows the pointer, the original is dimmed and the day it would land on is highlighted',
    (tester) async {
    useWindow(tester);
      final c = makeController(
        events: [makeEvent('a', 20, 9, title: 'Drag me')],
      );
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final cell = tester.getSize(find.byKey(const ValueKey('day-2026-7-20')));
    final from = tester.getCenter(find.byKey(const ValueKey('event-a')));
    final g = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 650));
      expect(
        find.byKey(const ValueKey('drag-ghost')),
        findsOneWidget,
      ); // a lifted copy
      final ghost0 = tester.getTopLeft(
        find.byKey(const ValueKey('drag-ghost')),
      );
    await g.moveBy(Offset(cell.width * 2, 0));
    await tester.pump();
      final ghost1 = tester.getTopLeft(
        find.byKey(const ValueKey('drag-ghost')),
      );
      expect(
        (ghost1.dx - ghost0.dx).round(),
        (cell.width * 2).round(),
      ); // it moves with the pointer
      expect(
        c.localStart('a'),
        DateTime(2026, 7, 20, 9, 0),
      ); // not moved until released
    // The day under it is highlighted.
      final target = tester.widget<Container>(
        find.byKey(const ValueKey('day-2026-7-22')),
      );
    expect((target.foregroundDecoration! as BoxDecoration).border, isNotNull);
      final other = tester.widget<Container>(
        find.byKey(const ValueKey('day-2026-7-21')),
      );
    expect((other.foregroundDecoration! as BoxDecoration).border, isNull);
    await g.up();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('drag-ghost')), findsNothing);
    expect(c.dropTarget, isNull);
    expect(c.localStart('a'), DateTime(2026, 7, 22, 9, 0));
    },
  );

  testWidgets(
    'CAL-03.b: in Week the dragged event shows a snapped outline of where it would land',
    (tester) async {
    useWindow(tester);
      final c = makeController(
        view: CalendarView.week,
        events: [makeEvent('a', 15, 10, title: 'Block')],
      );
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
      final g = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('event-a'))),
      );
    await tester.pump(const Duration(milliseconds: 650));
    await g.moveBy(const Offset(0, hourHeight * 1.4));
    await tester.pump();
    expect(find.byKey(const ValueKey('drag-ghost')), findsOneWidget);
    expect(find.byKey(const ValueKey('drop-preview')), findsOneWidget);
      expect(
        find.text('11:30 am'),
        findsOneWidget,
      ); // 11:24 snapped to the 15-minute step
    await g.up();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('drop-preview')), findsNothing);
    expect(find.byKey(const ValueKey('drag-ghost')), findsNothing);
    },
  );

  testWidgets(
    'UIC-27: the Cancel | Save pair is joined and 130 by 34',
    (tester) async {
    useWindow(tester, tall);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    final cancel = tester.getRect(find.byKey(const ValueKey('event-cancel')));
    final save = tester.getRect(find.byKey(const ValueKey('event-save')));
    expect(save.left, cancel.right); // joined
    expect(cancel.top, save.top);
    expect(tester.getSize(find.byType(CancelSavePair)), const Size(130, 34));
      expect(
        save.right <=
            tester.getRect(find.byKey(const ValueKey('event-dialog'))).right,
        isTrue,
      ); // bottom right
    },
  );
}

extension on CalendarController {
  DateTime localStart(String id) {
    final e = events.firstWhere((x) => x.id == id);
    final s = e.startIn(zoneNamed(zone));
    return DateTime(s.year, s.month, s.day, s.hour, s.minute);
  }
}

void pairBehaviorTests() {
  testWidgets('UIC-27.b: Save cannot be activated before something changes', (
    tester,
  ) async {
    useWindow(tester, tall);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('event-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('event-dialog')), findsOneWidget);
    expect(c.events, isEmpty);
  });

  testWidgets(
    'the add/edit event dialog is wide, in the proportions of the Product Owner\'s picture',
    (tester) async {
    useWindow(tester, const Size(1400, 1100));
    final c = makeController();
      await tester.pumpWidget(
        appFor(CalendarPage(controller: c), size: const Size(1400, 1100)),
      );
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
      final dialog = tester.getSize(
        find
            .descendant(
              of: find.byType(Dialog).last,
              matching: find.byType(Material),
            )
            .first,
      );
    expect(dialog.width, greaterThanOrEqualTo(940));
    // Two columns of about equal width (the fields and Notes).
      final title = tester
          .getSize(find.byKey(const ValueKey('event-title')))
          .width;
      final notes = tester
          .getSize(find.byKey(const ValueKey('event-notes')))
          .width;
    expect((title - notes).abs() < 30, isTrue);
    },
  );
}

void pressDelayTests() {
  test(
    'SET-09: a press-and-hold delay is read in seconds or milliseconds, from 0.2 to 1.5 seconds',
    () {
    expect(parsePressDelayInput('0.3'), const Duration(milliseconds: 300));
    expect(parsePressDelayInput('0,5'), const Duration(milliseconds: 500));
    expect(parsePressDelayInput('1'), const Duration(seconds: 1));
    expect(parsePressDelayInput('1.5 s'), const Duration(milliseconds: 1500));
    expect(parsePressDelayInput('400ms'), const Duration(milliseconds: 400));
    expect(parsePressDelayInput('0.2'), const Duration(milliseconds: 200));
    expect(parsePressDelayInput('1.6'), isNull);
    expect(parsePressDelayInput('250ms'), const Duration(milliseconds: 250));
    expect(parsePressDelayInput('0.1'), isNull);
    expect(parsePressDelayInput('150ms'), isNull);
    expect(parsePressDelayInput('soon'), isNull);
    expect(parsePressDelayInput(''), isNull);
    expect(formatPressDelay(const Duration(milliseconds: 300)), '0.3');
    expect(formatPressDelay(const Duration(seconds: 1)), '1.0');
    },
  );

  testWidgets(
    'SET-09: the press-and-hold delay is a setting the user edits, 0.3 seconds until changed, kept on the device',
    (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    useWindow(tester, tall);
      final c = CalendarController(
        localZone: const LocalZone.system(zone),
        timeFormat: TimeFormat.twelveHour,
        prefs: prefs,
      );
    expect(c.longPress, const Duration(milliseconds: 300));
      await tester.pumpWidget(
        appFor(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => openSettingsDialog(context, c),
              child: const Text('open'),
            ),
          ),
          size: tall,
        ),
      );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'setting-press-delay'), '0.3');
      await tester.enterText(
        find.byKey(const ValueKey('setting-press-delay')),
        '2',
      );
    await tester.pump();
    expect(find.text('Use a delay from 0.2 to 1.5 seconds.'), findsOneWidget);
    expect(c.longPress, const Duration(milliseconds: 300));
      await tester.enterText(
        find.byKey(const ValueKey('setting-press-delay')),
        '0.8',
      );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('settings-close')));
    await tester.pumpAndSettle();
    expect(c.longPress, const Duration(milliseconds: 800));
      final again = CalendarController(
        localZone: const LocalZone.system(zone),
        timeFormat: TimeFormat.twelveHour,
        prefs: prefs,
      );
    expect(again.longPress, const Duration(milliseconds: 800));
    // The length setting is untouched.
    expect(c.defaultLength, const Duration(hours: 1));
    },
  );

  test('SET-03.g: an animation time is read in seconds or milliseconds, from 0 to 2 seconds', () {
    expect(parseAnimationInput('0'), Duration.zero);
    expect(parseAnimationInput('0,5'), const Duration(milliseconds: 500));
    expect(parseAnimationInput('1.5 s'), const Duration(milliseconds: 1500));
    expect(parseAnimationInput('250ms'), const Duration(milliseconds: 250));
    expect(parseAnimationInput('2'), const Duration(seconds: 2));
    expect(parseAnimationInput('2.1'), isNull);
    expect(parseAnimationInput('fast'), isNull);
    expect(parseAnimationInput(''), isNull);
  });

  testWidgets('SET-03.g: the animation time is a setting, 0.5 seconds until changed, kept on the device', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    useWindow(tester, tall);
    final c = CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      prefs: prefs,
    );
    expect(c.animationDuration, const Duration(milliseconds: 500));
    await tester.pumpWidget(
      appFor(
        Builder(
          builder: (context) => TextButton(onPressed: () => openSettingsDialog(context, c), child: const Text('open')),
        ),
        size: tall,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-theme')));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'setting-animation'), '0.5 s');
    await tester.enterText(find.byKey(const ValueKey('setting-animation')), '3');
    await tester.pump();
    expect(find.text('Use a number from 0 to 2.'), findsOneWidget);
    expect(c.animationDuration, const Duration(milliseconds: 500));
    await tester.enterText(find.byKey(const ValueKey('setting-animation')), '0');
    await tester.pump();
    expect(c.animationDuration, Duration.zero);
    final again = CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      prefs: prefs,
    );
    expect(again.animationDuration, Duration.zero);
  });
}

void stepperTests() {
  testWidgets(
    'UIC-41: every time or number field offers up and down arrows that step its value',
    (tester) async {
    useWindow(tester, tall);
    final c = makeController();
    await tester.pumpWidget(appFor(CalendarPage(controller: c), size: tall));
    await tester.tap(find.byKey(const ValueKey('day-2026-7-20')));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'event-start-time'), '12:00 pm');
    await tester.tap(find.byKey(const ValueKey('event-start-time-up')));
    await tester.pump();
    expect(fieldText(tester, 'event-start-time'), '12:15 pm');
      expect(
        fieldText(tester, 'event-end-time'),
        '01:15 pm',
      ); // the end keeps the length
    await tester.tap(find.byKey(const ValueKey('event-start-time-down')));
    await tester.tap(find.byKey(const ValueKey('event-start-time-down')));
    await tester.pump();
    expect(fieldText(tester, 'event-start-time'), '11:45 am');
    // An end time of 1:20 steps to the next quarter hour.
      await tester.enterText(
        find.byKey(const ValueKey('event-end-time')),
        '1:20 pm',
      );
    await tester.tap(find.byKey(const ValueKey('event-end-time-up')));
    await tester.pump();
    expect(fieldText(tester, 'event-end-time'), '01:30 pm');
    // The keys step the focused field too.
    await tester.tap(find.byKey(const ValueKey('event-end-time')));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(fieldText(tester, 'event-end-time'), '01:15 pm');
    // Reminder numbers step by one, from 0 up to the longest lead.
    await tester.ensureVisible(find.byKey(const ValueKey('reminder-add')));
    await tester.tap(find.byKey(const ValueKey('reminder-add')));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'reminder-number-0'), '10');
    await tester.tap(find.byKey(const ValueKey('reminder-number-0-up')));
    await tester.pump();
    expect(fieldText(tester, 'reminder-number-0'), '11');
    for (var i = 0; i < 12; i++) {
      await tester.tap(find.byKey(const ValueKey('reminder-number-0-down')));
    }
    await tester.pump();
    expect(fieldText(tester, 'reminder-number-0'), '0'); // never below 0
    },
  );

  testWidgets('UIC-41: the settings fields have arrows too', (tester) async {
    useWindow(tester, tall);
    final c = makeController();
    await tester.pumpWidget(
      appFor(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => openSettingsDialog(context, c),
            child: const Text('open'),
          ),
        ),
        size: tall,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-calendar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('setting-default-length-up')));
    await tester.pump();
    expect(fieldText(tester, 'setting-default-length'), '1.25');
    await tester.tap(find.byKey(const ValueKey('settings-general')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('setting-press-delay-up')));
    await tester.pump();
    expect(fieldText(tester, 'setting-press-delay'), '0.4');
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const ValueKey('setting-press-delay-down')));
    }
    await tester.pump();
    expect(
      fieldText(tester, 'setting-press-delay'),
      '0.2',
    ); // not below 0.2 seconds
  });
}
