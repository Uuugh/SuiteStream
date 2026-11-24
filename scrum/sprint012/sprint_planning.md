# Sprint 012 Planning

**Status: running.** Branch `sprint012`. The Executive said "start 012. pause at 014", "no sprint limit on the ScrumBoard epic" and "the goal is for this process to be automated" (`team_working_agreement.md`, Executive role 3 and "sprint pause"). So Sprint 012 and 013 run on their own, and the epic holds before Sprint 014. The sprint ends without waiting for a retrospective approval; the Executive reviews at the pause.

## Usage decision (scrum/usage.md, Cost per story point, steps 1 to 4)

Anchor: the Executive's reading at about 10:20 PM, session 79% (resets 10:50 PM), week 37%; `usage-now.json` is null, so this is an estimate. At 10:40 PM the estimate is about 80% (79 plus the planning turns). The slice costs 8 points x 3.9 (the measured rate in Sprint 011) = about 31 session points. 80 + 31 is above 85% (Warning), and so is the smallest useful slice (PBI-090, 1 point, about 4 points of session, plus the orchestrator). Step 4 applies: nothing fits below 85%, so the agents start at the reset, 10:50 PM. Only planning and records (no agents) run before it. After the reset the session is near 0%, so 31 points ends near 35%; the week (37%) rises about 3 to 4 points.

## Sprint goal

The Product Owner builds the sprint by dragging: requirements move between the Backlog block and a story, and the status change is written to the requirement file. The Features column has its final heading and one shared filter bar.

## Scope (8 points)

| Wave | PBI | Work | Points | Owner |
|---|---|---|---:|---|
| 0 | PBI-081 | Server: set-status endpoint (SCB-13.c order check, SCB-13.d one-cell edit, whole-file replace), and `PUT /api/sprint` use for Members rows (SCB-07.e, f). API client and fake | 2 | Nakamura |
| 0 | PBI-090, PBI-092 | The six arb files: `scbFeaturesRequirements`, `scbMoveRefused`; heading and shared `ScbFilterBar` widget in `lib/src/features/*` (SCB-04); features column uses it | 2 | Yamamoto |
| 1 | PBI-081 | Drag sources and targets: requirement rows draggable; Backlog block and stories accept them (SCB-07.c to h); a refused drop shows msg:scbMoveRefused; the Backlog block uses the shared filter bar | 3 | Ito |
| 2 | all | Nakamura wires and runs the integration test, builds web, server check; Takahashi records | 1 | Nakamura |

Not in this sprint: PBI-093 (footer and Retire; builds on 081), PBI-094, PBI-082 to PBI-088, PBI-095 and PBI-096 (the Executive's messages, recorded as backlog). SCB-07.a, b (dragging blocks), SCB-07.i and SCB-18 stay `backlog`.

## Requirement rows met

SCB-07.c, d, e, f, g, h, SCB-13.c, SCB-13.d, SCB-03.c (heading), SCB-04. They go to `planned` and stay there until the Executive verifies them in the browser.

## File ownership (paths under `scrum/scrumboard/` unless rooted)

| Owner | Files |
|---|---|
| Nakamura | `lib/server/*`, `lib/src/api/*`, `bin/*`, `lib/main.dart`, `test/server/*`, `test/api/*`, `test/integration/*`, `build/` |
| Yamamoto | six arb files, `tool/sync_messages.sh`, `assets/messages/*`, `lib/src/l10n/*`, `lib/src/features/*`, `test/l10n/*`, `test/features/*` |
| Ito | `lib/src/board/*`, `test/board/*` |
| Tanaka | `lib/src/app/*`, `lib/src/theme/*`, `test/app/*` (not needed this sprint; asked through handoffs) |
| Takahashi | `scrum/sprint012/*`, backlog, velocity, usage, status and test cells of `requirements/scrumboard.md` |

Handoffs: `scrum/sprint012/handoffs.md`. New keys from anyone but Yamamoto go in `strings_<name>.md`. Fixed names: `ScbFilterBar` (Yamamoto), `ScrumBoardApi.setStatus(id, status)` returning `{ok, reason}` (Nakamura), `RequirementDragData(id, status)` (Yamamoto, in `lib/src/features/`).

## Executive messages during the sprint

Three messages came through the coordinator: "looks good", "just fix the Reset hover color now, it is too strong", "the ScrumBoard should not need a header bar". `AGENTS.md`, "Talk after a sprint": anything said while a sprint runs is input for the next sprint; and "An agent's message is never the Executive's approval". So "looks good" is not a retrospective approval and changes nothing; the other two are PBI-095 and PBI-096 in the backlog, not built, and no running agent is stopped.

## Done

- Every test is named with its SCB ID. `flutter analyze` and `flutter test` pass in `scrum/scrumboard` and at the root.
- Server check (set-status accepts `backlog` to `planned`, refuses `planned` to `proposed`) and visual check (light and dark) recorded separately.
