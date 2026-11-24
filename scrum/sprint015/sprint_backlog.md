# Sprint 015 Backlog

Sprint goal: the Executive sees every open question and every waiting verification in one ScrumBoard column and answers, accepts or returns each one there.

| PBI | Title | Points | Owners | Status |
|---|---|---:|---|---|
| PBI-126 | Every In Review PBI has its verification | 2 | Tanaka, Takahashi | Planned |
| PBI-086 | ScrumBoard Questions and Verifications column lists both | 5 | Nakamura, Yamamoto, Ito, Tanaka | Planned |
| PBI-125 | ScrumBoard Questions and Verifications column writes answers and results | 3 | Nakamura, Ito, Tanaka | Planned (cut first) |
| PBI-113 | Zoom icon sizes and alpha from theme tokens | (1) | - | Stretch, only if early |

Total: 10 points. Burndown Day 0: 10. No new mark, seen state or count badge.

## Tasks (61 h)

| # | Wave | Task | PBI | h | Owner |
|---|---|---|---|---:|---|
| 1 | 0 | Row statements: SCB-17, 17.a-d, 15.a, 04, 22, 01.a, 13.b; SCB-17.c order: open first, then answered or closed, newest first within each | 086, 125 | 1 | Takahashi |
| 2 | 0 | Verifications, first 18 In Review PBIs; a PBI whose check is already listed in a sprint review file takes that check; Suzuki reads the wording | 126 | 3 | Tanaka |
| 3 | 0 | Verifications, other 18; same rule; Suzuki reads the wording | 126 | 3 | Tanaka |
| 4 | 0 | "waits for verification N" on the 36 rows; check one per In Review PBI | 126 | 2 | Takahashi |
| 5 | 0 | 13 keys in the six arb files; sync | 086, 125 | 3 | Yamamoto |
| 8a | 0 (first) | `BoardItem` model; "model landed" in `handoffs.md` | 086 | 0.5 | Nakamura |
| 6 | 0 | Generic bar and `requirementFilterFields`; Features column on it; then (after 8a) bar test on `BoardItem` | 086 | 4 | Yamamoto |
| 7 | 0 | Parser, GET route, both files in the stamp; fixtures copied from the real files (note 9) | 086 | 6 | Nakamura |
| 8b | 0 | Client read, interface with all three methods, fake with in-memory writes (`answerQuestion`, `setVerificationResult`), tests; `HttpScrumBoardApi` implements the two writes returning `(ok: false, reason)` until task 14; handoff "fake writes landed" | 086, 125 | 2.5 | Nakamura |
| 9 | 0 | Page slot `questions`; page tests pass a placeholder; `main.dart` passes a placeholder until 10b | 086 | 2 | Tanaka |
| 10 | 1 | Column read side: heading, list (order of task 1), PBI on verifications, bar, empty state, scrollbar, reload; DEF-01 test; theme tokens only | 086 | 7 | Ito |
| 6b | 1, 2 | Tokens Ito asks for in `handoffs.md` (waves 1 and 2), added to `scrum_theme.dart` | 086, 125 | 1 | Tanaka |
| 10b | 1 | `main.dart`: `questions: QuestionsColumn(api: api)`, after 10 | 086 | 1 | Tanaka |
| 11 | 1 | README: GET route in the API table | 086 | 0.5 | Tanaka |
| 12 | 1 | Kobayashi code review of waves 0-1 (IMP-003) | 086, 126 | 2 | Takahashi (runs Kobayashi) |
| 12b | 1 | Verifications for PBI-086 and PBI-126 | 086, 126 | 1 | Tanaka |
| 13 | 2 | Write routes, gone (changed heading and deleted item), 400s, line endings; SCB-01.a test | 125 | 5 | Nakamura |
| 14 | 2 | HTTP client writes and their tests | 125 | 1 | Nakamura |
| 14b | 2 | README: write routes and "server writes" | 125 | 0.5 | Tanaka |
| 15 | 2 | Answer (choice or typed) and result UI; Returned disabled while empty; scbItemGone and reload; stays listed after a write; DEF-01 test; theme tokens only | 125 | 7 | Ito |
| 16 | 2 | Kobayashi code review of wave 2 (IMP-003) | 125 | 2 | Takahashi (runs Kobayashi) |
| 16b | 2 | Verification for PBI-125 | 125 | 1 | Tanaka |
| 17a | 3 | Integration test with the real three columns on the fake (three `scb-shown-of`) | all | 1.5 | Tanaka |
| 17b | 3 | Web build; Windows server on copies; Windows and web checks (after 10, 10b) | all | 1.5 | Nakamura |
| 18 | 3 | Records, backlog, velocity | all | 2 | Takahashi |

