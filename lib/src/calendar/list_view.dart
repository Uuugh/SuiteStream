import 'package:flutter/material.dart';

import 'package:suitestream/src/l10n/dates.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/event_colors.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/tokens.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/event_dialog.dart';

/// CAL-01.b: the List view: the events of the focused month, a day at a time.
class AgendaView extends StatelessWidget {
  const AgendaView({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = controller;
    final locale = context.msg.locale;
    final first = DateTime(c.focused.year, c.focused.month);
    final days = DateTime(c.focused.year, c.focused.month + 1, 0).day;
    final rows = <Widget>[];
    for (var d = 0; d < days; d++) {
      final day = DateTime(first.year, first.month, first.day + d);
      final events = c.eventsOn(day);
      if (events.isEmpty) continue;
      final isToday = day == c.today;
      // Clicking a day's title adds an event on that day.
      rows.add(InkWell(
        key: ValueKey('list-day-${day.day}'),
        onTap: () => openEventDialog(context, c, day: day),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Text(
            dayTitle(locale, day),
            style: SuiteText.label(t).copyWith(color: isToday ? t.accent : t.text),
          ),
        ),
      ));
      for (final e in events) {
        final s = e.startIn(c.localZone.location);
        final en = e.endIn(c.localZone.location);
        final when = e.allDay
            ? context.msg('allDay')
            : multiDayLabel(start: s, end: en, day: day, format: c.timeFormat, cont: context.msg('cont')) ??
                formatTimeOfDay(s.hour, s.minute, c.timeFormat); // CAL-09.c: the start only
        final color = c.colorOf(e);
        final fill = Color(color ?? defaultEventColor);
        final ink = eventTextColorOn(fill, Theme.of(context).brightness);
        rows.add(InkWell(
          key: ValueKey('event-${e.id}'),
          onTap: () => c.selectEvent(e.id), // EVT-07
          // EVT-03.b: the row fills with the event's own color; text readable on it (THM-10.h).
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: fill,
            child: Row(
              children: [
                SizedBox(width: 120, child: Text(when, style: SuiteText.note(t).copyWith(color: ink))),
                Expanded(
                  child: Text(
                    e.title,
                    overflow: TextOverflow.ellipsis,
                    style: SuiteText.body(t).copyWith(color: ink, decoration: e.deleted ? TextDecoration.lineThrough : null),
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    }
    if (rows.isEmpty) {
      return Center(child: Text(context.msg('noEventsThisMonth'), style: SuiteText.note(t)));
    }
    return ListView(key: const ValueKey('list-view'), children: rows);
  }
}
