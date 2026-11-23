# Usage

The Product Owner's readings of the 5-hour session % and the 7-day weekly % (`/usage` or the status line), taken at the
start and end of each sprint.

Estimate = what was said before the work. Before and after = the readings (session % / weekly %). Actual = after minus
before; a window reset in between makes the session actual unknown (`?`). A dash = never recorded.

## Levels

The same for the 5-hour and the 7-day readings. A job is a sprint or any other task; project its after-reading before starting it.

The readings file is `C:\Users\rfrie\.claude\usage-now.json` (fields `five_hour_used`, `seven_day_used`, `context_used`, `written_at`). It is stale after 10 minutes (the Product Owner confirms the number). When its values are `null`, ask the Product Owner for the reading.

| Level | Reading | Action |
|---|---|---|
| Caution | 70% | Notify the Product Owner before starting a job projected to end at or above it, and continue; tell running agents to commit |
| Warning | 85% | Ask the Product Owner's permission, and wait, before starting a job projected to end at or above it; stop a running agent when a reading reaches it without permission |

| Sprint | Story or round | Date | Model | Estimate session % | Before s / w | After s / w | Actual session % | Notes |
|---|---|---|---|---|---|---|---|---|
| sprint001 | planning, then T01 to T12 (build and tests) | 2026-11-21 | Sonnet 5.5 | – | – / – | 9 / 90 | ? | Only an after-reading was supplied (session 9%, resets 3:40 AM; weekly 90%, resets Wed Nov 25 5:00 PM); the 5-hour window had reset, so the session actual is unknown |
| sprint002 | T01 to T10 (messages, five views, header, date picker, Calendar filter) | 2026-11-21 | Sonnet 5.5 | – | 9 / 90 | 20 / 92 | 11 | Before-reading is the sprint 001 after-reading (9 / 90); after-reading 20 / 92 supplied by the Product Owner; the week rose 2 points. Includes the Product Owner's three review changes and the legend removal |

| sprint003 | T01 to T14 and the Product Owner's review changes (event dialog, store, header, drag, popups, settings) | 2026-11-21 to 22 | Sonnet 5.5 | 30–40 (est.) | 20 / 92 | 66 / 98 | 46 | Before-reading is the sprint 002 after-reading; after-reading supplied by the Product Owner on 2026-11-22. The week rose 6 points and is above the 85% Warning level: no new job should start until the weekly reset (Wed Nov 25, 5:00 PM) |

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
