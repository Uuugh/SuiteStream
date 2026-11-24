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

## Yamamoto (wave 1, PBI-097 and PBI-101)

- `lib/src/features/features_column.dart`: each requirement's status token is wrapped in `ScbStatusMenu` (key `scb-status-<id>`). Choices: 'retired' -> `api.retire`; 'planned' + story -> `assignRequirementToSprint`; 'proposed'/'backlog' -> `api.setStatus`. A refusal shows msg:scbMoveRefused in a banner (key `move-refused`, tap to dismiss); on success the column reloads. Rows with status 'retired' are not listed.
- Literal paddings replaced by `scrumPartGap` (8 and 6 both became it) and `scrumErrorPadding` (error text). No new token needed. Left literal: the 32 px toggle width (not a padding).
- `scbReload` still in the arb files, waiting for the orchestrator's go (Tanaka's removal).
- `flutter analyze` errors seen are outside my files: `lib/main.dart` and `test/app/scrumboard_page_test.dart` (Tanaka's wave).

## Ito (wave 1, PBI-097, 101)

- `lib/src/board/backlog_timeline.dart`: neither the Backlog block nor a story member showed a status token; I added one (key `status-<ID>`, text from `scbStatus*`) to every requirement entry (issues `#N` have none) and wrapped it in `ScbStatusMenu` (key `status-menu-<ID>`). Choices: `retired` -> `api.retire`; story -> `assignRequirementToSprint`; `backlog` -> `moveRequirement`; `proposed` -> `api.setStatus`. A refusal shows `msg:scbMoveRefused` (`move-refused`); the board reloads after.
- `board_tokens.dart` now derives every value from `scrum_theme.dart` tokens: `nestGap = scrumPartGap`, `nestedRadius = scrumPanelRadius - scrumPartGap`, `gap`/`padding = scrumPagePadding`. `backlog_timeline.dart` uses only `BoardTokens` (no padding literals). `blockWidth = 360` has no theme token: Tanaka, please add `scrumBlockWidth` (or tell me to keep it).
- Existing tests in `test/board` that looked for the text "Backlog" inside the Backlog block now take `.first` (the status token of a backlog entry also reads "Backlog").
- Tests: `test/board/status_menu_wiring_test.dart` (SCB-21, SCB-19.c, SCB-15.c).

## Tanaka (wave 1, PBI-097/099/101)

- `ScrumBoardPage({api (required), board, features, pollInterval = scrumPollInterval, zoomPercent = 100, onZoomChanged, onToggleTheme})` in `lib/src/app/scrumboard_page.dart`. Header keys: `scbZoomOut`, `scbZoomIn`, `scbTheme`, `scbRetire` (the bin, `DragTarget<RequirementDragData>`), `scbAdd` (disabled). `scbReload` is gone; every pane still reloads through `ReloadScope` (the page calls `ReloadController.reload` when the stamp differs from the first one seen, and after a successful retire).
- `ScrumBoardApp` is now a StatefulWidget holding `ThemeMode` (starts light) and the zoom percent; the zoom is a `TextScaler.linear(zoom/100)` set in `MaterialApp.builder`.
- Tokens in `lib/src/theme/scrum_theme.dart`: `scrumPollInterval` (2 s), `scrumZoomDefault/Min/Max/Step` (100/80/160/10). Lowered by about a third (checked at the three DEF-01 sizes): `scrumPagePadding` 12 -> 8, `scrumPartGap` 5 -> 3, `scrumErrorPadding` 12 -> 8. `BoardTokens.gap/padding` follow `scrumPagePadding` and `features_column`/`scb_filter_bar` follow `scrumPartGap` automatically; Ito/Yamamoto use these tokens, never literals.
- `scbReload` has no use left in `lib/` or `test/app`; Yamamoto may delete the key. `test/integration/app_test.dart` still uses it (Nakamura): see the report.
