import 'package:flutter/material.dart';

import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../ui/suite_dropdown.dart';
import 'calendar_controller.dart';
import 'month_view.dart';
import 'week_view.dart';

const List<String> monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// CAL-01.b: the views offered today.
const List<DropdownItem<CalendarView>> _viewItems = [
  DropdownItem(value: CalendarView.month, label: 'Month', icon: Icons.calendar_month),
  DropdownItem(value: CalendarView.week, label: 'Week', icon: Icons.view_week),
];

IconData _viewIcon(CalendarView v) => v == CalendarView.week ? Icons.view_week : Icons.calendar_month;

/// The calendar section: header and the chosen view.
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final t = context.tokens;
        final c = controller;
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
                child: switch (c.view) {
                  CalendarView.week => WeekView(controller: c),
                  _ => MonthView(controller: c),
                },
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

  String get _title {
    final c = controller;
    if (c.view == CalendarView.week) {
      final s = c.weekStart;
      final e = c.weekEnd;
      final a = '${monthNames[s.month - 1].substring(0, 3)} ${s.day}';
      final b = s.month == e.month
          ? '${e.day}'
          : '${monthNames[e.month - 1].substring(0, 3)} ${e.day}';
      return '$a – $b, ${e.year}';
    }
    return '${monthNames[c.focused.month - 1]} ${c.focused.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = controller;
    // UIC-14: left, center and right zones; CAL-01.l: previous, next, Today, then the title.
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 40, top: 4, bottom: 4),
      child: Row(
        children: [
          IconButton(key: const ValueKey('previous'), tooltip: 'Previous', icon: const Icon(Icons.chevron_left), onPressed: c.previous),
          IconButton(key: const ValueKey('next'), tooltip: 'Next', icon: const Icon(Icons.chevron_right), onPressed: c.next),
          TextButton(key: const ValueKey('today'), onPressed: c.goToToday, child: const Text('Today')),
          const SizedBox(width: 8),
          Flexible(
            child: InkWell(
              key: const ValueKey('title'),
              borderRadius: BorderRadius.circular(6),
              onTap: () => _pickMonth(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(_title, overflow: TextOverflow.ellipsis, style: SuiteText.moduleKind(t, windowWidth: MediaQuery.sizeOf(context).width)),
              ),
            ),
          ),
          const Spacer(),
          SuiteDropdown<CalendarView>(
            icon: _viewIcon(c.view),
            tooltip: 'View',
            items: _viewItems,
            selected: {c.view},
            onChanged: (s) => c.view = s.first,
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final c = controller;
    final picked = await showDialog<(int, int)>(
      context: context,
      builder: (_) => _MonthPicker(year: c.focused.year, month: c.focused.month),
    );
    if (picked != null) c.goToMonth(picked.$1, picked.$2);
  }
}

/// CAL-01.d: a small month picker; picking a month closes it.
class _MonthPicker extends StatefulWidget {
  const _MonthPicker({required this.year, required this.month});
  final int year;
  final int month;

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  late int _year = widget.year;
  bool _choosingYear = false;

  /// DEF-01: supported calendar years, 2000 to 2100.
  static const int firstYear = 2000;
  static const int lastYear = 2100;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Dialog(
      backgroundColor: t.card,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(key: const ValueKey('year-prev'), icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _year--)),
                  // Clicking the year opens the list of years to choose from.
                  TextButton(
                    key: const ValueKey('year-title'),
                    onPressed: () => setState(() => _choosingYear = !_choosingYear),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$_year', style: SuiteText.label(t)),
                        Icon(_choosingYear ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  IconButton(key: const ValueKey('year-next'), icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _year++)),
                ],
              ),
              if (_choosingYear) _yearGrid(t) else _monthGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _monthGrid() => Wrap(
        children: [
          for (var m = 1; m <= 12; m++)
            SizedBox(
              width: 280 / 4 - 1,
              child: TextButton(
                key: ValueKey('month-$m'),
                onPressed: () => Navigator.of(context).pop((_year, m)),
                child: Text(monthNames[m - 1].substring(0, 3)),
              ),
            ),
        ],
      );

  Widget _yearGrid(SuiteTokens t) {
    const cols = 4;
    final rowOfYear = (_year.clamp(firstYear, lastYear) - firstYear) ~/ cols;
    return SizedBox(
      key: const ValueKey('year-grid'),
      height: 240,
      child: GridView.count(
        crossAxisCount: cols,
        childAspectRatio: 1.6,
        controller: ScrollController(initialScrollOffset: rowOfYear * (280 / cols / 1.6)),
        children: [
          for (var y = firstYear; y <= lastYear; y++)
            TextButton(
              key: ValueKey('year-$y'),
              style: y == _year
                  ? TextButton.styleFrom(backgroundColor: t.accent, foregroundColor: t.onAccent)
                  : null,
              onPressed: () => setState(() {
                _year = y;
                _choosingYear = false;
              }),
              child: Text('$y'),
            ),
        ],
      ),
    );
  }
}
