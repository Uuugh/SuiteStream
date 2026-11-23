import 'package:shared_preferences/shared_preferences.dart';

import 'package:suitestream/src/time/length_input.dart';
import 'package:suitestream/src/time/time_input.dart';

/// SET-08.a (Settings > Calendar): the unit the default event length is shown and typed in.
enum LengthUnit {
  minutes(1, 'minutes', 15),
  hours(60, 'unitHours', 0.25);

  const LengthUnit(this.inMinutes, this.messageKey, this.step);

  /// Minutes in one of this unit.
  final int inMinutes;

  /// The message key of the unit's name.
  final String messageKey;

  /// How far the arrows move the value, in this unit (UIC-41: a length steps by 15 minutes).
  final double step;
}

/// DEF-01: a new event starts at 9:00 until the user changes the default time.
const int standardEventStartMinutes = 9 * 60;

/// SET-08.a: the calendar defaults kept on the device: the unit of the default length, and
/// the default time of a new event. The length itself is `CalendarController.defaultLength`
/// and the default time zone is its Local zone (SET-02); this keeps the rest.
class CalendarDefaults {
  const CalendarDefaults({this.unit = LengthUnit.hours, this.startMinutes = standardEventStartMinutes});

  final LengthUnit unit;

  /// The default start of a new event, in minutes after midnight.
  final int startMinutes;

  TimeOfDayValue get startTime => TimeOfDayValue(startMinutes ~/ 60, startMinutes % 60);

  static const unitKey = 'event.defaultLengthUnit';
  static const startKey = 'event.defaultStartMinutes';

  /// Reads the saved defaults; anything missing or out of range is the default.
  static CalendarDefaults load(SharedPreferences? prefs) {
    if (prefs == null) return const CalendarDefaults();
    final u = prefs.getString(unitKey);
    final s = prefs.getInt(startKey);
    return CalendarDefaults(
      unit: LengthUnit.values.where((x) => x.name == u).firstOrNull ?? LengthUnit.hours,
      startMinutes: s != null && s >= 0 && s < 24 * 60 ? s : standardEventStartMinutes,
    );
  }

  Future<void> save(SharedPreferences? prefs) async {
    if (prefs == null) return;
    await prefs.setString(unitKey, unit.name);
    await prefs.setInt(startKey, startMinutes);
  }

  CalendarDefaults copyWith({LengthUnit? unit, int? startMinutes}) =>
      CalendarDefaults(unit: unit ?? this.unit, startMinutes: startMinutes ?? this.startMinutes);
}

/// The default length as a number in [unit] (`1.5` hours, `90` minutes).
String formatLengthIn(Duration d, LengthUnit unit) {
  final v = d.inMinutes / unit.inMinutes;
  if (v == v.roundToDouble()) return v.round().toString();
  return v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

/// Reads a typed number of [unit]s (`90`, `1.5`, `1,5`). Gives null when it is not a
/// number or the length is outside 5 minutes to 24 hours.
Duration? parseLengthIn(String input, LengthUnit unit) {
  final s = input.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,4}(\.\d{1,2})?$').hasMatch(s)) return null;
  final d = Duration(minutes: (double.parse(s) * unit.inMinutes).round());
  return d < minEventLength || d > maxEventLength ? null : d;
}

/// Steps a length by one arrow press in [unit], within 5 minutes to 24 hours.
Duration stepLengthIn(Duration d, LengthUnit unit, int dir) =>
    clampEventLength(d + Duration(minutes: (unit.step * unit.inMinutes).round() * dir));

/// The same length, shown in the larger unit when it is a whole number of hours.
LengthUnit unitFor(Duration d) => d.inMinutes % 60 == 0 ? LengthUnit.hours : LengthUnit.minutes;

/// DEF-01 (Long-press time): press-and-hold starts after 0.2 seconds by default,
/// within 0.2 to 1.5 seconds. A Settings > Theme value (SET-03.b).
const Duration defaultLongPress = Duration(milliseconds: 200);
const Duration minLongPress = Duration(milliseconds: 200);
const Duration maxLongPress = Duration(milliseconds: 1500);

/// CAL-03.d: the long-press time stays within the limits in DEF-01.
Duration clampLongPress(Duration d) => d < minLongPress ? minLongPress : (d > maxLongPress ? maxLongPress : d);

/// DEF-01 (Saved or Cancelled shown): the pressed word of Cancel | Save shows
/// for 1 second by default, within 0.5 to 10 seconds. A Settings > Theme value (SET-03.m).
const Duration defaultStatusWordTime = Duration(seconds: 1);
const Duration minStatusWordTime = Duration(milliseconds: 500);
const Duration maxStatusWordTime = Duration(seconds: 10);

Duration clampStatusWordTime(Duration d) =>
    d < minStatusWordTime ? minStatusWordTime : (d > maxStatusWordTime ? maxStatusWordTime : d);
