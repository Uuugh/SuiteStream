import 'package:flutter/material.dart';

import 'package:scrumboard/src/l10n/messages.dart';

/// SCB-21: the status menu of a requirement entry. Tapping [child] opens a
/// menu with Proposed, Backlog, one item per story in [stories] (the next
/// upcoming story blocks of the sprint file) and Retired. The choice is
/// reported by [onSelected] as a lower-case status ('proposed', 'backlog',
/// 'planned' with the story id, or 'retired'); the caller does the change,
/// refuses it when SCB-13.c forbids it, and calls the API for 'retired'.
/// [status] is the entry's current status; its item is shown as the current
/// one and cannot be chosen.
class ScbStatusMenu extends StatelessWidget {
  const ScbStatusMenu({
    super.key,
    required this.status,
    required this.stories,
    required this.onSelected,
    required this.child,
  });

  final String status;
  final List<({String id, String name})> stories;
  final void Function(String status, String? storyId) onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final msg = context.msg;
    return PopupMenuButton<({String status, String? storyId})>(
      tooltip: msg('scbStatusMenu'),
      onSelected: (v) => onSelected(v.status, v.storyId),
      itemBuilder: (_) => [
        _item('proposed', null, msg('scbStatusProposed'), const ValueKey('scbStatusMenu.proposed')),
        _item('backlog', null, msg('scbStatusBacklog'), const ValueKey('scbStatusMenu.backlog')),
        for (final s in stories)
          _item('planned', s.id, msg('scbStatusSprintItem', {'name': s.name}), ValueKey('scbStatusMenu.story.${s.id}')),
        _item('retired', null, msg('scbStatusRetired'), const ValueKey('scbStatusMenu.retired')),
      ],
      child: child,
    );
  }

  PopupMenuItem<({String status, String? storyId})> _item(String s, String? storyId, String label, Key key) =>
      PopupMenuItem(
        key: key,
        value: (status: s, storyId: storyId),
        enabled: !(s == status && storyId == null),
        child: Text(label),
      );
}
