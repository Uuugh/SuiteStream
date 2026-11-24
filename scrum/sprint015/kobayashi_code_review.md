# Sprint 015 Kobayashi code review

## Day 1 (wave 0) - 2026-11-24

Scope: the uncommitted wave 0 diff (`git diff -w` and untracked files) for tasks 8a, 7, 8b (Nakamura), 5, 6 (Yamamoto), 2, 3, 9 (Tanaka), checked against `scrum/sprint015/sprint_backlog.md` (Fixed names, Keys, Named tests) and `scrum/definition_of_done.md`. Takahashi's records were not reviewed. This is not task 12.

### Commands and counts (run independently by Kobayashi)

| Where | Command | Result |
|---|---|---|
| `scrum/scrumboard` | `flutter analyze lib test` | No issues found (exit 0) |
| `scrum/scrumboard` | `flutter test` | +207: All tests passed (exit 0) |
| root | `flutter analyze` | No issues found (exit 0) |
| root | `flutter test` | +596: All tests passed (exit 0) |

Compared with `daily_scrum.md`: Nakamura +207 matches. Yamamoto +199 was taken before Nakamura's last tests landed; root +596 matches. Tanaka's "+197 -2" and "2 issues" were taken mid-run; neither reproduces now (see finding 1).

### What was checked and holds

