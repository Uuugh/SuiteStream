# Sprint 014 Planning

**Status: finished (Executive said Run Sprint 14; merged into main).** Planned; Kobayashi re-review verdict revise, must-fix 14 resolved by Takahashi. Branch `sprint014`. Executive words: "Run Sprint 14" (2026-11-24) released the pause at 014 (`scrum/order/order003.md`); the epic (PBI-049) stays agent-driven with no sprint limit. Review: `kobayashi_plan_review.md` (findings 1 to 18, Re-review section).

## Availability and timebox

Assumption (A, not a confirmed fact): all four developers (Ito, Tanaka, Yamamoto, Nakamura) are available with no leave; no repo record confirms it, and the Executive may correct it. Yamamoto and Nakamura were absent from planning only. Timebox: five days (`.github/skills/sprint-planning/SKILL.md`), ended early when the work is done.

## Usage decision (`scrum/usage/README.md`, When)

Anchor: the Executive's reading at sprint start, session 23% (resets 12:40 PM), week 49%. `bash scrum/usage/usage.sh project "Sonnet 5.5" 9 23 49`: session about 42%, week about 52% (2.062 session and 0.287 week % per story point, low confidence: 2 used rows; trend falling). With 2 points of margin for Takahashi and Kobayashi (11): about 46% and 52%. Below 70% (Caution): no notice needed. Velocity (`scrum/velocity.csv`): 8, 8, 10 points planned and completed in Sprints 011 to 013, so about 10 stays right; the next candidate (PBI-085, 3) would make 12 and is left out. Model: the estimate is for Sonnet 5.5 (`scrum/usage/usage.log`, estimated per model). If the orchestrator runs on another model, the Sonnet figure is borrowed and that model's first row has no estimate; Takahashi says so in the review.

## Sprint goal

The ScrumBoard looks and behaves as the Executive asked after Sprint 013: one zoom icon, status tokens at the row end, theme and zoom kept across restarts, no missed first change, and the server able to give the usage estimate and trend from `usage.sh`. PBI-106 ends at the server, API, fake and tests: the board shows no usage until PBI-084 (the chart) is built, and the review does not report it as "usage on the board".

## Scope (9 points; candidates taken in the order of the refinement outcome in `order003.md`)

| Wave | PBI | Work | Points | Owner |
|---|---|---|---:|---|
| 0 | PBI-109 (token) | `scrumBlockWidth` token (360) in `scrum_theme.dart`, landed first (Ito's wave 1 waits on it) | (in 109) | Tanaka |
| 0 | PBI-107 | Page reads the baseline stamp when it starts (SCB-22); test: a change before the first poll reloads the panes | 1 | Tanaka |
| 0 | PBI-102 | One zoom icon with a minus and a plus half (SCB-20, SCB-20.a rewritten); a widget test per half and per limit | 1 | Tanaka |
| 0 | PBI-104 | Theme and zoom stored by the page in browser local storage; unreadable store falls back to defaults; filters and outline not kept (new SCB-24) | 1 | Tanaka |
| 0 | PBI-108 | One status choice helper; the Backlog block uses it (SCB-21, SCB-07.f); helper test | 1 | Ito |
| 0 | PBI-106 | Server runs `usage.sh estimate` and `usage.sh trend` (read only, fixed arguments, no page input); endpoints, API client, fake; fake script for tests; missing, failing or timed-out script or missing bash gives `ok: false` with a reason, not empty data; SCB-01.a test and the server comment narrowed to the one runner file | 3 | Nakamura |
| 1 | PBI-103 | Status token right-aligned at the end of the first line of each requirement row, sub-rows too (new SCB-23); widget test of the position | 1 | Yamamoto |
| 1 | PBI-108 (column) | Features column uses the helper; column test of the backlog choice (see Behaviour change) | (in 108) | Yamamoto |
| 1 | PBI-109 | `BoardTokens.blockWidth` from `scrumBlockWidth` (SCB-06.g); layout tests pass | 1 | Ito |
| 2 | all | Nakamura runs the integration test, builds web, checks the server; Takahashi records | - | Nakamura, Takahashi |

Points: 1+1+1+1+3 in wave 0, 1+1 in wave 1: 9.

Not in this sprint: PBI-085 to PBI-088, PBI-083, PBI-084 (the usage chart that will show PBI-106's output; it now carries PBI-106's two chart clauses, `scrum/product_backlog.csv`), PBI-094 and PBI-082 (need PBI-063 verified), calendar items (PBI-089, PBI-100). PBI-103's Issues-column part applies when PBI-082 is built. Changing `scrum/usage/usage.sh` is out of scope: nobody owns it this sprint and PBI-105 is In Review.

## Behaviour change (PBI-108)

PBI-108 is not a pure refactor. Today the Backlog block's 'backlog' choice calls `moveRequirement` (sets `backlog` and removes the requirement's Members rows, SCB-07.f), while the Features column's calls only `api.setStatus` and leaves a Members row naming a `backlog` requirement. With the shared helper, the column's 'backlog' choice now also removes the requirement from its story. This matches SCB-07.f; the PBI-108 row in `scrum/product_backlog.csv` names it.

