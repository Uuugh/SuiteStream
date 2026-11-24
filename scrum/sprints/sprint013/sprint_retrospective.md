# Sprint 013 Retrospective (recorded automatically: epic running before the pause at 014)

Not the fifth retrospective (12th): no periodic requirements and test audit due. Kobayashi's rule 8 audit ran on the sprint's files (`kobayashi_audit.md`).

## Went well
- Kobayashi's plan review ran before any agent started; its 8 must-fix findings changed the plan (waves, key names, owners, padding split, reload_scope owner).
- Fixed names in the plan made three parallel waves integrate with no repair.

## Problems
- One developer used `git stash` on the shared tree (IMP-003); no edit was lost.
- Requirement rows built this sprint were left `backlog` with no test named until the audit caught it.
- A retire was tested only against a fake and an unknown id; a real retire needs the Executive's test row.

## Rule gaps
- "Agent-driven epic" (working agreement, sprint pause) is still undefined; "automatic" vs "usage-split" epic is contradictory across `AGENTS.md`, `sprint-retrospective` and Takahashi's file (see the report).
- `usage.md` has two rates (3.9 per story point, 2.7 per 100k tokens) and Sprint 012 a third (about 2.1 per point); "most recent wins" does not say whether a calibration note counts.
- No rule says whether the next sprint (held by a pause) is planned before the pause.

## Actions
- Suzuki: define "agent-driven epic"; Takahashi: tell agents not to use git stash or checkout.
- Executive: the visual check in the review; the real usage reading.
- Backlog candidates: first-stamp race (change inside the first 2 s is missed); duplicated status-choice logic in the column and the block; `blockWidth` literal.
