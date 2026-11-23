import 'package:suitestream/src/time/zones.dart';

/// TIM-10: the user's choice of 12-hour or 24-hour times.
enum TimeFormat { twelveHour, twentyFourHour }

/// TIM-10: until the user chooses, 12-hour in a US time zone, 24-hour elsewhere.
TimeFormat defaultTimeFormat(String deviceZoneName) =>
    isUsZone(deviceZoneName) ? TimeFormat.twelveHour : TimeFormat.twentyFourHour;

/// Formats a time of day as `hh:mm am` (12-hour, such as `01:30 pm`) or `hh:mm` (24-hour, such as `13:30`).
String formatTimeOfDay(int hour, int minute, TimeFormat format) {
  final mm = minute.toString().padLeft(2, '0');
  switch (format) {
    case TimeFormat.twentyFourHour:
      return '${hour.toString().padLeft(2, '0')}:$mm';
    case TimeFormat.twelveHour:
      final h12 = hour % 12 == 0 ? 12 : hour % 12;
      final suffix = hour < 12 ? 'am' : 'pm';
      return '${h12.toString().padLeft(2, '0')}:$mm $suffix';
  }
}

/// CAL-09.c: the label of a timed event that spans dates, on [day]: "18:00-" (start time and
/// a hyphen) on its first day, "-04:00" (a hyphen and the end time) on its last day, and
/// [cont] on the days between. Null when the event lies within one date (it keeps its
/// ordinary label). An event that ends at exactly 00:00 ends on the day before.
/// [start] and [end] must be in the zone the page shows.
String? multiDayLabel({
  required DateTime start,
  required DateTime end,
  required DateTime day,
  required TimeFormat format,
  required String cont,
}) {
  DateTime dateOf(DateTime d) => DateTime(d.year, d.month, d.day);
  final first = dateOf(start);
  var last = dateOf(end);
  if (end.isAfter(start) && end.hour == 0 && end.minute == 0) {
    last = DateTime(last.year, last.month, last.day - 1);
  }
  if (!last.isAfter(first)) return null;
  final d = dateOf(day);
  if (d == first) return '${formatTimeOfDay(start.hour, start.minute, format)}-';
  if (d == last) return '-${formatTimeOfDay(end.hour, end.minute, format)}';
  return cont;
}