## Dependencies on In Review work

PBI-107 on PBI-098; PBI-102, PBI-103, PBI-104 and PBI-108 on PBI-097; PBI-109 on PBI-101; PBI-106 on PBI-105. If the Executive rejects one of those, the dependent item is reopened in the next refinement.

## Requirement rows

Takahashi writes the statement cells before wave 0: SCB-20 and SCB-20.a rewritten (PBI-102), new SCB-23 (token position, PBI-103), new SCB-24 (theme and zoom kept, PBI-104), SCB-13.b rewritten to add the two usage requests (PBI-106), a new row SCB-14.o for the script output (PBI-106: the two endpoints, the `{ok, output, reason}` answer, and `ok: false` with a reason for a missing, failing or timed-out script; the dropped SCB-14.l is not reused), SCB-01.a test note (PBI-106). Each row built goes to `planned` with a named test in this sprint and stays there until the Executive verifies it in the browser.

## File ownership (paths under `scrum/scrumboard/`)

| Owner | Files |
|---|---|
| Nakamura | `lib/server/*` (new `usage_script.dart`), `lib/src/api/*` except `reload_scope.dart`, `bin/*`, `test/server/*` (fake scripts under `test/server/fixtures/`), `test/api/*`, `test/integration/*`, `build/` |
| Yamamoto | `requirements/messages/*.arb` (six), root `tool/sync_messages.sh`, `assets/messages/*`, `lib/src/l10n/*`, `lib/src/features/*`, `test/l10n/*`, `test/features/*` |
| Ito | `lib/src/board/*` (new `status_choice.dart`), `test/board/*` |
| Tanaka | `lib/main.dart`, `lib/src/app/*` (new `board_prefs.dart`, `board_prefs_default.dart`, `board_prefs_web.dart`), `lib/src/theme/*`, `lib/src/api/reload_scope.dart`, `test/app/*`, `test/api/reload_scope_test.dart`, `test/theme/*` |
| Takahashi | `scrum/sprints/sprint014/*`, backlog, velocity, `scrum/usage/usage.log`, statement, status and test cells of `requirements/scrumboard.md` |

Handoffs: `scrum/sprints/sprint014/handoffs.md`. Keys from anyone but Yamamoto go in `strings_<name>.md`; none are expected (no new labels: the zoom halves keep msg:scbZoomOut and msg:scbZoomIn).

## Fixed names

