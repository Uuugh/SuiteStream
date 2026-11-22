import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

export 'package:timezone/timezone.dart' show Location, TZDateTime;

bool _ready = false;

/// Loads the time zone database once.
void initZones() {
  if (_ready) return;
  tzdata.initializeTimeZones();
  _ready = true;
}

/// Looks up an IANA zone name such as `America/New_York`.
tz.Location zoneNamed(String name) {
  initZones();
  return tz.getLocation(name);
}

bool isKnownZone(String name) {
  initZones();
  try {
    tz.getLocation(name);
    return true;
  } catch (_) {
    return false;
  }
}

/// True when [zoneName] is a time zone of the United States.
bool isUsZone(String zoneName) {
  if (zoneName.startsWith('US/')) return true;
  if (_usZones.contains(zoneName)) return true;
  return zoneName.startsWith('America/Indiana/') ||
      zoneName.startsWith('America/Kentucky/') ||
      zoneName.startsWith('America/North_Dakota/');
}

const Set<String> _usZones = {
  'America/New_York',
  'America/Detroit',
  'America/Chicago',
  'America/Menominee',
  'America/Denver',
  'America/Boise',
  'America/Phoenix',
  'America/Los_Angeles',
  'America/Anchorage',
  'America/Juneau',
  'America/Sitka',
  'America/Metlakatla',
  'America/Yakutat',
  'America/Nome',
  'America/Adak',
  'Pacific/Honolulu',
};
