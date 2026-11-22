import 'package:flutter/material.dart';

import '../l10n/dates.dart';
import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/suite_event.dart';
import '../time/time_format.dart';
import 'calendar_controller.dart';

/// Height of one event line in a day cell, and of the date number's row.
const double monthLineHeight = 16;
const double monthDateRowHeight = 24;

/// CAL-01.a, CAL-01.i: the Month view.
class MonthView extends StatelessWidget {
  const MonthView({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = controller;
    final locale = context.msg.locale;
    final start = c.monthGridStart;
    final weeks = c.monthGridWeeks;
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    weekdayAbbreviation(locale, DateTime(start.year, start.month, start.day + i)),
                    textAlign: TextAlign.center,
                    style: SuiteText.note(t),
                  ),
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

    // THM-04.e: today's day is marked with a 2 px accent outline, not a border.
    return Container(
      key: ValueKey('day-${day.year}-${day.month}-${day.day}'),
      decoration: BoxDecoration(
        border: Border.all(color: t.line, width: 0.5),
        color: inMonth ? t.card : t.soft,
      ),
      foregroundDecoration: isToday ? BoxDecoration(border: Border.all(color: t.accent, width: 2)) : null,
      padding: const EdgeInsets.all(2),
      child: LayoutBuilder(
        builder: (context, box) {
          // CAL-01.g: the cell shows how many of its visible events do not fit.
          final lines = ((box.maxHeight - 4 - monthDateRowHeight) / monthLineHeight).floor();
          final fit = events.length <= lines ? events.length : (lines - 1).clamp(0, events.length);
          final hidden = events.length - fit;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  key: isToday ? const ValueKey('today-marker') : null,
                  height: monthDateRowHeight - 4,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: isToday
                      ? BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(10))
                      : null,
                  child: Text(
                    '${day.day}',
                    style: SuiteText.label(t).copyWith(color: isToday ? t.onAccent : (inMonth ? t.text : t.muted)),
                  ),
                ),
              ),
              for (final e in events.take(fit)) _EventLine(event: e, controller: c),
              if (hidden > 0)
                SizedBox(
                  key: ValueKey('more-${day.year}-${day.month}-${day.day}'),
                  height: monthLineHeight,
                  child: Text(context.msg('moreEvents', {'n': hidden}), style: SuiteText.note(t)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EventLine extends StatelessWidget {
  const _EventLine({required this.event, required this.controller});

  final SuiteEvent event;
  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = controller;
    final s = event.startIn(c.localZone.location);
    final text = event.allDay ? event.title : '${formatTimeOfDay(s.hour, s.minute, c.timeFormat)} ${event.title}';
    final color = c.colorOf(event);
    return SizedBox(
      height: monthLineHeight,
      child: Row(
        children: [
          if (color != null)
            Container(width: 3, height: 12, margin: const EdgeInsets.only(right: 3), color: Color(color)),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SuiteText.note(t).copyWith(
                color: t.text,
                decoration: event.deleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
