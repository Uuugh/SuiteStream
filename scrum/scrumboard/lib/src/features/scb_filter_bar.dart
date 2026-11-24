import 'package:flutter/material.dart';

import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/features/scb_filter.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

const _statuses = ['proposed', 'backlog', 'planned', 'done'];

/// SCB-04: what the user chose to hide in the three filters. Kept by the owner
/// in memory; [apply] gives the entries that are listed (SCB-04.d).
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
}

/// SCB-04: the one filter bar (feature, requirement and status filters, and
/// the shown-of count) shared by every column; no column has its own copy.
/// [items] is every entry of the column; [trailing] sits at the right end of
/// the same row.
class ScbFilterBar extends StatelessWidget {
  const ScbFilterBar({
    super.key,
    required this.items,
    required this.hidden,
    required this.onChanged,
    this.trailing,
  });

  final List<Requirement> items;
  final ScbHiddenFilters hidden;
  final ValueChanged<ScbHiddenFilters> onChanged;
  final Widget? trailing;

  static String _statusText(Messages m, String status) => switch (status) {
        'proposed' => m('scbStatusProposed'),
        'backlog' => m('scbStatusBacklog'),
        'planned' => m('scbStatusPlanned'),
        'done' => m('scbStatusDone'),
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    final theme = Theme.of(context);
    final features = ({for (final r in items) r.feature}.toList()..sort());
    final shown = hidden.apply(items).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: scrumPartGap),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ScbFilter(
                  label: m('scbFilterFeature'),
                  choices: [for (final f in features) ScbFilterChoice(f, f)],
                  hidden: hidden.features,
                  onChanged: (h) => onChanged(hidden.copyWith(features: h)),
                ),
                ScbFilter(
                  label: m('scbFilterRequirement'),
                  choices: [for (final r in items) ScbFilterChoice(r.id, r.id)],
                  hidden: hidden.ids,
                  onChanged: (h) => onChanged(hidden.copyWith(ids: h)),
                ),
                ScbFilter(
                  label: m('scbFilterStatus'),
                  choices: [for (final s in _statuses) ScbFilterChoice(s, _statusText(m, s))],
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
