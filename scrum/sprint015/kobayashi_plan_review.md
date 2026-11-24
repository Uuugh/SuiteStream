# Sprint 015 Plan Review (Kobayashi)

I checked `sprint_planning.md` and `sprint_backlog.md` against `scrum/product_backlog.csv` (PBI-086, PBI-092, PBI-125, PBI-126 rows and the status column), `scrum/definition_of_done.md`, `scrum/usage/README.md` and `usage.log`, `scrum/velocity.csv`, `scrum/questions.md`, `scrum/verifications.md`, `requirements/scrumboard.md` (SCB-17, 17.a-d, 15.a, 04, 22, 01.a, 13.b), `scrum/order/order004.md`, `scrum/sprints/sprint014/sprint_retrospective.md` and the code in `scrum/scrumboard/` (`scb_filter_bar.dart`, `scrumboard_page.dart`, `server.dart`, `scrumboard_api.dart`, `board_tokens.dart`, `README.md`). Reviewer model: Opus (GPT not available).

**Verdict: revise.** One must-fix (1). The should-fix items are plan-text changes; the notes Takahashi may accept.

## Verified, no finding

- **Scope and sizes.** PBI-126 (2) + PBI-086 (5) + PBI-125 (3) = 10, matching the CSV sizes; all three `In Sprint`, sprint 015; the three rows have 10 fields. Velocity 8, 8, 10, 9 for Sprints 011 to 014 (`velocity.csv`) is quoted correctly.
- **PBI-126 count.** The CSV has 41 rows `In Review` plus 3 `In Review (partly built ...)` (PBI-013, PBI-037, PBI-063): 44. Eight have a verification (PBI-092, PBI-106 to PBI-109, PBI-119, PBI-120, PBI-122), so 36 need one. Tasks 2 and 3 (18 + 18) match.
- **Usage figures.** I re-ran `bash scrum/usage/usage.sh project "Sonnet 5.5" 10 8 60`: session 34.7 %, week 63.6 %, no level crossed; `estimate` gives 2.667 and 0.358 per point (3 used, 2 discarded). The anchor 5 x 0.358 / 2.667 = 0.67 (about 60 % week) and the outlier cases (8 + 58.9 = 66.9 %; 12 points 78.7 %) are correct.
- **Availability.** Stated as an assumption, not as a fact, with the timebox (5 days, ended early). No leave is recorded in the repository. Takahashi accepts or confirms it before wave 0 (as assumption A in Sprint 014).
- **BoardItem ordering.** Task 8a (model, 0.5 h, first in wave 0) and the "model landed" handoff come before Yamamoto's `BoardItem` bar test in task 6; the bar test uses `BoardItem`, not its own type.
- **One editor per file.** No file has two owners. Existing callers of `ScbFilterBar` (`backlog_timeline.dart`, Ito; `features_column.dart`, Yamamoto) compile unchanged because `fields: null` means requirements. `ScbHiddenFilters` (features, ids, statuses) fits `applyWith<T>`. Only `HttpScrumBoardApi` and `FakeScrumBoardApi` implement `ScrumBoardApi`, both Nakamura's, so new methods break no other owner's file.
- **Arb keys.** The 13 keys are new (none of them is in the six `requirements/messages/app_*.arb`); only Yamamoto adds them (task 5); others use `strings_<name>.md`. `scbFilterFeature` and `scbFilterStatus` exist and are reused.
- **No new mark, seen state or count badge.** Not in the plan; the heading is text only, no count (SCB-17.e deleted, d6ebfba). The plan's correction of order004's refinement record (point 2, "badge") is right and order004 is not edited.
- **Requirement IDs** are cited, not copied. **PBI-119**: a doc file and a Windows and a web check are named for the GET route and the PUT routes; no option or setting changes. **PBI-120** and **IMP-003** (code review per wave, tasks 12 and 16) are planned.
- **Dependencies** on PBI-092 (verification 8) and PBI-126 are named, with the rule for a returned verification 8.

## Must-fix

1. **must-fix: the "deleted meanwhile" clause of PBI-125 has no test.**
   - **Finding:** PBI-125's acceptance says an item an agent has *deleted* meanwhile is not written and the board says so (msg:scbItemGone). The SCB-17.b named test covers only "the heading on disk changed under the same number". A route that matches by number alone, or that appends a new item when the number is missing, would pass it.
   - **Fix:** Add to SCB-17.b: (a) server: the item's number is no longer in the file -> `{ok: false, reason: "gone"}` and the file is byte-for-byte unchanged; (b) column (task 15): a write answered with `gone` shows msg:scbItemGone and reloads.

