# Usage

The Executive's readings of the 5-hour session % and the 7-day weekly % (`/usage` or the status line), taken at the
start and end of each sprint.

Estimate = what was said before the work. Before and after = the readings (session % / weekly %). Actual = after minus
before; a window reset in between makes the session actual unknown (`?`). A dash = never recorded.

## Levels

The same for the 5-hour and the 7-day readings. A job is a sprint or any other task; project its after-reading before starting it.

The readings file is `C:\Users\rfrie\.claude\usage-now.json` (fields `five_hour_used`, `seven_day_used`, `context_used`, `written_at`). It is stale after 10 minutes (the Executive (XO) confirms the number). When its values are `null`, ask the Executive (XO) for the reading.

| Level | Reading | Action |
|---|---|---|
| Caution | 70% | Notify the Executive (XO) before starting a job projected to end at or above it, and continue; tell running agents to commit |
| Warning | 85% | Do not start a job projected to end at or above it. When running an epic automatically, decide without asking (split smaller, or wait for the reset time if nothing fits); otherwise ask the Executive's permission and wait; stop a running agent when a reading reaches it without permission |

| Sprint | Story or round | Date | Model | Estimate session % | Before s / w | After s / w | Actual session % | Notes |
|---|---|---|---|---|---|---|---|---|
| sprint001 | planning, then T01 to T12 (build and tests) | 2026-11-21 | Sonnet 5.5 | – | – / – | 9 / 90 | ? | Only an after-reading was supplied (session 9%, resets 3:40 AM; weekly 90%, resets Wed Nov 25 5:00 PM); the 5-hour window had reset, so the session actual is unknown |
| sprint002 | T01 to T10 (messages, five views, header, date picker, Calendar filter) | 2026-11-21 | Sonnet 5.5 | – | 9 / 90 | 20 / 92 | 11 | Before-reading is the sprint 001 after-reading (9 / 90); after-reading 20 / 92 supplied by the Executive (XO); the week rose 2 points. Includes the Executive's three review changes and the legend removal |

| sprint003 | T01 to T14 and the Executive's review changes (event dialog, store, header, drag, popups, settings) | 2026-11-21 to 22 | Sonnet 5.5 | 30–40 (est.) | 20 / 92 | 66 / 98 | 46 | Before-reading is the sprint 002 after-reading; after-reading supplied by the Executive (XO) on 2026-11-22. The week rose 6 points and is above the 85% Warning level: no new job should start until the weekly reset (Wed Nov 25, 5:00 PM) |
| sprint010 | Stack, sync, fixes and reviews (agent run), round 2 and quick fixes, ScrumBoard requirements and mockups | 2026-11-23 | Sonnet 5.5 | – | 18 / 20 | 16 / 29 | ? | Readings along the way: 58 / 25 and 69 / 26 (still the first window). The after-reading is in the next window (reset 4:50 PM, next 10:50 PM), so the session actual is unknown; the week rose 9 points |
| sprint011 | ScrumBoard slice 1 (PBI-077 to PBI-080) | 2026-11-23 | Sonnet 5.5 | 11 | 27 / 30 | ~45 / ~33 (orchestrator estimate, not a reading) | ~18 (est.) | After-reading is an orchestrator estimate; the Executive's real reading replaces it. |
| sprint011 | ScrumBoard first slice (PBI-077 to 080, 8 points) run by a sub-agent as orchestrator, 13 agent runs, about 1.2M agent tokens | 2026-11-23 | Sonnet 5.5 | 11 (plan) | 27 / 30 | 58 / 34 | 31 | Executive reading after the sprint; the orchestrator's own estimate was 45 / 33, so it ran about 13 session points low; about 3.9 session points per story point, far above the 1.1 of earlier sprints (a first sprint on a new project with a server and many reviews) |

## ChatGPT

| Date | Context | 5-hour limit remaining | 5-hour reset in | Weekly limit remaining | Weekly reset in |
|---|---|---:|---|---:|---|
| 2026-11-22 | Sprint 005 planning, awaiting approval | 85% | 3h 33m | 98% | 6d 22h |

## Copilot Fusion

These product usage readings are tracked separately from Claude's session and weekly percentages; they are not added
together.

| Date | Model | Inline suggestions used | Included credits used |
|---|---|---:|---:|
| 2026-11-22 | Copilot Fusion | 27% | 96% |

## Baseline

