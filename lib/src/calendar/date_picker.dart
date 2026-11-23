import 'package:flutter/material.dart';

import '../theme/suite_icons.dart';
import '../l10n/dates.dart';
import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/theme_settings.dart';
import '../ui/suite_dialog.dart';
import '../theme/tokens.dart';
import 'calendar_controller.dart';

/// Opens the date picker over the calendar and applies the choice.
Future<void> pickDate(BuildContext context, CalendarController c) async {
  final msgs = context.msg;
  final picked = await showSuiteDialog<(int, int, int?)>(
    context: context,
    builder: (_) => MessagesScope(
      messages: msgs,
      child: DatePickerDialog(focused: c.focused, today: c.today),
    ),
  );
  if (picked == null) return;
  if (picked.$3 != null) {
    c.goToDate(DateTime(picked.$1, picked.$2, picked.$3!)); // a day: that date
  } else {
    c.goToMonth(picked.$1, picked.$2); // CAL-01.p: a month: its 1st, or today
  }
}

enum _PickerMode { days, months, years }

/// UIC-09, CAL-01.t: the date picker is a small month calendar that opens on the
/// displayed month; picking a day goes to that date and closes it. Its title
/// opens the month list (CAL-01.s) and the year in that list opens the year list.
class DatePickerDialog extends StatefulWidget {
  const DatePickerDialog({super.key, required this.focused, required this.today});
  final DateTime focused;
  final DateTime today;

  @override
  State<DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  late int _year = widget.focused.year;
  late int _month = widget.focused.month;
  _PickerMode _mode = _PickerMode.days;

  static const double _width = 280;

  /// The weekday row and six weeks of days.
  static const double gridHeight = 28 + 6 * 36;

