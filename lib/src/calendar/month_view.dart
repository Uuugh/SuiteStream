import 'package:flutter/material.dart';

import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/time_format.dart';
import 'calendar_controller.dart';

const List<String> weekdayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

/// CAL-01.a, CAL-01.i: the Month view.
class MonthView extends StatelessWidget {
  const MonthView({super.key, required this.controller});

  final CalendarController controller;

  static const int maxVisibleEvents = 3;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = controller;
    final start = c.monthGridStart;
    final weeks = c.monthGridWeeks;
    return Column(
      children: [
        Row(
          children: [
            for (final n in weekdayNames)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(n, textAlign: TextAlign.center, style: SuiteText.note(t)),
                ),
              ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              for (var w = 0; w < weeks; w++)
                Expanded(
                  child: Row(
                    children: [
                      for (var d = 0; d < 7; d++)
                        Expanded(
                          child: _DayCell(
                            controller: c,
                            day: DateTime(start.year, start.month, start.day + w * 7 + d),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.controller, required this.day});

  final CalendarController controller;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = controller;
    final isToday = day == c.today;
    final inMonth = day.month == c.focused.month;
    final events = c.eventsOn(day);
    final shown = events.take(MonthView.maxVisibleEvents).toList();
    final hidden = events.length - shown.length;
    final loc = c.localZone;

    // THM-04.e: today's day is marked with a 2 px accent outline, not a border.
    return Container(
      key: ValueKey('day-${day.year}-${day.month}-${day.day}'),
      decoration: BoxDecoration(
        border: Border.all(color: t.line, width: 0.5),
        color: inMonth ? t.card : t.soft,
      ),
      foregroundDecoration: isToday
          ? BoxDecoration(border: Border.all(color: t.accent, width: 2))
          : null,
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              key: isToday ? const ValueKey('today-marker') : null,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: isToday
                  ? BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(10))
                  : null,
              child: Text(
                '${day.day}',
                style: SuiteText.label(t).copyWith(
                  color: isToday ? t.onAccent : (inMonth ? t.text : t.muted),
                ),
              ),
            ),
          ),
          for (final e in shown)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                e.allDay
                    ? e.title
                    : '${_start(e, loc.location, c.timeFormat)} ${e.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SuiteText.note(t).copyWith(color: t.text),
              ),
            ),
          if (hidden > 0)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text('+$hidden more', style: SuiteText.note(t)),
            ),
        ],
      ),
    );
  }

  String _start(dynamic e, dynamic location, TimeFormat f) {
    final s = e.startIn(location);
    return formatTimeOfDay(s.hour, s.minute, f);
  }
}
