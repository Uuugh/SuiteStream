import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/board/sprint_assign.dart';

/// SCB-21: the one place where a status-menu choice for requirement [id]
/// becomes server calls, used by the Features & Requirements column and the
/// Backlog block alike (PBI-108).
///
/// [choice] is the chosen status; [storyId] names the story for 'planned'.
/// - 'retired' -> `api.retire` (SCB-19.a);
/// - 'planned' with a story -> [assignRequirementToSprint];
/// - 'backlog' -> [moveRequirement] with no story: the status becomes
///   `backlog` and the requirement's Members rows are removed (SCB-07.f);
/// - any other choice -> `api.setStatus` (SCB-13.c may refuse).
///
/// The current status and the sprint file are read here, as
/// [assignRequirementToSprint] does. A refusal or a failure is `ok: false`
/// with its reason (for msg:scbMoveRefused), never an exception.
Future<({bool ok, String reason})> applyStatusChoice(
  ScrumBoardApi api, {
  required String id,
  required String choice,
  String? storyId,
}) async {
  try {
    if (choice == 'retired') return await api.retire(id);
    if (choice == 'planned' && storyId != null) {
      return await assignRequirementToSprint(api, id, storyId);
    }
    if (choice == 'backlog') {
      final requirements = await api.requirements();
      final status = requirements.where((r) => r.id == id).map((r) => r.status).firstOrNull;
      if (status == null) return (ok: false, reason: 'unknown requirement $id');
      final sprint = await api.sprint();
      return await moveRequirement(api, id: id, status: status, sprint: sprint, storyId: null);
    }
    return await api.setStatus(id, choice);
  } on ScrumBoardApiException catch (e) {
    return (ok: false, reason: e.reason);
  } on ScrumBoardUnreachableException catch (e) {
    return (ok: false, reason: e.reason);
  }
}
