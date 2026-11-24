# Sprint 004 Planning (2026-11-22)

## Basic information

| Item | Value |
|---|---|
| Duration | 1 day |
| Participants | Product Owner and one developer session; named team-agent prompt files are absent |
| Planning basis | Product Goal, Definition of Done, Product Backlog, velocity history, latest request memo, and Sprint 003 retrospective |

## Why

Keep the different-end-time-zone option readable in the Add event dialog at narrow widths without shrinking its label.

## What

| PBI | Title | Estimate | Selection reason |
|---|---|---:|---|
| PBI-018 | Readable different-end-time-zone label | 1 | Explicit Product Owner request; small, testable, and ready |

### Backlog readiness

| PBI | Refined scope | Status / dependency |
|---|---|---|
| PBI-009 | Event palette only (THM-09.a-b), split from remaining theme work | In Review from Sprint 003 |
| PBI-010 | Shared form controls and resize bar (UIC-14 to UIC-17, UIC-27 to UIC-37) | Ready; deferred |
| PBI-011 | Event drag only (CAL-03.a-d), split from resize work | In Review from Sprint 003 |
| PBI-013 | Event dialog | In Review, partly built; remaining rows depend on History, sources, rules, links, or templates |
| PBI-014 | Local event store | In Review from Sprint 003 |
| PBI-015 | Header time-zone and clock controls | In Review, partly built; remaining work needs Settings, Print, or Full page |
| PBI-016 | Calendar height and Full page (CAL-04.a-l) | New; depends on UIC-16 in PBI-010; re-estimated to 8 |
| PBI-017 | Location address autocomplete | Blocked until Photon hosting is decided |
| PBI-018 | Readable different-end-time-zone label | Selected; 1 point |
| PBI-019 | Remaining theme components (THM-03 to THM-08) | Ready; deferred |

PBI-013/014/015 are still awaiting review rather than new sprint commitments. PBI-016 and PBI-017 have explicit blockers. PBI-009 and PBI-011 were split to separate Sprint 003 increments from unfinished work. PBI-019 remains available for a later sprint but is outside this focused goal.

Selected scope is 1 point, deliberately below the 15- and 26-point completions in Sprints 002 and 001. The sprint is shortened because no other unblocked item is needed to meet this goal.

## How

See the task breakdown in [sprint_backlog.md](sprint_backlog.md). Verify the full and compact labels at wide and narrow widths, all six supported locales, paired-field alignment, and the Definition of Done.

## Decisions and constraints

- The Product Owner authorized starting Sprint 004 after being informed that the usage ledger reported a 98% Claude weekly reading; this is a Claude usage reading, not Git usage.
- No feedback is attributed to the absent named agent roles. Refinement and planning are recorded from the backlog, sprint records, and Product Owner decisions.
- The existing Definition of Done remains unchanged.