- Server (`lib/server/board_items.dart`): `readBoardItems(String questionsPath, String verificationsPath)` as named; `## <n>. ` headings; the ``` fence is skipped, so the Format block's heading gives no item; CR stripped per line (CRLF and LF); a missing file or a file that vanishes while read gives an empty list.
- Route: `GET /api/questions` answers `{"questions":[...],"verifications":[...]}`; each list is open first, then the rest, newest first (reverse file order), every status kept. POST, PUT, DELETE and PATCH on it answer 404 (test SCB-13.b). Both files are in the change stamp (`_changeStamp`), test SCB-22 changes each file in turn.
- Model `BoardItem` has exactly the eight fields of the fixed name, with `toJson` / `fromJson`.
- API: `boardItems()`, `answerQuestion(number, heading, answer)` and `setVerificationResult(number, heading, result, status)` on the interface, the HTTP client and the fake, with the fixed return types. The fake writes in memory, matches number AND heading, gives `(ok: false, reason: 'gone')`, throws the 400 cases, and changes `changeStamp()`. `HttpScrumBoardApi` writes return `(ok: false, reason: boardWritesNotAvailable)` without a request (test fails on any request). Matches task 8b.
- Fixtures: `verifications.md` copy has 44 items (the real file); `questions.md` copy keeps the Format block and adds four items with indented choices and file order 3, 1, 2, 4 (reused number), as note 9 and SCB-17.a / SCB-17.c say; the test file states so. A CRLF copy is tested.
- Bar: `ScbFilterFields<T>` with the fixed fields; `const requirementFilterFields`; `ScbFilterBar<T>({items, fields, ...})` with null = requirements and the assert; `applyWith<T>` added; `apply` and `shows` kept; widget keys unchanged. `lib/src/board/backlog_timeline.dart` is unchanged and still compiles (`git diff HEAD` empty). The BoardItem bar test (SCB-04) hides by kind, by item (question 1 and verification 1 apart) and by status, found with `find.descendant` of `scbColumnQuestions`; the Features test now uses `find.descendant` of `scbColumnFeatures`.
- Keys: all 13 keys present once in each of the six `requirements/messages/app_*.arb`; each synced copy in `scrum/scrumboard/assets/messages/` is byte-identical (`cmp`); English matches the Keys table.
- Page: `ScrumBoardPage` has `required Widget questions`, shown in `scbColumnQuestions`; page tests pass a placeholder and check the slot and its own scrolling; `main.dart` passes `SizedBox.shrink()` until 10b.
- Theme tokens: no new color, size or font literal in the changed `lib/` code.
- PBI-126: 44 PBIs whose status starts "In Review" in `scrum/product_backlog.csv`; 44 open verifications in `scrum/verifications.md`, one per PBI, no PBI twice, no verification for a PBI not In Review; each of the 44 acceptance fields carries exactly one "waits for verification N (`scrum/verifications.md`)" whose N is that PBI's item (checked with a script, 10 fields per row). Suzuki's wording read is recorded in `daily_scrum.md`.

### Findings

1. **should (Tanaka)**: Tanaka's Day 1 test line in `daily_scrum.md` (+197 -2, analyze 2 issues) is a mid-run count and is now false for the state of the tree. PBI-120 asks for the command and pass count; append a rerun line (Kobayashi got +207, analyze clean).
2. **note (Yamamoto)**: `features_column.dart` now passes `fields: requirementFilterFields`. Harmless and within task 6 ("Features column on it"), but the plan said it compiles unchanged; either is fine, no action needed.
3. **note (Yamamoto, Ito)**: with `fields` null the bar casts `requirementFilterFields as ScbFilterFields<T>`; the assert guards it in debug only. Ito's column must always pass `questionFilterFields`.
4. **note (Ito, task 10)**: the server gives two lists, each in SCB-17.c order; Suzuki's decision in `handoffs.md` (open questions, open verifications, answered questions, accepted or returned verifications) is a merge the column does. Task 10's SCB-17.c test should cover the merge.
5. **note (Tanaka)**: a sample of verifications 9-44 (e.g. 10, PBI-013) names no light/dark or hard refresh; the Format rule asks for that "for the board", and these are app PBIs, so acceptable. Not every item was checked against the sprint review files.
6. **note (nobody's task)**: untracked root `devtools_options.yaml` (a DevTools settings file) is outside every task; leave it out of the commit or add it to `.gitignore` by decision.

No must-fix finding.

### Verdict

Wave 0 is done as planned: every claimed file, fixed name, route behavior, key and named wave 0 test exists and passes, and the counts reproduce (207 / 596, analyze clean). Fix finding 1 in the record; the rest are notes for task 12.

## Day 2 (wave 1, task 12) - 2026-11-24

Scope: the uncommitted wave 1 diff: task 10 (Ito, untracked `lib/src/questions/questions_column.dart`, `test/questions/questions_column_test.dart`), 10b (Tanaka, `lib/main.dart`), 11 (Tanaka, `README.md`), 6b (Tanaka, no token asked), and the Day 2 sections of `daily_scrum.md` and `handoffs.md`; checked against `sprint_backlog.md` (Fixed names, Keys, Named tests, tasks 10, 10b, 11, 6b), Suzuki's order decision in `handoffs.md`, SCB-17 to SCB-17.d, SCB-04, SCB-15.a in `requirements/scrumboard.md`, PBI-086 and PBI-126 in `scrum/product_backlog.csv`, and `scrum/definition_of_done.md`. Paths under `scrum/scrumboard/` unless rooted.

### Commands and counts (run independently by Kobayashi)

| Where | Command | Kobayashi | `daily_scrum.md` Day 2 |
|---|---|---|---|
| `scrum/scrumboard` | `flutter analyze lib test` | No issues found (exit 0) | Ito, Tanaka: No issues found |
| `scrum/scrumboard` | `flutter test` | +219: All tests passed (exit 0) | Ito +219 (Tanaka +207, taken before task 10 landed, says so) |
| `scrum/scrumboard` | `flutter test test/server test/api` | +104 | Nakamura +104 |
| `scrum/scrumboard` | `flutter test test/features test/l10n` | +29 | Yamamoto +29 |
| `scrum/scrumboard` | `flutter test test/questions` | +12 | Ito: 12 tests |
| root | `flutter analyze lib test` | No issues found (exit 0) | Ito: No issues found |
| root | `flutter test` | +596: All tests passed (exit 0) | Ito +596 |

Every claimed count reproduces; 207 + 12 = 219.

### Day 1 findings

- 1 (Tanaka): handled; "Day 1 - Tanaka (rerun)" in `daily_scrum.md` gives analyze clean and +207, which Kobayashi got on Day 1.
- 3 (Ito): handled; the column passes `fields: questionFilterFields` (line 149); the SCB-04 column test checks the bar's `fields` is `identical` to `questionFilterFields`.
- 4 (Ito): handled; `questionColumnOrder` merges in Suzuki's order (open questions, open verifications, answered questions, accepted or returned verifications), API order kept within each. Three SCB-17.c tests: the server fixtures (file order 3, 1, 2, 4 gives q2, q1, v44..v1, q4, q3), four groups with a reused number through `orderBoardItems`, and top-to-bottom order in the built column.
- 6 (nobody): still open; root `devtools_options.yaml` is untracked.

### What was checked and holds

- Column (task 10) matches the Fixed name: `QuestionsColumn({required ScrumBoardApi api})`; `questionFilterFields` with kind, number or PBI, and statuses open, answered, accepted, returned; item id `'$kind-$number'`; `idText` gives the PBI or the number. Heading msg:scbQuestions, text only (test checks the Padding holds only the Text). Each verification shows its PBI (key `scb-item-pbi-<id>`), a question none. Empty state msg:scbNoQuestions. Own `Scrollbar` with `thumbVisibility`; the SCB-17.d test drags the list and checks the top row and the column did not move. Reads again on `ReloadScope.generationOf` (tested) and when `api` changes. Load errors show msg:scbServerUnreachable or msg:scbLoadFailed, as the Features column does (tested for 500).
- Theme tokens only: the new `lib` code uses `scrumPartGap`, `scrumPagePadding`, `scrumErrorPadding` (all in `scrum_theme.dart`), `theme.textTheme.*` and `theme.colorScheme.*`; no color, size or font literal. No token was asked (6b: none needed, matches `handoffs.md`).
- Text: every shown word comes from the 13 keys or existing ones (`scbFilterStatus`, `scbServerUnreachable`, `scbLoadFailed`); no literal user text in `lib`.
- DEF-01 test: at 1024 x 640 (the narrowest size in DEF-01, "ScrumBoard window sizes", `requirements/common.md`), in the locale whose column words are longest (picked in the test from the six languages), once in light and once in dark (theme brightness checked), an open question with choices and an open verification with a long heading: no exception (no overflow), each item and every Text in it inside the column, status token, PBI, heading and shown-of inside the column. It runs in the real `ScrumBoardPage`.
- SCB-17 / SCB-15.a: the column sits right of Issues, which sits right of Features, in the real page.
- 10b: `main.dart` passes `questions: QuestionsColumn(api: api)`, the same `api` as Features; placeholder gone.
- 11: the README `GET /api/questions` row and its paragraph match `server.dart` (lines 204-213: the two lists of `BoardItem.toJson`) and `board_items.dart` (status lowercased, `pbi` only for a verification heading starting `PBI-<n>`, open first then the rest, reverse file order, missing file empty, both files in `_changeStamp`). `--root` names the two files.
- Tanaka's task 14b note holds: `README.md` line 29 says the server writes only `scrum/sprint.md`, but `server.dart` also has `PUT /api/requirements/{id}/status` (line 169) and `POST /api/requirements/{id}/retire` (line 192); neither, nor `GET /api/changes` (line 214), is in the API table.
- PBI-126: still 44 In Review PBIs and 44 open verifications (the 45th `Status: open` is the Format block); `scrum/verifications.md`, `product_backlog.csv` and `requirements/` unchanged since commit; every backlog row has 10 fields.
- No write route: `server.dart` has only the GET for questions; the client writes still return without a request (Day 1).

### Findings

1. **should (Ito, before or in task 15)**: `_load` has no guard against an older read finishing after a newer one: a reload during a slow read, or a write followed by a reload in wave 2, can show the older list last. Keep a load counter and drop a result that is not the latest. Also no test covers the "reads again when given another API" path (`didUpdateWidget`) that `handoffs.md` tells task 15 it relies on.
2. **should (Tanaka, 12b; Nakamura, 17b)**: DoD "Documentation" asks each route "checked on Windows and web", and the Executive verifies in the browser; the web build and Windows check are task 17b (wave 3). The PBI-086 verification written in 12b should name that it can be checked after 17b, or 12b's In Review should wait for it.
3. **note (Ito, Nakamura)**: the questions fixture's item 4 has `Status: closed`, a status SCB-17.a does not name (a question is open or answered). The column then shows the raw word "closed", not from an `.arb` file, and the status filter cannot hide it. Real files following their Format never give it; no action unless the Format changes.
4. **note (Tanaka, task 14b)**: the README gaps above (two write routes, `GET /api/changes`, "writes one file only").
5. **note (Takahashi)**: `sprint_backlog.md` still shows tasks 10, 10b, 11 and 6b "to do"; `daily_scrum.md` reports them done.
6. **note (nobody)**: Day 1 finding 6 (`devtools_options.yaml`) stays open.

No must-fix finding.

### Verdict

Wave 1 is done as planned and every count reproduces (scrumboard 219, root 596, analyze clean in both). Day 1 findings 1, 3 and 4 are handled.

Task 12b: **PBI-126 is fit to go In Review** (all of its acceptance holds, no code). **PBI-086's read side is fit to go In Review** on its own acceptance (one read route, both files in the stamp, heading key in six languages, open items newest first with the PBI on each verification, generic bar with Features tests passing, empty state, own scrollbar, no write route, named tests, fixtures from the real files, theme tokens only, DEF-01 light and dark), with finding 2 taken into its verification. Finding 1 is for wave 2.

## Day 3: task 16 review (wave 2)

Scope: the uncommitted wave 2 diff since commit 45d79d9: tasks 13 and 14 (Nakamura: `lib/server/server.dart`, untracked `lib/server/board_item_write.dart`, `lib/src/api/scrumboard_api.dart`, `test/server/server_test.dart`, `test/api/board_items_api_test.dart`), 15 (Ito: `lib/src/questions/questions_column.dart`, `test/questions/questions_column_test.dart`), 14b and 6b (Tanaka: `README.md`, no token), and the Day 3 sections of `daily_scrum.md` and `handoffs.md`; checked against `sprint_backlog.md` (Fixed names, Keys, Named tests, Docs and platforms), SCB-17.b, SCB-13.b and SCB-01.a in `requirements/scrumboard.md`, the Format sections of `scrum/questions.md` and `scrum/verifications.md`, and `scrum/definition_of_done.md`. Paths under `scrum/scrumboard/` unless rooted.

### Commands and counts (run independently by Kobayashi)

| Where | Command | Kobayashi | `daily_scrum.md` Day 3 |
|---|---|---|---|
| `scrum/scrumboard` | `flutter analyze lib test` | No issues found (exit 0) | Nakamura, Ito, Tanaka: No issues found |
| `scrum/scrumboard` | `flutter test` | +240: All tests passed (exit 0) | Nakamura, Ito, Tanaka +240 |
| `scrum/scrumboard` | `flutter test test/server test/api` | +117 | Nakamura +117 |
| `scrum/scrumboard` | `flutter test test/questions` | +20 | Ito +20 |
| root | `flutter analyze lib test` | No issues found (exit 0) | Tanaka: No issues found |
| root | `flutter test` | +596: All tests passed (exit 0) | Tanaka +596 |

Every claimed count reproduces. 219 (Day 2) + 13 server and API (104 to 117) + 8 column (12 to 20) = 240. Nakamura's note of 2 failures in a first full run (Ito's tests still being written) does not reproduce.

### Day 2 findings

- 1 (Ito): handled on Day 2 (read counter; tests for a slow earlier read and for a new `api`).
- 2 (Tanaka, Nakamura): handled for PBI-086 (verification 46 names task 17b); the same applies to PBI-125 in 16b.
- 4 (Tanaka): handled by 14b (below).
- 5 (Takahashi): still open, now for wave 2 too (finding 5).
- 6 (nobody): still open (finding 6).

### What was checked and holds

- Routes (task 13) match the Fixed names: `PUT /api/questions/{n}/answer` with `{heading, answer}` and `PUT /api/verifications/{n}/result` with `{heading, result, status}`; `{n}` is 1 to 9 digits; any other verb or path is 404. The body is checked before the write (`answerRefusal`, `resultRefusal`): non-JSON, non-object, missing or non-string field, `\n` or `\r` in heading, answer or result, blank answer, a status other than exactly `accepted` or `returned`, `returned` with a blank result, all 400; over the limit 413. The write runs inside `_serialized` and reads the file again; it matches number AND heading (heading trimmed as `board_items.dart` trims it, so the heading the GET gave matches), skips the ``` Format block, and with no match or no file answers `{ok: false, reason: "gone"}` without touching the file. Only the matched item's `Status:` and `Answer:` / `Result:` lines change; lines are split with their own ends and joined back, so every other byte stays; an added line takes CRLF when the file has any CRLF. The file is replaced through `<file>.tmp` and a rename, as `sprint_file.dart` and `requirement_status.dart` already do.
- Write format fits the Format blocks: a question becomes `Status: answered` / `Answer: <text>`, a verification `Status: accepted` or `Status: returned` / `Result: <text>` (`Result:` alone for an empty accept). Those are exactly the statuses `scrum/questions.md` and `scrum/verifications.md` tell agents to act on, and the reader (`board_items.dart`) reads the answer back from the same line (a server test reads it back through `GET /api/questions`). An agent can act on a board write as on a hand-written one.
- Client (task 14): `answerQuestion` and `setVerificationResult` send `PUT` with a JSON body to the fixed paths and return `(ok, reason)`; a 400 throws `ScrumBoardApiException` with statusCode 400 and the server's reason, as the fake does (tested side by side). `boardWritesNotAvailable` is removed and used nowhere.
- Named tests, each found and read:
  - SCB-17.b server (8): answer (whole-file expected text, read back through GET); accept with an empty result and return with a result (whole-file expected text); gone on a changed heading, both files byte-for-byte unchanged; gone on a missing number in a CRLF file with no final line end, byte-for-byte unchanged, and a missing file stays missing; a numbered heading inside the Format fence is never written; 20 refused bodies, all 400, both files unchanged; CRLF on every line after three writes, including an added `Answer:` line at a file end without a line end (asserts no lone `\n` and no lone `\r`); a real fixture copy changes only its item.
  - SCB-13.b: the three routes answer; GET, POST, DELETE and PATCH on both write routes and six wrong paths are 404.
  - SCB-01.a: a snapshot of the whole test repository shows each write changes only `scrum/questions.md` or `scrum/verifications.md` (so no `.tmp` stays); the process scan now asserts it saw `board_item_write.dart`.
  - SCB-17.b column (6): answer by choice writes the trimmed choice line, letter included, then reads again; typed text is written as typed (trailing space kept), Answered disabled while empty and while blank; Returned disabled while the result is empty and while blank, then writes `returned`; Accepted with an empty result writes `accepted` and the other open verification keeps its controls; gone shows msg:scbItemGone (checked against the English key text) and reads again, for a changed heading and for a deleted item; a 400 and an unreachable server are shown, no exception, the item stays open with its controls. After each successful write the item stays listed with its new status and no field or button inside it (`_listedWithoutControls`).
  - DEF-01: once light and once dark, 1024 x 640, longest language (now also over `scbAnswerHint` and `scbResultHint`): every answer control of an open question (field, Answered, both choices) and of an open verification (field, Accepted, Returned) lies inside its item, and no label or hint exceeds its lines.
