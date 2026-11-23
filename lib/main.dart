import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/calendar/calendar_controller.dart';
import 'src/calendar/calendar_page.dart';
import 'src/calendar/event_filter.dart';
import 'src/calendar/event_store.dart';
import 'src/calendar/local_calendar_store.dart';
import 'src/calendar/settings_dialog.dart';
import 'src/l10n/messages.dart';
import 'src/theme/suite_icons.dart';
import 'src/theme/suite_theme.dart';
import 'src/theme/tokens.dart';
import 'src/time/local_zone.dart';
import 'src/time/suite_event.dart';
import 'src/time/time_format.dart';
import 'src/time/zones.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initZones();
  await initializeDateFormatting();
  var zone = 'UTC';
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    if (isKnownZone(info)) zone = info;
  } catch (_) {
    // Falls back to UTC when the device zone cannot be read.
  }
  final prefs = await SharedPreferences.getInstance();
  // SHL-02.a: the page language follows the device language when it is offered, otherwise English.
  final deviceLanguage = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final messages = await Messages.load(deviceLanguage);

  final now = DateTime.now();
  SuiteEvent sample(String id, String title, int hour, {String? calendarId, bool edited = false, bool hiddenFromGoogle = false}) =>
      SuiteEvent.zoned(
        id: id,
        title: title,
        year: now.year,
        month: now.month,
        day: now.day,
        hour: hour,
        minute: 0,
        length: const Duration(hours: 1),
        zone: zone,
        calendarId: calendarId,
      ).withState(edited: edited, hiddenFromGoogle: hiddenFromGoogle);

  final store = PrefsEventStore(prefs);
  final savedEvents = store.load();
  final localCalendarStore = LocalCalendarStore(prefs);
  const localId = 'local';
  final initialCalendars = [
    SuiteCalendar(id: localId, name: messages('local'), color: null),
    if (savedEvents.any((event) => event.calendarId == 'work'))
      const SuiteCalendar(id: 'work', name: 'Work', color: null),
    if (savedEvents.any((event) => event.calendarId == 'home'))
      const SuiteCalendar(id: 'home', name: 'Home', color: null),
  ];
  final savedCalendars = localCalendarStore.load();
  final savedDefault = savedCalendars?.defaultId;
  final defaultId = savedCalendars != null && savedCalendars.calendars.any((calendar) => calendar.id == savedDefault)
      ? savedDefault!
      : savedCalendars?.calendars.firstOrNull?.id ?? localId;
  if (savedEvents.any((event) => event.custom && event.calendarId == null)) {
    await store.save([
      for (final event in savedEvents)
        if (event.custom && event.calendarId == null) event.copyWith(calendarId: defaultId) else event,
    ]);
  }
  const samplesShownKey = 'demo.samplesShown';
  final showSamples = prefs.getBool(samplesShownKey) != true && savedEvents.isEmpty;
  if (prefs.getBool(samplesShownKey) != true) await prefs.setBool(samplesShownKey, true);
  final controller = CalendarController(
    store: store,
    prefs: prefs,
    localZone: LocalZone.system(zone),
    timeFormat: defaultTimeFormat(zone),
    filter: EventFilter(prefs: prefs),
    localCalendarStore: localCalendarStore,
    calendars: initialCalendars,
    // The first start shows a few sample events; later starts show what the user kept.
    events: !showSamples ? const [] : [
      sample('demo-1', 'Sample event', 10, calendarId: localId),
      sample('demo-2', 'Lunch', 12, calendarId: localId, edited: true),
      sample('demo-3', 'Hidden from Google', 15, calendarId: localId, hiddenFromGoogle: true),
    ],
  );
  runApp(SuiteStreamApp(controller: controller, messages: messages));
}

class SuiteStreamApp extends StatelessWidget {
  const SuiteStreamApp({super.key, required this.controller, required this.messages});

  final CalendarController controller;
  final Messages messages;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuiteStream',
      debugShowCheckedModeBanner: false,
      theme: buildSuiteTheme(Brightness.light),
      darkTheme: buildSuiteTheme(Brightness.dark),
      builder: (context, child) => MessagesScope(messages: messages, child: child!),
      home: ListenableBuilder(
        listenable: controller,
        child: CalendarPage(controller: controller),
        builder: (context, calendar) {
          final t = context.tokens;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: t.scheme.primaryContainer,
              foregroundColor: t.scheme.onPrimaryContainer,
              actions: [
                IconButton(
                  key: const ValueKey('settings-button'),
                  tooltip: context.msg('settings'),
                  style: suiteIconButtonStyle(),
                  icon: const Icon(SuiteIcons.settings),
                  onPressed: () => openSettingsDialog(context, controller),
                ),
              ],
              title: Row(
                children: [
                  Image.asset(
                    t.scheme.brightness == Brightness.dark
                        ? 'assets/images/logo/mark-dark-72.png'
                        : 'assets/images/logo/mark-light-72.png',
                    width: 30,
                    height: 30,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 8),
                  const Text('SuiteStream'),
                ],
              ),
            ),
            body: calendar,
          );
        },
      ),
    );
  }
}
