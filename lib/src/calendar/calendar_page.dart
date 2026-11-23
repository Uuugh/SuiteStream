import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/suite_icons.dart';
import '../l10n/dates.dart';
import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/time_format.dart';
import '../ui/anchored_badge.dart';
import '../ui/overflow_info.dart';
import '../ui/resize_bar.dart';
import '../ui/suite_dropdown.dart';
import '../ui/zone_picker.dart';
import '../ui/zoned_row.dart';
import 'calendar_controller.dart';
import 'calendar_print_dialog.dart';
import 'date_picker.dart';
import 'event_details.dart';
import 'event_dialog.dart';
import 'filter_panel.dart' show CalendarFilterButton;
import 'list_view.dart';
import 'month_view.dart';
import 'swipe_detector.dart';
import 'week_view.dart';

/// CAL-06.c: the view picker's icons.
IconData viewIcon(CalendarView v) => switch (v) {
      CalendarView.month => SuiteIcons.calendarMonth,
      CalendarView.week => SuiteIcons.viewWeek,
      CalendarView.fiveDay => SuiteIcons.viewColumn,
      CalendarView.day => SuiteIcons.viewDay,
      CalendarView.list => SuiteIcons.viewList,
    };

String viewMessageKey(CalendarView v) => switch (v) {
      CalendarView.month => 'viewMonth',
      CalendarView.week => 'viewWeek',
      CalendarView.fiveDay => 'viewFiveDay',
      CalendarView.day => 'viewDay',
      CalendarView.list => 'viewList',
    };

/// The calendar section: header, the chosen view and the filter legend.
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    // CAL-01.f: the starting view depends on the window width.
    c.layout(phone: MediaQuery.sizeOf(context).width <= phoneMaxWidth);
    return EventDetailsHost(
      controller: c,
      child: ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final t = context.tokens;
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.line),
          ),
          child: Column(
            children: [
              _Header(controller: c),
              Divider(height: 1, color: t.line),
              Expanded(child: _CalendarBody(controller: c)),
            ],
          ),
        );
      },
      ),
    );
  }
}

