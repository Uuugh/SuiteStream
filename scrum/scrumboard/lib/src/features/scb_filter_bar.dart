import 'package:flutter/material.dart';

import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/features/scb_filter.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// SCB-04: what the shared bar filters on, for one kind of entry [T]: a group
/// (feature or kind), an id (requirement, or number or PBI) and a status.
/// [groupName] and [idName] are message keys for the two filter labels; the
/// status filter is always labelled msg:scbFilterStatus. [statuses] are the
/// status values offered, in order.
class ScbFilterFields<T> {
  const ScbFilterFields({
    required this.group,
    required this.id,
    required this.status,
    required this.statuses,
    required this.groupName,
    required this.idName,
    required this.groupText,
    required this.statusText,
    required this.idText,
  });

  final String Function(T) group;
  final String Function(T) id;
  final String Function(T) status;
  final List<String> statuses;
  final String groupName;
  final String idName;
  final String Function(Messages, String) groupText;
  final String Function(Messages, String) statusText;
  final String Function(T) idText;
}

String _requirementFeature(Requirement r) => r.feature;
String _requirementId(Requirement r) => r.id;
String _requirementStatus(Requirement r) => r.status;
String _asIs(Messages m, String value) => value;
String _requirementStatusText(Messages m, String status) => switch (status) {
      'proposed' => m('scbStatusProposed'),
      'backlog' => m('scbStatusBacklog'),
      'planned' => m('scbStatusPlanned'),
      'done' => m('scbStatusDone'),
      _ => status,
    };

/// SCB-04: the requirement filters (feature, requirement, status) of the
/// Features column and the backlog; the bar's default.
const requirementFilterFields = ScbFilterFields<Requirement>(
  group: _requirementFeature,
  id: _requirementId,
  status: _requirementStatus,
  statuses: ['proposed', 'backlog', 'planned', 'done'],
  groupName: 'scbFilterFeature',
  idName: 'scbFilterRequirement',
  groupText: _asIs,
  statusText: _requirementStatusText,
  idText: _requirementId,
);

/// SCB-04: what the user chose to hide in the three filters. Kept by the owner
/// in memory; [apply] gives the entries that are listed (SCB-04.d).
/// [features] holds the hidden groups (features, or kinds), [ids] the hidden
/// ids and [statuses] the hidden statuses.
class ScbHiddenFilters {
  const ScbHiddenFilters({this.features = const {}, this.ids = const {}, this.statuses = const {}});

  final Set<String> features;
  final Set<String> ids;
  final Set<String> statuses;

  ScbHiddenFilters copyWith({Set<String>? features, Set<String>? ids, Set<String>? statuses}) =>
      ScbHiddenFilters(
        features: features ?? this.features,
        ids: ids ?? this.ids,
        statuses: statuses ?? this.statuses,
      );

  /// SCB-04.d: an entry is listed when it meets all three filters.
  bool shows(Requirement r) =>
      !features.contains(r.feature) && !ids.contains(r.id) && !statuses.contains(r.status);

  List<Requirement> apply(List<Requirement> all) => [
        for (final r in all)
          if (shows(r)) r,
      ];

  /// SCB-04.d for any entry: an entry of [all] is listed when its group, id
  /// and status (read through [fields]) are all shown.
  List<T> applyWith<T>(List<T> all, ScbFilterFields<T> fields) => [
        for (final e in all)
          if (!features.contains(fields.group(e)) &&
              !ids.contains(fields.id(e)) &&
              !statuses.contains(fields.status(e)))
            e,
      ];
}

/// SCB-04: the one filter bar (group, id and status filters, and the shown-of
/// count) shared by every column; no column has its own copy. [items] is
/// every entry of the column; [fields] says what the filters read, and null
/// means requirements ([requirementFilterFields]); [trailing] sits at the
/// right end of the same row.
class ScbFilterBar<T> extends StatelessWidget {
  const ScbFilterBar({
    super.key,
    required this.items,
    this.fields,
    required this.hidden,
    required this.onChanged,
    this.trailing,
  }) : assert(fields != null || items is List<Requirement>,
            'ScbFilterBar without fields lists requirements only');

  final List<T> items;
  final ScbFilterFields<T>? fields;
  final ScbHiddenFilters hidden;
  final ValueChanged<ScbHiddenFilters> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    final theme = Theme.of(context);
    final f = fields ?? requirementFilterFields as ScbFilterFields<T>;
    final groups = ({for (final e in items) f.group(e)}.toList()..sort());
    final shown = hidden.applyWith(items, f).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: scrumPartGap),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ScbFilter(
                  label: m(f.groupName),
                  choices: [for (final g in groups) ScbFilterChoice(g, f.groupText(m, g))],
                  hidden: hidden.features,
                  onChanged: (h) => onChanged(hidden.copyWith(features: h)),
                ),
                ScbFilter(
                  label: m(f.idName),
                  choices: [for (final e in items) ScbFilterChoice(f.id(e), f.idText(e))],
                  hidden: hidden.ids,
                  onChanged: (h) => onChanged(hidden.copyWith(ids: h)),
                ),
                ScbFilter(
                  label: m('scbFilterStatus'),
                  choices: [for (final s in f.statuses) ScbFilterChoice(s, f.statusText(m, s))],
                  hidden: hidden.statuses,
                  onChanged: (h) => onChanged(hidden.copyWith(statuses: h)),
                ),
                Text(
                  m('scbShownOf', {'shown': shown, 'total': items.length}),
                  key: const ValueKey('scb-shown-of'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
