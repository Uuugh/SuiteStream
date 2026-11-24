# Sprint 014 Code Review (Kobayashi)

Scope: `git diff 689eb01..HEAD` for `scrum/scrumboard/lib`, `scrum/scrumboard/bin`, `scrum/scrumboard/test` and `requirements/scrumboard.md` (27 files; `scrum/XO` not read). Checked against `sprint_planning.md` (Fixed names, Named tests, Behaviour change, Done), `scrum/definition_of_done.md` and the rows SCB-01.a, 06.g, 07.f, 13.b, 14.o, 20, 20.a, 21, 22, 23, 24.

## Results I ran myself (2026-11-24, Windows, branch `sprint014` at 83b3333)

| Where | Command | Result |
|---|---|---|
| `scrum/scrumboard` | `flutter analyze` | No issues found |
| `scrum/scrumboard` | `flutter test` | 186 passed, 0 skipped, 0 failed (the bash-dependent SCB-14.o tests ran: Git Bash was found) |
| root | `flutter analyze` | No issues found |
| root | `flutter test` | 596 passed, 0 failed |
| `scrum/scrumboard` | `flutter build web --release --no-web-resources-cdn -o <scratch dir>` | Built; `main.dart.js` contains `localStorage` and `scrumboard.zoom`, so the web branch of the conditional import was taken. Built outside the repo; working tree still clean |

## Checks asked for

