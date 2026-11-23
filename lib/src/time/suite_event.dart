import 'zones.dart';

/// DEF-01: the limits of an event's fields.
const int eventTitleLength = 200;
const int eventLocationLength = 200;
const int eventMeetingLength = 500;
const int eventNotesLength = 4000;
const int remindersPerEvent = 5;

/// An event. TIM-01: start and end are stored in UTC together with the time
/// zone each was recorded in.
class SuiteEvent {
  SuiteEvent({
    required this.id,
    required this.title,
    required DateTime startUtc,
    required DateTime endUtc,
    required this.startZone,
    required this.endZone,
    this.allDay = false,
    this.calendarId,
    this.edited = false,
    this.changedBySource = false,
    this.hiddenFromGoogle = false,
    this.deleted = false,
    this.custom = true,
    this.location = '',
    this.notes = '',
    this.color,
    this.reminders = const [],
    this.meetingUrl = '',
  })  : startUtc = _plainUtc(startUtc),
        endUtc = _plainUtc(endUtc) {
    if (this.endUtc.isBefore(this.startUtc)) {
      throw ArgumentError('An event cannot end before it starts.');
    }
  }

  final String id;
  final String title;
  final DateTime startUtc;
  final DateTime endUtc;
  final String startZone;
  final String endZone;
  final bool allDay;
  final String? calendarId;

  /// Event states the Calendar filter can show or hide (FLT-01.a).
  final bool edited;
  final bool changedBySource;
  final bool hiddenFromGoogle;
  final bool deleted;

  /// CAP-02: a custom event is the user's own and can be deleted; an event that
  /// comes from a calendar source can only be hidden.
  final bool custom;

  final String location;
  final String notes;

  /// EVT-03.b: ARGB color value, or null for the calendar's color.
  final int? color;

  /// EVT-03.e: minutes before the start (0 = at the start), at most
  /// [remindersPerEvent].
  final List<int> reminders;

  /// EVT-03: an online meeting address (empty or an http(s) link).
  final String meetingUrl;

  /// An event given as wall-clock times in [zone] (TIM-02: the zone it is recorded in).
  factory SuiteEvent.zoned({
    required String id,
    required String title,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required Duration length,
    required String zone,
    String? endZone,
    String? calendarId,
  }) {
    final start = TZDateTime(zoneNamed(zone), year, month, day, hour, minute);
    return SuiteEvent(
      id: id,
      title: title,
      startUtc: start.toUtc(),
      endUtc: start.toUtc().add(length),
      startZone: zone,
      endZone: endZone ?? zone,
      calendarId: calendarId,
    );
  }

  /// TIM-04: an all-day event is a 24-hour event, local midnight to the next
  /// local midnight in its own time zone, stored in UTC like any other.
  factory SuiteEvent.allDay({
    required String id,
    required String title,
    required int year,
    required int month,
    required int day,
    required String zone,
    int days = 1,
    String? calendarId,
  }) {
    final loc = zoneNamed(zone);
    final start = TZDateTime(loc, year, month, day);
    final end = TZDateTime(loc, year, month, day + days);
    return SuiteEvent(
      id: id,
      title: title,
      startUtc: start.toUtc(),
      endUtc: end.toUtc(),
      startZone: zone,
      endZone: zone,
      allDay: true,
      calendarId: calendarId,
    );
  }

  /// The start as wall-clock time in [location].
  TZDateTime startIn(Location location) => TZDateTime.from(startUtc, location);
  TZDateTime endIn(Location location) => TZDateTime.from(endUtc, location);

  /// TIM-05: what "Friday" or "22:00" means for an event is decided by the
  /// event's own recorded zone.
  TZDateTime get recordedStart => startIn(zoneNamed(startZone));
  int get recordedWeekday => recordedStart.weekday;
  int get recordedMinuteOfDay => recordedStart.hour * 60 + recordedStart.minute;

  /// TIM-06: the wire form sent to an outside calendar: UTC instants with their zones.
  Map<String, Object?> toWire() => {
        'id': id,
        'title': title,
        'start': {'utc': startUtc.toIso8601String(), 'zone': startZone},
        'end': {'utc': endUtc.toIso8601String(), 'zone': endZone},
        'allDay': allDay,
        if (calendarId != null) 'calendarId': calendarId,
        if (edited) 'edited': true,
        if (changedBySource) 'changedBySource': true,
        if (hiddenFromGoogle) 'hiddenFromGoogle': true,
        if (deleted) 'deleted': true,
        if (!custom) 'custom': false,
        if (location.isNotEmpty) 'location': location,
        if (notes.isNotEmpty) 'notes': notes,
        if (color != null) 'color': color,
        if (reminders.isNotEmpty) 'reminders': reminders,
        if (meetingUrl.isNotEmpty) 'meetingUrl': meetingUrl,
      };