None yet. The retired CalendarStream repository (https://github.com/Uuugh/CalendarStream, `scrum/usage.md`) holds an earlier usage baseline only: about 1.3 session % per changed file for a code story (plus or minus 30%), later measured at 0.35 per file in one sprint. Different task type and models; use it only until this project has three finished sprints of its own.

## Status values

Statuses used in `product_backlog.csv` and `product_backlog_done.csv`:

| Status | Meaning |
|---|---|
| Backlog | Not started and not committed to a sprint. May still need refinement. |
| Ready | Refined (clear acceptance criteria, estimated, no open blocker) and small enough to be pulled into a sprint. |
| In Sprint | Committed to the current sprint and being built. |
| In Review | Built and tested by the team, but not yet accepted: waiting for the Executive (XO) to verify it (for example in the browser). Counts as completed only after acceptance. |
| Done | Accepted by the Executive (XO) and meets the Definition of Done. Moves to `product_backlog_done.csv`. |
| Superseded | Replaced by another PBI or requirement; kept for history, not to be built. |
| Blocked | Cannot proceed because of an open impediment (see `impediment_log.csv`) or a missing decision; say what blocks it in the PBI. |

PBI-011, PBI-013, PBI-014 and PBI-018 stay In Review; they are the Sprint 006 stretch PBI-032 (review closure).

## Monitoring without the Executive (XO) (added 2026-11-23)

The orchestrator checks `usage-now.json` first. When it is stale or null (the VS Code extension does not run the status line, so only a terminal session refreshes it), the orchestrator estimates usage itself, without asking:

- Anchor: the Executive's last pasted reading and the time it was given.
- Add: the token counts that each finished agent reports, at the rate calibrated in Sprint 007 (about 28 session points for about 690k agent tokens, so roughly 4 points per 100k tokens in Sprint 007, but only about 2.7 per 100k in Sprints 009 and 011 (about 16 points for 590k tokens and 31 points for 1.2M tokens, against the Executive's readings); use 2.7 for the next estimate and replace it with the next measured value, plus the orchestrator's own turns).
- Apply the Caution (70%) and Warning (85%) actions to the estimate. Say the number is an estimate, and take any new reading the Executive (XO) gives as the new anchor.
- The session window resets at the time in the reading; weekly usage does not reset until its reset time, so check the weekly estimate too.

## Cost per story point (calibrated 2026-11-23; use it instead of asking)

Measured over Sprints 006 and 007 (planning, three waves of four developers, Kobayashi's review, rounds of fixes):

- **About 1 session point per story point.** Sprint 007 delivered 22 points and the session went from about 44% to about 65%, plus planning and review.
- **About 4 session points per 100,000 agent tokens** (agents report their token use when they finish). Wave 1 of Sprint 007 cost 28 points for about 690,000 tokens; later, smaller waves cost less. Add about 3 session points per sprint for the orchestrator (planning, review, merge).
- So **5% of the session buys about 4 story points**, and a whole 8-point slice costs about 8 + 3 = 11%.
- Weekly usage moves about one tenth as fast (Sprint 007 moved it about 7 points). Check it too.

### Decision procedure (never wait for the window to reset when a slice fits)

1. Anchor: the Executive's last pasted reading and the time of it. Add the cost of everything since (agent tokens, or points at the rate above). The result is the estimate now; say it is an estimate.
2. Slice cost = story points + 3. If estimate now + slice cost stays below **85%** (Warning), start it now. At or above **70%** (Caution) send the Executive (XO) one short line and continue.
3. If it does not fit, split the story (Epics in the `backlog-refinement` skill) and start the largest slice that fits now; the other slices are the epic's next sprints and start as soon as they fit. Complete each sprint automatically (see Takahashi's role, "Running sprints and epics automatically").
4. Only when not even the smallest useful slice fits below 85%, wait for the reset time in the reading, then continue. Never stop a running agent for usage unless a real reading reaches 85%.
5. Take any new reading the Executive (XO) pastes as the new anchor and note how far the estimate was off.

If `usage-now.json` is null or stale (the VS Code extension does not refresh it), do not ask: estimate as above from the Executive's last pasted reading. Ask only if there has never been a reading.

| sprint008-009 | Usage epic slices 1 and 2 (Sprint 009 run by an orchestrator sub-agent) | 2026-11-23 | Sonnet 5.5 | 16–20 (est.) | 0 (after reset) / ? | ? | est. 25 | Sprint 009 agents reported about 590k tokens in total (waves 1 and 2); at 4 points per 100k that is about 24 session points. No real reading taken; the coordinator reported 94% before the 11:50 reset and 0% after. |

## Measured rate (Sprint 009, Executive (XO) readings)

Sprint 009 (14 story points, parallel agents, about 20 minutes of work from 11:45) took the session from 91% to the reset at 11:50 and on to 7% afterwards: about 16 points, or **about 0.8% per minute of active sprint time** and about 1.1 session points per story point. Sprints 007 and 008 gave 0.4 to 0.7% per minute. Use **0.5% per minute** as the rule when the Executive (XO) says so, and 0.8% per minute when several agents run in parallel. Idle time costs nothing; measure from the commit times.