- Theme tokens only: the new code uses `scrumPartGap`, `scrumPagePadding`, `scrumErrorPadding` and `theme.colorScheme.*` / `textTheme.*`; no color, size or font literal. `_hintLines = 3` is a line count, not a theme value. Task 6b: no token asked; `lib/src/theme` and `lib/main.dart` unchanged since 45d79d9.
- Keys: the six keys task 15 uses (`scbAnswered`, `scbAccepted`, `scbReturned`, `scbItemGone`, `scbAnswerHint`, `scbResultHint`) come from the Keys table; Yamamoto's Day 3 check holds.
- README (14b) checked line by line against `server.dart` and `board_item_write.dart`: route rows and bodies, `{n}` 1 to 9 digits, 404 for others, the 200 written and gone answers, every 400 case, 413, "nothing is written", "an open one first when two match", `Result:` alone, continuation lines dropped, where a missing line goes, not trimmed, line ends, `<file>.tmp` and rename. The "server writes" list matches the four write paths in `server.dart`; the status, retire and changes rows match `requirement_status.dart`, `requirement_retire.dart` and `_changeStamp`. Day 2 finding 4 is closed.

### Findings

1. **should (Suzuki decides; Yamamoto, next sprint)**: a refused write shows the server's English reason alone (`_notice = e.reason`, and `result.reason` for any `ok: false` other than `gone`), so that line is not from an `.arb` file. Today the UI blocks every 400 a user can cause (blank answer, blank returned result; a single-line field drops `\n`), so it shows only on rare paths: a pasted `\r`, a 500 (`internal error`, for example a file Windows will not let the rename replace), a 413. Ito flagged it in `handoffs.md`. Not blocking: the load error already passes the server's reason through a key placeholder (msg:scbLoadFailed). Make it a backlog item: one key such as "Nothing was written: {reason}" in six languages, used for both cases.
2. **note (Suzuki, open point)**: Ito's "picking a choice writes at once" (no second press) is how SCB-17.b reads ("picking a choice writes that choice line"), but a mis-tap answers with no undo on the board. Suzuki confirms the reading or asks for a confirm step as a backlog item.
3. **note (Suzuki, open point)**: "Answered is disabled while the typed text is blank" is not stated in SCB-17.b; it matches the server's 400 and the Returned rule. Recommend Suzuki accepts it and Takahashi adds it to the SCB-17.b statement so the row and the test agree.
4. **note (Nakamura)**: the writer and the reader disagree on where an old answer ends. The writer drops continuation lines up to a blank line or a `Word:` line; the reader (`board_items.dart`) keeps reading the answer across blank lines and unknown `Word:` lines. So an open item that already holds a multi-line answer with a blank line or a "Note:" line in it keeps that tail, and the board shows it after the new answer. Also a write to an item no longer open (two tabs, within the 2 s sync) overwrites the earlier answer, as the plan's "number AND heading" allows. Real files following the Format never hit either; no action this sprint, worth a server test if the Format changes.
5. **note (Takahashi)**: `sprint_backlog.md` still shows tasks 13, 14, 14b, 15 "to do" and 6b "wave 2 to do"; `daily_scrum.md` and `handoffs.md` report them done. The SCB-01.a test cell names only the process scan; the new "writes change only the two files" test is in the same file.
6. **note (nobody; Takahashi at commit)**: root `devtools_options.yaml` is still untracked (Day 1 finding 6). Root `AGENTS.md` is also changed in the working tree (the Start rule's trigger words) by no wave 2 task; it must not go into the wave 2 commit unless its author (presumably the Executive) says so. Add files by name.
7. **note (Ito)**: the notice line stays after a `gone` until the next write, even after the board has reloaded many times. Harmless; clearing it on the next successful read would be tidier.
8. **note (Nakamura)**: `handoffs.md` says the answer goes on one line "as the answered example in `scrum/questions.md`"; that file has no answered example (its Format block shows `Answer:` empty). The behavior is right; the reference is not.

No must-fix finding.

### Verdict

Wave 2 is done as planned: every fixed name, route behavior, refusal, line-ending rule, key and named test exists, asserts what its name says, and passes; the README matches the server; the counts reproduce (scrumboard 240, root 596, analyze clean in both). The write format is the one both files' Format sections tell agents to act on.

**PBI-125 is fit to go In Review** on its own acceptance, with its verification (16b) saying, as verification 46 does, that the Windows and web check (line endings kept with the file open in an editor; the three buttons write in the browser) is ready only after task 17b. Suzuki decides open points 2 and 3; finding 1 goes to the backlog.
