import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/calendar/calendar_controller.dart';
import 'src/calendar/calendar_page.dart';
import 'src/calendar/event_filter.dart';
import 'src/l10n/messages.dart';
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

  final controller = CalendarController(
    localZone: LocalZone.system(zone),
    timeFormat: defaultTimeFormat(zone),
    filter: EventFilter(prefs: prefs),
    calendars: const [
      SuiteCalendar(id: 'work', name: 'Work', color: 0xFF5B6F9A),
      SuiteCalendar(id: 'home', name: 'Home', color: 0xFF2A9D8F),
    ],
    events: [
      sample('demo-1', 'Sample event', 10, calendarId: 'work'),
      sample('demo-2', 'Lunch', 12, calendarId: 'home', edited: true),
      sample('demo-3', 'Hidden from Google', 15, calendarId: 'work', hiddenFromGoogle: true),
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
      home: Builder(
        builder: (context) {
          final t = context.tokens;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: t.card,
              title: Text.rich(TextSpan(children: [
                TextSpan(text: 'Suite', style: TextStyle(color: t.titleCalendar, fontWeight: FontWeight.w700)),
                TextSpan(text: 'Stream', style: TextStyle(color: t.titleStream, fontWeight: FontWeight.w700)),
              ])),
            ),
            body: CalendarPage(controller: controller),
          );
        },
      ),
    );
  }
}
