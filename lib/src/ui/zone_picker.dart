import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../theme/suite_icons.dart';
import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/zones.dart';
import 'suite_dialog.dart';

/// DEF-01: the Common time zones, in this order.
const List<String> commonZones = [
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Phoenix',
  'America/Los_Angeles',
  'America/Anchorage',
  'Pacific/Honolulu',
  'Pacific/Guam',
  'UTC',
  'Europe/London',
  'Europe/Frankfurt',
  'Asia/Tokyo',
  'Asia/Hong_Kong',
  'Australia/Sydney',
];

const List<String> _hiddenPrefixes = ['Etc/', 'SystemV/', 'posix/', 'right/'];

/// UIC-39: every zone offered after the Common group: region and city names
/// only, without Etc/, SystemV/, posix/ or right/.
List<String> allZoneNames() {
  initZones();
  final names = tz.timeZoneDatabase.locations.keys
      .where((n) => n.contains('/') && !_hiddenPrefixes.any(n.startsWith))
      .toList()
    ..sort();
  return names;
}

/// UIC-39: a value is valid when it is UTC or in the list.
bool isValidZoneChoice(String name) => name == 'UTC' || allZoneNames().contains(name);

/// Opens the time zone list (UIC-39) and returns the zone chosen, or null.
Future<String?> pickZone(BuildContext context, {required String current, required String defaultZone}) {
  final msgs = context.msg;
  return showSuiteDialog<String>(
    context: context,
    builder: (_) => MessagesScope(messages: msgs, child: _ZoneDialog(current: current, defaultZone: defaultZone)),
  );
}

/// UIC-39: the time zone picker. The Common group comes first, then
/// msg:allTimeZones; the default zone is marked ★.
class ZoneField extends StatelessWidget {
  const ZoneField({super.key, required this.value, required this.defaultZone, required this.onChanged, this.label});

  final String value;
  final String defaultZone;
  final ValueChanged<String> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: () async {
        final picked = await pickZone(context, current: value, defaultZone: defaultZone);
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderSide: BorderSide(color: t.line)),
          suffixIcon: const Icon(SuiteIcons.arrowDropDown),
        ),
        child: Text(value == defaultZone ? '$value ★' : value, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _ZoneDialog extends StatefulWidget {
  const _ZoneDialog({required this.current, required this.defaultZone});
  final String current;
  final String defaultZone;

  @override
  State<_ZoneDialog> createState() => _ZoneDialogState();
}

class _ZoneDialogState extends State<_ZoneDialog> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    bool match(String z) => _filter.isEmpty || z.toLowerCase().contains(_filter.toLowerCase());
    final common = commonZones.where(match).toList();
    final rest = allZoneNames().where((z) => !commonZones.contains(z) && match(z)).toList();
    String label(String z) => z == widget.defaultZone ? '$z ★' : z;
    Widget tile(String z) => ListTile(
          key: ValueKey('zone-$z'),
          dense: true,
          selected: z == widget.current,
          title: Text(label(z)),
          onTap: () => Navigator.of(context).pop(z),
        );
    return Dialog(
      backgroundColor: t.card,
      child: SizedBox(
        width: 360,
        height: 480,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(suiteDialogPadding),
              child: TextField(
                key: const ValueKey('zone-filter'),
                autofocus: true,
                decoration: const InputDecoration(prefixIcon: Icon(SuiteIcons.search), isDense: true),
                onChanged: (v) => setState(() => _filter = v),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final z in common) tile(z),
                  if (rest.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(m('allTimeZones'), style: TextStyle(color: t.muted, fontWeight: FontWeight.w600)),
                    ),
                  for (final z in rest) tile(z),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
