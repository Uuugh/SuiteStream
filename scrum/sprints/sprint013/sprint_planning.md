# Sprint 013 Planning

**Status: finished (recorded automatically).** Branch `sprint013`. Executive words: "start 012. pause at 014", "no sprint limit on the ScrumBoard epic", "the goal is for this process to be automated with me tweaking priorities". `team_working_agreement.md` (sprint pause: "pause at N" means sprints before N run, N does not) so Sprint 013 runs on its own and the epic holds before Sprint 014. The Executive reviews at the pause; no retrospective approval is waited for.

## Usage decision (scrum/usage.md, Cost per story point, steps 1 to 4)

Anchor: the Executive's reading at 11:18 PM, session 17% (resets 3:50 AM), week 40%. `usage-now.json` is null, so the figure is an estimate; at 11:20 PM it is about 18% (planning turns only). Slice = 10 points. Rates: Sprint 011 gave 3.9 session points per story point (10 x 3.9 + 3 = 42, ends near 60%); Sprint 012 (the newer measurement, 17 points for 8 story points, orchestrator included) gives about 2.1 per point (ends near 40%). Both stay below 85% (Warning) and below 70% (Caution): no notice needed, start now. Week: 40 plus about 4 to 5 = about 45%.

## Sprint goal

The ScrumBoard controls sit where the Executive asked: zoom and theme icons, the recycling bin and the add control in the header right zone, a menu on each status token, no Reload button because the server tells the page when a file changed, and tighter padding.

## Scope (10 points)

| Wave | PBI | Work | Points | Owner |
|---|---|---|---:|---|
| 0 | PBI-098 | Server: `GET /api/changes` (a stamp that changes when any requirement file, `scrum/sprint.md`, `scrum/usage.md` or a progress file changes); `PUT`-style retire endpoint `POST /api/requirements/<id>/retire` (SCB-19.a: row moved to `requirements/retired.md`); API client and fake | 3 | Nakamura |
| 0 | PBI-097 | The six arb files: header icon labels, status menu labels, retire and add labels; shared `ScbStatusMenu` widget in `lib/src/features/`; Features & Requirements column uses it | 2 | Yamamoto |
| 1 | PBI-097, 099, 101 | Header right zone: zoom - and +, theme button, recycling bin (drop target, calls retire), + add control (disabled until PBI-083); Reload removed; the page polls the stamp and reloads its panes; padding tokens reduced | 3 | Tanaka |
| 1 | PBI-097 | Status token menu on requirement entries in the Backlog block and the story members (uses the shared widget); assign-to-sprint helper | 1 | Ito |
| 2 | all | Nakamura wires, runs the integration test, builds web and checks the server; Takahashi records | 1 | Nakamura |

Not in this sprint: PBI-082 to PBI-088, PBI-093 (its footer is dropped by PBI-097; its Retire part is done here for requirements only), PBI-094 (issues), PBI-100 and PBI-089 (Calendar, not ScrumBoard), PBI-091. Issues in the status menu and the bin wait for PBI-094 and PBI-082.

## Requirement rows met

SCB-15.a and SCB-15.d (header replaces footer), SCB-19 to SCB-19.c (requirements only), SCB-01.c and SCB-12.c (Reload removed; page synced by the server), and new rows written for the header icons, the status menu and the change stamp. They go to `planned` and stay there until the Executive verifies them in the browser.

## File ownership (paths under `scrum/scrumboard/`)

| Owner | Files |
|---|---|
| Nakamura | `lib/server/*`, `lib/src/api/*` except `reload_scope.dart`, `bin/*`, `test/server/*`, `test/api/*`, `test/integration/*`, `build/` |
| Yamamoto | `requirements/messages/*.arb` (six), root `tool/sync_messages.sh`, `assets/messages/*`, `lib/src/l10n/*`, `lib/src/features/*`, `test/l10n/*`, `test/features/*` |
| Ito | `lib/src/board/*`, `test/board/*` |
| Tanaka | `lib/main.dart` (taken from Nakamura for this sprint), `lib/src/app/*`, `lib/src/theme/*`, `lib/src/api/reload_scope.dart`, `test/app/*`, `test/api/reload_scope_test.dart` |
| Takahashi | `scrum/sprints/sprint013/*`, backlog, velocity, usage, status and test cells of `requirements/scrumboard.md` |

