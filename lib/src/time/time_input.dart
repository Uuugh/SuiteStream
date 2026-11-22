/// A time of day read from what the user typed.
class TimeOfDayValue {
  const TimeOfDayValue(this.hour, this.minute);
  final int hour;
  final int minute;

  int get minutes => hour * 60 + minute;

  @override
  bool operator ==(Object other) => other is TimeOfDayValue && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => '$hour:${minute.toString().padLeft(2, '0')}';
}

final RegExp _meridiem = RegExp(r'\s*([ap])\.?\s*m\.?$');
final RegExp _separated = RegExp(r'^(\d{1,2})[:.h](\d{2})$');
final RegExp _digits = RegExp(r'^\d{1,4}$');

/// EVT-02.a, EVT-02.l: reads a typed time. 9:30, 9.30, 9h30, 930, 21:30, 2130,
/// 9 pm, 9:30pm and 9:30 p.m. are read as the times they mean; a bare hour means
/// that hour and :00; an am or pm hour is 1 to 12. Anything else (13pm, 25:00)
/// is not a time and gives null.
TimeOfDayValue? parseTimeInput(String input) {
  var s = input.trim().toLowerCase();
  if (s.isEmpty) return null;
  String? mer;
  final m = _meridiem.firstMatch(s);
  if (m != null) {
    mer = m.group(1);
    s = s.substring(0, m.start).trim();
  }
  int? hour;
  int minute = 0;
  final sep = _separated.firstMatch(s);
  if (sep != null) {
    hour = int.parse(sep.group(1)!);
    minute = int.parse(sep.group(2)!);
  } else if (_digits.hasMatch(s)) {
    if (s.length <= 2) {
      hour = int.parse(s);
    } else {
      hour = int.parse(s.substring(0, s.length - 2));
      minute = int.parse(s.substring(s.length - 2));
    }
  }
  if (hour == null || minute > 59) return null;
  if (mer != null) {
    if (hour < 1 || hour > 12) return null;
    hour = hour % 12 + (mer == 'p' ? 12 : 0);
  }
  if (hour > 23) return null;
  return TimeOfDayValue(hour, minute);
}
