# Sprint 015 Retrospective

Facilitated by Takahashi; Suzuki, Ito and Tanaka each ran as their own agent (Yamamoto and Nakamura speak through Ito and Tanaka). Recorded automatically inside the agent-driven epic PBI-049, under the sprint pause at 016 (`scrum/order/order005.md`); audited by Kobayashi (`kobayashi_retro_audit.md`, verdict: accept after re-audit).

## Inspection summary
- Built: PBI-126, PBI-086, PBI-125, 10 of 10 points and 61 of 61 task hours; all In Review, none Done; verifications 45 to 47 (`sprint_review.md`).
- In Review now: 47 PBIs, 134 points, 47 open verifications (Sprint 014: 44 PBIs, 124 points). The velocity row counts the 10 points while question 3 is still open. IMP-002 is open since sprint006.
- Every day ran with separate role agents; IMP-003 resolved on Day 3. Kobayashi's plan review found one must-fix (no test for the deleted-item case of PBI-125) and the hours (58, not 55), fixed before wave 0; the wave reviews found no must-fix and reproduced every final count (Tanaka's mid-run Day 1 count did not reproduce; see Problem).
- Usage: planning took a before-reading and ran `project`; no reading at Start and none at the end, so `scrum/usage/usage.log` has no sprint015 row. The forecast used Sonnet figures for a sprint run on Opus.
- Tools: headless Edge gave one light screenshot; clicks and dark mode moved to verifications 46 and 47. The Windows check on copies found a held file gives 500 (PBI-130).
- Definition of Done: met except the Executive's browser checks; "errors are reported clearly" partly met (PBI-129).

## Keep
- Kobayashi's plan review and a review after each wave, with its own counts, before PBIs go In Review (all).
- Fixed names, file ownership, fake writes and keys confirmed in wave 0; handoff lines that unblock work (Ito, Tanaka, Suzuki).
- Decisions taken during the day written in `handoffs.md` with PBI rows at once (PBI-129, PBI-130) (Suzuki).
- Server checks on copies, real files unchanged; records that say what was not checked (Tanaka, Ito).
- Executive input during a sprint recorded as `scrum/order/orderNNN.md` and held until the sprint ends (Suzuki).

## Problem
- The Executive's checking time is the bottleneck: 47 open verifications; agents cannot click in a browser or see dark mode (Ito, Tanaka, Suzuki; Sato in the review).
- Task 17b was reported done when only partly done (Kobayashi Day 4 finding 1); the DoD line "checked on Windows and web" mixes the agents' check with the Executive's (Ito, Tanaka).
- The usage rule was skipped at Start and end, so no Opus data for the next planning (all; Takahashi).
- Full-suite counts taken mid-wave in the one shared working tree went into the record (Tanaka +197 -2; Kobayashi Day 1 finding 1) (Ito, Tanaka).
- The plan had no message key for a refused board write (PBI-129); no record of why stretch PBI-113 was not taken (Ito).
- Data hygiene (Takahashi): the sprint005 velocity row has 8 fields; `impediment_log_resolved.csv` holds three IMP-003 rows; 13 PBIs plus PBI-039 still "In Sprint" from Sprints 006 and 007; the review said the merge waits for the Executive although order005 makes the close-out automatic; the working agreement's start words differ from the Executive's uncommitted `AGENTS.md` change.
- Tool friction: `dart format` reformatted whole files and restore was denied; Git Bash `sed -i` drops CRs; a line-end one-liner counted 9 instead of 263 (Tanaka).
- Tanaka's Day 2 "Later" lines landed under Ito's heading (Ito, Tanaka).

## Try
1. Usage reading at Start and end, logged with `usage.sh` with the model actually used; no Day 1 without it (Tanaka, Ito, Suzuki, Takahashi).
2. Reduce the Executive verification bottleneck: agent-run browser checks that click and switch the app's theme light and dark before the Executive checks (PBI-136) (Tanaka, Ito, Suzuki).
3. Test counts written only after a wave's handoffs have landed, or marked mid-wave (Ito, Tanaka).
4. Data hygiene: one 10-field check for the backlog files, `velocity.csv` and both impediment logs; unique impediment ids; stale "In Sprint" rows sorted out (Tanaka, Takahashi).
5. Planning's Keys table names an error key for each new write path; the Day 4 Daily Scrum records the stretch decision (Ito).
6. Sprint 016 refinement puts the Linux stack items first (order006); Watanabe reviews `setup.sh` and the `curl | bash` line in the plan review (Suzuki).
7. Format only the files a developer owns and touched, in their own commit (Tanaka).

