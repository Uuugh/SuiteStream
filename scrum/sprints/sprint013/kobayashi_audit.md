# Sprint 013 Audit (Kobayashi, retrospective step 8)

Scope: files changed in Sprint 013 (`git diff --stat main...HEAD` plus the working tree). `flutter analyze` in `scrum/scrumboard`: no issues. `flutter test` there: 145 tests pass. `git stash list` is empty.

## Stash incident check

Every handoff behavior exists in the working tree; no agent edit was lost.
- Yamamoto wave 1: `ScbStatusMenu` (key `scb-status-<id>`) with retire, assign and setStatus, the `move-refused` banner, retired rows hidden, `scrumPartGap` and `scrumErrorPadding` in `features_column.dart`.
- Ito wave 1: status token `status-<ID>` and `status-menu-<ID>`, `onStatus` handler, and `BoardTokens` derived from theme tokens in `backlog_timeline.dart` and `board_tokens.dart`; `status_menu_wiring_test.dart` is present.
- Tanaka wave 1: the page header keys, the 2 s poll, the `scrumZoom*` and `scrumPollInterval` tokens, the lowered paddings, and `ScrumBoardApp` as a StatefulWidget with theme mode and zoom.
- `scbReload` is gone from lib, from both arb sets and from the tests, except the single `findsNothing` assert.

## Findings

1. MUST-FIX (before commit): the retrospective records do not exist yet. `scrum/sprints/sprint013/` has no `sprint_review.md` or `sprint_retrospective.md`. `scrum/velocity.csv` has no sprint013 row, and `product_backlog.csv` still has PBI-097/098/099/101 as `In Sprint`. These are for Takahashi to write. The same applies to `scrum/impediment_log.csv` (the stash incident is a candidate entry) and to the `rule_tests.md` row 013 ("Not yet run"; update it if that test happens).
2. MUST-FIX: `requirements/scrumboard.md` rows that the code and tests now cover are still `backlog` with Tests `—`.
   - SCB-13.b: the retire and `/api/changes` routes are built. `server_test.dart` has groups named SCB-13.b, SCB-19.a and SCB-22 for them. Set the row to `planned` and name `scrum/scrumboard/test/server/server_test.dart`.
   - SCB-19.a: built in `lib/server/requirement_retire.dart` and tested in `server_test.dart` ("retire moves the row to retired.md", "refuses an unknown id"). Set to `planned` with that test file.
   - SCB-19.c: built (retired rows hidden in the Features column, Backlog and stories). Tested in `features_column_test.dart`, `status_menu_wiring_test.dart` and `sprint_assign_test.dart`. Set to `planned` with those files.
   - SCB-12.c is only half built: the stamp reload exists, but the bars (SCB-12) do not exist yet. Leaving it `backlog` is correct.
   - SCB-16.a is a note: the `+` is disabled, so `backlog` is correct; `scrumboard_page_test.dart` could be cited as partial.
3. MUST-FIX: SCB-19 and SCB-20 say "recycling-bin icon", but the code uses `Icons.delete_outline` (a trash bin). Either use `Icons.recycling` or reword the rows. SCB-19.d and PBI-093 still say trash bin; PBI-093 is superseded and should be marked so.
4. NOTE (rows checked against the code and test files):
   - SCB-01.c, 15.a, 15.d, 19, 20, 20.a, 21 and 22 match the code, and every file they name exists.
   - SCB-22 names `server_test.dart` and `scrumboard_page_test.dart`; both have SCB-22 tests, and `api_test.dart` and `integration/app_test.dart` add more.
   - SCB-15.a and the tests are green at the DEF-01 sizes.
   - SCB-20.a: the zoom is a `TextScaler` only, so it enlarges fonts, not paddings or icons. This matches the wording ("size of every font").
5. NOTE: SCB-22 and the page poll. The first stamp is read after the first interval (2 s), so a file change in that window is not noticed until the next change. A change after the first read triggers a reload. A one-line baseline read in `initState` would close the gap.
6. NOTE: tests cover each wiring with the fake API. There is no test that an outside file change reaches the page end to end (PBI-098 asked for one). `server_test.dart` proves the stamp changes and `scrumboard_page_test.dart` proves a changed stamp reloads; together they cover it, but no single test does.
7. NOTE: `features_column.dart` `_choose` sends `proposed` and `backlog` through `setStatus`, while `backlog_timeline.dart` sends `backlog` through `moveRequirement` and `proposed` through `setStatus`. The behavior is equivalent today, but the two are duplicates. A shared helper would remove it (Tanaka or Ito, next sprint).
8. NOTE: handoff open item: `blockWidth = 360` is still a literal in `board_tokens.dart` (Ito asked Tanaka for `scrumBlockWidth`). No decision is recorded; carry it as an action.
9. NOTE: DoD addition ("rows stay `planned` until the Executive has verified in the browser") is in `definition_of_done.md`; the rows above must follow it (use `planned`, not `done`).
10. NOTE: `requirements/retired.md` already exists with the same four columns that `retireRequirement` writes (`ID | Date | Reason | Row as it was`). No action.