| Check | Finding |
|---|---|
| Named tests test the requirement and could fail | Yes for each. SCB-22 (PBI-107): without the start read, the first poll would take the bumped stamp as baseline and `seen.last` stays 0. SCB-07.f column test: the old column called only `setStatus`, so the Members row would remain. SCB-23: the old `Wrap` put the token after the ID, so `row.right - token.right == scrumPartGap` fails. SCB-20/20.a: each half and each limit asserted by key, `onTap` null and the values sent. SCB-24: survival on a new app, filters and outline not kept, broken store, zoom 70/170/115, no `prefs`. SCB-14.o timeout: a 3 s sleep against a 0.5 s limit, asserted under 3 s, so a runner that waits for the orphaned child fails. SCB-06.g: asserts `scrumBlockWidth`. |
| Windows Git Bash lookup never returns System32 bash | Holds. `findDefaultBash` rejects any candidate containing `\system32\`, `\sysnative\` or `\windowsapps\` (case-insensitive, slashes normalised), including the `git.exe`-derived and Program Files candidates; tests cover git on PATH (cmd and mingw64\bin), install path, PATH fallback, WSL-only PATH (null) and this machine. Edge in finding 4. |
| Usage script runner safe | Fixed arguments: `Process.start(bash, [script, mode])`, no shell, `mode` checked against `{'estimate','trend'}` and only literals passed from `server.dart`; the routes read nothing from the request. Timeout is the named `usageScriptTimeout` (10 s), a parameter. After a timeout bash is killed and the answer returns at once (tested). Notes in findings 2 and 3. |
| Conditional import compiles on VM and web | Yes: VM by `flutter test` (and `defaultBoardPrefs()` is `MemoryBoardPrefs`, asserted); web by the release build above. Only `board_prefs_web.dart` imports `dart:js_interop`. |
| Theme tokens, not literals | Sizes are tokens (`scrumBlockWidth`, `scrumZoomIconWidth/Height/GlyphSize/MarkSize/Stroke`). Remaining literals in finding 5. |
| arb keys in all six languages | No new page text: the zoom halves reuse msg:scbZoomOut and msg:scbZoomIn; no `.arb` changed. Server reasons are English strings, as the existing refusal reasons are (finding 6). |
| Features column behaviour change | As planned: `_choose` now calls `applyStatusChoice`, so 'backlog' goes through `moveRequirement` with no story and removes the Members rows (SCB-07.f); the Backlog block uses the same helper. Tested in `features_column_test.dart` and `status_choice_test.dart`. |

## Findings

| # | Severity | Finding | Fix | Owner |
|---|---|---|---|---|
| 1 | Medium (must fix) | `scrum/scrumboard/README.md` is now wrong: it says the server "runs no shell and no process", and its options table and API table lack `--usage-script`, `--bash`, `GET /api/usage/estimate` and `GET /api/usage/trend`. A false security statement in user-facing docs fails the DoD (Documentation: instructions current) and misleads a reader about what the server runs. | State that the one process is `usage.sh estimate` or `trend` through bash (`usage_script.dart`); add the two options (with the Git Bash default and the System32 exclusion) and the two routes with `{ok, output, reason}`. | Nakamura |
| 2 | Low | After a normal exit the runner waits up to another `timeout` for stdout and stderr to close, so a script that exits but leaves a child holding the pipe answers after up to 20 s, not 10 s. | Wait for the streams with a short fixed grace (for example 1 s, a named constant), or subtract the time already used. | Nakamura |
| 3 | Low | After a timeout the `outDone` and `errDone` futures are left unawaited; a later stream error would be an unhandled async error in the server zone. Each request also starts a new bash with no limit on concurrent runs (local only, page has no input, so not a security issue). | `unawaited(outDone.catchError((_) {}))` (same for stderr); optionally let one run at a time per mode. Backlog item is enough. | Nakamura |
| 4 | Low | `findDefaultBash` matches the WSL folders only with a leading backslash, so a relative PATH entry such as `System32` would not be excluded; the rule is by folder name, not by the Windows folder. Unlikely in practice; the requirement still holds for every absolute PATH form tested. | Also reject any candidate under `%SystemRoot%` / `%windir%` from the environment, or compare path segments instead of substrings. | Nakamura |
| 5 | Low | Literals in `zoom_control.dart`: the disabled alpha `0.38` and the glyph ratios `0.3`, `0.72`, `0.75`. The project rule is theme tokens only. | Move the disabled alpha to a token in `scrum_theme.dart` (or use the theme's disabled color); name the glyph ratios as tokens. | Tanaka |
| 6 | Info | Usage reasons (`bash not found ...`, `usage script timed out after ...`) are English and not message keys. Nothing shows them yet. | When PBI-084 shows them, wrap them in a msg key with {reason}, as msg:scbMoveRefused does. Record in PBI-084's refinement. | Suzuki, Takahashi |
| 7 | Info | The SCB-23 test uses a column width of 320 as "about a third" of the 1024 DEF-01 width rather than the width the page gives the column; the SCB-14.o "bash not found" server path is tested with a non-existent bash path (reason "could not start bash"), the `null` case only on the runner. Both are acceptable. | None needed; optionally pump the full page at 1024 for SCB-23. | Yamamoto, Nakamura |
| 8 | Info | Untested here by design and owed to the Executive (sprint_planning Done): local storage on the real browser, the zoom icon's look, token position, the Features 'backlog' choice, and a run against the real `usage.sh` on the Executive's Windows machine. Rows stay `planned`. | Keep them in the sprint review list. | Takahashi |

## Verdict

**Revise**: fix finding 1 (README) before the sprint review; findings 2 to 5 can go to the backlog. The code, the tests and the requirement rows otherwise match the plan, and the analyze, test and web build results above are real.

## Audit of the review (`sprint-review` skill, step 7)

Checked the working tree on `sprint014` after 068d515: `sprint_review.md`, `velocity.csv`, `product_backlog.csv`, `questions.md`, `impediment_log.csv`, `order/order003.md`, `requirements/scrumboard.md`, `sprint_backlog.md`. `scrum/XO`: no change in `git status` and no commit in its log; not read.

| File | Check | Result |
|---|---|---|
| `product_backlog.csv` | Every row 10 fields; no duplicate IDs | Holds (awk count over all rows; the three quoted rows are older and have no comma inside quotes). New rows have no quotes |
| `product_backlog.csv` | PBI-102/103/104/106/107/108/109 | All `In Review`, sprint `014`, sizes match `sprint_backlog.md` (1,1,1,3,1,1,1 = 9) |
| `product_backlog.csv` | PBI-110 to 117 | Each traces to a source: 110 to 113 and 117 to code review findings 2 to 6; 115 to plan review note 17; 116 to Sato; 114 to the README (see A3). Sizes plausible. 116 is `Backlog` and waits on question 1; the rest `Ready` |
| `velocity.csv` | sprint014 row | 7 fields as the header, same quoting as sprint011 to 013; 9 planned, 9 completed, 0 carried match `sprint_backlog.md`. The test counts in its note: see A1 |
| `questions.md` | Format section | Holds: numbers 1 and 2 (lowest free), `Status: open`, choices on own lines indented 3 spaces, recommended first and marked. Q2 needs no choices. The file ends without a newline (cosmetic) |
| `impediment_log.csv` | IMP-003 | Present, 9 fields. Still `Open` (see A4) |
| `requirements/scrumboard.md` | Statuses | No row is `done`; SCB-14.o, 20, 20.a, 21, 22, 23, 24, 06.g, 07.f, 13.b are `planned`, as they must be until the Executive's checks. Correct |
| `ask_user.md` | Needed? | No. `AGENTS.md` (Questions) puts questions in `scrum/questions.md`; both are there. A separate file would duplicate them |
| `sprint_review.md` | Against role outputs | Goal, decisions and Executive checks match `sprint_backlog.md`, Sato and Suzuki; code review section is accurate (finding 1 fixed in 068d515: README now has `--usage-script`, `--bash`, both routes and the one process). Gaps below |

### Findings

| # | Severity | Finding | Fix | Owner |
|---|---|---|---|---|
| A1 | Medium | `sprint_review.md` (Demonstration) and the `velocity.csv` note say "34 and 88 tests re-run, all pass". No file in `scrum/sprint014` records that run, so the figure has no source (`AGENTS.md`, Safety: numbers from a measurement). The measured figures on record are mine above: 186 ScrumBoard tests and 596 root tests pass, analyze clean, web build done. | Either name where the 34 and 88 come from (which test files, which command) or replace them with the recorded 186 and 596 in both files. | Takahashi |
| A2 | Low | `sprint_review.md` "Code review" says findings 2 to 5 became PBIs; finding 6 also did (PBI-117), and PBI-114 and PBI-115 are not mentioned by source. | One line: 2 to 6 are PBI-110 to 113 and 117; PBI-114 README routes; PBI-115 plan review note 17. | Takahashi |
| A3 | Low | The README still says "The server writes one file only: `scrum/sprint.md`" and its API table lacks `GET /api/changes`, `PUT /api/requirements/{id}/status`, `POST /api/requirements/{id}/retire` (all present in `server.dart` / `scrumboard_api.dart`). This is the same kind of fault as finding 1 (DoD, Documentation). It predates Sprint 014, so PBI-114 is acceptable, but the review should not read as if the README is now current. | Say in `sprint_review.md` that the README is still incomplete (PBI-114), or fix it as a quick fix if the Executive asks. | Takahashi, Nakamura |
| A4 | Low | IMP-003 is `Open`, yet its own action ("run it before the Sprint 014 review") is done: this code review ran. `sprint_backlog.md` line 15 still says "The independent Kobayashi review has not run". | Set IMP-003 to `Resolved` with date and resolution (code review run 2026-11-24; days ran with roles collapsed), or keep it open and say why; update the line in `sprint_backlog.md`. | Takahashi |
| A5 | Low | Sato's "each half of the zoom icon is a small click target" has no PBI; it is only Executive check 1. Sato's "show the reason when usage fails" maps to PBI-084/117 but is not cited. | Add a PBI for the zoom target size or state in `sprint_review.md` that it waits on check 1. | Suzuki |
| A6 | Low | Step 5 (environmental changes) is missing from `sprint_review.md`. The Executive's pause at 015 (`order/order003.md`, 2026-11-24) belongs there. | One line under "How the sprint ran". | Takahashi |

### Audit verdict

**Revise** (light): A1 must be fixed before commit, because an unsourced figure would enter `velocity.csv`. A2 to A6 are one-line edits. Everything else (backlog rows, statuses, velocity figures, questions, requirement statuses, `scrum/XO` untouched) is correct.
