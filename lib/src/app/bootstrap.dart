import 'package:shared_preferences/shared_preferences.dart';

import '../calendar/calendar_controller.dart';
import '../calendar/event_filter.dart';
import '../calendar/event_store.dart';
import '../calendar/local_calendar_store.dart';
import '../l10n/messages.dart';
import '../time/local_zone.dart';
import '../time/suite_event.dart';
import '../time/time_format.dart';

/// Id of the calendar every installation starts with.
const localCalendarId = 'local';

/// A startup step failed; [step] names it so the error screen can say what broke.
class BootstrapException implements Exception {
  BootstrapException(this.step, this.cause, this.stack);
  final String step;
  final Object cause;
  final StackTrace stack;

  @override
  String toString() => 'Startup failed at "$step": $cause';
}

Future<T> _step<T>(String step, Future<T> Function() body) async {
  try {
    return await body();
  } catch (error, stack) {
    throw BootstrapException(step, error, stack);
  }
}

/// Builds the calendar controller from stored data: no automatic sample events (PBI-041: Settings > Admin adds test data),
/// the silent migration of events without a calendar, and the synthesized
/// work and home calendars. Any failure is thrown as a [BootstrapException].
Future<CalendarController> bootstrapCalendar({
  required SharedPreferences prefs,
  required Messages messages,
  required String zone,
}) async {
  final store = PrefsEventStore(prefs);
  final localCalendarStore = LocalCalendarStore(prefs);
  final savedEvents = await _step('read stored events', () async => store.load());
  final savedCalendars = await _step('read stored calendars', () async => localCalendarStore.load());

  final initialCalendars = [
    SuiteCalendar(id: localCalendarId, name: messages('local'), color: null),
    if (savedEvents.any((event) => event.calendarId == 'work')) const SuiteCalendar(id: 'work', name: 'Work', color: null),
    if (savedEvents.any((event) => event.calendarId == 'home')) const SuiteCalendar(id: 'home', name: 'Home', color: null),
  ];
  final savedDefault = savedCalendars?.defaultId;
  final defaultId = savedCalendars != null && savedCalendars.calendars.any((calendar) => calendar.id == savedDefault)
      ? savedDefault!
      : savedCalendars?.calendars.firstOrNull?.id ?? localCalendarId;

  // Migration: events saved before calendars existed belong to the default calendar.
  if (savedEvents.any((event) => event.custom && event.calendarId == null)) {
    await _step(
      'migrate stored events',
      () => store.save([
        for (final event in savedEvents)
          if (event.custom && event.calendarId == null) event.copyWith(calendarId: defaultId) else event,
      ]),
    );
  }

  return CalendarController(
    store: store,
    prefs: prefs,
    localZone: LocalZone.system(zone),
    timeFormat: defaultTimeFormat(zone),
    filter: EventFilter(prefs: prefs),
    localCalendarStore: localCalendarStore,
    calendars: initialCalendars,
  );
}
