import 'zones.dart';

/// TIM-10: the user's choice of 12-hour or 24-hour times.
enum TimeFormat { twelveHour, twentyFourHour }

/// TIM-10: until the user chooses, 12-hour in a US time zone, 24-hour elsewhere.
TimeFormat defaultTimeFormat(String deviceZoneName) =>
    isUsZone(deviceZoneName) ? TimeFormat.twelveHour : TimeFormat.twentyFourHour;

/// Formats a time of day, such as `1:30pm` or `13:30`.
String formatTimeOfDay(int hour, int minute, TimeFormat format) {
  final mm = minute.toString().padLeft(2, '0');
  switch (format) {
    case TimeFormat.twentyFourHour:
      return '${hour.toString().padLeft(2, '0')}:$mm';
    case TimeFormat.twelveHour:
      final h12 = hour % 12 == 0 ? 12 : hour % 12;
      final suffix = hour < 12 ? 'am' : 'pm';
      return minute == 0 ? '$h12$suffix' : '$h12:$mm$suffix';
  }
}
