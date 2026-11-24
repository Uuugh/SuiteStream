# Request 004 — Sprint 015

Written by Sato (customer) without the Executive, by `.github/skills/order-create-without-user/SKILL.md`: points the Executive did not settle are decided below as the Executive would likely decide them, and marked "assumed".

## Requested outcome

Continue the ScrumBoard epic (PBI-049) with Sprint 015. The Executive set a sprint pause at 015 (`scrum/order/order003.md`, "Executive pause") and released it with "run sprint 15" on 2026-11-24. The epic stays agent-driven with no sprint limit: sprints after 015 run on their own unless the Executive sets a new pause.

Business goal (unchanged from order003): the process runs on its own and the Executive only tweaks priorities; the ScrumBoard is how the Executive follows and steers the sprints.

## Usage at the start

Before-reading (Executive): session 3 % (resets 5:40 PM), week 59 %. `usage.sh project "Sonnet 5.5" 10 3 59` gave about 30 % session and about 63 % week after 10 points; no level crossed. Planning fits the scope with `project` as `scrum/usage/README.md` ("When") says; about 10 points fit.

## What the Executive asked for since Sprint 014 (candidates, in this order of value)

1. The Executive's own feedback on the board, newest first in value because it is what they asked for after looking:
   - PBI-123: zoom control as a boxed font size between minus and plus (build with or after PBI-113).
   - PBI-124: show the ID only, the name in a tooltip (depends on PBI-108, verification 1 open).
   - PBI-125: the Questions column becomes Questions and Verifications. Not refined yet.
2. The Questions column, built once and right: assumed, PBI-086 and PBI-125 are refined together so the column is built with verifications from the start, not built for questions only and then rewritten. If they do not fit together, PBI-086 waits for PBI-125's refinement rather than going first.
3. Sprint 014 review follow-ups (small, Ready): PBI-113 then PBI-118 (theme tokens and the literal test), PBI-116 (visible effect of the backlog choice; depends on PBI-108), PBI-114 (README), PBI-115 (usage.sh trend), PBI-110, PBI-111, PBI-112 (usage script runner and bash lookup).
4. The remaining epic slices: PBI-085, PBI-087, PBI-088, PBI-083, PBI-084 (with PBI-117 after it).
5. Issues stay last: PBI-094 then PBI-082, not Ready until PBI-063 is verified.

## Clean-up the team must do in refinement

- Refine PBI-125 (size is a first guess) and decide how it and PBI-086 are built (point 2 above).
- PBI-049's description still says the Executive approves each sprint of the epic and that it is not agent-driven; order003 and the working agreement say it is agent-driven. Bring the PBI text in line.
- Open verifications 1 to 7 (`scrum/verifications.md`) wait for the Executive. Items that build on them (PBI-124 and PBI-116 on PBI-108; PBI-084 on PBI-106) name that dependency in the plan, as order003 required for In Review items.
- Velocity (Sprint 014 retrospective decided action, question 3): the question was removed from `scrum/questions.md` with no answer written. Assumed: keep counting built and tested points as completed (the recommended choice and current practice) until the Executive says otherwise; Takahashi records it before the Sprint 015 review.

## How the sprint runs (Sprint 014 retrospective actions)

- Separate role agents in planning and every development day; Kobayashi reviews each wave before its PBIs go In Review (IMP-003 stays Open until done).
- Planning names the doc file and platform check for each changed option, route or setting (PBI-119); developers write the test command and the count in `daily_scrum.md` (PBI-120).

## Acceptance for every Sprint 015 item (from the customer's side)

- The board shows what the files say, without an agent pressing anything.
- Every label is an arb key in the six languages; theme colors and tokens only; no clipping at the DEF-01 window sizes; checked in light and dark.
- Each requirement row built is set to its status with a named test in the same sprint.
- Each item that reaches In Review gets one verification in `scrum/verifications.md`; anything that changes a real file (`scrum/questions.md`, `scrum/verifications.md`, the sprint file) has a test row on a copy.

## Out of scope

- Calendar work (PBI-089, PBI-100 and the others) waits until the epic ends, unless the Executive changes priorities.
- PBI-073 and PBI-074 run after the epic.

## Refinement record (2026-11-24, Sprint 015)

- Point 2 incorporated: PBI-086 (read side: heading, list of both files, generic filter bar, badge; 5 points) and PBI-125 (writes: Answered, Accepted, Returned; 3 points, after PBI-086) are refined together and Ready; sizes by Ito and Tanaka. Open: question 1 (`scrum/questions.md`) on the new mark; PBI-086 assumes choice a.
- PBI-049 text now states it is agent-driven; size 81 (sum of the stories that name it); PBI-123 to PBI-125 now name it.
- Dependencies on items waiting for verification named: PBI-124 and PBI-116 on PBI-108 (verification 1), PBI-084 on PBI-106 (verification 4), PBI-086 on PBI-092 (new verification 8).
- Found: 36 In Review PBIs have no verification although `scrum/verifications.md` requires one; added PBI-126 (Ready, 2 points).
- Velocity assumption (counting built and tested points): Takahashi records it in `scrum/sprints/sprint015` before the Sprint 015 review.
- Audit (Kobayashi) findings added as PBI-127 (working agreement start rule wording) and PBI-128 (done backlog rows with commas).
