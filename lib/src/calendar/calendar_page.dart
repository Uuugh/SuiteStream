import 'package:flutter/material.dart';

import '../l10n/dates.dart';
import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../ui/suite_dropdown.dart';
import 'calendar_controller.dart';
import 'date_picker.dart';
import 'filter_panel.dart' show CalendarFilterButton;
import 'list_view.dart';
import 'month_view.dart';
import 'swipe_detector.dart';
import 'week_view.dart';

/// CAL-06.c: the view picker's icons.
IconData viewIcon(CalendarView v) => switch (v) {
      CalendarView.month => Icons.calendar_month,
      CalendarView.week => Icons.view_week,
      CalendarView.fiveDay => Icons.view_column,
      CalendarView.day => Icons.view_day,
      CalendarView.list => Icons.view_list,
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
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final t = context.tokens;
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.sectionBorder(SuiteSection.calendar)),
          ),
          child: Column(
            children: [
              _Header(controller: c),
              Divider(height: 1, color: t.line),
              Expanded(
                child: SwipeDetector(
                  onNext: c.next,
                  onPrevious: c.previous,
                  child: switch (c.view) {
                    CalendarView.month => MonthView(controller: c),
                    CalendarView.list => AgendaView(controller: c),
                    _ => HourlyView(controller: c),
                  },
                ),
              ),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 40, top: 4, bottom: 4),
      child: Row(
        children: [
          IconButton(key: const ValueKey('previous'), tooltip: m(prevKey), icon: const Icon(Icons.chevron_left), onPressed: c.previous),
          IconButton(key: const ValueKey('next'), tooltip: m(nextKey), icon: const Icon(Icons.chevron_right), onPressed: c.next),
          TextButton(key: const ValueKey('today'), onPressed: c.goToToday, child: Text(m('today'))),
          const SizedBox(width: 8),
          Flexible(
            child: InkWell(
              key: const ValueKey('title'),
              borderRadius: BorderRadius.circular(6),
              onTap: () => pickDate(context, controller),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  _title(context),
                  overflow: TextOverflow.ellipsis,
                  style: SuiteText.moduleKind(t, windowWidth: MediaQuery.sizeOf(context).width),
                ),
              ),
            ),
          ),
          const Spacer(),
          CalendarFilterButton(controller: c),
          // CAL-06.c: the view picker shows icons; its tooltip names the current view.
          Semantics(
            label: m('viewName'),
            child: SuiteDropdown<CalendarView>(
              icon: viewIcon(c.view),
              tooltip: m('viewTooltip', {'name': viewName}),
              items: [
                for (final v in CalendarView.values)
                  DropdownItem(value: v, label: m(viewMessageKey(v)), icon: viewIcon(v)),
              ],
              selected: {c.view},
              onChanged: (s) => c.view = s.first,
            ),
          ),
        ],
      ),
    );
  }

}