Load: Nakamura 16.5 h, Tanaka 14.5, Ito 14, Takahashi 9, Yamamoto 7. Tanaka backs up Ito. PBI-126 is done before 12b puts PBI-086 In Review. Tasks 2 and 3 are tight (36 verifications); Tanaka reports at the first Daily Scrum. Suzuki and Kobayashi own no tasks. New tokens: Ito asks Tanaka in `handoffs.md` (task 6b); `board_tokens.dart` only aliases `scrum_theme.dart`.

## File ownership (under `scrum/scrumboard/` unless rooted)

| Owner | Files |
|---|---|
| Nakamura | `lib/server/*`, `lib/src/api/*` except `reload_scope.dart`, `bin/*`, `test/server/*`, `test/api/*` except `reload_scope_test.dart`, `build/` |
| Yamamoto | root `requirements/messages/app_*.arb` (six), root `tool/sync_messages.sh`, `assets/messages/*`, `lib/src/l10n/*`, `lib/src/features/*`, `test/l10n/*`, `test/features/*` |
| Ito | `lib/src/questions/*`, `test/questions/*`, `lib/src/board/*`, `test/board/*` |
| Tanaka | `lib/main.dart`, `lib/src/app/*`, `lib/src/theme/*`, `lib/src/api/reload_scope.dart`, `test/app/*`, `test/api/reload_scope_test.dart`, `test/theme/*`, `test/integration/*`, `README.md`, root `scrum/verifications.md` |
| Takahashi | `scrum/sprint015/*` except Kobayashi's `kobayashi_plan_review.md` and `kobayashi_code_review.md`, root `scrum/questions.md`, `scrum/product_backlog.csv`, `scrum/velocity.csv`, statement, status and test cells of `requirements/scrumboard.md` |

`handoffs.md` and `daily_scrum.md`: each developer appends only their own dated section, with the test command and its pass count (PBI-120). Keys from anyone but Yamamoto go in `scrum/sprint015/strings_<name>.md`. Tanaka acts on any verification the Executive accepts or returns during the sprint.

## Fixed names