## Should-fix

2. **should-fix: the task hours add up to 58 h, not 55 h.**
   - **Finding:** 1+3+3+2+3+0.5+4+6+1.5+2+6+1+1+2+1+5+2+6+2+1+3+2 = 58. "Tasks (55 h)" and "Tasks total 55 h" are wrong (probably not updated after the 8a/8b split). Load: Nakamura 19 h (critical path in waves 0, 2 and 3), Ito 12, Tanaka 11, Takahashi 9, Yamamoto 7.
   - **Fix:** Write 58 h in both files; the "about 3.5 of 5 days" claim should follow from Nakamura's critical path, not the total.

3. **should-fix: "open first" (SCB-17.c) is undecided, and "stays listed" has no test.**
   - **Finding:** SCB-17.c today says open questions come first, newest first. The plan lists every status in reverse file order. PBI-125 says an answered item stays listed until an agent deletes it, so the order of open and answered items now matters. No named test asserts either.
   - **Fix:** Decide in the task 1 statement (open first, or file order only) and add to the SCB-17.c test; add to SCB-17.b that after Answered / Accepted / Returned the item is still listed with its new status and no answer controls.

4. **should-fix: three acceptance clauses lack a named assertion.**
   - "each verification shows the PBI it waits for" (PBI-086): the SCB-17.a test only parses the PBI; add a column test that the PBI id is shown.
   - "a choice or typed text" (PBI-125): say what is written when a choice is picked (the letter or the choice line) and test the choice path as well as typed text.
   - "no clipping at the DEF-01 window sizes; light and dark" (both): name the test. The riskiest layout is an open verification (result field, Accepted, Returned) in a third-width column at the narrowest DEF-01 size in the longest language.

5. **should-fix: "the page test asserts three `scb-shown-of`" cannot pass as planned.**
   - **Finding:** Task 9 has the page tests pass placeholders for `board`, `features` and now `questions` (as `scrumboard_page_test.dart` does today), so no bar is built there.
   - **Fix:** Move that assertion to the integration test (task 17, Nakamura) after task 10b, or have one page test pass the real three widgets with the fake.

6. **should-fix: new theme tokens have no editor.**
   - **Finding:** Task 10 says "theme tokens only (`scrum_theme.dart`, `board_tokens.dart`)". `board_tokens.dart` (Ito) only aliases `scrum_theme.dart` (Tanaka, `lib/src/theme/*`). A new size (field width, button gap) needs a Tanaka edit.
   - **Fix:** Say that Ito asks Tanaka through `handoffs.md` for any new token, or that tasks 10 and 15 use existing tokens only.

7. **should-fix: wave 2 has an unordered dependency.**
   - **Finding:** Task 15 (Ito) needs the fake's `answerQuestion` and `setVerificationResult`, which task 14 (Nakamura) adds in the same wave.
   - **Fix:** As with 8a: task 8b already adds both signatures to the interface and an in-memory fake in wave 0, or task 14 lands the fake first and writes a handoff before task 15 starts its tests.

8. **should-fix: the usage forecast rests on borrowed and stale figures.**
   - **Finding:** (a) `scrum/usage/README.md` says one model's data is never used to predict another's; `usage.sh project "Opus 5.5" 10 8 60` answers "No session estimate for Opus 5.5" (exit 1). The plan says so openly, but the closest evidence for an Opus-heavy sprint is the Sprint 014 row (5.889 session and 0.778 week per point), which gives 66.9 % session and 67.8 % week for 10 points; the plan quotes only the session figure. (b) The 3 % before-reading was taken before refinement and planning ran with several Opus agents.
   - **Fix:** Add the 67.8 % week figure next to the 67 % session one, and record that the orchestrator takes a fresh before-reading at Start (README, "When") and re-runs `project`; if it projects at or over 70 %, cut PBI-125 first.

## Notes