- **Ito**, `lib/src/board/status_choice.dart`: `Future<({bool ok, String reason})> applyStatusChoice(ScrumBoardApi api, {required String id, required String choice, String? storyId})`. `choice` is the chosen status; the helper fetches the requirements (current status) and the sprint file itself, as `assignRequirementToSprint` does. Mapping as the Backlog block does today: 'retired' -> `api.retire`; a story -> `assignRequirementToSprint`; 'backlog' -> `moveRequirement` with `storyId: null`; any other choice -> `api.setStatus` (review note 15).
- **Tanaka**, `lib/src/app/board_prefs.dart`: `abstract interface class BoardPrefsStore { ({ThemeMode? theme, int? zoom}) load(); void save({ThemeMode? theme, int? zoom}); }` and `MemoryBoardPrefs`; `BoardPrefsStore defaultBoardPrefs()` comes from a conditional import: `board_prefs_default.dart` (returns `MemoryBoardPrefs`, the default) or `board_prefs_web.dart` (`BrowserBoardPrefs`, local storage through `dart:js_interop`, an SDK library: no new package) only `if (dart.library.js_interop)`. No file outside `board_prefs_web.dart` imports `dart:js_interop`, so `flutter test` on the Dart VM compiles. `ScrumBoardApp({BoardPrefsStore? prefs})`; null uses `defaultBoardPrefs()` and never touches browser storage on the VM. Keys `scrumboard.theme`, `scrumboard.zoom`; a zoom outside the token limits or not a step is ignored. The local-storage path stays an Executive browser check.
- **Tanaka**, zoom control (PBI-102): one custom-drawn control (minus subscript, plus superscript; no Material icon has it) with two hit areas; keys `scbZoomOut` and `scbZoomIn` stay on the halves so the existing tests find them.
- **Nakamura**: `GET /api/usage/estimate` and `GET /api/usage/trend` answer `{"ok": bool, "output": "<script text>", "reason": "<text>"}`; `ScrumBoardApi.usageEstimate()` and `ScrumBoardApi.usageTrend()` return `Future<({bool ok, String output, String reason})>`; `FakeScrumBoardApi` carries both. The server runs `<bash> scrum/usage/usage.sh estimate` or `trend` with no further argument, from the repository root, with the time limit `usageScriptTimeout = Duration(seconds: 10)` (named constant in `usage_script.dart`). The runner takes the limit as a parameter defaulting to `usageScriptTimeout`; after a timeout it kills bash and returns without waiting for stdout to close (on Windows the orphaned child keeps it open) (note 16). Start options: `--usage-script <path>` (default `scrum/usage/usage.sh`) and `--bash <path>` (overrides the default bash). Default bash (must-fix 14): on Windows it is Git Bash, found by its install path (from `git --exec-path`, or the usual `C:\Program Files\Git\bin\bash.exe`) or by the first `bash.exe` on PATH outside `System32`; never a bare `bash`, which Windows resolves to `C:\Windows\System32\bash.exe` (WSL). No Git Bash found -> `ok: false` with a reason. Elsewhere the default is `bash`. The `test/server/` helper finds bash with the same lookup. The server runs `usage.sh` with no model argument, so the figures are always Sonnet 5.5 (note 17; PBI-084 labels its chart so). Results: exit 0 -> `ok: true` with the output as printed (including `estimate`'s "no usable rows"); non-zero exit (for example `trend`'s "No rows for ...") -> `ok: false`, reason from the script's output; script missing, bash not found, or timeout -> `ok: false` with a reason saying which. Both options are acceptable for a local 127.0.0.1-only server whose page cannot set them.

## Named tests (beyond those in the scope table)

- SCB-13.b, SCB-14.o (`test/server/`): both routes answer and are not "not found"; missing script; bash not found; non-zero exit; timeout (fake script that sleeps a few seconds, past a short limit passed to the runner; the test ends without waiting on the orphaned child); exit 0 with output; on Windows the bash lookup never returns a path under `System32`. API client and fake tests in `test/api/`.
- SCB-01.a: narrowed to the runner file `usage_script.dart`; asserts it runs only the configured path with `estimate` or `trend`.
- SCB-21, SCB-07.f: helper test (`test/board/`); column test (`test/features/`): choosing backlog for a planned story member removes its Members row.
- SCB-23: token position on a requirement row and a sub-row, at the narrowest DEF-01 width (SCB-15.c).
- SCB-24 (`test/app/`): theme and zoom survive a new `ScrumBoardApp` built on the same `MemoryBoardPrefs`; filters and outline do not; an unreadable store, and a zoom out of range or off-step, give the defaults; `ScrumBoardApp()` with no `prefs` starts with the default theme and zoom (the integration runs in `test/integration/app_test.dart` keep compiling).
- SCB-06.g: `backlog_timeline_test.dart` asserts the width against `scrumBlockWidth` (360), not `BoardTokens.blockWidth`.

## Scrum Master decisions (Takahashi, on the re-review)

- Must-fix 14: resolved in "Fixed names" (Git Bash default, same lookup in tests, `System32` test).
- Assumption A (no leave): kept as an assumption, not a fact (see "Availability and timebox"); the Executive may correct it.
- Assumption B (10-second timeout): accepted, on Kobayashi's timings.
- Notes 15 to 17: in "Fixed names" and "Named tests".
- Note 18, for PBI-084's refinement, not this sprint: reconcile SCB-14.g (empty chart with msg:scbNoUsage) with the clause moved from PBI-106 (an error, not an empty chart); and a backlog candidate: `usage.sh trend` compares only the first of the last three estimates with the last one.

## Done

Every test named with its SCB ID; `flutter analyze` and `flutter test` pass in `scrum/scrumboard` and at the root; checked at the DEF-01 window sizes in light and dark; the review lists the Executive's checks: zoom icon, token position, theme and zoom after a restart (local storage), the Features column's 'backlog' choice now removing the requirement from its story, and a test row for PBI-106 against the real `usage.sh`, run on the Executive's Windows machine.
