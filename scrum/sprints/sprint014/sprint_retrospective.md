# Sprint 014 Retrospective

Facilitated by Takahashi; Suzuki, Ito and Tanaka each ran as their own agent (Yamamoto and Nakamura speak through Ito and Tanaka). Recorded automatically inside the agent-driven epic PBI-049; audited by Kobayashi (`kobayashi_retro_audit.md`, verdict revise; L1, L3 and I1 fixed, L2 recorded as PBI-122).

## Inspection summary
- Built: all 7 PBIs, 9 of 9 points, in 2 of 5 planned days; none Done: all wait for the Executive's 7 checks (`sprint_review.md`).
- Velocity rows 011 to 014 record 8, 8, 10, 9 as completed, but every one of those PBIs is In Review. In Review now: 19 PBIs, 38 points from Sprints 011 to 014 plus PBI-105; 44 PBIs, 124 points in all, including 3 partly built (`product_backlog.csv`). IMP-002 (acceptance without browser check) is open since sprint006.
- Planning and development days ran with roles collapsed (IMP-003); the review ran with separate role agents and Kobayashi's code review found 8 findings (one must-fix, fixed in 068d515; four low; three info).
- Usage (`scrum/usage/usage.log`, sprint014 row): session 23 to 76 percent (53 points), week 49 to 56 percent (7 points) for 9 story points; 5.9 session points per story point, discarded as an outlier; the session ended above the 70 percent Caution level.
- Definition of Done: "setup and usage instructions are current" passed while the README was stale (code review finding 1; PBI-114).

## Keep
- Kobayashi's plan review: four must-fix gaps and the WSL bash default caught before building (Suzuki, Tanaka).
- Review with separate role agents fed the backlog (PBI-110 to PBI-117; the retrospective added PBI-118 to PBI-121) (Suzuki).
- Fixed names, file ownership and handoffs; named tests that can fail; per-day figures (Ito, Tanaka).
- A concrete list of 7 Executive checks (Suzuki).

## Problem
- Roles collapsed in planning and development: developers reviewed their own work; finding 5 (literals in `zoom_control.dart`) slipped through (IMP-003; Ito, Tanaka, Suzuki).
- Velocity counts built points as completed while acceptance piles up (Suzuki, Tanaka).
- Planning did not check platform behaviour (Windows bash, js_interop) (Ito, Tanaka).
- The DoD documentation check passed a stale README; planning did not name the doc file each changed option or route touches (Ito).
- Test counts in the review were not sourced in a file (Ito; `sprint_review.md`, Demonstration).
- Built in 2 of 5 days: estimates high or verification skipped (Suzuki, Ito).
- The Executive spent long correcting greeting and questions wording; one reply numbered the help question wrongly (Suzuki).

## Try
1. Separate role agents for planning and every development day; Kobayashi reviews each wave before its PBIs go In Review (all).
2. Count points complete only when accepted (Suzuki, Tanaka); still open as question 3. An acceptance session for all In Review PBIs was proposed; the Executive withdrew it (covered by the existing agent-driven epic rules).
3. A cap on items waiting In Review was proposed (Tanaka); the Executive withdrew it.
4. Planning names the doc file touched by each changed option or route and checks platform behaviour (Ito).
5. Developers write the test command and the measured count in `daily_scrum.md` (Ito).
6. A test that fails on number literals in ScrumBoard widgets outside `scrum_theme.dart` (Tanaka).
7. Rule-wording changes go through the backlog as PBIs (Suzuki).

## Decided actions
| Action | Owner | Deadline |
|---|---|---|
| Separate role agents in planning and development days; Kobayashi per wave (IMP-003 stays Open until done) | Takahashi | Sprint 015 planning and every Sprint 015 day |
| Velocity as built and Done (question 3) | Executive; Takahashi records | Before Sprint 015 review |
| Number-literal test (PBI-118, after PBI-113) | Tanaka | Next sprint that takes PBI-113 |
| Planning names doc files and platform checks (PBI-119) | Suzuki proposes; Executive approves the wording | Sprint 015 refinement |
| Test command and count in `daily_scrum.md` (PBI-120) | Takahashi proposes; Executive approves | Sprint 015 refinement |
| Rule-wording changes as PBIs (PBI-121) | Suzuki proposes; Executive approves | Sprint 015 refinement |
| Stale "first audit still owed" wording in the retrospective skill and Kobayashi role file (PBI-122, audit L2) | Suzuki proposes; Executive approves | Sprint 015 refinement |

Withdrawn by the Executive after the retrospective: the cap on items In Review (former question 4) and the acceptance session for all In Review PBIs (former question 5). Answered: PBI-116 shows a visible effect, undo comes later with history (former question 1; PBI-116 Ready); the usage reading above (former question 2).

Nothing graduates to `scrum/scrum_team_culture` this sprint.

## Definition of Done review
No change to `definition_of_done.md`. The criteria were right; the documentation check was applied without naming the file. PBI-119 adds the named doc file to planning so the check has a target; the Executive decides.

## Periodic requirements and test audit
Not due. `scrum/sprints` holds 12 `sprint_retrospective.md` files (11 sprints plus `sprintSAMPLE`); with this one 13 (12 without the sample), not a multiple of 5.
