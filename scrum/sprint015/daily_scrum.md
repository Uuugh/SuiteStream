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

### 2026-11-24 Day 2 - Takahashi
- Progress toward the goal: wave 1 is done: tasks 10, 10b, 11, 12, 12b and the wave 1 part of 6b (no token asked; its wave 2 part stays). The Questions and Verifications column reads both files and shows them in `main.dart`; the README API table has `GET /api/questions`. Wave 2 (the writes, PBI-125: tasks 13 to 16b) is next.
- Tasks done: 38.5 of 61 task hours (Day 1: 27; Day 2: tasks 10 (7), 10b (1), 11 (0.5), 12 (2), 12b (1)).
- Burndown (points not yet In Review, of 10): Day 0: 10; Day 1: 10; Day 2: 3.
- In Review: PBI-126 (waits for verification 45) and PBI-086, read side (waits for verification 46; its Windows and web check is ready after task 17b), both in `scrum/product_backlog.csv` with their "waits for verification" note. Check rerun: 46 In Review PBIs, 46 open verifications, one each; every backlog row has 10 fields.
- Kobayashi task 12 review (`kobayashi_code_review.md`, Day 2): wave 1 done as planned, every count reproduces, no must-fix; PBI-126 and PBI-086's read side fit to go In Review. Finding 1 (should, stale read): fixed by Ito (read counter, two tests, +221). Finding 2 (should, Windows and web check): named in verification 46. Finding 5 (sprint backlog statuses): done here. Findings 3, 4 and 6 are notes.
- Impediments: none new. IMP-003 (`scrum/impediment_log.csv`) updated: Day 2 ran with separate role agents and Kobayashi's wave 1 review ran; stays Open until task 16.
- Note for task 14b (Tanaka): the README says the server writes one file only, but it also has `PUT /api/requirements/{id}/status` and `POST /api/requirements/{id}/retire`; neither, nor `GET /api/changes`, is in the API table.
- Note: Tanaka's "Later" lines for tasks 10b, 6b and 12b were appended under Ito's Day 2 heading; they are Tanaka's work.
- Tests: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +221: All tests passed!; root `flutter analyze lib test` -> No issues found!; root `flutter test` -> +596: All tests passed!

### 2026-11-24 Day 2 - Yamamoto
- Yesterday: tasks 5 (13 keys, six languages, synced) and 6 (generic bar, `requirementFilterFields`, SCB-04 bar test on `BoardItem`) done.
- Today: no wave 1 task; handoff to Ito in `handoffs.md`: the SCB-04 stand-in `scbColumnQuestions` stays, his column tests cover the bar in the real column.
- Impediments: none
- Tests: `cd scrum/scrumboard && flutter test test/features test/l10n` -> +29: All tests passed!

### 2026-11-24 Day 2 - Nakamura
- Yesterday: tasks 8a, 7 and 8b done (`BoardItem`, GET /api/questions, client read and fake writes; see `handoffs.md`).
- Today: no wave 1 task; ready for tasks 13 and 14 on Day 3 (wave 2); available to answer Ito about the API (`boardItems()`, `FakeScrumBoardApi`, write results).
- Impediments: none. Wave 2 needs nothing from wave 1: tasks 13 and 14 build on my own wave 0 files.
- Tests: `cd scrum/scrumboard && flutter test test/server test/api` -> +104: All tests passed!

