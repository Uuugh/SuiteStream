# Sprint 013 Handoffs

Owners publish here what others need.

## Yamamoto (wave 0, PBI-097)

- Arb keys added to all six files and synced to `assets/messages`: `scbZoomIn`, `scbZoomOut`, `scbTheme`, `scbRetire`, `scbAdd`, `scbStatusRetired`, `scbStatusSprintItem` ({name}), `scbStatusMenu`. `scbStatusProposed`, `scbStatusBacklog` and `scbMoveRefused` already existed (unchanged).
- `scbReload` is still in the arb files: `lib/src/app/scrumboard_page.dart`, `test/app/scrumboard_page_test.dart`, `test/integration/app_test.dart` and `test/l10n/messages_test.dart` use it. Tanaka removes the use in wave 1; then Yamamoto deletes the key from the six arb files (and the key list and two asserts in `test/l10n/messages_test.dart`), then runs `tool/sync_messages.sh`.
- Public: `ScbStatusMenu({super.key, required String status, required List<({String id, String name})> stories, required void Function(String status, String? storyId) onSelected, required Widget child})` in `lib/src/features/scb_status_menu.dart` (import `package:scrumboard/src/features/scb_status_menu.dart`). Tapping `child` opens a PopupMenu: Proposed, Backlog, one item per story ("Sprint: {name}"), Retired. `onSelected` gets 'proposed', 'backlog', 'planned' (with the story id) or 'retired' (id null). The item equal to the current `status` (non-story) is disabled. Item keys: `scbStatusMenu.proposed`, `.backlog`, `.story.<id>`, `.retired`. The caller handles scbMoveRefused and `api.retire`. Needs a `MessagesScope` above it.

## Ito (wave 0, PBI-097 board part)

Public names in `scrum/scrumboard/lib/src/board/sprint_assign.dart`:
- `List<({String id, String name})> upcomingStories(SprintFile file, {int limit = 3})`: story blocks in file order.
- `Future<({bool ok, String reason})> assignRequirementToSprint(ScrumBoardApi api, String id, String storyId)`: reads requirements and sprint, sets `planned` via `api.setStatus` (SCB-13.c), adds the member row, saves the sprint. Returns `ok: false` and the reason when refused or unreachable; the caller shows msg:scbMoveRefused with it. Returns a record, not void.
- `Future<({bool ok, String reason})> moveRequirement(api, {id, status, sprint, storyId})`: the shared move the board drop uses (storyId null = backlog).
- `BacklogTimeline` now hides members whose requirement is not in the requirement list (SCB-19.c); issues `#N` stay.

## Nakamura (wave 0, PBI-098)

Public names (in `scrum/scrumboard/lib/src/api/scrumboard_api.dart`):
- `ScrumBoardApi.changeStamp()` -> `Future<String>`; `GET /api/changes` answers `{"stamp": "<string>"}`.
- `ScrumBoardApi.retire(String id)` -> `Future<({bool ok, String reason})>`; `POST /api/requirements/<id>/retire`, a refusal (unknown id) is `ok: false` with a reason, not an exception.
- `FakeScrumBoardApi.bump()` (changes the stamp), `FakeScrumBoardApi.retireCalls` (ids retired), `calls['changeStamp']`, `calls['retire']`. The fake stamp also changes when `requirementList` or `sprintFile` is replaced or edited in its ids/statuses.
- Server: `lib/server/requirement_retire.dart` (`retireRequirement`). `retired.md` is now in `excludedRequirementFiles` so its rows are never listed as requirements (SCB-19.c).
