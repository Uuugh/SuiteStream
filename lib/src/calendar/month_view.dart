import 'package:flutter/material.dart';

import '../l10n/dates.dart';
import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/suite_event.dart';
import '../time/time_format.dart';
import 'calendar_controller.dart';
import 'event_dialog.dart';
import 'event_drag.dart';

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
        // The day a dragged event is over is highlighted (CAL-03).
        color: c.dropTarget?.day == day ? t.runBg : (inMonth ? t.card : t.soft),
      ),
      // Always present (a border only for today or a drop), so the cell keeps its widget
      // structure while an event is dragged over it.
      foregroundDecoration: BoxDecoration(
        border: isToday
            ? Border.all(color: t.accent, width: 2)
            : (c.dropTarget?.day == day ? Border.all(color: t.run, width: 2) : null),
      ),
      padding: const EdgeInsets.all(2),
      // EVT-01.a: clicking a day opens the new-event dialog for that date.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // The start time follows where the click is down the day: the top of the block is
        // midnight, the bottom the end of the day, snapped to the nearest drag step.
        onTapUp: (d) {
          final box = context.findRenderObject() as RenderBox;
          final dy = box.globalToLocal(d.globalPosition).dy;
          final minute = box.size.height <= 0 ? null : (dy / box.size.height * 24 * 60 / dragStepMinutes).round() * dragStepMinutes;
          openEventDialog(context, c, day: day, startMinute: minute?.clamp(0, 24 * 60 - dragStepMinutes));
        },
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
              for (final e in events.take(fit)) _EventLine(event: e, controller: c, day: day, cell: Size(box.maxWidth + 4, box.maxHeight + 4)),
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
      ),
    );
  }
}

class _EventLine extends StatelessWidget {
  const _EventLine({required this.event, required this.controller, required this.day, required this.cell});

  final SuiteEvent event;
  final CalendarController controller;
  final DateTime day;
  final Size cell;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = controller;
    final s = event.startIn(c.localZone.location);
    final text = event.allDay ? event.title : '${formatTimeOfDay(s.hour, s.minute, c.timeFormat)} ${event.title}';
    final color = c.colorOf(event);
    return DragMovable(
      key: ValueKey('event-${event.id}'),
      longPress: c.longPress,
      enabled: canMove(event),
      // While dragging, the day it would land on is highlighted.
      onPreview: (d) {
        if (d == null) {
          c.setDropTarget(null);
          return;
        }
        final cols = (d.dx / cell.width).round();
        final rows = (d.dy / cell.height).round();
        c.setDropTarget(DropTarget(eventId: event.id, day: DateTime(day.year, day.month, day.day + cols + 7 * rows)));
      },
      // CAL-03.c: in Month the event moves to the day it is dropped on and keeps its time.
      onMoved: (d) {
        final cols = (d.dx / cell.width).round();
        final rows = (d.dy / cell.height).round();
        if (cols == 0 && rows == 0) return;
        c.move(event.id, day: DateTime(day.year, day.month, day.day + cols + 7 * rows));
      },
      // EVT-07: clicking an event opens its details in place.
      onTap: () => c.selectEvent(event.id),
      child: SizedBox(
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
      ),
    );
  }
}
