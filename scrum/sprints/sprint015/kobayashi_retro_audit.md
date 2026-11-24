# Sprint 015 Retrospective audit (Kobayashi)

Step 8 of `.github/skills/sprint-retrospective/SKILL.md`, limited to the files changed in the sprint and the retrospective (agent-driven epic PBI-049). Branch `sprint015` at da97e11 plus the uncommitted retrospective changes, 2026-11-24. Run on Opus (GPT not selectable). Primary sources only; every count below was measured by me.

## Scope

Uncommitted changes: new `sprint_retrospective.md`; `scrum/product_backlog.csv`; `requirements/scrumboard.md`; `scrum/impediment_log.csv`; `sprint_review.md`. Checked against the skill (Recording and steps 1 to 8), the role inputs of Suzuki, Ito and Tanaka, and Takahashi (scratchpad, not committed), `scrum/order/order005.md` to `order007.md`, `scrum/sprint015/*`, `scrum/velocity.csv`, both impediment logs, `scrum/definition_of_done.md`, `scrum/scrum_team_culture.md`, `requirements/README.md` (Line format, rules 11 and 12), `scrum/team_working_agreement.md`, `scrum/verifications.md`, `scrum/questions.md`. `AGENTS.md` (the Executive's uncommitted change) and `devtools_options.yaml` read through `git diff` only, not touched. `scrum/XO` not read. CalendarStream not touched. No code changed, so `flutter analyze` and the tests were not rerun here; they are the close-out gate.

## Measured

A quote-aware Dart check (`kobayashi_check.dart` in the session scratchpad):
- `product_backlog.csv`: 120 rows after my fixes (119 before), every row 10 fields, no comma inside any field, ids unique across `product_backlog.csv` and `product_backlog_done.csv`, dates well formed. In Review: 47 PBIs, 134 points. 47 open verifications in `scrum/verifications.md` (48 `Status: open` lines less the Format template).
- Stale "In Sprint" rows: PBI-026 to PBI-030, PBI-033 to PBI-036, PBI-039, PBI-041 to PBI-044: 13 plus PBI-039, as the retrospective says.
- Pre-existing, unchanged: `product_backlog_done.csv` PBI-020 to PBI-023 hold quoted commas, and the file mixes LF (19) and CRLF (16) line ends; `velocity.csv` sprint005 has 8 fields; `impediment_log_resolved.csv` holds three IMP-003 rows. All are in PBI-128 as extended.
- Periodic audit count: `scrum/sprints` holds 13 `sprint_retrospective.md` files, 12 without `sprintSAMPLE`; with this one 13. Not a multiple of 5: not due.

## Checks

| Item | Result |
|---|---|
| Recording | `sprint_retrospective.md` written; no impediment resolved, so nothing moves to `impediment_log_resolved.csv`; IMP-002 stays Open with a note, 9 fields. |
| Steps 1 to 6 | Inspection, Keep, Problem, Try, decided actions with owners and deadlines, DoD review (no change, PBI-137 for the wording) all present. Nothing graduates to `scrum_team_culture.md`: consistent with the inputs. |
| Facts | Match the sources: 10 of 10 points and 61 of 61 hours (`sprint_backlog.md`, `velocity.csv`); 47 PBIs, 134 points; Sprint 014 44 and 124 (`sprints/sprint014/sprint_retrospective.md`); plan review must-fix 1 and hours 58 not 55 (`kobayashi_plan_review.md`); Tanaka +197 -2 and the 9-for-263 one-liner (`kobayashi_code_review.md` Day 1 finding 1, Day 4 finding 3); Sonnet figures for an Opus sprint and no Start or end reading (`sprint_planning.md`, `usage.log` ends at sprint014); the "Later" lines slip (`daily_scrum.md` line 47); DoD Documentation line (`definition_of_done.md`). Except finding 5. |
| Role inputs | Every Keep, Problem and Try of the four inputs appears, except findings 2 and 4. |
| Order 006 | PBI-063, PBI-066, PBI-073, PBI-074 put ahead of the seven ScrumBoard slices; "after the ScrumBoard epic" removed from PBI-073 and PBI-074; Linux target (DEP-01.b); the installer addition (Dart and Flutter applications, open points); reusable settings in PBI-063, PBI-066, PBI-073, PBI-074, PBI-133, PBI-134; PBI-133 and PBI-134 added; ccusage source rule in PBI-134. Nothing built. |
| Order 007 | SCB-19, SCB-11.c, SCB-11.f reworded and set to `backlog`, SCB-11.i reworded, SCB-11.b unchanged, no row added; PBI-135 added. The renames were not recorded (finding 1). Nothing built. |
| Order 005 | Pause at 016 kept; the review's merge line now agrees with it and the working agreement (sprint pause). |
| Requirements | Cited by ID in the retrospective; no requirement text copied. |

## Findings

1. **should (Suzuki; fixed by me)**: order007's agent renames and the `rols.md` step were in no backlog item ("no backlog item"), against `AGENTS.md` (Talk after a sprint) and the task that every point of orders 006 and 007 is a backlog item or requirement change. Added PBI-140 (Ready, 2 points, Medium) and a decided-action row.
2. **should (Takahashi; fixed by me)**: Try 6 (Watanabe reviews `setup.sh` and the `curl | bash` line) and Try 7 (format only own touched files) had no backlog item or action. Added to PBI-073 and as item 5 of PBI-138 (title updated), with decided-action rows.
3. **should (Suzuki; fixed by me)**: PBI-138 item 1 named "the Keys table" of the sprint-planning skill; the skill has no such table (it is the sprint backlog's practice, `sprint_backlog.md` "Keys"). Reworded.
4. **should (Suzuki; fixed by me)**: order006's request that Sato or Suzuki cite the ccusage findings had no owner or deadline (only "not Ready" in PBI-134). Added a decided-action row.
5. **should (Takahashi; fixed by me)**: Inspection said the wave reviews "reproduced every count"; Tanaka's mid-run Day 1 count did not reproduce. Reworded to "every final count", pointing at the Problem.
6. **should (Takahashi; fixed by me)**: `sprint_review.md` said the merge was "done at the retrospective close-out" before it happened. Reworded: not done in the review; it follows at the close-out.
7. **note (Yamamoto, when PBI-135 is built)**: SCB-11.c cites `msg:scbCollapseAll`, not yet in `requirements/messages/app_en.arb`; README rule 12's check would report it. Same practice as other `backlog` rows (for example `msg:scbIssues`, `msg:scbStart`). No action now.
8. **note (Suzuki, at acceptance)**: verifications 37 (PBI-080) and 40 (PBI-097) still check the Expand all switch and the bin as built (white). When accepted, SCB-11.c, SCB-11.f and SCB-19 stay `backlog` (PBI-135 owns them); their kept test cells name tests of the old behaviour until PBI-135 rewrites them.
9. **note (Takahashi, at the archive)**: records that will need `scrum/sprint015` changed to `scrum/sprints/sprint015`: `product_backlog.csv` PBI-129, PBI-130, PBI-131, PBI-137 (`scrum/sprint015/handoffs.md`) and PBI-134 (`scrum/sprint015 notes`); `scrum/order/order006.md` line 10. `scrum/questions.md` line 41 and `velocity.csv` name the sprint, not the folder: no change. `order004.md` already uses `scrum/sprints/sprint015`.
10. **note (Suzuki)**: PBI-073 records that the order's installer path was not found; I did not check it (CalendarStream is outside my scope). The decided action to ask once covers it.
11. **note (Nakamura; fixed by me)**: `.github/skills/playwright-cli` exists; named in PBI-136 as one option for refinement.
12. **note**: `product_backlog.csv` working copy is LF (as before); git normalizes it. The "Later" lines slip has no action and needs none (annotated in `daily_scrum.md` line 47).

## Verdict

Revise: findings 1 to 6 are should items, all pure record fixes.

## Re-audit

2026-11-24, after my fixes to findings 1 to 6 and 11 in `scrum/product_backlog.csv` (PBI-073, PBI-136, PBI-138 changed; PBI-140 added), `sprint_retrospective.md` (Inspection count line; renames line; four decided-action rows; header verdict) and `sprint_review.md` (merge line). The check reruns clean: 120 rows, 10 fields each, no comma in a field, ids unique across both backlog files; In Review still 47 PBIs and 134 points. No code changed.

**Verdict: accept.** No must-fix or should left. Notes 7 to 10 go to their owners; note 9 is for the archive step of the close-out.
