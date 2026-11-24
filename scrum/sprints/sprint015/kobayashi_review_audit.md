# Sprint 015 review audit (Kobayashi)

2026-11-24, step 7 of `.github/skills/sprint-review/SKILL.md`. Run on Opus (GPT not selectable).

## Scope

The uncommitted review changes on `sprint015` (HEAD a4f995f): new `sprint_review.md`; `scrum/velocity.csv`; `scrum/product_backlog.csv`; `scrum/impediment_log.csv`. Checked against `sprint_backlog.md`, `daily_scrum.md`, `kobayashi_code_review.md`, `handoffs.md`, `scrum/verifications.md`, `scrum/questions.md`, `scrum/order/order005.md` to `order007.md`, `scrum/usage/usage.log`, `scrum/team_working_agreement.md`, `requirements/scrumboard.md`, `scrum/product_goal.md`. `AGENTS.md` and `devtools_options.yaml` left alone.

## Commands and counts (run by Kobayashi)

- `scrum/scrumboard`: `flutter analyze lib test` no issues; `flutter test` +241; `test/questions` +20; `test/server test/api` +117; `test/features test/l10n` +29; `test/integration test/app` +36.
- Root: `flutter analyze lib test` no issues; `flutter test` +596.
- CSV check (a quote-aware Dart script): `product_backlog.csv` every row 10 fields, ids unique, no comma inside any field; 47 In Review PBIs (44 plain, 3 "In Review (partly built...)") and 47 open verifications, one each, every "waits for verification N" matching. PBI-126, PBI-086, PBI-125 In Review; PBI-129 to PBI-131 Ready; PBI-132 Backlog. `velocity.csv` sprint015 row 7 fields like the header. `impediment_log.csv` 3 rows, well formed, no IMP-003.

## What holds

- Every fact in `sprint_review.md` matches its source: burndown 10, 10, 3, 0, 0 and 61 of 61 hours; IMP-003 resolved Day 3 (`daily_scrum.md` line 109, `impediment_log_resolved.csv`); waves 0 to 3 reviewed with no must-fix; 17b scope and what was not checked; no usage reading for Sprint 015 (`usage.log` last row is sprint014); orders 005 to 007 summarized correctly; step 8 (merge, pull) recorded as not done. No requirement text copied; requirements cited by ID.
- PBI-049 matches `order005.md`. PBI-129 addition traces to Day 3 note 7. PBI-131 and PBI-132 are well formed.
- `sprint_backlog.md` final statuses agree with the review. Requirement rows of PBI-086 and PBI-125 stay `planned`, as they must until acceptance. `product_goal.md` needs no change. Velocity notes and line endings (CRLF, like the rest of the working copy) are consistent.

## Findings

1. **must-fix (Takahashi; wording Suzuki)**: the three decisions in "For the Executive to decide" are written only in `sprint_review.md`. `AGENTS.md` (Questions and verifications) says each question goes in `scrum/questions.md`, and the skill names `ask_user.md` as needed; `scrum/questions.md` has no open question. Also, (a) asks something different from PBI-132: the review asks "how many per group and in what order", while PBI-132 asks whether a group heading may show a count and whether grouping replaces the SCB-17.c order. Write (a) to (c) as questions in `scrum/questions.md` (PBI-132's wording for (a)) and point the review at them.
2. **should (Takahashi, with Suzuki)**: the sprint015 row records completed 10, but `team_working_agreement.md` (In Review row) says In Review counts as completed only after acceptance, and no PBI is accepted. The sprint014 row (written after that rule) did the same, so the precedent and the rule disagree. Either record 0 completed until acceptance, or say in the notes that completed counts In Review; fix both rows the same way.
3. **should (Takahashi)**: "Tanaka's backtick point declined" in `sprint_review.md` is not defined and is in no other file. Say in one clause what was proposed.
4. **note (Takahashi)**: pre-existing: `velocity.csv` line 6 (sprint005) has 8 fields against a 7-field header. Not fixed here; PBI-128's 10-field check could cover this file.
5. **note (Takahashi)**: pre-existing: `impediment_log_resolved.csv` holds three rows with id IMP-003 (sprints 003, 013, 014).
6. **note**: the working copy of `product_backlog.csv` is all LF (113 lines) while the other files are CRLF; with `core.autocrlf=true` git stores it as LF as before, so the diff is content only. `impediment_log.csv` now ends with a newline (HEAD did not). No action.
7. **note (Suzuki, at acceptance)**: SCB-01.a and SCB-04 stay `backlog` although this sprint built parts of them; both also cover parts not built. Decide their status when verifications 46 and 47 are accepted.

## Verdict

Revise: fix finding 1 before step 8; 2 and 3 should be fixed in the same pass. Counts and every other record are correct.

## Re-audit

2026-11-24, after the fixes to findings 1 to 3. Suites not rerun: `git status` shows only records changed (`AGENTS.md`, `scrum/impediment_log.csv`, `scrum/product_backlog.csv`, `scrum/questions.md`, `scrum/velocity.csv`, the two new `scrum/sprint015` files, untracked `devtools_options.yaml`); no code changed, so the counts above stand.

- Finding 1 fixed: `scrum/questions.md` holds questions 1 to 3 in its Format (lowest free numbers, Status: open, recommended choice first, choices indented 3 spaces, empty Answer:). Question 2 asks the two decisions PBI-132's acceptance names (count on a group heading; replace or sit inside the SCB-17.c order). `sprint_review.md` now only points at questions 1 to 3, and verification 47's line (answer a real open question: 1 to 3 are open) agrees with the file.
- Finding 2 fixed by deferral: the sprint015 notes say the 10 points are counted while In Review as in sprint011 to sprint014, pending question 3. Row has 7 fields, CRLF like every line of the file; no other row changed.
- Finding 3 fixed: the backtick point is explained in one clause (Format writes the path in backticks, backlog rows without; the check passes either way).

### Findings

1. **note (Takahashi)**: the sprint014 row's notes do not yet say In Review is counted; question 3 choice a covers that, so leave it until answered.
2. **note**: question 2's recommended choice adds "newest sprint first", not in PBI-132; fine as a proposal, record it in PBI-132 if chosen.
3. **note**: `scrum/questions.md` working copy is LF, like `product_backlog.csv` (finding 6); git normalizes it. No action.

### Verdict

Accept: no must-fix or should left; step 8 may proceed when the Executive says so.
