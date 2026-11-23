import 'dart:convert';

import 'package:flutter/material.dart';

import '../l10n/dates.dart';
import '../l10n/messages.dart';
import '../theme/event_colors.dart';
import '../theme/suite_theme.dart';
import '../time/time_format.dart';
import '../ui/cancel_save_pair.dart';
import '../ui/suite_dialog.dart';
import 'calendar_controller.dart';
import 'calendar_print_platform.dart';

/// CAL-05: preview and print the calendar period selected when Print opens.
Future<void> showCalendarPrint(
  BuildContext context,
  CalendarController controller,
  String title,
) {
  final messages = context.msg;
  final colors = Theme.of(context).colorScheme;
  final sheet = _PrintSheet.fromCalendar(controller, messages, colors, title);
  return showSuiteDialog<void>(
    context: context,
    builder: (_) => _PrintPreview(messages: messages, sheet: sheet),
  );
}

class _PrintPreview extends StatelessWidget {
  const _PrintPreview({required this.messages, required this.sheet});

  final Messages messages;
  final _PrintSheet sheet;

  @override
  Widget build(BuildContext context) {
    final orientation = messages(
      sheet.landscape ? 'calendarPrintLandscape' : 'calendarPrintPortrait',
    );
    return SuiteAlertDialog(
      title: Text(messages('calendarPrintPreview')),
      content: SizedBox(
        width: sheet.landscape ? 780 : 540,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                orientation,
                key: const ValueKey('calendar-print-orientation'),
              ),
            ),
            const SizedBox(height: suitePartGap),
            Flexible(
              child: SingleChildScrollView(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: sheet.colors.surface,
                    border: Border.all(color: sheet.colors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(suiteDialogPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          sheet.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(sheet.zone),
                        const SizedBox(height: suitePartGap),
                        if (sheet.rows.isEmpty) Text(messages('noEvents')),
                        if (sheet.rows.isNotEmpty)
                          Table(
                            border: TableBorder.all(
                              color: sheet.colors.outlineVariant,
                            ),
                            columnWidths: sheet.hourly
                                ? {0: const FixedColumnWidth(60)}
                                : null,
                            children: [
                              for (final row in sheet.rows)
                                TableRow(
                                  children: [
                                    for (final cell in row)
                                      _PrintCellView(
                                        cell: cell,
                                        colors: sheet.colors,
                                      ),
                                  ],
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!calendarPrintingAvailable)
              Padding(
                padding: const EdgeInsets.only(top: suitePartGap),
                child: Text(messages('calendarPrintBrowserOnly')),
              ),
          ],
        ),
      ),
      actions: [
        CancelSavePair(
          cancelLabel: messages('cancel'),
          saveLabel: messages('calendarPrint'),
          onCancel: () => Navigator.of(context).pop(),
          saveEnabled: calendarPrintingAvailable,
          onSave: () => printCalendarHtml(sheet.html(messages)),
        ),
      ],
    );
  }
}

class _PrintCellView extends StatelessWidget {
  const _PrintCellView({required this.cell, required this.colors});

  final _PrintCell cell;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cell.quiet ? colors.surfaceContainerLow : colors.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (cell.label.isNotEmpty)
              Text(
                cell.label,
                style: style?.copyWith(fontWeight: FontWeight.bold),
              ),
            for (final event in cell.events)
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsetsDirectional.only(start: 4),
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(color: event.color, width: 3),
                  ),
                ),
                child: Text.rich(
                  TextSpan(
                    text: event.when.isEmpty ? '' : '${event.when} ',
                    children: [TextSpan(text: event.title)],
                  ),
                  style: style?.copyWith(
                    decoration: event.strike
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PrintEvent {
  const _PrintEvent(
    this.title,
    this.when,
    this.color,
    this.strike,
    this.startHour,
  );

  final String title;
  final String when;
  final Color color;
  final bool strike;
  final int? startHour;
}

class _PrintCell {
  const _PrintCell(this.label, {this.events = const [], this.quiet = false});

  final String label;
  final List<_PrintEvent> events;
  final bool quiet;
}

class _PrintSheet {
  const _PrintSheet(
    this.title,
    this.zone,
    this.landscape,
    this.hourly,
    this.colors,
    this.rows,
  );

  factory _PrintSheet.fromCalendar(
    CalendarController calendar,
    Messages messages,
    ColorScheme colors,
    String title,
  ) {
    final locale = messages.locale;
    final focused = calendar.focused;
    final month = calendar.view == CalendarView.month;
    final list = calendar.view == CalendarView.list;
    final hourly = !month && !list;
    final landscape = switch (calendar.view) {
      CalendarView.month || CalendarView.week || CalendarView.fiveDay => true,
      CalendarView.day || CalendarView.list => false,
    };
    final location = calendar.localZone.location;
    final monthGrid = (start: calendar.monthGridStart, weeks: calendar.monthGridWeeks);
    final first = month
        ? monthGrid.start
        : DateTime(focused.year, focused.month);
    final count = month
        ? monthGrid.weeks * 7
        : DateTime(focused.year, focused.month + 1, 0).day;
    final days = hourly
        ? calendar.hourlyDays
        : [
            for (var i = 0; i < count; i++)
              DateTime(first.year, first.month, first.day + i),
          ];

    final eventsByDay = [
      for (final day in days)
        [
          for (final event in calendar.eventsOn(day))
            _PrintEvent(
              event.title,
              month
                  ? ''
                  : event.allDay
                  ? list
                        ? messages('allDay')
                        : ''
                  : '${_eventTime(event.startIn(location), calendar.timeFormat)} – '
                        '${_eventTime(event.endIn(location), calendar.timeFormat)}',
              Color(calendar.colorOf(event) ?? defaultEventColor),
              event.deleted || event.hiddenFromGoogle,
              event.allDay
                  ? null
                  : event.startIn(location).day == day.day &&
                        event.startIn(location).month == day.month &&
                        event.startIn(location).year == day.year
                  ? event.startIn(location).hour
                  : 0,
            ),
        ],
    ];

    final rows = <List<_PrintCell>>[];
    if (month) {
      rows.add([
        for (final day in days.take(7))
          _PrintCell(weekdayAbbreviation(locale, day), quiet: true),
      ]);
      for (var i = 0; i < days.length; i += 7) {
        rows.add([
          for (var j = i; j < i + 7; j++)
            _PrintCell(
              '${days[j].day}',
              events: eventsByDay[j],
              quiet: days[j].month != focused.month,
            ),
        ]);
      }
    } else if (list) {
      for (var i = 0; i < days.length; i++) {
        if (eventsByDay[i].isNotEmpty) {
          rows.add([
            _PrintCell(dayTitle(locale, days[i]), events: eventsByDay[i]),
          ]);
        }
      }
    } else {
      rows.add([
        const _PrintCell('', quiet: true),
        for (final day in days)
          _PrintCell(
            '${weekdayAbbreviation(locale, day)} ${day.day}',
            quiet: true,
          ),
      ]);
      rows.add([
        _PrintCell(messages('allDay'), quiet: true),
        for (final events in eventsByDay)
          _PrintCell(
            '',
            events: events.where((event) => event.startHour == null).toList(),
          ),
      ]);
      final activeHours = {
        for (final events in eventsByDay)
          for (final event in events)
            if (event.startHour != null) event.startHour!,
      };
      if (activeHours.isEmpty) {
        rows.add([
          const _PrintCell(''),
          for (final events in eventsByDay)
            _PrintCell(events.isEmpty ? messages('noEvents') : ''),
        ]);
      }
      for (final hour in activeHours.toList()..sort()) {
        rows.add([
          _PrintCell(
            formatTimeOfDay(hour, 0, calendar.timeFormat),
            quiet: true,
          ),
          for (final events in eventsByDay)
            _PrintCell(
              '',
              events: events.where((event) => event.startHour == hour).toList(),
            ),
        ]);
      }
    }

    return _PrintSheet(
      title,
      messages('timesIn', {'tz': calendar.localZone.name}),
      landscape,
      hourly,
      colors,
      rows,
    );
  }

  final String title;
  final String zone;
  final bool landscape;
  final bool hourly;
  final ColorScheme colors;
  final List<List<_PrintCell>> rows;

  String html(Messages messages) {
    final e = const HtmlEscape().convert;
    final orientation = landscape ? 'landscape' : 'portrait';
    final paper = messages.locale == 'en' ? 'letter' : 'A4';
    final body = StringBuffer();
    for (final row in rows) {
      body.write('<tr>');
      for (final cell in row) {
        body.write('<td${cell.quiet ? ' class="quiet"' : ''}>');
        if (cell.label.isNotEmpty) body.write('<b>${e(cell.label)}</b>');
        for (final event in cell.events) {
          final type = event.strike ? 'event strike' : 'event';
          body.write(
            '<div class="$type" style="border-color:${_cssColor(event.color)}">'
            '${e(event.when)} ${e(event.title)}</div>',
          );
        }
        body.write('</td>');
      }
      body.write('</tr>');
    }
    return '''
<!doctype html>
<html lang="${e(messages.locale)}">
<head>
<meta charset="utf-8">
<title>${e(title)}</title>
<style>
@page { size: $paper $orientation; margin: 5mm; }
html { print-color-adjust: exact; -webkit-print-color-adjust: exact; }
body { margin: 0; padding: 8px; font: 12px system-ui, sans-serif;
  background: ${_cssColor(colors.surface)}; color: ${_cssColor(colors.onSurface)}; }
h1 { margin: 0; font-size: 18px; }
p { margin: 4px 0 8px; }
table { width: 100%; table-layout: fixed; border-collapse: collapse; }
td { border: 1px solid ${_cssColor(colors.outlineVariant)}; padding: 4px;
  vertical-align: top; overflow-wrap: anywhere; }
${hourly ? 'td:first-child { width: 60px; }' : ''}
.quiet { background: ${_cssColor(colors.surfaceContainerLow)}; }
.event { margin-top: 3px; padding-inline-start: 4px; border-inline-start: 3px solid; }
.strike { text-decoration: line-through; }
tr { break-inside: avoid; }
</style>
</head>
<body>
<h1>${e(title)}</h1><p>${e(zone)}</p>
${rows.isEmpty ? '<p>${e(messages('noEvents'))}</p>' : '<table><tbody>$body</tbody></table>'}
</body>
</html>
''';
  }
}

String _eventTime(DateTime value, TimeFormat format) =>
    formatTimeOfDay(value.hour, value.minute, format);

String _cssColor(Color color) {
  final rgb = (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  return '#$rgb';
}
