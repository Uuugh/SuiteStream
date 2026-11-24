# Sprint 015 Planning

**Status: planned; Kobayashi approved on re-review; not started.** Review: `kobayashi_plan_review.md` (findings 1 to 17, addressed below). Branch `sprint015`. Day 1 starts only as `AGENTS.md` ("Start") says; Sprint 015 is part of the agent-driven epic PBI-049. Inputs: `scrum/order/order004.md`, refinement commit d916568, SCB-17.e deletion d6ebfba.

## Availability and timebox

Assumption (not a confirmed fact): Ito, Tanaka, Yamamoto and Nakamura are all available with no leave; no leave is recorded in the repository, and the Executive may correct it. Takahashi keeps it as an assumption before wave 0. Yamamoto and Nakamura were absent from planning only (contract). Timebox: five days, ended early when the work is done. Tasks total 61 h (Nakamura 16.5, Tanaka 14.5, Ito 14, Takahashi 9, Yamamoto 7). The critical path (Nakamura in wave 0, Ito in waves 1 and 2, then wave 3) is about 4 of 5 days.

## Topic 1: Why (sprint goal)

**Goal:** The Executive sees every open question and every waiting verification in one ScrumBoard column and answers, accepts or returns each one there.

Suzuki proposed it; Ito, Tanaka and Takahashi agree. Takahashi: it is one objective, valuable to the Executive (no question or check lost in the chat), and testable by the named tests in `sprint_backlog.md`. If PBI-125 is cut, the goal narrows to "sees" (Ito) and the review says so.

## Topic 2: What (scope and usage fit)

Scope 10 points, in build order: PBI-126 (2), PBI-086 (5), PBI-125 (3, after PBI-086). Cut PBI-125 first. Stretch: PBI-113 (1) only if the sprint finishes early. PBI-123 and PBI-118 go to Sprint 016. Velocity (`scrum/velocity.csv`), Sprints 011 to 014: 8, 8, 10, 9 points built; 10 fits.