- **Server** `lib/server/board_items.dart`: `readBoardItems(String questionsPath, String verificationsPath)`; parses `## <n>. ` headings, skips the ``` Format block, reads CRLF and LF; a missing file gives an empty list.
- **Routes:** `GET /api/questions` -> `{"questions":[item],"verifications":[item]}`, each open first, then answered or closed, newest first (reverse file order) within each, every status. `PUT /api/questions/{n}/answer` takes `{heading, answer}`; `PUT /api/verifications/{n}/result` takes `{heading, result, status}` (`accepted` or `returned`). Writes answer `{ok, reason}`, re-read inside `_serialized`, match number AND heading; not found (heading changed or number gone) -> reason `"gone"`, file unchanged. A line break, an empty answer, or `returned` with no result -> 400. Line endings kept.
- **Answer by choice:** picking a choice writes that choice line's text (trimmed, letter included) as the answer; typed text is written as typed.
- **Model:** `BoardItem{String kind, int number, String heading, String status, String text, List<String> choices, String? pbi, String answer}` (Nakamura, `lib/src/api/`, task 8a).
- **API** (client and `FakeScrumBoardApi`): `boardItems()` -> `Future<({List<BoardItem> questions, List<BoardItem> verifications})>`; `answerQuestion(int number, String heading, String answer)` and `setVerificationResult(int number, String heading, String result, String status)` -> `Future<({bool ok, String reason})>`.
- **Bar** (`scb_filter_bar.dart`): `ScbFilterFields<T>` with `String Function(T) group, id, status`; `List<String> statuses`; `String groupName, idName` (scbFilterFeature or scbFilterKind; scbFilterRequirement or scbFilterItem; status keeps scbFilterStatus); `String Function(Messages, String) groupText, statusText`; `String Function(T) idText`. `const requirementFilterFields` reproduces today's bar exactly. `ScbFilterBar<T>({items, ScbFilterFields<T>? fields, ...})`: null means requirements, so `backlog_timeline.dart` and `features_column.dart` compile unchanged; asserts `fields != null || items is List<Requirement>`. `ScbHiddenFilters.applyWith<T>(items, fields)` added; `apply` and `shows(Requirement)` stay. Widget keys unchanged (`scb-shown-of`, `scb-filter-button-<label>`, `scb-filter-<value>`); every new or changed test finds a bar with `find.descendant` of `scbColumnQuestions`, `scbColumnFeatures` or the backlog block.
- **Column** `lib/src/questions/questions_column.dart`: `QuestionsColumn({required ScrumBoardApi api})`; `questionFilterFields` (kind; number or PBI; open, answered, accepted, returned); item id `'$kind-$number'` (numbers repeat across the two files), `idText` shows the number or the PBI. `ScrumBoardPage` gets `required Widget questions`, shown in `scbColumnQuestions`. Reads again on `ReloadScope.generationOf` and after each write. Heading is text only, no count.

## Keys (confirmed by Suzuki; Yamamoto, task 5, six languages)

| Key | English |
|---|---|
| scbQuestions | Questions and Verifications |
| scbNoQuestions | No open questions or verifications |
| scbAnswered | Answered |
| scbAccepted | Accepted |
| scbReturned | Returned (button text and status token) |
| scbItemGone | An agent removed this item meanwhile; nothing was written |
| scbFilterKind | Kind |
| scbFilterItem | Number or PBI |
| scbKindQuestion | Question |
| scbKindVerification | Verification |
| scbStatusOpen | Open |
| scbAnswerHint | Your answer |
| scbResultHint | Result (required to return) |

## Named tests

- SCB-17.a: real file copies parse; each copy's Format block holds a `## <n>.` heading that must not become an item; one CRLF copy; questions (Choices) and verifications (Verify, PBI). `scrum/questions.md` has no open question, so its fixture copies the Format block as is and adds question items written in that format (with indented choice lines); the test says so. Column: each verification shows the PBI it waits for.
- SCB-17, SCB-15.a: heading and third column. DEF-01: at the narrowest DEF-01 window size, in the longest language, light and dark, an open verification (result field, Accepted, Returned) and an open question do not clip (tasks 10, 15).
- SCB-17.c: open first, then answered or closed, newest first within each, with a fixture whose file order differs from number order (a reused number); empty state.
- SCB-17.d: with more items than fit, the column's own `Scrollbar` scrolls and the page does not (SCB-15.b).
- SCB-04: a bar on `BoardItem` hides by kind, by item (question 1 and verification 1 apart) and by status; the Features and Backlog bar tests still pass.
- SCB-22: a change to either file changes the stamp.
- SCB-13.b: three routes; any other verb on them is not found.
- SCB-17.b (server): answer, accept, return; gone when the heading on disk changed under the same number; gone when the number is no longer in the file, with the file byte-for-byte unchanged; the 400s; a CRLF file stays CRLF on every line after a write.
- SCB-17.b (column): answer by choice writes the choice line, answer by typed text writes the text; Returned disabled while the result is empty; a `gone` answer shows msg:scbItemGone and reloads; after Answered, Accepted or Returned the item stays listed with its new status and no answer controls.
- SCB-01.a: the new routes change only `scrum/questions.md` and `scrum/verifications.md`; only `usage_script.dart` starts a process.
- Integration (task 17a, integration test only): the page with the real three columns on the fake shows three `scb-shown-of`. The web build is in task 17b (Nakamura owns `build/`).

## Docs and platforms (PBI-119)

- GET route: doc README API table (task 11); Windows: CRLF files parse; web: the column shows (task 17b).
- PUT routes: doc README API table and "server writes" (task 14b); Windows: line endings kept, file open in an editor; web: the three buttons write (task 17b).
- No option or setting changes.

## Test command and done

After each wave: `flutter analyze lib test` and `flutter test` in `scrum/scrumboard` and at the root; each developer writes the command and pass count in `daily_scrum.md` (PBI-120). Kobayashi code review per wave (IMP-003) before its PBIs go In Review. Theme tokens only; no clipping at the DEF-01 window sizes; light and dark.