### 2026-11-24 Day 2 - Tanaka
- Yesterday: tasks 2, 3 (verifications 9-44, PBI-126) and 9 (`questions` page slot) done; Day 1 rerun +207.
- Today: task 11 done: `scrum/scrumboard/README.md` API table has `GET /api/questions` (`{"questions":[item],"verifications":[item]}`, item fields, open first then answered or closed, newest first, every status, both files in the change stamp `GET /api/changes`); `--root` names the two files. Checked against `lib/server/server.dart`, `lib/server/board_items.dart` and `BoardItem.toJson`. Tasks 6b, 10b and 12b later today.
- Impediments: none. Noted for task 14b: the README line "The server writes one file only" already misses `PUT /api/requirements/{id}/status` and `POST /api/requirements/{id}/retire`, and the API table lists neither them nor `GET /api/changes`.
- Tests: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +207: All tests passed! (Ito's task 10 files not yet present, so they are not in the count.)

### 2026-11-24 Day 2 - Ito
- Yesterday: no code (wave 0 day); checked the wave 0 inputs for task 10.
- Today: task 10 (PBI-086) built, read side of the column: `lib/src/questions/questions_column.dart` (`QuestionsColumn({required ScrumBoardApi api})`, `questionFilterFields`, `questionColumnOrder`). Heading msg:scbQuestions, text only; one list merged in Suzuki's order (open questions, open verifications, answered questions, accepted or returned verifications; API order kept within each); each verification shows its PBI; `ScbFilterBar<BoardItem>` always with `fields: questionFilterFields`; msg:scbNoQuestions with no item; own `Scrollbar`; reads again on `ReloadScope.generationOf` and when given another API; theme tokens only, no new token needed. Tests in `test/questions/questions_column_test.dart` (12): SCB-17/SCB-15.a heading in the third column; SCB-17.c merge on the server fixtures (questions file order 3, 1, 2, 4) and on lists with all four groups, top-to-bottom order in the column, empty state; SCB-17.a PBI on each verification; SCB-04 bar fields; reload; load error; SCB-17.d column scrolls, page does not; DEF-01 1024 x 640, longest language (chosen in the test from the six arb files), light and dark, open question and open verification do not clip. Yamamoto keeps the SCB-04 stand-in; no request.
- Impediments: none.
- Tests: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +219: All tests passed!; root `flutter analyze lib test` -> No issues found!; root `flutter test` -> +596: All tests passed!
- Kobayashi finding 1 fixed: `_load` applies only the latest read (read counter); tests added: a slow earlier read does not overwrite a later one; the column reads again when given a different api. `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +221: All tests passed!
- Later: task 10b done (`lib/main.dart` passes `questions: QuestionsColumn(api: api)`; no test checked the placeholder, page tests keep their own stand-ins); 6b: no tokens requested in wave 1. Tests: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +219: All tests passed! (with Ito's task 10 tests).
- Later: task 12b done: verification 45 (PBI-126) and 46 (PBI-086) in `scrum/verifications.md`; numbers handed to Takahashi in `handoffs.md`. No code changed.

### 2026-11-24 Day 3 - Yamamoto
- Yesterday: no wave 1 task; SCB-04 stand-in handoff to Ito.
- Today: no wave 2 task. Checked the six keys task 15 uses (`scbAnswered`, `scbAccepted`, `scbReturned`, `scbItemGone`, `scbAnswerHint`, `scbResultHint`): present in all six `requirements/messages/app_*.arb` files, and the six copies in `scrum/scrumboard/assets/messages/` are identical, so no sync was run.
- Impediments: none
- Tests: `cd scrum/scrumboard && flutter test test/features test/l10n` -> +29: All tests passed!

### 2026-11-24 Day 3 - Nakamura
- Yesterday: no wave 1 task.
- Today: task 13 (PBI-125) done: `PUT /api/questions/{n}/answer` and `PUT /api/verifications/{n}/result` in `lib/server/server.dart`, writer in new `lib/server/board_item_write.dart` (re-read inside `_serialized`, number AND heading, `gone` with the file untouched, 400s, line endings kept). Task 14 done: `HttpScrumBoardApi.answerQuestion` and `setVerificationResult` send the real PUTs (400 -> `ScrumBoardApiException` statusCode 400). Tests: SCB-17.b server (8), SCB-13.b (three routes, other verbs 404), SCB-01.a (writes change only the two files; process scan covers the new file), client writes (4). Handoff in `handoffs.md`.
- Impediments: none. A first full run had 2 failures in Ito's in-progress DEF-01 tests (`test/questions/questions_column_test.dart`, task 15); the rerun passed.
- Tests: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test test/server test/api` -> +117: All tests passed!; `flutter test` -> +240: All tests passed!

### 2026-11-24 Day 3 - Ito
- Yesterday: task 10 (PBI-086, column read side) done; Kobayashi finding 1 (stale read) fixed.
- Today: task 15 (PBI-125) built in `lib/src/questions/questions_column.dart` (SCB-17.b): an open question's choice lines are buttons (picking one writes that line, trimmed, letter included), a field (msg:scbAnswerHint) with Answered (msg:scbAnswered) to its right writes the typed text as typed; an open verification has a result field (msg:scbResultHint), Accepted (msg:scbAccepted) and Returned (msg:scbReturned), Returned disabled while the result is blank. Calls `answerQuestion` / `setVerificationResult` with number and heading; after a write the column reads again and the item stays listed with its new status and no controls; `gone` shows msg:scbItemGone and reads again; a 400 or an unreachable server is shown in the column, nothing crashes. Theme tokens only, no new token. Tests: 6 SCB-17.b column tests, DEF-01 test extended (controls inside the item at 1024 x 640, longest language, light and dark); the SCB-17.d test now picks the list's own Scrollable (the fields hold their own).
- Impediments: none. Answered is disabled while the typed text is blank (not named in SCB-17.b; the server refuses it anyway). A refused write shows the server's reason alone: there is no key for "write refused" (see `handoffs.md`).
- Tests: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +240: All tests passed! (`flutter test test/questions` -> +20)

### 2026-11-24 Day 3 - Tanaka
- Yesterday: tasks 10b, 11, 12b done; 6b wave 1: none asked.
- Today: task 14b (PBI-125) done in `scrum/scrumboard/README.md`: API table rows for `PUT /api/requirements/{id}/status`, `POST /api/requirements/{id}/retire`, `GET /api/changes`, `PUT /api/questions/{n}/answer` and `PUT /api/verifications/{n}/result`, with bodies, `{ok, reason}`, `gone`, the 400s and 413, and line endings kept (SCB-13.c, SCB-13.d, SCB-17.b, SCB-19.a, SCB-22); the error line now names write bodies, not only the sprint body; "server writes" now lists every file written (`scrum/sprint.md`, the requirement file and `requirements/retired.md`, `scrum/questions.md`, `scrum/verifications.md`). Checked against `lib/server/server.dart`, `lib/server/board_item_write.dart`, `lib/server/requirement_status.dart` and `lib/server/requirement_retire.dart`. Closes Kobayashi Day 2 finding 4. Task 6b wave 2: none asked (Ito, `handoffs.md` Day 3); `scrum_theme.dart` unchanged.
- Impediments: none. The Windows and web check of the routes stays with task 17b.
- Tests: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +240: All tests passed!; root `flutter analyze lib test` -> No issues found!; root `flutter test` -> +596: All tests passed!
- Later: task 16b done: verification 47 (PBI-125).

### 2026-11-24 Day 3 - Takahashi
- Progress toward the goal: wave 2 is done: tasks 13, 14, 14b, 15, 16, 16b and the wave 2 part of 6b (no token asked; 6b done). The column now answers a question (by choice or typed text) and accepts or returns a verification through two write routes; the README documents every route. All three sprint PBIs are In Review; only wave 3 (tasks 17a, 17b, 18) is left.
- Tasks done: 56 of 61 task hours (Day 2: 38.5; Day 3: tasks 13 (5), 14 (1), 14b (0.5), 15 (7), 16 (2), 16b (1), 6b (1)).
- Burndown (points not yet In Review, of 10): Day 0: 10; Day 1: 10; Day 2: 3; Day 3: 0.
- In Review: PBI-126 (verification 45), PBI-086 (verification 46) and PBI-125 (verification 47), each with its "waits for verification" note in `scrum/product_backlog.csv`; the Windows and web check of 46 and 47 is ready only after task 17b. Check rerun: 47 In Review PBIs, 47 open verifications, one each; every backlog row has 10 fields.
- Kobayashi task 16 review (`kobayashi_code_review.md`, "Day 3: task 16 review (wave 2)"): wave 2 done as planned, every count reproduces (scrumboard 240, root 596), no must-fix (1 should, 7 notes); PBI-125 fit to go In Review. Handling: 1 (refused write shows the server's English reason): backlog item PBI-129 (msg:scbWriteRefused; Low, 1 point, Ready). 2 (picking a choice writes at once): Suzuki confirmed as built. 3 (Answered disabled while blank): added to the SCB-17.b statement in `requirements/scrumboard.md`. 4 (Nakamura: writer and reader disagree on where an old multi-line answer ends; a write to an item no longer open overwrites), 7 (Ito: the notice stays after a `gone` until the next write) and 8 (Nakamura: `handoffs.md` cites an answered example `scrum/questions.md` does not have): notes for their owners, no action this sprint. 5: done (task statuses here and in `sprint_backlog.md`; the SCB-01.a test cell now names the "writes change only the two files" test). 6: `AGENTS.md` (the Executive's change) and `devtools_options.yaml` are left out of the commit.
- Suzuki decisions (`handoffs.md`, Day 3 Suzuki): finding 1 to the backlog next sprint (PBI-129); finding 2 confirmed as built; finding 3 accepted and stated in SCB-17.b this sprint. No question for the Executive.
- Impediments: none new. IMP-003 resolved and moved to `scrum/impediment_log_resolved.csv`: Day 3 ran with separate role agents and Kobayashi's task 16 review ran; both wave reviews (tasks 12 and 16) have now run, so its open action is met.
- Tests: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +240: All tests passed!; root `flutter analyze lib test` -> No issues found!; root `flutter test` -> +596: All tests passed!
- Remaining for Day 4: wave 3: tasks 17a (integration test, Tanaka), 17b (web build and Windows and web checks, Nakamura) and 18 (records, backlog, velocity, Takahashi).
