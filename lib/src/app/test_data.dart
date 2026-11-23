import 'package:suitestream/src/theme/event_colors.dart';
import 'package:suitestream/src/time/suite_event.dart';

/// PBI-041: the test calendars Settings > Admin adds and removes. Every id is
/// fixed, so adding twice replaces instead of duplicating, and removing finds
/// exactly these calendars and their events and nothing of the user's.
const String testCalendarIdPrefix = 'test-';

/// Test calendar year and month: November 2026.
const int testDataYear = 2026;
const int testDataMonth = 11;

/// Test calendars (names are sample data, not interface text).
final List<SuiteCalendar> testCalendars = [
  SuiteCalendar(id: 'test-work', name: 'Work', color: calendarPalette[15].argb), // Blue
  SuiteCalendar(id: 'test-family', name: 'Family', color: calendarPalette[7].argb), // Green
  SuiteCalendar(id: 'test-travel', name: 'Travel', color: calendarPalette[11].argb), // Gold
];

/// Ids of the events the first-run sample data created before Sprint 007
/// (calendar 'local', fixed ids). Remove test data deletes them too.
const List<String> legacySampleEventIds = ['demo-1', 'demo-2', 'demo-3'];

bool isTestCalendarId(String? id) => id != null && testCalendars.any((c) => c.id == id);

/// A test event, or an old automatic sample event.
bool isTestEvent(SuiteEvent e) => isTestCalendarId(e.calendarId) || legacySampleEventIds.contains(e.id);

/// The test events: 8 per calendar across November 2026, timed, all-day,
/// multi-day and overlapping, some with reminders, recorded in [zone].
List<SuiteEvent> buildTestEvents(String zone) {
  SuiteEvent timed(String cal, int n, String title, int day, int hour, int minutes,
      {int minute = 0, List<int> reminders = const [], String location = ''}) =>
      SuiteEvent.zoned(
        id: 'test-$cal-$n',
        title: title,
        year: testDataYear,
        month: testDataMonth,
        day: day,
        hour: hour,
        minute: minute,
        length: Duration(minutes: minutes),
        zone: zone,
        calendarId: 'test-$cal',
      ).copyWith(reminders: reminders, location: location);

  SuiteEvent allDay(String cal, int n, String title, int day, {int days = 1, List<int> reminders = const []}) =>
      SuiteEvent.allDay(
        id: 'test-$cal-$n',
        title: title,
        year: testDataYear,
        month: testDataMonth,
        day: day,
        zone: zone,
        days: days,
        calendarId: 'test-$cal',
      ).copyWith(reminders: reminders);

  return [
    // Work
    timed('work', 1, 'Team standup', 2, 9, 30, reminders: [10]),
    timed('work', 2, 'Design review', 4, 10, 90, reminders: [15, 60]),
    timed('work', 3, 'Client call', 4, 11, 60), // overlaps the design review
    allDay('work', 4, 'Quarterly planning', 9, days: 2, reminders: [1440]),
    timed('work', 5, 'Release window', 12, 22, 240, location: 'Online'), // runs past midnight
    timed('work', 6, 'One-on-one', 17, 14, 45, minute: 15, reminders: [5]),
    allDay('work', 7, 'Company holiday', 26),
    timed('work', 8, 'Retro and demo', 30, 15, 120),
    // Family
    timed('family', 1, 'School pickup', 3, 15, 30, reminders: [30]),
    allDay('family', 2, 'Anna birthday', 7, reminders: [1440]),
    timed('family', 3, 'Dinner with grandparents', 8, 18, 120),
    timed('family', 4, 'Soccer practice', 11, 16, 90, reminders: [60]),
    timed('family', 5, 'Movie night', 14, 19, 150),
    allDay('family', 6, 'Weekend at the lake', 21, days: 2),
    allDay('family', 7, 'Thanksgiving', 26),
    timed('family', 8, 'Family call', 4, 11, 60), // overlaps Client call
    // Travel
    allDay('travel', 1, 'Trip to Lisbon', 12, days: 5, reminders: [2880]),
    timed('travel', 2, 'Flight out', 12, 7, 180, minute: 30, reminders: [60, 180]),
    timed('travel', 3, 'Hotel check-in', 12, 14, 60),
    timed('travel', 4, 'City tour', 14, 10, 240),
    timed('travel', 5, 'Train to Porto', 15, 9, 150, minute: 15, reminders: [30]),
    allDay('travel', 6, 'Conference', 18, days: 3),
    timed('travel', 7, 'Flight home', 22, 18, 600, reminders: [180]),
    timed('travel', 8, 'Airport pickup', 23, 6, 60), // overlaps the end of the flight home
  ];
}