  void _shiftMonth(int by) => setState(() {
        final d = DateTime(_year, _month + by);
        _year = d.year;
        _month = d.month;
      });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    // SET-03.i: the Date picker size setting scales the whole picker (100 % = as designed).
    final scale = ThemeSettingsScope.of(context).datePicker / 100;
    Widget scaled(Widget child) => scale == 1
        ? SizedBox(width: _width, child: child)
        : SizedBox(width: _width * scale, child: FittedBox(fit: BoxFit.fitWidth, child: SizedBox(width: _width, child: child)));
    return Dialog(
      backgroundColor: t.card,
      child: Padding(
        padding: const EdgeInsets.all(suiteDialogPadding),
        child: scaled(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_mode == _PickerMode.days) _daysHeader(t, m) else _yearHeader(t, m),
              // Days, months and years are one size (selecting a view only shows or hides things;
              // a popup is not resized once drawn).
              SizedBox(
                height: gridHeight,
                child: switch (_mode) {
                  _PickerMode.days => _dayGrid(t, m.locale),
                  _PickerMode.months => _monthGrid(t, m.locale),
                  _PickerMode.years => _yearGrid(t),
                },
              ),
              Visibility(
                visible: _mode == _PickerMode.days,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const ValueKey('picker-today'),
                    onPressed: () => Navigator.of(context).pop((widget.today.year, widget.today.month, widget.today.day)),
                    child: Text(m('today')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Days mode: previous and next month around the month title.
  Widget _daysHeader(SuiteTokens t, Messages m) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            key: const ValueKey('picker-prev-month'),
            tooltip: m('previousMonth'),
            icon: const Icon(SuiteIcons.chevronLeft),
            onPressed: () => _shiftMonth(-1),
          ),
          Expanded(
            child: TextButton(
              key: const ValueKey('picker-title'),
              onPressed: () => setState(() => _mode = _PickerMode.months),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(monthYearTitle(m.locale, DateTime(_year, _month)), style: SuiteText.label(t)),
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('picker-next-month'),
            tooltip: m('nextMonth'),
            icon: const Icon(SuiteIcons.chevronRight),
            onPressed: () => _shiftMonth(1),
          ),
        ],
      );

  /// CAL-01.r: the year row has previous and next year buttons; the year opens the year list.
  Widget _yearHeader(SuiteTokens t, Messages m) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            key: const ValueKey('year-prev'),
            tooltip: m('previousYear'),
            icon: const Icon(SuiteIcons.chevronLeft),
            onPressed: () => setState(() => _year--),
          ),
          TextButton(
            key: const ValueKey('year-title'),
            onPressed: () => setState(() => _mode = _mode == _PickerMode.years ? _PickerMode.months : _PickerMode.years),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$_year', style: SuiteText.label(t)),
                Icon(_mode == _PickerMode.years ? SuiteIcons.arrowDropUp : SuiteIcons.arrowDropDown),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('year-next'),
            tooltip: m('nextYear'),
            icon: const Icon(SuiteIcons.chevronRight),
            onPressed: () => setState(() => _year++),
          ),
        ],
      );

  Widget _dayGrid(SuiteTokens t, String locale) {
    final first = DateTime(_year, _month);
    final lead = first.weekday % 7; // weeks start on Sunday
    final count = DateTime(_year, _month + 1, 0).day;
    const rows = 6; // always six weeks, so every month is the same size
    const cell = _width / 7;
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              SizedBox(
                width: cell,
                height: 28,
                child: Center(
                  child: Text(weekdayAbbreviation(locale, DateTime(2026, 7, 12 + i)), style: SuiteText.note(t)),
                ),
              ),
          ],
        ),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++) _dayCell(t, r * 7 + c - lead + 1, count, cell),
            ],
          ),
      ],
    );
  }

  Widget _dayCell(SuiteTokens t, int day, int count, double cell) {
    if (day < 1 || day > count) return SizedBox(width: cell, height: 36);
    final date = DateTime(_year, _month, day);
    final isToday = date == widget.today;
    final isFocused = date == widget.focused;
    return SizedBox(
      width: cell,
      height: 36,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: TextButton(
          key: ValueKey('pick-day-$day'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            backgroundColor: isFocused ? t.accent : null,
            foregroundColor: isFocused ? t.onAccent : t.text,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: isToday ? BorderSide(color: t.accent, width: 2) : BorderSide.none,
            ),
          ),
          onPressed: () => Navigator.of(context).pop((_year, _month, day)),
          child: Text('$day'),
        ),
      ),
    );
  }

  Widget _monthGrid(SuiteTokens t, String locale) => Wrap(
        children: [
          for (var mo = 1; mo <= 12; mo++)
            SizedBox(
              width: _width / 4 - 1,
              child: TextButton(
                key: ValueKey('month-$mo'),
                // The displayed year and month are marked.
                style: (_year == widget.focused.year && mo == widget.focused.month)
                    ? TextButton.styleFrom(backgroundColor: t.accent, foregroundColor: t.onAccent)
                    : null,
                onPressed: () => setState(() {
                  _month = mo;
                  _mode = _PickerMode.days; // back down to the days of that month
                }),
                child: Text(monthAbbreviation(locale, mo)),
              ),
            ),
        ],
      );

  Widget _yearGrid(SuiteTokens t) {
    const cols = 4;
    final rowOfYear = (_year.clamp(firstSupportedYear, lastSupportedYear) - firstSupportedYear) ~/ cols;
    return SizedBox(
      key: const ValueKey('year-grid'),
      height: gridHeight,
      child: GridView.count(
        crossAxisCount: cols,
        childAspectRatio: 1.6,
        controller: ScrollController(initialScrollOffset: rowOfYear * (_width / cols / 1.6)),
        children: [
          for (var y = firstSupportedYear; y <= lastSupportedYear; y++)
            TextButton(
              key: ValueKey('year-$y'),
              style: y == _year ? TextButton.styleFrom(backgroundColor: t.accent, foregroundColor: t.onAccent) : null,
              onPressed: () => setState(() {
                _year = y;
                _mode = _PickerMode.months;
              }),
              child: Text('$y'),
            ),
        ],
      ),
    );
  }
}

/// Picks one date with the date picker (used by the event dialog's date fields).
/// Picking a month alone gives the 1st of that month.
Future<DateTime?> pickDay(BuildContext context, {required DateTime initial, required DateTime today}) async {
  final msgs = context.msg;
  final picked = await showSuiteDialog<(int, int, int?)>(
    context: context,
    builder: (_) => MessagesScope(messages: msgs, child: DatePickerDialog(focused: initial, today: today)),
  );
  if (picked == null) return null;
  return DateTime(picked.$1, picked.$2, picked.$3 ?? 1);
}