## Decided actions
| Action | Owner | Deadline |
|---|---|---|
| Usage before-reading at Start and after-reading at end, logged with the model used; enforcement wording in PBI-138 | Takahashi (orchestrator) | Sprint 016 Start |
| Agent-run browser checks, light and dark (PBI-136) | Nakamura; Tanaka reviews | Sprint 016 refinement sizes it |
| DoD wording: checks agents cannot run are named in the verification (PBI-137) | Suzuki proposes; Executive approves the exact text | Sprint 016 refinement |
| Skill wording: error keys, counts after the wave, stretch decision, usage gate, formatting only own touched files (PBI-138) | Suzuki and Takahashi propose; Executive approves | Sprint 016 refinement |
| Stale "In Sprint" rows (PBI-139) | Suzuki | Sprint 016 refinement |
| 10-field check extended to `velocity.csv` and both impediment logs; unique ids for the IMP-003 rows; line-end check script (PBI-128) | Takahashi; Nakamura for the script | Sprint that takes PBI-128 |
| Start words of the working agreement match `AGENTS.md` (PBI-127) | Suzuki proposes; Executive approves | After the Executive commits `AGENTS.md` |
| Velocity counting In Review points (question 3, overdue) | Executive; Suzuki asks once, Takahashi records | Sprint 016 planning |
| Ask where the CalendarStream installer is (PBI-073) | Suzuki asks once | Before Sprint 016 refinement |
| Security review of `setup.sh` and its `curl \| bash` line (PBI-073) | Watanabe | Sprint 016 plan review |
| Cite the ccusage findings from the session that found them (PBI-134, order006) | Sato or Suzuki | Sprint 016 refinement |
| Agent renames (PBI-140, order007) | Takahashi (orchestrator) | After this close-out, before Sprint 016 starts |
| Say what replaced PBI-121 in its row | Suzuki | Sprint 016 refinement |
| Number-literal test (PBI-118) with PBI-113 | Tanaka | Sprint 016 |
| Review line on merge corrected (`sprint_review.md`) | Takahashi | Done in this retrospective |

## Status of Sprint 014 actions
| Action | Status |
|---|---|
| Separate role agents and Kobayashi per wave | Met every day; IMP-003 resolved on Day 3 |
| Velocity as built and Done (question 3) | Missed its deadline; still open (`kobayashi_review_audit.md` finding 2) |
| Number-literal test (PBI-118) | Not due: waits for PBI-113, moved to Sprint 016 |
| Planning names doc files and platform checks (PBI-119) | Applied; In Review |
| Test command and count in `daily_scrum.md` (PBI-120) | Applied; In Review |
| Rule-wording changes as PBIs (PBI-121) | Superseded; its row does not yet say by what |
| Stale audit wording (PBI-122) | In Review |

## Executive input recorded
- `scrum/order/order006.md` (Linux Docker stack first; reusable for CalendarStream): PBI-063, PBI-066, PBI-073, PBI-074 rewritten (order before the remaining ScrumBoard slices, Linux target, reusable settings; PBI-074 Medium to High); new PBI-133 (ScrumBoard in the stack) and PBI-134 (usage tooling on Linux, not Ready until the ccusage findings are cited).
- `scrum/order/order007.md` (bin color; expand and collapse icons): SCB-19, SCB-11.c and SCB-11.f back to `backlog` with new statements, SCB-11.i reworded (`requirements/scrumboard.md`, test cells kept); new PBI-135. The key msg:scbCollapseAll is added when PBI-135 is built. Agent renames: PBI-140, run by the orchestrator after this close-out; whether past records keep old names is asked once in `scrum/questions.md` before the rename.
- `scrum/order/order005.md`: the pause at Sprint 016 stands.

Nothing graduates to `scrum/scrum_team_culture.md` this sprint. Candidate: separate role agents with Kobayashi per wave (kept two sprints).

## Definition of Done review
No change to `definition_of_done.md`. The criteria held; "checked on Windows and web" was read as covering checks the agents cannot run. The rewording goes to the Executive as PBI-137. "All relevant tests pass on the agreed target platforms" covers Linux once the stack items arrive.

## Impediments
IMP-002 stays Open, now pointing at the verification process (PBI-126, `scrum/verifications.md`); it closes when the sprint005 items are verified or retired. Nothing moves to `impediment_log_resolved.csv`.

## Periodic requirements and test audit
Not due. `scrum/sprints` holds 12 retrospectives without `sprintSAMPLE`; with this one 13, not a multiple of 5 (next at the 15th).

## Close-out
Sprint 015 is completed under the agent-driven epic rule: `flutter analyze` and the tests, commit, push `sprint015`, merge into `main`, push `main`. Sprint 016 is held by the pause (`order005.md`) and is not started.
