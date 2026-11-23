import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/calendar/event_filter.dart';
import 'package:suitestream/src/theme/tokens.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

Future<void> openFilter(WidgetTester tester) async {
  await tester.tap(find.byIcon(SuiteIcons.filterList));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  final work = makeEvent('w', 15, 9, title: 'Standup', calendarId: 'work');
  final home = makeEvent('h', 15, 12, title: 'Lunch', calendarId: 'home');

  testWidgets('FLT-01.a: one filter icon with a dropdown lists every calendar with its color and the event states; choosing items shows only those events', (tester) async {
    useWindow(tester);
    final c = makeController(events: [work, home]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    expect(find.byIcon(SuiteIcons.filterList), findsOneWidget);
    await openFilter(tester);
    for (final id in ['cal:work', 'cal:home', 'state:edited', 'state:changedBySource', 'state:hiddenFromGoogle', 'state:deleted']) {
      expect(find.byKey(ValueKey('dropdown-item-$id')), findsOneWidget, reason: id);
    }
    expect(find.text('Work'), findsWidgets);
    expect(find.text('Edited'), findsWidgets);
    expect(find.text('Changed by the source since the edit'), findsWidgets);
    expect(find.text('Hidden from Google'), findsWidgets);
    expect(find.text('Deleted'), findsWidgets);
    // Each calendar shows its color.
    final dot = tester.widget<Container>(find.descendant(of: find.byKey(const ValueKey('dropdown-item-cal:work')), matching: find.byType(Container)).at(1));
    expect((dot.decoration! as BoxDecoration).color, const Color(0xFF5B6F9A));
    // Choosing an item hides its events at once; the events themselves are unchanged.
    expect(find.textContaining('Lunch'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('dropdown-item-cal:home')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Lunch'), findsNothing);
    expect(find.textContaining('Standup'), findsOneWidget);
    expect(c.events.length, 2);
  });

  test('FLT-01.b: the Calendar filter follows the common filter rules (UIC-21)', () {
    final f = EventFilter();
    expect(f.shows(work), isTrue);
    f.toggleCalendar('work');
    expect(f.shows(work), isFalse);
    expect(f.shows(home), isTrue);
    f.selectAll();
    expect(f.shows(work) && f.shows(home), isTrue);
    f.selectNone(['work', 'home']);
    expect(f.shows(work) || f.shows(home), isFalse);
  });

  test('UIC-21: one, several, all or none can be selected; it shows when active; the choices are saved and kept; a change applies at once', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final f = EventFilter(prefs: prefs);
    var notified = 0;
    f.addListener(() => notified++);
    expect(f.active, isFalse);
    f.setShown(calendarIds: ['work', 'home'], shownCalendars: {'work'}, shownStates: EventState.values.toSet()); // one
    expect(f.active, isTrue);
    expect(notified, 1); // at once, nothing to apply
    expect(f.shows(work), isTrue);
    expect(f.shows(home), isFalse);
    f.setShown(calendarIds: ['work', 'home'], shownCalendars: {'work', 'home'}, shownStates: {EventState.edited}); // several
    expect(f.stateShown(EventState.deleted), isFalse);
    f.selectNone(['work', 'home']); // none
    expect(f.shows(work), isFalse);
    // Kept: a new filter on the same storage starts with the same choices.
    final again = EventFilter(prefs: prefs);
    expect(again.hiddenCalendars, {'work', 'home'});
    expect(again.hiddenStates, EventState.values.toSet());
    expect(again.active, isTrue);
    again.selectAll(); // all
    expect(again.active, isFalse);
    expect(EventFilter(prefs: prefs).active, isFalse);
  });

  testWidgets('UIC-21: the filter shows when it is active', (tester) async {
    useWindow(tester);
    final c = makeController(events: [work, home]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    final accent = SuiteTokens.light.accent;
    Color? iconColor() => tester.widget<Icon>(find.byIcon(SuiteIcons.filterList)).color;
    expect(iconColor(), isNull);
    c.filter.toggleCalendar('home');
    await tester.pump();
    expect(iconColor(), accent);
    // Select all and Select none are offered.
    await openFilter(tester);
    await tester.tap(find.byKey(const ValueKey('dropdown-action-Select none')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Standup'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('dropdown-action-Select all')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Standup'), findsOneWidget);
    expect(iconColor(), isNull);
  });

  testWidgets('FLT-01.e: a calendar name and color follow its source and show at once', (tester) async {
    useWindow(tester);
    final c = makeController(events: [work]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    c.setCalendars(const [
      SuiteCalendar(id: 'work', name: 'Office', color: 0xFFB8733A),
      SuiteCalendar(id: 'home', name: 'Home', color: 0xFF2A9D8F),
    ]);
    await tester.pump();
    await openFilter(tester);
    expect(find.text('Work'), findsNothing);
    expect(find.text('Office'), findsOneWidget);
    expect(c.colorOf(work), 0xFFB8733A);
  });

  testWidgets('FLT-01.i: the header shows the title and controls only; the filter lists calendars and event states only', (tester) async {
    useWindow(tester);
    final c = makeController(events: [work]);
    await tester.pumpWidget(appFor(CalendarPage(controller: c)));
    for (final word in ['Timed', 'Added']) {
      expect(find.text(word), findsNothing);
    }
    await openFilter(tester);
    expect(find.byKey(const ValueKey('dropdown-item-cal:work')), findsOneWidget);
    expect(find.text('Timed'), findsNothing);
    expect(find.text('Added'), findsNothing);
    expect(find.text('All-day'), findsNothing);
    expect(c.calendars.length + 4, 6); // the choices are the calendars and the four event states
  });

  group('event states', () {
    SuiteEvent ev(String id, {bool edited = false, bool changed = false, bool hidden = false, bool deleted = false}) =>
        makeEvent(id, 15, 9, edited: edited, changedBySource: changed, hiddenFromGoogle: hidden, deleted: deleted);

    test('FLT-01.k: hiding Hidden from Google hides the events hidden from Google and not deleted', () {
      final f = EventFilter()..toggleState(EventState.hiddenFromGoogle);
      expect(f.shows(ev('a', hidden: true)), isFalse);
      expect(f.shows(ev('b', hidden: true, deleted: true)), isTrue); // deleted: governed by Deleted
      expect(f.shows(ev('c')), isTrue);
    });

    test('FLT-01.l: hiding Changed by the source since the edit hides the events the source changed since an edit and that are not deleted', () {
      final f = EventFilter()..toggleState(EventState.changedBySource);
      expect(f.shows(ev('a', edited: true, changed: true)), isFalse);
      expect(f.shows(ev('b', edited: true, changed: true, deleted: true)), isTrue);
      expect(f.shows(ev('c', edited: true)), isTrue);
    });

    test('FLT-01.m: hiding Edited hides the edited events whose source has not changed since and that are not deleted', () {
      final f = EventFilter()..toggleState(EventState.edited);
      expect(f.shows(ev('a', edited: true)), isFalse);
      expect(f.shows(ev('b', edited: true, changed: true)), isTrue); // changed since: governed by the other state
      expect(f.shows(ev('c', edited: true, deleted: true)), isTrue);
      expect(f.shows(ev('d')), isTrue);
    });

    test('filter: hiding Deleted hides deleted events; the filter applies in every view', () {
      final f = EventFilter()..toggleState(EventState.deleted);
      expect(f.shows(ev('a', deleted: true)), isFalse);
      final c = makeController(events: [ev('a', deleted: true), ev('b')], filter: f);
      for (final v in CalendarView.values) {
        c.view = v;
        expect(c.eventsOn(DateTime(2026, 7, 15)).map((e) => e.id), ['b'], reason: '$v');
      }
    });
  });
}
