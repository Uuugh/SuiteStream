
import 'package:flutter/material.dart';

import 'package:suitestream/src/l10n/dates.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/event_colors.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/tokens.dart';
import 'package:suitestream/src/time/suite_event.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/event_dialog.dart';
import 'package:suitestream/src/calendar/event_drag.dart';

/// Height of one event line in a day cell, and of the date number's row.
const double monthLineHeight = 20;
const double monthDateRowHeight = 24;
const double minMonthGridWidth = 640;

/// CAL-01.a, CAL-01.i: the Month view.
class MonthView extends StatelessWidget {
  const MonthView({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final locale = context.msg.locale;
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= minMonthGridWidth) {
          return _grid(context, locale);
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: minMonthGridWidth,
            height: box.maxHeight,
            child: _grid(context, locale),
          ),
        );
      },
    );
  }

  Widget _grid(BuildContext context, String locale) {
    final t = context.tokens;
    final c = controller;
    final start = c.monthGridStart;
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
        Expanded(child: _MonthWeeks(controller: c, start: start)),
      ],
    );
  }
}

class _MonthWeeks extends StatelessWidget {
  const _MonthWeeks({required this.controller, required this.start});

  final CalendarController controller;
  final DateTime start;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var w = 0; w < controller.monthGridWeeks; w++)
          Expanded(
            child: Row(
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: _DayCell(
                      controller: controller,
                      day: DateTime(start.year, start.month, start.day + w * 7 + d),
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
          final fit = events.length <= lines
              ? events.length
              : (lines - 1).clamp(0, events.length);
          final hidden = events.length - fit;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  key: isToday ? const ValueKey('today-marker') : null,
                  height: monthDateRowHeight - 4,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: isToday
                      ? BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(suiteChipRadius))
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
          return content;
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
    final en = event.endIn(c.localZone.location);
    // CAL-09.c: a multi-day event shows 18:00- on its first day, -04:00 on its last and cont. between.
    final label = event.allDay
        ? null
        : multiDayLabel(start: s, end: en, day: day, format: c.timeFormat, cont: context.msg('cont')) ?? formatTimeOfDay(s.hour, s.minute, c.timeFormat);
    final text = label == null ? event.title : '$label ${event.title}';
    final color = c.colorOf(event);
    final muted = event.deleted || event.hiddenFromGoogle;
    final base = muted ? t.muted : Color(color ?? defaultEventColor);
    final chipFill = base; // EVT-03.b: the chip fills with the event's own color
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
      // A chip in the event's own color (its calendar's, else the theme's default event
      // color); a deleted or hidden event is muted and struck through.
      child: SizedBox(
        height: monthLineHeight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: chipFill,
            borderRadius: BorderRadius.circular(suiteChipRadius),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SuiteText.note(t).copyWith(
              color: eventTextColorOn(chipFill, Theme.of(context).brightness),
              decoration: muted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }
}
