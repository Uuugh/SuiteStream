# Sprint 015 Review

Slice 5 of the ScrumBoard epic (PBI-049): PBI-126, PBI-086, PBI-125 (the Questions and Verifications column). All 3 built and In Review, 10 of 10 points; acceptance pending the Executive. Stretch PBI-113 not taken.

## Sprint goal (Takahashi)
- Met as far as In Review. Burndown 10, 10, 3, 0, 0 and 61 of 61 task hours (`sprint_backlog.md`).
- Every day ran with separate role agents; IMP-003 resolved on Day 3 (`scrum/impediment_log_resolved.csv`).
- Kobayashi reviewed waves 0 to 3 (`kobayashi_code_review.md`): no must-fix; test counts reproduced.
- Not done here: task 17b browser clicks and dark mode, moved to verifications 46 and 47.

## Demonstration (Ito, Tanaka), measured in this review
- Ito, in `scrum/scrumboard`: `flutter analyze lib test` no issues; `test/questions` +20; `test/server test/api` +117; `test/features test/l10n` +29; full `flutter test` +241.
- Ito mapped named tests to SCB-17, SCB-17.a to SCB-17.d, SCB-15.a, SCB-04, SCB-22, SCB-01.a, SCB-13.b and DEF-01 (light and dark).
- Tanaka, at the root: `flutter analyze lib test` no issues; `flutter test` +596. In `scrum/scrumboard`: `test/integration test/app` +36.
- PBI-126 checked by script: 47 In Review PBIs, 47 open verifications, one each with matching numbers; every backlog row has 10 fields.
- README routes match `server.dart`.
- Task 17b evidence: web release build; GET and writes on CRLF copies; gone and 400 answers; line endings kept; held-file 500; headless Edge screenshot at 1024x640, light only. Not checked: browser clicks, dark mode, other DEF-01 sizes, filter, scrolling, live reload.
- Definition of Done: met except the Executive's browser checks. Error handling partly met: a refused write shows the raw server reason (PBI-129).
- Known limitation: on Windows a file held by another program gives a 500; the README documents it (PBI-130).

## Stakeholder feedback (Sato): conditional accept
- PBI-126 fine. PBI-086 and PBI-125 on condition of verifications 46 and 47 in a real browser, light and dark.
- Usability: 47 items in one list; a choice or Accepted writes at once with no undo; a refused write reads in English; the notice stays until the next write; held-file 500.
- Value high; the bottleneck is the Executive's checking time.

## Decisions (Suzuki)
- PBI-126, PBI-086, PBI-125 stay In Review (no verification answered); none Done.
- New PBIs in `scrum/product_backlog.csv`: PBI-129 (Day 3) and PBI-130 (Day 4); in this review PBI-131 (reopen an item until an agent acts: undo, not a confirm step) and PBI-132 (group verifications by sprint: not Ready, see question 2).
- Clearing the notice is folded into PBI-129. Bulk accept declined. Tanaka's backtick point declined: the `scrum/verifications.md` Format writes the path in backticks and the backlog rows write it without; the check passes either way.
- PBI-049 row updated for the pause at Sprint 016.

## How the sprint ran
- Separate role agents every day, Kobayashi reviewing each wave before its PBIs went In Review.
- Environment: `scrum/order/order005.md` (pause at Sprint 016), `order006.md` (Linux Docker stack items first for Sprint 016; reusable for CalendarStream), `order007.md` (bin color, header expand and collapse icons, agent renames after Sprint 015 is closed out). All are Sprint 016 refinement input.
- Usage: no reading was taken for this sprint; nothing is logged in `scrum/usage/usage.log`.
- Housekeeping: a cut-off copy of the IMP-003 row left in `scrum/impediment_log.csv` by the Day 3 commit is removed.
- Merge to main and `git pull origin main`: not done in the review; they follow at the retrospective close-out under `scrum/order/order005.md` and the agent-driven epic rule (amended in the retrospective).
- For information: the Day 1 `dart format` churn in `models.dart` and `scrumboard_api.dart` is committed as is (`daily_scrum.md` Day 1).

## Checks the Executive must do (light and dark, hard refresh)
Record results in `scrum/verifications.md`:
- 45. PBI-126 Every In Review PBI has its verification.
- 46. PBI-086 Questions and Verifications column.
- 47. PBI-125 Questions and Verifications column writes. Answer a real open question on the board: questions 1 to 3 in `scrum/questions.md` are open.
- Verifications 1 to 44 are still open.

## For the Executive to decide
Open questions in `scrum/questions.md`:
- Question 1: `devtools_options.yaml`.
- Question 2: PBI-132 group heading count and order.
- Question 3: velocity counting In Review points.
