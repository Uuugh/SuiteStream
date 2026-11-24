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
