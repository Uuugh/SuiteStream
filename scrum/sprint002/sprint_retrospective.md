# Sprint Retrospective Record - Sprint 002

Draft by the facilitator from the sprint's record. Product Owner to add their own observations.

## Basic Information
| Item | Value |
|---|---|
| Date | 2026-11-21 |
| Participants | PO: Product Owner / SM and Developers: one Claude session (no separate agents) |

## Keep
- Product Owner reviewing the running site as it was built: three useful corrections (dropdown icon alignment, year list, a date picker that picks a day) and one scope cut (the Calendars and Key legend).
- Writing tests named by requirement ID; claiming only the rows a test fully proves and leaving the rest `backlog`.

## Problem
- Three of the Product Owner's corrections were about things the requirements already implied (UIC-09 says the picker is a small month calendar). The sprint built to the rows' literal text and missed it.
- The legend was built from rows that depend on features that do not exist (rules, Print) and was then removed; cheaper to have asked first.
- Usage readings are only given after the fact, so the before-reading for each sprint is unknown.
- Still one session playing every role; no independent review.

## Try
- Before building a control the rows describe loosely, read the shared UI rows it links to (UIC-xx) and say what the plan is.
- When a row depends on an unbuilt feature, flag it at planning and leave it out of the sprint.
- Ask for a usage reading at the start of each sprint.

## Improvement Actions
| # | Action | Owner | Due date | Status |
|---|---|---|---|---|
| 1 | Check linked shared rows (UIC, THM) when planning each PBI | Facilitator | Sprint 003 planning | Not Started |
| 2 | Record a usage before-reading at sprint start | Product Owner | Sprint 003 start | Not Started |
| 3 | Remove the header's 40 px right padding when the header right zone is built | Developer | Sprint 003 | Not Started |
