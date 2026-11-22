/// The shortest and longest default event length (5 minutes to 24 hours).
const Duration minEventLength = Duration(minutes: 5);
const Duration maxEventLength = Duration(hours: 24);

/// DEF-01: a new event lasts one hour until the user changes the setting.
const Duration standardEventLength = Duration(hours: 1);

final RegExp _hoursMinutes = RegExp(r'^(\d{1,2}):(\d{2})$');
final RegExp _minutes = RegExp(r'^(\d{1,4})\s*(m|min|mins|minutes?)$');
final RegExp _hours = RegExp(r'^(\d{1,2})(?:\.(\d{1,2}))?\s*(h|hr|hrs|hours?)?$');

/// Reads a typed length: `1:30`, `2`, `1.5` and `1.5h` are hours; `90m` and
/// `90 min` are minutes. Gives null when it cannot be read or is outside 5
/// minutes to 24 hours.
Duration? parseLengthInput(String input) {
  final s = input.trim().toLowerCase();
  if (s.isEmpty) return null;
  Duration? d;
  final hm = _hoursMinutes.firstMatch(s);
  final mm = _minutes.firstMatch(s);
  final hh = _hours.firstMatch(s);
  if (hm != null) {
    final minutes = int.parse(hm.group(2)!);
    if (minutes > 59) return null;
    d = Duration(hours: int.parse(hm.group(1)!), minutes: minutes);
  } else if (mm != null) {
    d = Duration(minutes: int.parse(mm.group(1)!));
  } else if (hh != null) {
    final whole = int.parse(hh.group(1)!);
    final frac = hh.group(2);
    final extra = frac == null ? 0 : (double.parse('0.$frac') * 60).round();
    d = Duration(hours: whole, minutes: extra);
  }
  if (d == null || d < minEventLength || d > maxEventLength) return null;
  return d;
}

/// A length as the setting shows it, such as `1:00` or `1:30`.
String formatLength(Duration d) => '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}';

/// Keeps a length within 5 minutes to 24 hours.
Duration clampEventLength(Duration d) => d < minEventLength ? minEventLength : (d > maxEventLength ? maxEventLength : d);

/// Reads a typed press-and-hold delay in seconds (`0.3`, `0,5`, `1`) or milliseconds
/// (`300ms`). Gives null when it is not a number or is outside 0.2 to 1.5 seconds.
Duration? parsePressDelayInput(String input) {
  final s = input.trim().toLowerCase().replaceAll(',', '.');
  if (s.isEmpty) return null;
  final ms = RegExp(r'^(\d{3,4})\s*ms$').firstMatch(s);
  double? seconds;
  if (ms != null) {
    seconds = int.parse(ms.group(1)!) / 1000;
  } else {
    final sec = RegExp(r'^(\d+(?:\.\d{1,3})?)\s*s?$').firstMatch(s);
    if (sec != null) seconds = double.parse(sec.group(1)!);
  }
  if (seconds == null || seconds < 0.2 || seconds > 1.5) return null;
  return Duration(milliseconds: (seconds * 1000).round());
}

/// A press-and-hold delay as the setting shows it, in seconds (`0.3`).
String formatPressDelay(Duration d) {
  final s = d.inMilliseconds / 1000;
  return s == s.roundToDouble() ? s.toStringAsFixed(1) : s.toString();
}
