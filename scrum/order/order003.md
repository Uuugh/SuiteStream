# Request 003 — Sprint 014

## Requested outcome

Continue the ScrumBoard epic (PBI-049) with Sprint 014. The Executive put the epic on a sprint pause at 014 ("start 012. pause at 014", Sprint 013 planning) and released it with "Run Sprint 14" on 2026-11-24. The epic stays agent-driven with no sprint limit: sprints after 014 run on their own unless the Executive sets a new pause.

Business goal (Executive, Sprint 013 planning): the process runs on its own and the Executive only tweaks priorities. The ScrumBoard is how the Executive follows and steers the sprints without the assistant.

## What the Executive asked for since Sprint 013 (candidates, in this order of value)

1. Fixes to what Sprint 013 built, from the Executive's own look at the board:
   - PBI-102: one zoom icon instead of two (the minus and plus halves are an assumption).
   - PBI-103: the status token right-aligned at the end of the row, as in `scrum/deliverables/scrumboard_mockup.png` (sub-requirement rows too is an assumption).
   - PBI-104: the board keeps the theme and the zoom step across restarts and reloads; filters and the outline state are not kept. Where it is stored is the team's choice, as long as the file holds no secret.
2. Usage on the board through the script: PBI-106 (the server runs `scrum/usage/usage.sh` for the estimate and the trend, read only, with fixed arguments). It changes PBI-084: SCB-14.l is dropped and readings are entered with `usage.sh`. Build PBI-106 before or with PBI-084, not after.
3. The remaining epic slices: PBI-085 (agent bars, block usage), PBI-086 (Questions column), PBI-087 (sprint lifecycle buttons), PBI-088 (pointer actions, older sprints), PBI-083 (add popup), PBI-084 (usage chart).
4. Issues: PBI-094 (issue database and API) comes before PBI-082 (Issues column). PBI-094 needs the Postgres store of PBI-063, which is still In Review and not verified, so the Issues slices are the last ones in the epic.

## Clean-up the team must do in refinement

- PBI-093 is overtaken: PBI-097 removed the footer and Sprint 013 built the bin in the header. Refinement decides whether anything of PBI-093 is left (retiring an issue needs PBI-094) or whether it is closed.
- The Sprint 013 retrospective left backlog candidates: the first-stamp race (a change in the first 2 s is missed), duplicated status-choice logic in the column and the block, and the `blockWidth` literal. They belong in the backlog before planning.
- The Sprint 011 to 013 items (PBI-077 to PBI-081, PBI-090, PBI-092, PBI-097 to PBI-099, PBI-101) are In Review. The Executive's visual checks are listed in `scrum/sprints/sprint013/sprint_review.md`; nothing in Sprint 014 may depend on an item the Executive later rejects without saying so in the plan.

## Acceptance for every Sprint 014 item (from the customer's side)

- The board shows what the files say, without an agent pressing anything (PBI-098 stands).
- Every label is an arb key in the six languages; theme colors only; no clipping at the DEF-01 window sizes; checked in light and dark.
- Each requirement row built is set to its status with a named test in the same sprint (Sprint 013 retrospective).
- The review lists the visual checks the Executive must do, with a test row for anything that changes a real file.

## Out of scope

- Calendar work (PBI-089, PBI-100 and the others) waits until the epic ends, unless the Executive changes priorities.
- PBI-073 and PBI-074 run after the epic, as their rows say.

## Refinement outcome (Sprint 014)

- The Sprint 013 retrospective candidates are in the backlog: PBI-107 (first-stamp race), PBI-108 (one status choice helper), PBI-109 (block width token).
- PBI-093 is Superseded: the footer and Reload are gone (PBI-097, PBI-099) and the header bin is built; what is left (retiring an issue, SCB-19.b and SCB-19.d) moved to PBI-082.
- PBI-084 no longer cites SCB-14.l and is built after or with PBI-106. PBI-104 is stored by the page in the browser.
- Ready, in order of value: PBI-107, PBI-102, PBI-103 with PBI-108, PBI-109, PBI-104, PBI-106, PBI-085, PBI-086, PBI-087, PBI-088, PBI-083, PBI-084. Not Ready: PBI-094 then PBI-082 (need PBI-063 verified).
- Every Ready item that builds on Sprint 011 to 013 work names the In Review item it depends on.
