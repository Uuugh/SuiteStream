
import 'package:flutter/material.dart';

import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/l10n/dates.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/theme_mode_controller.dart';
import 'package:suitestream/src/theme/tokens.dart';
import 'package:suitestream/src/time/time_format.dart';
import 'package:suitestream/src/ui/anchored_badge.dart';
import 'package:suitestream/src/ui/overflow_info.dart';
import 'package:suitestream/src/ui/suite_dropdown.dart';
import 'package:suitestream/src/ui/zone_picker.dart';
import 'package:suitestream/src/ui/zoned_row.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_print_dialog.dart';
import 'package:suitestream/src/calendar/date_picker.dart';
import 'package:suitestream/src/calendar/event_details.dart';
import 'package:suitestream/src/calendar/event_dialog.dart';
import 'package:suitestream/src/calendar/filter_panel.dart' show CalendarFilterButton;
import 'package:suitestream/src/calendar/list_view.dart';
import 'package:suitestream/src/calendar/month_view.dart';
import 'package:suitestream/src/calendar/swipe_detector.dart';
import 'package:suitestream/src/calendar/week_view.dart';

/// Room a header keeps for a short title before its zones stack (UIC-14). TODO: token in suite_theme.dart (Tanaka).
const double _shortTitleWidth = 160;

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

/// UIC-45 / UIC-14: the back button in the left zone of a page header (Settings).
/// It leaves the page; the caller saves before it pops.
class HeaderBackButton extends StatelessWidget {
  const HeaderBackButton({super.key, required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) => IconButton(
        key: const ValueKey('header-back'),
        tooltip: tooltip,
        style: suiteIconButtonStyle(),
        icon: const Icon(SuiteIcons.arrowBack),
        onPressed: onPressed,
      );
}

/// A page header with the back button first in the left zone, then the title; the right
/// zone is optional. Same zones and padding as the calendar header (UIC-14).
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.onBack, required this.backTooltip, this.right = const []});

  final Widget title;
  final VoidCallback onBack;
  final String backTooltip;
  final List<Widget> right;

  @override
  Widget build(BuildContext context) => ZonedRow(
        left: [
          HeaderBackButton(onPressed: onBack, tooltip: backTooltip),
          const SizedBox(width: suitePartGap),
          Flexible(child: title),
        ],
        right: right,
        leftMinWidth: suiteControlHeight * 2 + _shortTitleWidth, // back button and a short title
        rightMinWidth: suiteControlHeight * right.length,
      );
}

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
          margin: const EdgeInsets.fromLTRB(suitePagePadding, suitePartGap, suitePagePadding, suitePagePadding),
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(suitePanelRadius),
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
    return calendar;
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
      const SizedBox(width: suitePartGap),
      Flexible(
        child: InkWell(
          key: const ValueKey('title'),
          borderRadius: BorderRadius.circular(suiteChipRadius),
          onTap: () => pickDate(context, controller),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: suiteLabelGap),
            child: OverflowInfoText(
              _title(context),
              style: SuiteText.moduleKind(t, windowWidth: MediaQuery.sizeOf(context).width),
            ),
          ),
        ),
      ),
    ];
    // CAL-06.a: the right zone holds Time Zone, View and the 12/24 clock, in this order.
    // CAL-06.e: 12-hour is a filled badge; 24-hour inverts it (outlined, accent text).
    final inverted = c.timeFormat == TimeFormat.twentyFourHour;
    final right = <Widget>[
      CalendarFilterButton(controller: c),
      IconButton(
        key: const ValueKey('zone-button'),
        style: suiteIconButtonStyle(),
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
        style: suiteIconButtonStyle(),
        tooltip: '${m('timeFormat')}: ${c.timeFormat == TimeFormat.twelveHour ? m('m12Hour130pm') : m('m24Hour1330')}',
        icon: AnchoredBadge(
          badge: Container(
            key: const ValueKey('clock-badge'),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: inverted ? t.onAccent : t.accent,
              border: Border.all(color: t.accent),
              borderRadius: BorderRadius.circular(suiteChipRadius),
            ),
            child: Text(
              c.timeFormat == TimeFormat.twelveHour ? '12' : '24',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: inverted ? t.accent : t.onAccent),
            ),
          ),
          child: const Icon(SuiteIcons.schedule, size: 24),
        ),
        onPressed: () => c.timeFormat = c.timeFormat == TimeFormat.twelveHour ? TimeFormat.twentyFourHour : TimeFormat.twelveHour,
      ),
      // SHL-03.b: Light / Dark / Match system is one icon, a menu like the view picker.
      if (ThemeModeScope.maybeOf(context) case final themeController?)
        Semantics(
          label: m('themeName'),
          child: SuiteDropdown<ThemeMode>(
            key: const ValueKey('theme-menu'),
            icon: ThemeModeIcons.of(themeController.mode),
            tooltip: m('themeTooltip', {'name': m(themeModeMessageKey(themeController.mode))}),
            items: [
              for (final mode in ThemeMode.values)
                DropdownItem(value: mode, label: m(themeModeMessageKey(mode)), icon: ThemeModeIcons.of(mode)),
            ],
            selected: {themeController.mode},
            onChanged: (s) => themeController.mode = s.first,
          ),
        ),
      IconButton(
        key: const ValueKey('calendar-print-button'),
        style: suiteIconButtonStyle(),
        tooltip: m('calendarPrint'),
        icon: const Icon(SuiteIcons.print),
        onPressed: () => showCalendarPrint(context, c, _title(context)),
      ),
      // CAL-06.a: + comes last: it adds an event on the day the calendar is on.
      IconButton(
        key: const ValueKey('add-event-button'),
        style: suiteIconButtonStyle(),
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
      leftMinWidth: suiteControlHeight * 5 + _shortTitleWidth, // previous, next, Today and a short title (UIC-14)
      rightMinWidth: suiteControlHeight * right.length,
    );
  }
}
