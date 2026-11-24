# Sprint 014 Retrospective audit (Kobayashi)

Step 8 of `.github/skills/sprint-retrospective/SKILL.md`, limited to the files changed in the sprint. Branch `sprint014` at 068d515 plus the uncommitted retrospective changes, 2026-11-24. Primary sources only; every count below was measured by me.

## Results I ran myself

| Where | `flutter analyze` | `flutter test` |
|---|---|---|
| `scrum/scrumboard` | No issues found | 186 passed, all tests passed |
| repository root | No issues found | 596 passed, all tests passed |

The commit gate holds. The counts match the `scrum/velocity.csv` sprint014 row.

## Checks

| File | Check | Result |
|---|---|---|
| `sprint_retrospective.md` | Against the files | Correct except finding L1. These claims are correct: 7 PBIs, 9 points, 2 of 5 days (`sprint_planning.md` timebox); 7 Executive checks (`sprint_review.md`); velocity 8, 8, 10, 9; IMP-002 Open since sprint006; four plan-review must-fix items plus must-fix 14 (WSL bash) in `kobayashi_plan_review.md`; README fix in 068d515; PBI-110 to PBI-121 exist, and each Try item has a PBI, an impediment or a question. |
| `sprint_retrospective.md` | Periodic audit count | Correct. `scrum/sprints` holds 12 `sprint_retrospective.md` files (11 sprints, as 004 and 006 have none, plus `sprintSAMPLE`). With this one there are 13, or 12 without the sample. Sprint 013 used the same method (it counted itself as the 12th, sample included). Not a multiple of 5 either way, so no audit is due. |
| `sprint_retrospective.md` | Sprint 010 audit claim | The retrospective makes no such claim. The `velocity.csv` sprint010 row does say "fifth-retrospective audit run", and `scrum/sprints/sprint010/sprint_retrospective.md` confirms it (line 3 and the section "Kobayashi audit"). See L2. |
| `product_backlog.csv` | Structure | 104 rows plus the header. Every row has exactly 10 fields (parsed as CSV). No duplicate IDs. PBI-110 to PBI-121 are present once each, use semicolons instead of commas, have whole-number sizes and a blank sprint, are dated 2026-11-24, and carry Ready or Backlog status. That status agrees with the open questions (PBI-116 is Backlog until question 1 is answered). |
| `product_backlog.csv` | In Review recount | Sprints 011 to 014: 18 PBIs, 35 points (011: 4/8, 012: 3/8, 013: 4/10, 014: 7/9). PBI-105 adds 3 points, giving **19 PBIs, 38 points**, so the claim is correct. Whole backlog: 41 rows with status exactly "In Review" (95 points), plus 3 rows "In Review (partly built ...)" (PBI-013 13, PBI-037 8, PBI-063 8). That gives **44 PBIs, 124 points**, so the claim is correct when the partly built rows are counted (I1). |
| `questions.md` | Format | Five open questions, numbered 1 to 5, each with the heading `## <n>. <asker, sprint> <title>`, `Status: open`, `Question:`, choices indented 3 spaces with the recommended choice first, and `Answer:`. Blank lines separate the questions. The header text is unchanged. Question 4's figures (44 PBIs, 124 points, 38 points from 011 to 014 and PBI-105) match my recount. |
| `impediment_log.csv` | Fields | All rows have 9 fields. The IMP-002 row is unchanged. The IMP-003 row's description was only extended (no commas), it stays Open, and it names the owner and the condition for closing. This agrees with the retrospective's first action. |
| `velocity.csv` | sprint014 row | 7 fields: 9 planned, 9 completed, 0 carried, dated 2026-11-24. The test counts match my run. Counting built points as completed is the open question 3, which the retrospective leaves to the Executive. See L3. |
| `order/order003.md` | Pause note | Agrees with the sprint pause definition in `scrum/team_working_agreement.md`: Sprint 015 may be drafted and branched, but not started. |
| `sprint014/sprint_backlog.md` | Burndown note | Agrees with `kobayashi_code_review.md` (verdict revise, finding 1 fixed in 068d515). |
| Rule files | Not changed | `git diff HEAD` shows no change to `scrum/definition_of_done.md`, `AGENTS.md`, `CLAUDE.md`, `scrum/greeting.md` or `scrum/team_working_agreement.md`. No commit after 0f75f4f touches them. |
| Archive | `scrum/sprint014` to `scrum/sprints/sprint014` | Ready. The only records that use the path are inside the folder: `sprint_planning.md` lines 56 and 58 (`scrum/sprint014/*`, `scrum/sprint014/handoffs.md`). No code, CSV, order or question points at it. See I2. |

## Findings

| # | Severity | Finding | Fix | Owner |
|---|---|---|---|---|
| L1 | Low | The retrospective's Inspection summary says Kobayashi's code review "found 6 findings (one must-fix ...)". `kobayashi_code_review.md` lists 8: one Medium must-fix, four Low and three Info. | Write "8 findings (one must-fix, fixed in 068d515; four low; three info)". | Takahashi |
| L2 | Low | `.github/skills/sprint-retrospective/SKILL.md` step 7 and `.github/agents/reviewer.kobayashi.agent.md` ("Owned reviews") still say the first fifth-retrospective audit "is still owed". The sprint010 velocity row and the Sprint 010 retrospective show it ran. The two rule files contradict the records, and this retrospective does not mention it. | Record a backlog item (rule wording through the backlog, as Try 7 and PBI-121 propose), or have the Executive approve a quick fix. Do not change the rule files in this retrospective. | Suzuki |
| L3 | Low | The `velocity.csv` sprint014 notes say "New PBI-110 to PBI-117". The retrospective added PBI-118 to PBI-121. | Write "New PBI-110 to PBI-121 (118 to 121 from the retrospective)". | Takahashi |
| I1 | Info | "44 PBIs (124 points) In Review" counts three rows whose status is "In Review (partly built ...)". The rows with the exact status "In Review" are 41 PBIs, 95 points. The figure is right, but a reader filtering on the exact status gets 41. | Optional: add "including 3 partly built" in the retrospective and in question 4. | Takahashi |
| I2 | Info | At archive time, `sprint_planning.md` lines 56 and 58 still say `scrum/sprint014/`. Sprint 013's archive changed the same lines to `scrum/sprints/sprint013/`. | In the archive commit, `git mv scrum/sprint014 scrum/sprints/sprint014` and change those two paths. | Takahashi |
| I3 | Info | The `velocity.csv` sprint005 row has 8 fields (an unquoted comma in its notes). It was not changed in this sprint and is outside this audit's scope, but a strict CSV reader breaks on it. | Backlog item: quote the notes field. | Takahashi |
| I4 | Info | Some role attributions (Suzuki, Ito, Tanaka) and the claim "one reply numbered the help question wrongly" are not in any file in the repository, so I cannot check them against a primary source. | None required. Keep role outputs in a file in future if they are to be audited. | Takahashi |

## Verdict

**Revise.** L1 is a misstatement in the record and L3 an incomplete note; both are one-line fixes and need no new audit. Every other claim checked matches the files, the CSV files are well formed, the rule files are unchanged, and analyze and tests pass (186 and 596). L2 goes to the backlog. I2 is done in the archive commit.
