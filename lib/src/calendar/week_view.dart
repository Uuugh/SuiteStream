import 'package:flutter/material.dart';

import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/suite_event.dart';
import '../time/time_format.dart';
import '../time/zones.dart';
import 'calendar_controller.dart';
import 'event_dialog.dart';
import 'event_drag.dart';
import '../l10n/dates.dart';
import '../l10n/messages.dart';
import 'week_layout.dart';

/// DEF-01: the hourly grid starts at the first event, or at 7 am.
const int defaultScrollStartHour = 7;

/// DEF-01: the hour height is 2 event lines by default.
const double eventLineHeight = 20;
const int defaultHourLines = 2;
const double hourHeight = eventLineHeight * defaultHourLines;

/// CAL-01.h: the hour the grid scrolls to: the hour of the first timed event in
/// [days], or [defaultScrollStartHour] when there is none.
int scrollStartHour(CalendarController c, List<DateTime> days) {
  int? first;
  for (final d in days) {
    for (final e in c.eventsOn(d)) {
      if (e.allDay) continue;
      final s = _minutesOn(e, c, d).$1;
      if (first == null || s < first) first = s;
    }
  }
  return first == null ? defaultScrollStartHour : first ~/ 60;
}

/// An event's start and end as minutes of the day [d] in the Local zone,
/// clipped to that day.
(int, int) _minutesOn(SuiteEvent e, CalendarController c, DateTime d) {
  final loc = c.localZone.location;
  final dayStart = TZDateTime(loc, d.year, d.month, d.day);
  final s = e.startIn(loc);
  final en = e.endIn(loc);
  final startMin = s.isBefore(dayStart) ? 0 : s.hour * 60 + s.minute;
  final dayEnd = TZDateTime(loc, d.year, d.month, d.day + 1);
  final endMin = en.isAfter(dayEnd) ? 24 * 60 : en.hour * 60 + en.minute;
  return (startMin, endMin == 0 && en.isAfter(s) ? 24 * 60 : endMin);
}

/// CAL-01.h: the hourly views (Week, 5-day, Day): an hourly grid, all-day events above.
class HourlyView extends StatefulWidget {
  const HourlyView({super.key, required this.controller});

  final CalendarController controller;

  @override
  State<HourlyView> createState() => _HourlyViewState();
}

class _HourlyViewState extends State<HourlyView> {
  late ScrollController _scroll;
  String? _shown;

