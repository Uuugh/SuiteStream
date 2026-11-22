import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/time/zones.dart';

void main() {
  setUpAll(initZones);

  final meeting = SuiteEvent.zoned(
    id: 'e1',
    title: 'Meeting',
    year: 2026,
    month: 7,
    day: 10,
    hour: 22,
    minute: 0,
    length: const Duration(hours: 1),
    zone: 'America/New_York',
  );

  test('TIM-01: start and end are stored in UTC with the zone each was recorded in', () {
    expect(meeting.startUtc.isUtc, isTrue);
    expect(meeting.startUtc, DateTime.utc(2026, 7, 11, 2, 0));
    expect(meeting.endUtc, DateTime.utc(2026, 7, 11, 3, 0));
    expect(meeting.startZone, 'America/New_York');
    expect(meeting.endZone, 'America/New_York');
    final stored = SuiteEvent.fromJson(meeting.toJson());
    expect(stored.startUtc, meeting.startUtc);
    expect(stored.endUtc, meeting.endUtc);
    expect(stored.startZone, 'America/New_York');
  });

  test('TIM-02: the zone is set at creation and stays until Edit Event', () {
    expect(zoneForNewEvent(imported: true, systemZone: 'Europe/Paris', sourceZone: 'Asia/Tokyo'), 'Asia/Tokyo');
    expect(zoneForNewEvent(imported: true, systemZone: 'Europe/Paris', calendarZone: 'Asia/Seoul'), 'Asia/Seoul');
    expect(zoneForNewEvent(imported: false, systemZone: 'Europe/Paris'), 'Europe/Paris');
    expect(
        zoneForNewEvent(imported: false, systemZone: 'Europe/Paris', calendarZone: 'America/Denver'), 'America/Denver');
    const local = LocalZone.fixed('Asia/Tokyo', systemZone: 'Europe/Paris');
    local.show(meeting.startUtc);
    expect(meeting.startZone, 'America/New_York');
    final renamed = meeting.withEdits(title: 'Renamed');
    expect(renamed.startZone, 'America/New_York');
    final moved = meeting.withEdits(startZone: 'Europe/London', endZone: 'Europe/London');
    expect(moved.startZone, 'Europe/London');
  });

  test('TIM-03: the calendar shows times in the Local zone; changing it changes only the display', () {
    const system = LocalZone.system('Europe/Paris');
    const fixed = LocalZone.fixed('Asia/Tokyo', systemZone: 'Europe/Paris');
    expect(system.show(meeting.startUtc).hour, 4); // 02:00 UTC in Paris (CEST, +2)
    expect(fixed.show(meeting.startUtc).hour, 11); // Tokyo +9
    expect(fixed.show(meeting.startUtc).day, 11);
    expect(meeting.startUtc, DateTime.utc(2026, 7, 11, 2, 0));
  });

  test('TIM-04: an all-day event runs local midnight to the next local midnight in its own zone', () {
    final day = SuiteEvent.allDay(
        id: 'a1', title: 'Holiday', year: 2026, month: 3, day: 8, zone: 'America/New_York');
    expect(day.allDay, isTrue);
    final start = day.startIn(zoneNamed('America/New_York'));
    final end = day.endIn(zoneNamed('America/New_York'));
    expect([start.hour, start.minute], [0, 0]);
    expect([end.hour, end.minute, end.day], [0, 0, 9]);
    // 8 March 2026 is the US spring-forward day: the event is 23 hours long.
    expect(day.endUtc.difference(day.startUtc), const Duration(hours: 23));
    // In Tokyo it spans two calendar days.
    final tokyoStart = day.startIn(zoneNamed('Asia/Tokyo'));
    final tokyoEnd = day.endIn(zoneNamed('Asia/Tokyo'));
    expect(tokyoStart.day, 8);
    expect(tokyoStart.hour, 14);
    expect(tokyoEnd.day, 9);
    // Sent to a calendar with an all-day type it carries dates for its stored zone.
    expect(day.toIcalTimes(), ['DTSTART;VALUE=DATE:20260308', 'DTEND;VALUE=DATE:20260309']);
  });

  test('TIM-05: rules read the event in its recorded zone, not a viewing zone', () {
    // 22:00 on Friday 10 July in New York is already Saturday in UTC and in Tokyo.
    expect(meeting.recordedWeekday, DateTime.friday);
    expect(meeting.recordedMinuteOfDay, 22 * 60);
    expect(meeting.startUtc.weekday, DateTime.saturday);
    expect(meeting.startIn(zoneNamed('Asia/Tokyo')).weekday, DateTime.saturday);
  });

  test('TIM-06: syncing records incoming zones and sends each event with its zones', () {
    final wire = meeting.toWire();
    expect((wire['start']! as Map)['zone'], 'America/New_York');
    expect((wire['start']! as Map)['utc'], '2026-07-11T02:00:00.000Z');
    final incoming = SuiteEvent.fromWire(wire, defaultZone: 'UTC');
    expect(incoming.startZone, 'America/New_York');
    expect(incoming.startUtc, meeting.startUtc);
  });

  test('TIM-07: calendar feeds carry each time with its zone', () {
    expect(meeting.toIcalTimes(), [
      'DTSTART;TZID=America/New_York:20260710T220000',
      'DTEND;TZID=America/New_York:20260710T230000',
    ]);
  });

  test('TIM-08: an imported event without a zone gets the default zone', () {
    final wire = {
      'id': 'x',
      'title': 'No zone',
      'start': {'utc': '2026-07-11T02:00:00Z'},
      'end': {'utc': '2026-07-11T03:00:00Z', 'zone': ''},
    };
    final e = SuiteEvent.fromWire(wire, defaultZone: 'Europe/Berlin');
    expect(e.startZone, 'Europe/Berlin');
    expect(e.endZone, 'Europe/Berlin');
  });

  test('TIM-10: default 12-hour in a US zone and 24-hour elsewhere; each format is written as shown', () {
    expect(defaultTimeFormat('America/Chicago'), TimeFormat.twelveHour);
    expect(defaultTimeFormat('America/Indiana/Knox'), TimeFormat.twelveHour);
    expect(defaultTimeFormat('Pacific/Honolulu'), TimeFormat.twelveHour);
    expect(defaultTimeFormat('Europe/Paris'), TimeFormat.twentyFourHour);
    expect(defaultTimeFormat('America/Toronto'), TimeFormat.twentyFourHour);
    expect(formatTimeOfDay(13, 30, TimeFormat.twelveHour), '1:30pm');
    expect(formatTimeOfDay(13, 30, TimeFormat.twentyFourHour), '13:30');
    expect(formatTimeOfDay(0, 5, TimeFormat.twelveHour), '12:05am');
    expect(formatTimeOfDay(12, 0, TimeFormat.twelveHour), '12pm');
  });
}
