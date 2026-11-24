import 'package:scrumboard/src/api/scrumboard_api.dart';

/// The next story blocks of the sprint file in file order, at most [limit]
/// (SCB-21): the sprint choices of the status menu. Members belong to stories
/// (SCB-02.c, SCB-07.c), so only stories are offered.
List<({String id, String name})> upcomingStories(SprintFile file, {int limit = 3}) => [
      for (final b in file.blocks)
        if (b.kind == 'story') (id: b.id, name: b.name),
    ].take(limit).toList();

/// Moves requirement [id] (now [status]) to the story [storyId], or to the
/// backlog when [storyId] is null: the status change first (SCB-13.c checks the
/// order and may refuse, then nothing changes), then the member rows of
/// [sprint] and a save of the sprint file when they changed (SCB-07.e, f). The
/// refusal reason is returned for msg:scbMoveRefused.
Future<({bool ok, String reason})> moveRequirement(
  ScrumBoardApi api, {
  required String id,
  required String status,
  required SprintFile sprint,
  required String? storyId,
}) async {
  final target = storyId == null ? 'backlog' : 'planned';
  final rows = [
    for (final m in sprint.members)
      if (m.item == id) m,
  ];
  try {
    if (status != target) {
      final r = await api.setStatus(id, target);
      if (!r.ok) return r;
    }
    final inStory = rows.any((m) => m.block == storyId);
    final changed = storyId != null ? !(inStory && rows.length == 1) : rows.isNotEmpty;
    if (changed) {
      final members = [
        for (final m in sprint.members)
          if (m.item != id) m,
        if (storyId != null) SprintMember(block: storyId, item: id),
      ];
      await api.saveSprint(SprintFile(exists: true, blocks: sprint.blocks, members: members));
    }
  } on ScrumBoardApiException catch (e) {
    return (ok: false, reason: e.reason);
  } on ScrumBoardUnreachableException catch (e) {
    return (ok: false, reason: e.reason);
  }
  return (ok: true, reason: '');
}

/// SCB-21: assigns requirement [id] to story [storyId]: it becomes `planned`
/// (SCB-13.c order check) and gets a member row there. Returns the refusal
/// reason when the move is refused, for msg:scbMoveRefused.
Future<({bool ok, String reason})> assignRequirementToSprint(
  ScrumBoardApi api,
  String id,
  String storyId,
) async {
  try {
    final requirements = await api.requirements();
    final sprint = await api.sprint();
    final status = requirements.where((r) => r.id == id).map((r) => r.status).firstOrNull;
    if (status == null) return (ok: false, reason: 'unknown requirement $id');
    return await moveRequirement(api, id: id, status: status, sprint: sprint, storyId: storyId);
  } on ScrumBoardApiException catch (e) {
    return (ok: false, reason: e.reason);
  } on ScrumBoardUnreachableException catch (e) {
    return (ok: false, reason: e.reason);
  }
}
