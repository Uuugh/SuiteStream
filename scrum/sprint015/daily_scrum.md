# Sprint 015 Daily Scrum

### 2026-11-24 Day 1 - Takahashi
- Progress toward the goal: wave 0 is done: tasks 1, 2, 3, 4, 5, 6, 7, 8a, 8b and 9 (27 of 61 task hours). The model, the GET route, the client, the fake writes, the generic bar, the 13 keys and the page slot are in place; wave 1 (the column read side, task 10) starts on Day 2.
- PBI-126: 44 PBIs In Review, 44 open verifications, one each; every acceptance field ends with its "waits for verification" note (task 4 check passed). Suzuki read the wording of 9-44 and fixed 12, 22, 32, 34 and 41.
- Decisions recorded (Suzuki, `handoffs.md`): the column lists the open questions, then the open verifications, then the answered questions, then the accepted or returned verifications, each newest first (SCB-17.c); SCB-04 and SCB-01.a stay `backlog`.
- Burndown (points not yet In Review, of 10): Day 0: 10; Day 1: 10. No PBI is In Review yet: PBI-126 is built and goes In Review with PBI-086 in task 12b.
- Impediments: none new. IMP-003 (`scrum/impediment_log.csv`): Day 1 ran with separate role agents; Kobayashi's Day 1 review (`kobayashi_code_review.md`): wave 0 done as planned, no must-fix, 6 findings (1 should, 5 notes); his runs: scrumboard analyze clean, +207; root analyze clean, +596. The wave reviews (tasks 12, 16) still run.
- Note: Nakamura's `dart format` re-indented `lib/src/api/models.dart` and `lib/src/api/scrumboard_api.dart` (a large diff, behaviour unchanged); restoring them with `git checkout` was denied, and nothing worked around it. The churn is committed as is unless the Executive says otherwise.
- Tests: none run by me (no code changed).

### 2026-11-24 Day 1 - Tanaka
- Yesterday: (planning only; no tasks)
- Today: tasks 2 and 3 (PBI-126): 44 PBIs In Review; 8 had a verification; 36 added as verifications 9-44 in `scrum/verifications.md`; list in `handoffs.md`. Task 9 (PBI-086): `ScrumBoardPage` takes `questions` shown in `scbColumnQuestions`; `main.dart` passes a placeholder until 10b; page tests pass a placeholder and check the slot.
- Impediments: none. Tasks 2 and 3 fit in Day 1 (36 verifications, as planned). Suzuki still reads the wording. Full suite has 2 failures in Yamamoto's in-progress task 6 tests and analyze has 2 warnings in Nakamura's in-progress `test/server/board_items_test.dart`; not mine.
- Tests: `cd scrum/scrumboard && flutter analyze lib test` -> 2 issues (both in test/server/board_items_test.dart line 189); `flutter test` -> +197 -2 (failures: test/features/features_column_test.dart and test/features/scb_filter_bar_test.dart, SCB-04); `flutter test test/app` -> +32, all passed.

### 2026-11-24 Day 1 - Nakamura
- Yesterday: (planning only; no tasks)
- Today: done task 8a (`BoardItem` in `lib/src/api/models.dart`, "model landed" in handoffs.md), task 7 (`lib/server/board_items.dart` parser, GET /api/questions, both files in the change stamp; fixtures copied from the real files in `test/server/fixtures/board_items/`, the questions copy with four added items as note 9 says; tests SCB-17.a, SCB-17.c, SCB-22, SCB-13.b GET part in `test/server/board_items_test.dart`), task 8b (client `boardItems()`, interface with the three methods, fake with in-memory writes, HTTP writes answer ok: false until task 14; tests in `test/api/board_items_api_test.dart`; "fake writes landed" in handoffs.md). Left for wave 2: tasks 13, 14; wave 3: 17b.
- Impediments: none. Note: `dart format` re-indented the whole of `lib/src/api/models.dart` and `lib/src/api/scrumboard_api.dart` (new formatter style, no behaviour change); restoring them with `git checkout` was denied, so the diff of those two files is larger than the change.
- Tests: `flutter analyze lib test` -> No issues found; `flutter test` (in scrum/scrumboard) -> +207: All tests passed!

### 2026-11-24 Day 1 - Yamamoto
- Yesterday: (planning only; no tasks)
- Today: task 5 done (13 keys in the six arb files, all six languages; synced with `bash tool/sync_messages.sh`). Task 6 done: generic `ScbFilterBar<T>`, `ScbFilterFields<T>`, `requirementFilterFields`, `ScbHiddenFilters.applyWith<T>`; Features column passes `fields: requirementFilterFields`; SCB-04 bar test on `BoardItem` (hides by kind, by item with question 1 and verification 1 apart, by status). The Features bar test now finds `ScbFilterBar<Requirement>` with `find.descendant` of `scbColumnFeatures` (the raw `find.byType(ScbFilterBar)` no longer matches a generic type). The BoardItem test uses a stand-in `scbColumnQuestions` until task 10 builds the column.
- Impediments: none
- Tests: `flutter analyze lib test` (scrum/scrumboard) -> No issues found!; `flutter test` (scrum/scrumboard) -> +199 All tests passed!; `flutter analyze` (root) -> No issues found!; `flutter test` (root) -> +596 All tests passed!

### 2026-11-24 Day 1 - Ito
- Yesterday: (planning only; no tasks)
- Today: no code (wave 0 day); checked wave 0 inputs for task 10 by signature: `BoardItem` with `question`/`verification` kinds (`models.dart`), `boardItems()` and `FakeScrumBoardApi` (`scrumboard_api.dart`), `ScbFilterBar<T>`, `ScbFilterFields<T>`, `applyWith` (`scb_filter_bar.dart`), `questions` slot shown in `scbColumnQuestions` (`scrumboard_page.dart`), the keys in the six arb files. All in place. I define `questionFilterFields` (groupName `scbFilterKind`, idName `scbFilterItem`) in `lib/src/questions/` as part of task 10. Noted Yamamoto's handoff: my tests find the bar with `find.descendant` of `scbColumnQuestions` and `find.byType(ScbFilterBar<BoardItem>)`, and I replace the stand-in in the SCB-04 bar test once the column exists (I ask Yamamoto in `handoffs.md` if that file stays his).
- Impediments: none
- Tests: none run (no code changed)

### 2026-11-24 Day 1 - Tanaka (rerun)
- Tests (rerun after wave 0 landed): `cd scrum/scrumboard && flutter analyze lib test` -> No issues found; `flutter test` -> +207, All tests passed!