**Velocity assumption (order004, refinement record):** velocity counts points built and tested in the sprint, not points the Executive has accepted (most stay In Review until the Executive's check). Recorded here by Takahashi before the review.

**Usage decision (`scrum/usage/README.md`, "When"):**
- Before-reading from the Executive: session 3% (resets 5:40 PM), week 59%.
- Anchor: +5% session for Steps 1 to 3 -> session 8%; week equivalent 5 x (0.358 / 2.667) = 0.7 -> week about 60%.
- `bash scrum/usage/usage.sh project "Sonnet 5.5" 10 8 60` (run by Takahashi):
  ```
  Projected session after-reading: 34.7% (now 8 + 10 points x 2.667)
  Projected week after-reading: 63.6% (now 60 + 10 points x 0.358)
  Below 70: no level crossed.
  ```
- `estimate`: 2.667 session % and 0.358 week % per point (3 rows used, 2 discarded).
- Model: the orchestrator and the sub-agents run on Opus. `usage.log` has no Opus rows (`project "Opus 5.5"` answers "No session estimate"), so the Sonnet 5.5 figures are borrowed and are a weak forecast; this sprint's row is the first Opus row.
- Closest evidence for an Opus-heavy sprint: the Sprint 014 row (5.889 session and 0.778 week % per point, discarded as an outlier). At that rate 10 points give about 66.9% session and 67.8% week: both below Caution (70%) but close. 12 points would give about 78.7% session, so the stretch is 1 point only.
- The 3% before-reading was taken before refinement and planning ran. At Start the orchestrator asks the Executive for a fresh before-reading and re-runs `project` (README, "When"); if it projects at or over 70%, PBI-125 is cut first.
- Decision: 10 points fit; no split. If a real reading reaches 70%, the orchestrator tells the Executive and continues; at 85% it launches nothing.

**Dependencies:**
- PBI-086 on PBI-092 (In Review, verification 8 in `scrum/verifications.md`): PBI-086 changes its filter bar. If verification 8 is returned, the bar rework goes into PBI-086 and PBI-125 is cut. Tanaka acts on any verification the Executive accepts or returns during the sprint (`AGENTS.md`, "Questions and verifications").
- PBI-086 on PBI-126: PBI-126 is done before task 12b puts PBI-086 In Review.
- PBI-125 on PBI-086: built after it (wave 2).

**Not in scope:** no new mark, seen state or count badge (SCB-17.e deleted by the Executive, d6ebfba). The column heading is text only.

## Topic 3: How

Tasks, owners, waves, fixed names, keys, tests and file ownership are in `sprint_backlog.md`. Ito broke the PBIs into tasks; Tanaka reviewed them; Suzuki confirmed the 13 keys and their English text. Every task is one day or less.

**Ordering decisions (Takahashi):**
- Task 6 (Yamamoto) tests the generic bar on `BoardItem`, which Nakamura creates. The model lands first: task 8a (first in wave 0) adds `BoardItem` and writes "model landed" in `handoffs.md`; Yamamoto writes the generic bar and `requirementFilterFields` first and starts the `BoardItem` bar test only after that handoff. The bar test does not use its own test type.
- Task 15 (Ito) needs the fake writes: task 8b (wave 0) already adds `answerQuestion` and `setVerificationResult` to the interface and an in-memory fake, so wave 2 has no unordered dependency.
- Task 9 makes `questions` required: Tanaka passes a placeholder in `main.dart` in wave 0 until task 10b.
- Task 17b's web check ("the column shows") runs after tasks 10 and 10b.

**Order in the column (Suzuki):** open items first, newest first (reverse file order); then answered or closed items (answered, accepted, returned), newest first. This matches SCB-17.c (open first); Takahashi writes it in the task 1 statement.

**Process from the Sprint 014 retrospective:**
- IMP-003: Kobayashi reviews the code of each wave (tasks 12, 16) before its PBIs go In Review; Kobayashi writes only `kobayashi_code_review.md` (and wrote `kobayashi_plan_review.md`).
- PBI-119: docs and platform checks are named for every changed route (`sprint_backlog.md`, "Docs and platforms"); no option or setting changes.
- PBI-120: each developer writes the test command and its pass count in their own section of `daily_scrum.md`.

## Corrections

`scrum/order/order004.md`, "Refinement record (2026-11-24, Sprint 015)", point 2 is outdated: it lists a "badge" in PBI-086 and says PBI-086 assumes question 1, choice a. The Executive deleted SCB-17.e (new mark, count badge) and question 1 was deleted (d6ebfba); PBI-086 and PBI-125 no longer include them. This plan follows the backlog rows. order004 (Sato's order) is not edited.

## Review findings addressed (`kobayashi_plan_review.md`)

| # | Fix |
|---|---|
| 1 (must) | SCB-17.b gains a server test (number no longer in the file -> `{ok: false, reason: "gone"}`, file byte-for-byte unchanged) and a column test (a `gone` answer shows msg:scbItemGone and reloads); tasks 13 and 15. |
| 2 | Hours recounted after the rebalance: 61 h. Nakamura's load cut from 19 h to 16.5 h: Tanaka takes the README (tasks 11, 14b) and the integration test (17a); Nakamura keeps the web build and the Windows and web checks (17b, see 15). Days follow the critical path, not the total. |
| 3 | Order decided (open first, then answered or closed; newest first within each); in the task 1 statement and the SCB-17.c test. SCB-17.b asserts the item stays listed with its new status and no answer controls after each write. |
| 4 | Named tests added: verification shows its PBI (SCB-17.a column part); answer by choice writes the choice line, typed text writes the text (SCB-17.b); DEF-01 widths in light and dark with an open verification in the narrowest size and longest language (SCB-15.a). |
| 5 | The three `scb-shown-of` assertion moves to the integration test (task 17a), with the real three columns on the fake. |
| 6 | Ito sends token needs to Tanaka through `handoffs.md`; Tanaka adds them to `scrum_theme.dart` (task 6b). |
| 7 | Fake writes land in task 8b (wave 0), before task 15. |
| 8 | Week at the Sprint 014 rate (67.8%) recorded; fresh before-reading at Start, cut PBI-125 first at 70% or over. |
| 9 | `scrum/questions.md` has no open question: fixtures copy its Format block as is and add question items written in that format (with indented choice lines); the test says so. |
| 10 | Tanaka acts on verifications changed during the sprint; `scrum/questions.md` is Takahashi's in the ownership table. |
| 11 | Tasks 2 and 3 take the check already listed in a sprint review file, when there is one. |
| 12 | Task 17b's web check runs after 10 and 10b; `main.dart` placeholder in task 9. |
| 13 | SCB-17.d names the failure: with more items than fit, the column's own `Scrollbar` scrolls and the page does not (SCB-15.b). |
| 14 | Ownership: `kobayashi_plan_review.md` is Kobayashi's, not Takahashi's. |
| 15 | Web build moved to task 17b (Nakamura owns `build/`); 17a is the integration test only (1.5 h each). |
| 16 | Task 6b takes token requests in waves 1 and 2. |
| 17 | In wave 0, task 8b makes `HttpScrumBoardApi` implement the two write methods, returning `(ok: false, reason)` until task 14. |

## Facilitation (Takahashi)

All three topics were discussed (Why: goal agreed by Suzuki, Ito, Tanaka, Takahashi; What: scope, usage fit and dependencies; How: tasks broken down and reviewed). The sprint goal is defined. Timeboxes were kept (planning well under its limit). The review's findings are addressed above; the sprint starts only when the Executive says start.