  /// TIM-06, TIM-08: reads an incoming event. An event that carries no time
  /// zone gets [defaultZone] (the installation's default zone).
  factory SuiteEvent.fromWire(Map<String, Object?> json, {required String defaultZone}) {
    Map<String, Object?> part(String key) => (json[key]! as Map).cast<String, Object?>();
    String zoneOf(Map<String, Object?> p) {
      final z = p['zone'] as String?;
      return (z == null || z.isEmpty || !isKnownZone(z)) ? defaultZone : z;
    }

    final s = part('start');
    final e = part('end');
    return SuiteEvent(
      id: json['id']! as String,
      title: json['title']! as String,
      startUtc: DateTime.parse(s['utc']! as String),
      endUtc: DateTime.parse(e['utc']! as String),
      startZone: zoneOf(s),
      endZone: zoneOf(e),
      allDay: (json['allDay'] as bool?) ?? false,
      calendarId: json['calendarId'] as String?,
      edited: (json['edited'] as bool?) ?? false,
      changedBySource: (json['changedBySource'] as bool?) ?? false,
      hiddenFromGoogle: (json['hiddenFromGoogle'] as bool?) ?? false,
      deleted: (json['deleted'] as bool?) ?? false,
      custom: (json['custom'] as bool?) ?? true,
      location: (json['location'] as String?) ?? '',
      notes: (json['notes'] as String?) ?? '',
      color: json['color'] as int?,
      reminders: ((json['reminders'] as List?) ?? const []).cast<int>(),
      meetingUrl: (json['meetingUrl'] as String?) ?? '',
    );
  }

  /// TIM-01: the stored form.
  Map<String, Object?> toJson() => toWire();
  factory SuiteEvent.fromJson(Map<String, Object?> json) => SuiteEvent.fromWire(json, defaultZone: 'UTC');

  /// A copy with some fields changed. [color] and [calendarId] can be set to
  /// null with [clearColor] and [clearCalendar].
  SuiteEvent copyWith({
    String? title,
    DateTime? startUtc,
    DateTime? endUtc,
    String? startZone,
    String? endZone,
    bool? allDay,
    String? calendarId,
    bool clearCalendar = false,
    bool? edited,
    bool? changedBySource,
    bool? hiddenFromGoogle,
    bool? deleted,
    bool? custom,
    String? location,
    String? notes,
    int? color,
    bool clearColor = false,
    List<int>? reminders,
    String? meetingUrl,
  }) =>
      SuiteEvent(
        id: id,
        title: title ?? this.title,
        startUtc: startUtc ?? this.startUtc,
        endUtc: endUtc ?? this.endUtc,
        startZone: startZone ?? this.startZone,
        endZone: endZone ?? this.endZone,
        allDay: allDay ?? this.allDay,
        calendarId: clearCalendar ? null : (calendarId ?? this.calendarId),
        edited: edited ?? this.edited,
        changedBySource: changedBySource ?? this.changedBySource,
        hiddenFromGoogle: hiddenFromGoogle ?? this.hiddenFromGoogle,
        deleted: deleted ?? this.deleted,
        custom: custom ?? this.custom,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        color: clearColor ? null : (color ?? this.color),
        reminders: reminders ?? this.reminders,
        meetingUrl: meetingUrl ?? this.meetingUrl,
      );

  /// TIM-02: a changed event keeps its recorded zones unless the user edits
  /// them (Edit Event passes new zones).
  SuiteEvent withEdits({
    String? title,
    DateTime? startUtc,
    DateTime? endUtc,
    String? startZone,
    String? endZone,
  }) =>
      copyWith(
        title: title,
        startUtc: startUtc,
        endUtc: endUtc,
        startZone: startZone,
        endZone: endZone,
        edited: true,
      );

  /// TIM-07: the event's times for a calendar feed (iCalendar), with each
  /// time's zone. An all-day event is sent as a date for its stored zone.
  List<String> toIcalTimes() {
    String p(int n, [int w = 2]) => n.toString().padLeft(w, '0');
    String stamp(TZDateTime t) =>
        '${p(t.year, 4)}${p(t.month)}${p(t.day)}T${p(t.hour)}${p(t.minute)}${p(t.second)}';
    String date(TZDateTime t) => '${p(t.year, 4)}${p(t.month)}${p(t.day)}';
    final s = startIn(zoneNamed(startZone));
    final e = endIn(zoneNamed(endZone));
    if (allDay) {
      return ['DTSTART;VALUE=DATE:${date(s)}', 'DTEND;VALUE=DATE:${date(e)}'];
    }
    return ['DTSTART;TZID=$startZone:${stamp(s)}', 'DTEND;TZID=$endZone:${stamp(e)}'];
  }
}

extension SuiteEventStates on SuiteEvent {
  /// A copy with its Calendar-filter states set (FLT-01.a).
  SuiteEvent withState({bool? edited, bool? changedBySource, bool? hiddenFromGoogle, bool? deleted}) => copyWith(
        edited: edited,
        changedBySource: changedBySource,
        hiddenFromGoogle: hiddenFromGoogle,
        deleted: deleted,
      );
}

/// TIM-02: the zone a new event is recorded in. An imported event takes the zone
/// of its source (or the zone its source calendar reports); an added event takes
/// the zone of the selected calendar, otherwise the system zone.
String zoneForNewEvent({
  required bool imported,
  required String systemZone,
  String? sourceZone,
  String? calendarZone,
}) {
  if (imported) return sourceZone ?? calendarZone ?? systemZone;
  return calendarZone ?? systemZone;
}

/// A calendar events belong to: its name and color follow its source (FLT-01.e).
class SuiteCalendar {
  const SuiteCalendar({required this.id, required this.name, required this.color, this.zone});
  final String id;
  final String name;

  /// ARGB color value.
  final int? color;

  /// The calendar's own time zone, when it has one (EVT-01.b).
  final String? zone;
}

/// A plain UTC [DateTime] (not a zoned subclass), so equal instants compare equal.
DateTime _plainUtc(DateTime t) => DateTime.fromMicrosecondsSinceEpoch(t.microsecondsSinceEpoch, isUtc: true);
