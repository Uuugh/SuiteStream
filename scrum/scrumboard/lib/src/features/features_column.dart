import 'package:flutter/material.dart';

import 'package:scrumboard/src/api/reload_scope.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/features/outline.dart';
import 'package:scrumboard/src/features/scb_filter.dart';
import 'package:scrumboard/src/l10n/messages.dart';

/// SCB-11.a: the sub-requirement indent (DEF-01), per level, in logical pixels.
const double subRequirementIndent = 16;

const _statuses = ['proposed', 'backlog', 'planned', 'done'];

/// SCB-03: the Requirements column (the Features column of the page). It fills
/// the space the page gives it and scrolls inside (SCB-15.b).
class FeaturesColumn extends StatefulWidget {
  const FeaturesColumn({super.key, required this.api});

  final ScrumBoardApi api;

  @override
  State<FeaturesColumn> createState() => _FeaturesColumnState();
}

class _FeaturesColumnState extends State<FeaturesColumn> {
  int? _loadedGeneration;
  List<Requirement> _all = const [];
  String? _error;
  bool _loading = true;

  // SCB-04: what the user chose to hide, kept in memory only.
  Set<String> _hiddenFeatures = {};
  Set<String> _hiddenIds = {};
  Set<String> _hiddenStatuses = {};

  // SCB-11.d: nothing is expanded when the page opens.
  Set<String> _expanded = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final generation = ReloadScope.generationOf(context);
    if (_loadedGeneration != generation) {
      _loadedGeneration = generation;
      _load();
    }
  }

  Future<void> _load() async {
    final m = context.msg;
    try {
      final list = await widget.api.requirements();
      if (!mounted) return;
      setState(() {
        _all = list;
        _error = null;
        _loading = false;
      });
    } on ScrumBoardUnreachableException catch (e) {
      _fail(m('scbServerUnreachable', {'reason': e.reason}));
    } on ScrumBoardApiException catch (e) {
      _fail(m('scbLoadFailed', {'reason': e.reason}));
    }
  }

  void _fail(String text) {
    if (!mounted) return;
    setState(() {
      _error = text;
      _loading = false;
    });
  }

  /// SCB-04.d: an entry is listed when it meets all three filters.
  List<Requirement> get _listed => [
        for (final r in _all)
          if (!_hiddenFeatures.contains(r.feature) &&
              !_hiddenIds.contains(r.id) &&
              !_hiddenStatuses.contains(r.status))
            r,
      ];

  String _statusText(Messages m, String status) => switch (status) {
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
    final listed = _listed;
    final parents = parentIds(listed);
    final allExpanded = parents.isNotEmpty && parents.every(_expanded.contains);
    final rows = buildOutline(listed, _expanded);
    final features = ({for (final r in _all) r.feature}.toList()..sort());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(m('scbRequirements'), style: theme.textTheme.titleMedium),
        ),
        // SCB-04 and SCB-11.f: the filters, the count, and at the right end the switch.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ScbFilter(
                      label: m('scbFilterFeature'),
                      choices: [for (final f in features) ScbFilterChoice(f, f)],
                      hidden: _hiddenFeatures,
                      onChanged: (h) => setState(() => _hiddenFeatures = h),
                    ),
                    ScbFilter(
                      label: m('scbFilterRequirement'),
                      choices: [for (final r in _all) ScbFilterChoice(r.id, r.id)],
                      hidden: _hiddenIds,
                      onChanged: (h) => setState(() => _hiddenIds = h),
                    ),
                    ScbFilter(
                      label: m('scbFilterStatus'),
                      choices: [for (final s in _statuses) ScbFilterChoice(s, _statusText(m, s))],
                      hidden: _hiddenStatuses,
                      onChanged: (h) => setState(() => _hiddenStatuses = h),
                    ),
                    Text(
                      m('scbShownOf', {'shown': listed.length, 'total': _all.length}),
                      key: const ValueKey('scb-shown-of'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(m('scbExpandAll'), style: theme.textTheme.bodySmall),
              Switch(
                key: const ValueKey('scb-expand-all'),
                value: allExpanded,
                onChanged: parents.isEmpty
                    ? null
                    : (on) => setState(() => _expanded = on ? {...parents} : {}),
              ),
            ],
          ),
        ),
        Expanded(child: _body(context, m, theme, rows)),
      ],
    );
  }

  Widget _body(BuildContext context, Messages m, ThemeData theme, List<OutlineRow> rows) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(_error!,
            key: const ValueKey('scb-requirements-error'), style: TextStyle(color: theme.colorScheme.error)),
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, i) => _row(context, m, theme, rows[i]),
    );
  }

  Widget _row(BuildContext context, Messages m, ThemeData theme, OutlineRow row) {
    final r = row.requirement;
    final open = _expanded.contains(r.id);
    return Container(
      key: ValueKey('scb-row-${r.id}'),
      padding: EdgeInsets.only(left: 8 + row.depth * subRequirementIndent, right: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: row.hasChildren
                ? IconButton(
                    key: ValueKey('scb-toggle-${r.id}'),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tooltip: open ? m('scbCollapseRow') : m('scbExpandRow'),
                    icon: Icon(open ? Icons.arrow_drop_down : Icons.arrow_right),
                    onPressed: () => setState(() {
                      _expanded = open ? ({..._expanded}..remove(r.id)) : {..._expanded, r.id};
                    }),
                  )
                : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      Text(r.id, style: theme.textTheme.labelLarge),
                      Text(_statusText(m, r.status),
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                      Text(r.feature, style: theme.textTheme.labelMedium),
                    ],
                  ),
                  Text(r.statement, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
