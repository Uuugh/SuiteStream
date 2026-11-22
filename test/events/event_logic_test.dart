import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/calendar/event_dialog.dart';
import 'package:suitestream/src/calendar/event_details.dart';
import 'package:suitestream/src/calendar/event_store.dart';
import 'package:suitestream/src/theme/event_palette.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/time_input.dart';
import 'package:suitestream/src/time/zones.dart';

import '../calendar/test_support.dart';

void main() {
  setUpAll(() async {
    initZones();
    await initializeDateFormatting();
  });

  test('EVT-02.l: a typed time may be written 9:30, 9.30, 9h30, 930, 21:30, 2130, 9 pm, 9:30pm or 9:30 p.m.', () {
    const nine30 = TimeOfDayValue(9, 30);
    for (final s in ['9:30', '9.30', '9h30', '930', '09:30', '9:30am', '9:30 am', '9:30 a.m.']) {
      expect(parseTimeInput(s), nine30, reason: s);
    }
    for (final s in ['21:30', '2130', '9:30pm', '9:30 pm', '9:30 p.m.', '9.30pm']) {
      expect(parseTimeInput(s), const TimeOfDayValue(21, 30), reason: s);
    }
    expect(parseTimeInput('9 pm'), const TimeOfDayValue(21, 0));
    expect(parseTimeInput('9'), const TimeOfDayValue(9, 0)); // a bare hour means that hour and :00
    expect(parseTimeInput('21'), const TimeOfDayValue(21, 0));
    expect(parseTimeInput('12am'), const TimeOfDayValue(0, 0));
    expect(parseTimeInput('12pm'), const TimeOfDayValue(12, 0));
    expect(parseTimeInput('1:30 pm'), const TimeOfDayValue(13, 30));
    expect(parseTimeInput('1505'), const TimeOfDayValue(15, 5));
    // An am or pm hour is 1 to 12.
    expect(parseTimeInput('0am'), isNull);
    expect(parseTimeInput('13pm'), isNull);
  });

  test('EVT-02.l: anything that is not a time gives no time', () {
    for (final s in ['', 'abc', '25:00', '9:60', '99', '12345', '9:5', '9::30']) {
      expect(parseTimeInput(s), isNull, reason: s);
    }
  });

  test('EVT-03.e: a reminder is from the event start back to the longest lead, at most five, only valid ones stored', () {
    expect(longestReminderLead, 10080); // 1 week
    expect(normalizeReminders([15, 60, 20000]), [15, 60]); // past the longest lead
    expect(normalizeReminders([15, 60, 7]), [7, 15, 60]); // any whole number of minutes up to it
    expect(normalizeReminders([-5, 30]), [30]);
    expect(normalizeReminders([]), isEmpty);
    expect(normalizeReminders([60, 15, 15, 0]), [0, 15, 60]);
    expect(normalizeReminders([0, 5, 10, 15, 30, 60, 120]).length, remindersPerEvent);
    expect(normalizeReminders([0, 5, 10, 15, 30, 60, 120]), [0, 5, 10, 15, 30]);
    expect(normalizeReminders([10080]), [10080]);
    expect(normalizeReminders([10081]), isEmpty);
  });

  test('a reminder is shown in the largest unit it is a whole number of', () {
    expect(splitReminder(0), (0, ReminderUnit.minutes));
    expect(splitReminder(15), (15, ReminderUnit.minutes));
    expect(splitReminder(90), (90, ReminderUnit.minutes));
    expect(splitReminder(60), (1, ReminderUnit.hours));
    expect(splitReminder(120), (2, ReminderUnit.hours));
    expect(splitReminder(1440), (1, ReminderUnit.days));
    expect(splitReminder(2880), (2, ReminderUnit.days));
    expect(splitReminder(10080), (1, ReminderUnit.weeks));
  });

  test('EVT-03.l: a reminder reads at the start, N min before, 1 hour, N hours, 1 day, N days or 1 week before', () {
    final m = messagesFor('en');
    expect(reminderLabel(m, 0), 'at the start');
    expect(reminderLabel(m, 5), '5 min before');
    expect(reminderLabel(m, 30), '30 min before');
    expect(reminderLabel(m, 60), '1 hour before');
    expect(reminderLabel(m, 120), '2 hours before');
    expect(reminderLabel(m, 1440), '1 day before');
    expect(reminderLabel(m, 2880), '2 days before');
    expect(reminderLabel(m, 10080), '1 week before');
  });

  test('EVT-03.a: the map link has the URL-encoded location as its address', () {
    final u = mapUrl('10 Main St & 5th, New York');
    expect(u.host, 'www.google.com');
    expect(u.queryParameters['query'], '10 Main St & 5th, New York');
    expect(u.toString(), contains('10%20Main%20St%20%26%205th%2C%20New%20York'));
  });

  test('EVT-01.p: the online meeting address is empty or an http(s) link with no spaces', () {
    expect(isValidMeetingUrl(''), isTrue);
    expect(isValidMeetingUrl('https://meet.example.com/abc?x=1'), isTrue);
    expect(isValidMeetingUrl('http://x.example'), isTrue);
    expect(isValidMeetingUrl('ftp://x.example'), isFalse);
    expect(isValidMeetingUrl('https://x.example/a b'), isFalse);
    expect(isValidMeetingUrl('meet.example.com'), isFalse);
  });

  test('THM-09.a: the event palette is Google Calendar\'s eleven colors', () {
    expect(eventPalette.length, 11);
    expect([for (final p in eventPalette) p.name], [
      'Tomato', 'Flamingo', 'Tangerine', 'Banana', 'Sage', 'Basil', 'Peacock', 'Blueberry', 'Lavender', 'Grape', 'Graphite',
    ]);
    expect([for (final p in eventPalette) p.value], [
      0xFFD50000, 0xFFE67C73, 0xFFF4511E, 0xFFF6BF26, 0xFF33B679, 0xFF0B8043, 0xFF039BE5, 0xFF3F51B5, 0xFF7986CB, 0xFF8E24AA, 0xFF616161,
    ]);
  });

  test('THM-09.b: the default event color is #1d4ed8', () {
    expect(defaultEventColor, 0xFF1D4ED8);
  });

  test('EVT-03.i: an event\'s color is its own, else its rule\'s, else its calendar\'s, else the default', () {
    expect(resolveEventColor(own: 1, rule: 2, calendar: 3), 1);
    expect(resolveEventColor(rule: 2, calendar: 3), 2);
    expect(resolveEventColor(calendar: 3), 3);
    expect(resolveEventColor(), defaultEventColor);
    final c = makeController(events: [
      makeEvent('a', 15, 9, calendarId: 'work').copyWith(color: 0xFFD50000),
      makeEvent('b', 15, 9, calendarId: 'work'),
      makeEvent('c', 15, 9),
    ]);
    expect(c.colorOf(c.events[0]), 0xFFD50000);
    expect(c.colorOf(c.events[1]), 0xFF5B6F9A);
    expect(c.colorOf(c.events[2]), isNull);
  });

  test('palette: a color not in the shared palette is represented by the nearest palette color', () {
    expect(nearestPaletteColor(0xFFD50000), 0xFFD50000);
    expect(nearestPaletteColor(0xFFD20505), 0xFFD50000); // near Tomato
    expect(nearestPaletteColor(0xFF606060), 0xFF616161); // near Graphite
  });

  test('CAP-02: a custom event can be deleted and the deletion undone; an event of a source can only be hidden and shown', () {
    final custom = makeEvent('mine', 15, 9);
    final imported = makeEvent('theirs', 15, 10).copyWith(custom: false);
    final c = makeController(events: [custom, imported]);
    expect(c.deleteEvent('theirs'), isFalse); // never deleted
    expect(c.events.map((e) => e.id), containsAll(['mine', 'theirs']));
    c.setHidden('theirs', true);
    expect(c.events.firstWhere((e) => e.id == 'theirs').hiddenFromGoogle, isTrue);
    c.setHidden('theirs', false);
    expect(c.events.firstWhere((e) => e.id == 'theirs').hiddenFromGoogle, isFalse);
    expect(c.canUndoDelete, isFalse);
    expect(c.deleteEvent('mine'), isTrue);
    expect(c.events.map((e) => e.id), ['theirs']);
    expect(c.canUndoDelete, isTrue);
    expect(c.undoDelete(), isTrue);
    expect(c.events.map((e) => e.id), containsAll(['mine', 'theirs']));
    expect(c.undoDelete(), isFalse);
  });

  test('TIM-01: events are kept on the device in UTC with their zones and read back whole', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = PrefsEventStore(prefs);
    final e = makeEvent('x', 15, 22, calendarId: 'work').copyWith(
      location: 'Office',
      notes: 'Bring slides',
      color: 0xFF33B679,
      reminders: [15, 60],
      meetingUrl: 'https://meet.example.com/x',
    );
    await store.save([e]);
    final back = PrefsEventStore(await SharedPreferences.getInstance()).load().single;
    expect(back.startUtc, e.startUtc);
    expect(back.startZone, zone);
    expect([back.location, back.notes, back.color, back.reminders, back.meetingUrl, back.calendarId],
        ['Office', 'Bring slides', 0xFF33B679, [15, 60], 'https://meet.example.com/x', 'work']);
  });

  test('TIM-01: an unreadable store starts empty', () async {
    SharedPreferences.setMockInitialValues({'events.v1': 'not json'});
    expect(PrefsEventStore(await SharedPreferences.getInstance()).load(), isEmpty);
  });

  test('a controller with a store keeps every change at once', () async {
    final store = MemoryEventStore([makeEvent('old', 15, 9)]);
    final withStore = makeController(store: store);
    expect(withStore.events.map((e) => e.id), ['old']);
    withStore.upsertEvent(makeEvent('new', 16, 9));
    expect(store.load().map((e) => e.id), ['old', 'new']);
    withStore.deleteEvent('old');
    expect(store.load().map((e) => e.id), ['new']);
    withStore.undoDelete();
    expect(store.load().map((e) => e.id), ['new', 'old']);
  });

  test('EVT-07.b: the range text is "day, start–end" for one day and "day start – day end" across days; all-day shows its days', () {
    final m = messagesFor('en');
    final loc = zoneNamed(zone);
    final oneDay = makeEvent('a', 15, 10);
    expect(eventRangeText(m, oneDay, loc, TimeFormat.twelveHour), 'Wed, Jul 15, 10:00 am–11:00 am');
    expect(eventRangeText(m, oneDay, loc, TimeFormat.twentyFourHour), 'Wed, Jul 15, 10:00–11:00');
    final overnight = makeEvent('b', 15, 22, minutes: 180);
    expect(eventRangeText(m, overnight, loc, TimeFormat.twelveHour), 'Wed, Jul 15 10:00 pm – Thu, Jul 16 01:00 am');
    final allDay = SuiteEvent.allDay(id: 'c', title: 'Day', year: 2026, month: 7, day: 15, zone: zone);
    expect(eventRangeText(m, allDay, loc, TimeFormat.twelveHour), 'Wed, Jul 15 (all day)');
    final span = SuiteEvent.allDay(id: 'd', title: 'Trip', year: 2026, month: 7, day: 15, zone: zone, days: 3);
    expect(eventRangeText(m, span, loc, TimeFormat.twelveHour), 'Wed, Jul 15 – Fri, Jul 17 (all day)');
  });
}