9. **note: `scrum/questions.md` has no open question,** so "fixtures copied from the real files" has no real question item. Copy the Format block as is and add question items written in that format (with indented choice lines), and say so in the test.
10. **note: verifications that change during the sprint.** Tanaka owns `scrum/verifications.md`; if the Executive accepts or returns one (verification 8 included) while the sprint runs, Tanaka acts on it (AGENTS.md, "Questions and verifications"), not another agent. `scrum/questions.md` has no owner in the table; name Takahashi.
11. **note: PBI-126 clause** "a PBI whose check is already listed in a sprint review file takes that check" is not in tasks 2 and 3; add it to their text.
12. **note: order inside waves.** Task 11's web check ("the column shows") needs tasks 10 and 10b; run it after them. Task 9 makes `questions` required, so Tanaka passes a placeholder in `main.dart` in wave 0 until task 10b.
13. **note: SCB-17.d "scrollbar"** should name what fails: for example, with more items than fit, the column's own `Scrollbar` scrolls while the page does not (SCB-15.b).
14. **note: ownership table.** `scrum/sprint015/*` is Takahashi's "except `kobayashi_code_review.md`"; add `kobayashi_plan_review.md` (this file).

## Re-review

I checked the revised `sprint_planning.md` ("Review findings addressed") and `sprint_backlog.md` against findings 1 to 14, recounted the hours and loads, checked the ownership moves (README, `test/integration/*` to Tanaka; `scrum/questions.md` to Takahashi) and the task order, and checked `build/` use in `bin/server.dart` and `lib/server/server.dart`.

**Verdict: approve.** Findings 1 to 14 are resolved. New finding 15 is a one-line fix in `sprint_backlog.md` that Takahashi makes (or accepts) before wave 0; notes 16 and 17 need no re-review.

### Earlier findings

| # | Resolved | Evidence |
|---|---|---|
| 1 | yes | SCB-17.b (server): gone when the number is no longer in the file, file byte-for-byte unchanged; (column): `gone` shows msg:scbItemGone and reloads. Tasks 13 and 15 name it; Fixed names say "number gone -> gone, file unchanged". |
| 2 | yes | The 25 tasks add up to 61 h. Loads recounted: Nakamura 16 (0.5+6+2.5+5+1+1), Tanaka 15, Ito 14 (7+7), Takahashi 9, Yamamoto 7; all match. Days follow the critical path (about 4 of 5). |
| 3 | yes | Order decided (open first, then answered or closed, newest first within each) in task 1, Fixed names and the SCB-17.c test; SCB-17.b (column) asserts "stays listed, new status, no answer controls". |
| 4 | yes | PBI shown on verifications (SCB-17.a column part); choice and typed answers with a fixed rule (choice line text, letter included); DEF-01 narrowest size, longest language, light and dark (tasks 10, 15). |
| 5 | yes | Three `scb-shown-of` moved to the integration test (task 17a) with the real three columns. |
| 6 | yes | Task 6b (Tanaka) adds tokens Ito asks for in `handoffs.md`; see note 16. |
| 7 | yes | Task 8b (wave 0) adds the interface methods and in-memory fake writes, with a handoff; see note 17. |
| 8 | yes | 67.8 % week figure added; fresh before-reading and `project` at Start; PBI-125 cut first at 70 % or over. |
| 9 to 14 | yes | Fixture rule in SCB-17.a; Tanaka acts on verifications during the sprint and `scrum/questions.md` is Takahashi's; PBI-126 review-file rule in tasks 2 and 3; 17b web check after 10 and 10b and the `main.dart` placeholder in task 9; SCB-17.d names the failure; `kobayashi_plan_review.md` is Kobayashi's. |

### New findings

15. **should-fix: task 17a writes a folder Tanaka does not own.**
    - **Finding:** Task 17a (Tanaka) runs the web build, which writes `scrum/scrumboard/build/`. The ownership table gives `build/` to Nakamura, and `bin/server.dart` serves `build/web` for Nakamura's Windows and web checks (17b).
    - **Fix:** Move the web build to task 17b (Nakamura), or move `build/` to Tanaka and state that 17b runs after 17a.

16. **note: task 6b sits only in wave 1.** Ito's task 15 (wave 2) may need new tokens too. Say that 6b takes requests in waves 1 and 2, and that Ito does not start a widget test that needs a token before Tanaka's handoff lands.

17. **note: `HttpScrumBoardApi` in wave 0.** Task 8b adds `answerQuestion` and `setVerificationResult` to the interface, so `HttpScrumBoardApi` must implement them in wave 0 to compile, while the HTTP writes come in task 14 (wave 2). Say that 8b gives them a body that returns `(ok: false, reason: ...)` (not a silent success) until task 14.
