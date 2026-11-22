import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/event_filter.dart';
import 'package:suitestream/src/calendar/event_store.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/time/local_zone.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/time_format.dart';

const zone = 'America/New_York';

Map<String, dynamic> arb(String code) =>
    jsonDecode(File('requirements/messages/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;

Messages messagesFor(String locale) => Messages.fromMaps(locale, arb(locale), arb('en'));

const calendars = [
  SuiteCalendar(id: 'work', name: 'Work', color: 0xFF5B6F9A),
  SuiteCalendar(id: 'home', name: 'Home', color: 0xFF2A9D8F),
];

/// Wednesday 15 July 2026, noon in New York.
CalendarController makeController({
  List<SuiteEvent> events = const [],
  CalendarView? view,
  DateTime? focused,
  List<SuiteCalendar> cals = calendars,
  EventFilter? filter,
  EventStore? store,
}) =>
    CalendarController(
      localZone: const LocalZone.system(zone),
      timeFormat: TimeFormat.twelveHour,
      events: events,
      calendars: cals,
      view: view,
      focused: focused,
      filter: filter,
      store: store,
      clock: () => DateTime.utc(2026, 7, 15, 16),
    );

SuiteEvent makeEvent(
  String id,
  int day,
  int hour, {
  int minutes = 60,
  String? title,
  String? calendarId,
  bool edited = false,
  bool changedBySource = false,
  bool hiddenFromGoogle = false,
  bool deleted = false,
}) =>
    SuiteEvent.zoned(
      id: id,
      title: title ?? 'Event $id',
      year: 2026,
      month: 7,
      day: day,
      hour: hour,
      minute: 0,
      length: Duration(minutes: minutes),
      zone: zone,
      calendarId: calendarId,
    ).withState(edited: edited, changedBySource: changedBySource, hiddenFromGoogle: hiddenFromGoogle, deleted: deleted);

Widget appFor(Widget child, {Size size = const Size(1000, 800), String locale = 'en'}) => MaterialApp(
      theme: buildSuiteTheme(Brightness.light),
      builder: (context, c) => MessagesScope(messages: messagesFor(locale), child: c!),
      home: Scaffold(body: SizedBox(width: size.width, height: size.height, child: child)),
    );

void useWindow(WidgetTester tester, [Size size = const Size(1000, 800)]) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Whether a field is hidden (kept in the layout but not shown), as all-day hides the times.
bool isHidden(WidgetTester tester, String key) {
  final v = find.ancestor(of: find.byKey(ValueKey(key)), matching: find.byType(Visibility));
  if (v.evaluate().isEmpty) return false;
  return !tester.widget<Visibility>(v.first).visible;
}
