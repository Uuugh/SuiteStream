import 'package:flutter/material.dart';

import '../l10n/dates.dart';
import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/time_format.dart';
import 'calendar_controller.dart';

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
      rows.add(Container(
        key: ValueKey('list-day-${day.day}'),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Text(
          dayTitle(locale, day),
          style: SuiteText.label(t).copyWith(color: isToday ? t.accent : t.text),
        ),
      ));
      for (final e in events) {
        final s = e.startIn(c.localZone.location);
        final en = e.endIn(c.localZone.location);
        final when = e.allDay
            ? context.msg('allDay')
            : '${formatTimeOfDay(s.hour, s.minute, c.timeFormat)} – ${formatTimeOfDay(en.hour, en.minute, c.timeFormat)}';
        final color = c.colorOf(e);
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Row(
            children: [
              Container(width: 4, height: 18, margin: const EdgeInsets.only(right: 8), color: color == null ? t.run : Color(color)),
              SizedBox(width: 120, child: Text(when, style: SuiteText.note(t))),
              Expanded(
                child: Text(
                  e.title,
                  overflow: TextOverflow.ellipsis,
                  style: SuiteText.body(t).copyWith(decoration: e.deleted ? TextDecoration.lineThrough : null),
                ),
              ),
            ],
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
