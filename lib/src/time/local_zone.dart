import 'zones.dart';

/// TIM-03: the Local time zone is the system (device) zone or a fixed zone
/// chosen in Settings > Time Zones. Changing it changes only how times are shown.
class LocalZone {
  const LocalZone.system(this.systemZoneName) : fixedZoneName = null;
  const LocalZone.fixed(String name, {required String systemZone}) : systemZoneName = systemZone, fixedZoneName = name;

  final String systemZoneName;
  final String? fixedZoneName;

  String get name => fixedZoneName ?? systemZoneName;
  Location get location => zoneNamed(name);

  /// Shows an instant as wall-clock time in the Local zone.
  TZDateTime show(DateTime utc) => TZDateTime.from(utc, location);
}
