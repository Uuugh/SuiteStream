# Sprint 003 Retrospective (2026-11-22)

This retrospective is evidence-only, approved by the Product Owner because the team-agent prompt files are absent. It records observations from the sprint artifacts and does not attribute opinions or performance to individuals.

## Inspection

| Area | Observation |
|---|---|
| Individuals | The artifacts do not contain individual feedback; no conclusions about motivation or skills are drawn. |
| Interactions | Product Owner feedback led to changes to the event dialog, date picker, settings, and time-zone behavior. The latest dialog feedback also exposed and fixed a 3 px start/end field offset. |
| Process | The sprint planned 47 points after prior sprints completed 26 and 15 points. About 22 points were built; theme, shared UI, Settings, and calendar-height work remained. The 92% weekly usage warning and subsequent Claude usage timeout made the commitment and session continuity risks concrete. |
| Tools | Requirement-linked tests and UI tests caught behavior and layout issues. The interruption checkpoint and sprint records made it possible to resume. The latest focused run passed 41 event-dialog and popup-layout tests; `flutter analyze` was clean. |
| Definition of Done | The existing criteria cover acceptance mapping, verification, quality, runtime, privacy, and documentation. No change is proposed. |

## Keep

- Map work to requirement IDs and verify acceptance criteria with focused tests.
- Incorporate Product Owner feedback as concrete, testable changes.
- Preserve a checkpoint in the sprint records so interrupted work can resume.

## Problems

- The 47-point commitment substantially exceeded either of the two prior completed sprints, despite the 92% weekly usage warning.
- Several selected rows depended on features that did not exist, so they could not be completed within this sprint.
- The empty-time requirements conflict was described in the daily notes but was not recorded in the impediment log when it arose.
- The Product Owner's follow-up review found responsive-layout issues after the dialog had already been built.
- Session usage exhaustion interrupted the planned Scrum sequence before its retrospective.

## Try (prioritized)

1. Bound the next sprint commitment by available usage and demonstrated throughput, with explicit capacity for review and interruptions.
2. Walk through the first vertical slice with the Product Owner early; include narrow-window layout checks for paired fields and labels.
3. Before planning, identify missing prerequisites and keep dependent work out of the committed scope; record requirement conflicts as impediments when they appear.

## Improvement actions

| Action | Owner | Due |
|---|---|---|
| Review available usage and recent throughput before setting the next sprint commitment; leave capacity for review and interruption recovery. | Scrum Master and Product Owner | Before Sprint 004 planning |
| Run a Product Owner walkthrough of the first vertical slice, including narrow layouts, before expanding the slice. | Product Owner and developer pair | First day of Sprint 004 |
| Map prerequisite features and log requirement conflicts as impediments when discovered. | Product Owner and Scrum Master | Before Sprint 004 planning |

No action is considered graduated to team culture yet. Carry these actions into Sprint 004 planning; no Sprint 004 backlog exists at this time.

## Definition of Done review

The current Definition of Done remains valid; no change is proposed. It already requires agreed criteria, pass/fail verification, relevant passing tests, quality, runtime and privacy checks, and current documentation.

## Audit and records

- The sprint backlog, review, daily notes, impediment logs, velocity history, and Definition of Done were checked.
- The resolved requirement conflict and the usage interruption are recorded in `../impediment_log_resolved.csv`.
- `definition_of_done.md` and `scrum_team_culture.md` were not changed: the DoD remains suitable and no practice has graduated.
- The reviewer and Scrum Master agent prompt files are absent, so their audit/merge roles were not simulated. The Product Owner approved this evidence-only record.
