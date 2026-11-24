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
