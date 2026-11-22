import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'src/calendar/calendar_controller.dart';
import 'src/calendar/calendar_page.dart';
import 'src/theme/suite_theme.dart';
import 'src/theme/tokens.dart';
import 'src/time/local_zone.dart';
import 'src/time/suite_event.dart';
import 'src/time/time_format.dart';
import 'src/time/zones.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initZones();
  var zone = 'UTC';
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    if (isKnownZone(info)) zone = info;
  } catch (_) {
    // Falls back to UTC when the device zone cannot be read.
  }
  final now = DateTime.now();
  final controller = CalendarController(
    localZone: LocalZone.system(zone),
    timeFormat: defaultTimeFormat(zone),
    events: [
      SuiteEvent.zoned(
        id: 'demo-1',
        title: 'Sample event',
        year: now.year,
        month: now.month,
        day: now.day,
        hour: 10,
        minute: 0,
        length: const Duration(hours: 1),
        zone: zone,
      ),
    ],
  );
  runApp(SuiteStreamApp(controller: controller));
}

class SuiteStreamApp extends StatelessWidget {
  const SuiteStreamApp({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuiteStream',
      debugShowCheckedModeBanner: false,
      theme: buildSuiteTheme(Brightness.light),
      darkTheme: buildSuiteTheme(Brightness.dark),
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