Handoffs: `scrum/sprints/sprint013/handoffs.md`. Keys from anyone but Yamamoto go in `strings_<name>.md`.

Fixed names: `ScrumBoardApi.changeStamp()` returns `Future<String>` (Nakamura); `ScrumBoardApi.retire(String id)` returns `Future<({bool ok, String reason})>` (Nakamura); `ScbStatusMenu` (Yamamoto, `lib/src/features/scb_status_menu.dart`): `ScbStatusMenu({required String status, required List<String> upcomingSprints, required void Function(String status, String? sprint) onSelected, Widget child})`; `Future<void> assignRequirementToSprint(ScrumBoardApi api, String id, String blockId)` (Ito, `lib/src/board/sprint_assign.dart`); `ScrumBoardPage` takes `api` (Tanaka).

## Done

Every test named with its SCB ID; `flutter analyze` and `flutter test` pass in `scrum/scrumboard` and at the root; server check and visual check (light and dark) recorded separately.

## Revision after Kobayashi's plan review (`kobayashi_plan_review.md`; the first agents start only after it)

1. Statement cells of `requirements/scrumboard.md` (SCB-01.a, SCB-01.c, SCB-12.c, SCB-13.b, SCB-13.d, SCB-15.a, SCB-15.d, SCB-16.a, SCB-19 and new rows SCB-20 header icons, SCB-21 status menu, SCB-22 change stamp): Takahashi writes them before wave 0. A single `+` in the header stands for SCB-16.a until PBI-083 builds the popup; it is disabled.
2. Yamamoto owns the six `requirements/messages/*.arb`, `tool/sync_messages.sh` (repo root `tool/`) and the copies in `scrum/scrumboard/assets/messages`. Keys fixed now: `scbZoomIn`, `scbZoomOut`, `scbTheme`, `scbRetire`, `scbAdd`, `scbStatusProposed`, `scbStatusBacklog`, `scbStatusRetired`, `scbStatusSprintItem` (placeholder `{name}`), `scbStatusMenu`. `scbReload` is deleted when Reload goes.
3. Waves: wave 0 = Nakamura (server, API, fake), Yamamoto (arb and the `ScbStatusMenu` widget), Ito (helpers). Wave 1 = Tanaka (header, poll, padding tokens), Yamamoto (features column wiring and padding), Ito (Backlog block wiring and padding). Wave 2 = Nakamura.
4. Menu target: the sprint choices are the next up to 3 **story blocks** of the sprint file in file order (members belong to stories, SCB-07.c, SCB-02.c); an id and a name. Ito publishes `List<({String id, String name})> upcomingStories(SprintFile file, {int limit = 3})` and `Future<void> assignRequirementToSprint(ScrumBoardApi api, String id, String storyId)` (it sets the status per the order check and adds the member). Revised signature: `ScbStatusMenu({super.key, required String status, required List<({String id, String name})> stories, required void Function(String status, String? storyId) onSelected, required Widget child})`. A choice that SCB-13.c refuses shows msg:scbMoveRefused, as a refused drop does. Choosing "retired" calls `api.retire`; the caller (Yamamoto's column, Ito's block) does it, so a retired requirement disappears and members naming a retired requirement are hidden (SCB-19.c, tested by Ito).
5. Padding (PBI-101): Tanaka lowers the tokens in `scrum_theme.dart`; Ito derives `board_tokens.dart` from them and removes literals in `backlog_timeline.dart`; Yamamoto replaces literal paddings (`EdgeInsets.all(8)`) in `features_column.dart` with tokens.
6. `lib/src/api/reload_scope.dart` and its test belong to Tanaka this sprint (the poll drives it). Poll interval: token `scrumPollInterval` = 2 seconds in `scrum_theme.dart`. The retire endpoint is `POST /api/requirements/<id>/retire`. The change stamp covers requirement files, `scrum/sprint.md`, `scrum/usage.md` and the progress folder; issues are not covered until PBI-094. `FakeScrumBoardApi` carries `changeStamp` and `retire` in wave 0. `ScrumBoardPage` takes `api`; Tanaka updates the five test call sites. "The SuiteStream themes" means light and dark (`buildScrumTheme`): the theme button toggles them.
7. Capacity: about 2 points of margin are added for Takahashi's and Kobayashi's work; the estimate stays well below 70%.