  List<DateTime> get _days => widget.controller.hourlyDays;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController(initialScrollOffset: _offset());
    _shown = _signature();
  }

  String _signature() => _days.map((d) => d.toIso8601String()).join(",");

  double _offset() => scrollStartHour(widget.controller, _days) * hourHeight;

  @override
  void didUpdateWidget(HourlyView old) {
    super.didUpdateWidget(old);
    final w = _signature();
    if (w != _shown) {
      _shown = w;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(_offset().clamp(0, _scroll.position.maxScrollExtent));
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = widget.controller;
    final days = _days;
    const gutter = 68.0;
    final allDay = [for (final d in days) c.eventsOn(d).where((e) => e.allDay).toList()];
    final maxAllDay = allDay.fold<int>(0, (m, l) => l.length > m ? l.length : m);

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: gutter),
            for (final d in days)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  child: Container(
                    key: d == c.today ? const ValueKey('today-marker') : null,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: d == c.today
                        ? BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12))
                        : null,
                    child: Text(
                      '${weekdayAbbreviation(context.msg.locale, d)} ${d.day}',
                      style: SuiteText.label(t).copyWith(color: d == c.today ? t.onAccent : t.text),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // The all-day row is always there: clicking an empty cell adds an all-day event.
        if (maxAllDay >= 0)
          Container(
            key: const ValueKey('all-day-row'),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.line))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: gutter, child: Text(context.msg('allDay'), textAlign: TextAlign.center, style: SuiteText.note(t))),
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: GestureDetector(
                      key: ValueKey('allday-slot-${days[i].year}-${days[i].month}-${days[i].day}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => openEventDialog(context, c, day: days[i], allDay: true),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 24),
                        child: Column(
                      children: [
                        for (final e in allDay[i])
                          GestureDetector(
                            key: ValueKey('event-${e.id}'),
                            onTap: () => c.selectEvent(e.id), // EVT-07
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              width: double.infinity,
                              color: t.runBg,
                              child: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: SuiteText.note(t).copyWith(color: t.run)),
                            ),
                          ),
                      ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            key: const ValueKey('hour-grid'),
            controller: _scroll,
            child: SizedBox(
              height: hourHeight * 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: gutter,
                    child: Stack(
                      children: [
                        for (var h = 1; h < 24; h++)
                          Positioned(
                            top: h * hourHeight - 8,
                            left: 0,
                            right: 6,
                            child: Text(
                              formatTimeOfDay(h, 0, c.timeFormat),
                              textAlign: TextAlign.right,
                              style: SuiteText.note(t),
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (final d in days) Expanded(child: _DayColumn(controller: c, day: d)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({required this.controller, required this.day});

  final CalendarController controller;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = controller;
    final timed = c.eventsOn(day).where((e) => !e.allDay).toList();
    final placed = layoutOverlaps<SuiteEvent>(timed, (e) => _minutesOn(e, c, day));
    return LayoutBuilder(
      builder: (context, box) {
        // Clicking an empty spot opens the new-event dialog at that time (EVT-01.a).
        return GestureDetector(
          key: ValueKey('slot-${day.year}-${day.month}-${day.day}'),
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            final minute = (d.localPosition.dy / hourHeight * 60 / dragStepMinutes).floor() * dragStepMinutes;
            openEventDialog(context, c, day: day, startMinute: minute.clamp(0, 24 * 60 - dragStepMinutes));
          },
          child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: t.line, width: 0.5))),
          child: Stack(
            children: [
              for (var h = 1; h < 24; h++)
                Positioned(
                  top: h * hourHeight,
                  left: 0,
                  right: 0,
                  child: Divider(height: 0.5, thickness: 0.5, color: t.line),
                ),
              // The drop preview: where a dragged event would land (CAL-03.b).
              if (c.dropTarget != null && c.dropTarget!.minute != null && c.dropTarget!.day == day)
                Positioned(
                  key: const ValueKey('drop-preview'),
                  top: c.dropTarget!.minute! / 60 * hourHeight,
                  height: (c.events.where((e) => e.id == c.dropTarget!.eventId).map((e) => e.endUtc.difference(e.startUtc).inMinutes).firstOrNull ?? 60) / 60 * hourHeight,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.run.withValues(alpha: 0.18),
                        border: Border.all(color: t.run, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        formatTimeOfDay(c.dropTarget!.minute! ~/ 60, c.dropTarget!.minute! % 60, c.timeFormat),
                        style: SuiteText.note(t).copyWith(color: t.run, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              for (final p in placed)
                Positioned(
                  key: ValueKey('event-${p.event.id}'),
                  top: p.startMinute / 60 * hourHeight,
                  height: ((p.endMinute - p.startMinute) / 60 * hourHeight).clamp(16, double.infinity),
                  left: box.maxWidth * p.column / p.columns,
                  width: box.maxWidth / p.columns - 1,
                  child: DragMovable(
                    longPress: c.longPress,
                    enabled: canMove(p.event),
                    // While dragging, a snapped outline shows where the event would land.
                    onPreview: (d) {
                      if (d == null) {
                        c.setDropTarget(null);
                        return;
                      }
                      final dayShift = (d.dx / box.maxWidth).round();
                      final minute = snapToDragStep(p.startMinute + d.dy / hourHeight * 60).clamp(0, 24 * 60 - dragStepMinutes);
                      c.setDropTarget(DropTarget(
                        eventId: p.event.id,
                        day: DateTime(day.year, day.month, day.day + dayShift),
                        minute: minute,
                      ));
                    },
                    // CAL-03.b: in Week and Day the start snaps to the drag step in DEF-01.
                    onMoved: (d) {
                      final dayShift = (d.dx / box.maxWidth).round();
                      final minute = snapToDragStep(p.startMinute + d.dy / hourHeight * 60).clamp(0, 24 * 60 - dragStepMinutes);
                      if (dayShift == 0 && minute == p.startMinute) return;
                      c.move(p.event.id, day: DateTime(day.year, day.month, day.day + dayShift), minuteOfDay: minute);
                    },
                    onTap: () => c.selectEvent(p.event.id), // EVT-07
                    child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: t.runBg,
                      border: Border(left: BorderSide(color: c.colorOf(p.event) == null ? t.run : Color(c.colorOf(p.event)!), width: 3)),
                    ),
                    child: Text(
                      '${formatTimeOfDay(p.startMinute ~/ 60, p.startMinute % 60, c.timeFormat)} ${p.event.title}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: SuiteText.note(t).copyWith(color: t.text),
                    ),
                  ),
                  ),
                ),
            ],
          ),
          ),
        );
      },
    );
  }
}