class _CalendarBody extends StatelessWidget {
  const _CalendarBody({required this.controller});


  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final m = context.msg;
    final calendar = SwipeDetector(
      holdTime: c.longPress,
      onNext: c.next,
      onPrevious: c.previous,
      child: switch (c.view) {
        CalendarView.month => MonthView(controller: c),
        CalendarView.list => AgendaView(controller: c),
        _ => HourlyView(controller: c),
      },
    );
    final showResize = c.view != CalendarView.list;
    final month = c.view == CalendarView.month;
    final unit = month ? monthLineHeight : eventLineHeight;
    final minimumHeight = month
        ? 32.0 + c.monthGridWeeks * (monthDateRowHeight + 2 * monthLineHeight)
        : 260.0; // 200 px hourly grid plus the date and all-day rows.
    final barHeight = math.max(48.0, suiteControlHeight);
    return LayoutBuilder(
      builder: (context, box) {
        final usableHeight = box.maxHeight;
        final fit = math.max(
          0,
          ((usableHeight - minimumHeight - barHeight) / unit).floor(),
        );
        final chosen = c.calendarHeightLines;
        final displayed = chosen ?? fit;
        final height = !showResize
            ? usableHeight
            : chosen == null
                ? math.max(minimumHeight, usableHeight - barHeight)
                : minimumHeight + chosen * unit;
        final panel = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: height, child: calendar),
            if (showResize)
              SizedBox(
                height: barHeight,
                child: ResizeBar(
                  key: const ValueKey('calendar-resize'),
                  value: displayed,
                  minimum: 0,
                  unitExtent: unit,
                  onChanged: (value) => c.calendarHeightLines = value,
                  expanded: displayed > 0,
                  onToggle: () => c.calendarHeightLines = displayed > 0 ? 0 : fit,
                  sliderLabel: m('stretchCalendar'),
                  collapseLabel: m('collapseCalendar'),
                  expandLabel: m('expandCalendar'),
                ),
              ),
          ],
        );
        return SingleChildScrollView(
          primary: false,
          physics: showResize ? null : const NeverScrollableScrollPhysics(),
          child: panel,
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final CalendarController controller;

  String _title(BuildContext context) {
    final c = controller;
    final locale = context.msg.locale;
    switch (c.view) {
      case CalendarView.day:
        return dayTitle(locale, c.focused);
      case CalendarView.week:
        return dateRange(locale, c.weekStart, c.weekEnd);
      case CalendarView.fiveDay:
        final d = c.hourlyDays;
        return dateRange(locale, d.first, d.last);
      case CalendarView.month:
      case CalendarView.list:
        return monthYearTitle(locale, c.focused);
    }
  }

  /// CAL-01.n: previous and next name the step of the view.
  (String, String) _stepKeys() => switch (controller.view) {
        CalendarView.day => ('previousDay', 'nextDay'),
        CalendarView.week || CalendarView.fiveDay => ('previousWeek', 'nextWeek'),
        _ => ('previousMonth', 'nextMonth'),
      };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = controller;
    final m = context.msg;
    final (prevKey, nextKey) = _stepKeys();
    final viewName = m(viewMessageKey(c.view));
    // UIC-14: left, center and right zones; CAL-01.l: previous, next, Today, then the title.
    final left = <Widget>[
      IconButton(
        key: const ValueKey('previous'),
        tooltip: m(prevKey),
        style: suiteIconButtonStyle(),
        icon: const Icon(SuiteIcons.chevronLeft),
        onPressed: c.previous,
      ),
      IconButton(
        key: const ValueKey('next'),
        tooltip: m(nextKey),
        style: suiteIconButtonStyle(),
        icon: const Icon(SuiteIcons.chevronRight),
        onPressed: c.next,
      ),
      TextButton(key: const ValueKey('today'), onPressed: c.goToToday, child: Text(m('today'))),
      const SizedBox(width: 8),
      Flexible(
        child: InkWell(
          key: const ValueKey('title'),
          borderRadius: BorderRadius.circular(6),
          onTap: () => pickDate(context, controller),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: OverflowInfoText(
              _title(context),
              style: SuiteText.moduleKind(t, windowWidth: MediaQuery.sizeOf(context).width),
            ),
          ),
        ),
      ),
    ];
    // CAL-06.a: the right zone holds Time Zone, View and the 12/24 clock, in this order.
    final right = <Widget>[
      CalendarFilterButton(controller: c),
      IconButton(
        key: const ValueKey('zone-button'),
        style: suiteIconButtonStyle(compact: true),
        tooltip: m('timesIn', {'tz': c.localZone.name}),
        icon: Icon(SuiteIcons.public, color: c.viewZone == null ? null : t.accent),
        onPressed: () async {
          final picked = await pickZone(context, current: c.localZone.name, defaultZone: c.baseZone.name);
          if (picked == null) return;
          // UIC-39: choosing the default clears the stored choice.
          c.viewZone = picked == c.baseZone.name ? null : picked;
        },
      ),
      // CAL-06.c: the view picker shows icons; its tooltip names the current view.
      Semantics(
        label: m('viewName'),
        child: SuiteDropdown<CalendarView>(
          icon: viewIcon(c.view),
          tooltip: m('viewTooltip', {'name': viewName}),
          items: [
            for (final v in CalendarView.values) DropdownItem(value: v, label: m(viewMessageKey(v)), icon: viewIcon(v)),
          ],
          selected: {c.view},
          onChanged: (s) => c.view = s.first,
        ),
      ),
      // CAL-06.e: one clock icon with the current format as a badge; it sets 12-hour or
      // 24-hour and never returns to the default.
      IconButton(
        key: const ValueKey('clock-button'),
        style: suiteIconButtonStyle(compact: true),
        tooltip: '${m('timeFormat')}: ${c.timeFormat == TimeFormat.twelveHour ? m('m12Hour130pm') : m('m24Hour1330')}',
        icon: AnchoredBadge(
          badge: Container(
            key: const ValueKey('clock-badge'),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(6)),
            child: Text(
              c.timeFormat == TimeFormat.twelveHour ? '12' : '24',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: t.onAccent),
            ),
          ),
          child: const Icon(SuiteIcons.schedule, size: 24),
        ),
        onPressed: () => c.timeFormat = c.timeFormat == TimeFormat.twelveHour ? TimeFormat.twentyFourHour : TimeFormat.twelveHour,
      ),
      IconButton(
        key: const ValueKey('calendar-print-button'),
        style: suiteIconButtonStyle(compact: true),
        tooltip: m('calendarPrint'),
        icon: const Icon(SuiteIcons.print),
        onPressed: () => showCalendarPrint(context, c, _title(context)),
      ),
      // CAL-06.a: + comes last: it adds an event on the day the calendar is on.
      IconButton(
        key: const ValueKey('add-event-button'),
        style: suiteIconButtonStyle(compact: true),
        tooltip: m('addEvent'),
        icon: const Icon(SuiteIcons.add),
        onPressed: () => openEventDialog(context, c, day: c.focused),
      ),
    ];
    // The header has a left, a center and a right zone (UIC-14): the dates and their
    // navigation stay left, the buttons are in the right zone (CAL-06.a), flush right.
    // When the line is too narrow the zones stack: left on top, then right.
    return ZonedRow(
      left: left,
      right: right,
      leftMinWidth: 48 + 48 + 80 + 8 + 160, // previous, next, Today, gap, a short title
      rightMinWidth: 48.0 * right.length,
    );
  }
}
