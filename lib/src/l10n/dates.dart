import 'package:intl/intl.dart';

String _capitalise(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// CAL-01.q: the title of Month and List: month name and year, first letter
/// capitalised, in the page language.
String monthYearTitle(String locale, DateTime d) => _capitalise(DateFormat.yMMMM(locale).format(d));

/// CAL-01.q: the title of Day: weekday, month, day and year in the page language.
String dayTitle(String locale, DateTime d) => _capitalise(DateFormat.yMMMMEEEEd(locale).format(d));

/// CAL-01.s: the page language's abbreviated month name (1 to 12).
String monthAbbreviation(String locale, int month) => _capitalise(DateFormat.MMM(locale).format(DateTime(2001, month)));

/// The abbreviated weekday name for a date.
String weekdayAbbreviation(String locale, DateTime d) => _capitalise(DateFormat.E(locale).format(d));

/// A short date range for a header, such as `Jul 12 – 18, 2026`.
String dateRange(String locale, DateTime a, DateTime b) {
  final left = a.year == b.year ? DateFormat.MMMd(locale).format(a) : DateFormat.yMMMd(locale).format(a);
  final right = a.month == b.month && a.year == b.year
      ? DateFormat.d(locale).format(b)
      : DateFormat.yMMMd(locale).format(b);
  final tail = a.year == b.year && a.month == b.month ? ', ${b.year}' : '';
  return '${_capitalise(left)} – $right$tail';
}
