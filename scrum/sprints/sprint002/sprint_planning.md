# Sprint 002 Planning (2026-11-21)

Duration: up to 5 days; sprint 001 finished 26 points in one day. Roles are played by one Claude session (no agent files, no independent review).

## Why (Sprint Goal)
All five calendar views work, with messages read from the message files and the Calendar filter limiting what is shown.

## Constraint
All code is Dart with Flutter (order001). Tests are Dart tests named by requirement ID.

## What
PBI-007, PBI-008, PBI-012 (15 points), all rows are `backlog` (agreed).
- PBI-007 Remaining views: CAL-01.b (5-day, Day, List), CAL-01.e, f, g, j, k, l, m, o, p, q, s; CAL-06.c (icons for all views).
- PBI-008 Calendar filter: FLT-01 and FLT-01.a to FLT-01.m (uses the shared dropdown, UIC-12).
- PBI-012 Message keys: load `requirements/messages/app_*.arb`, English fallback; the header, view and picker texts move to keys (CAL-01.n, CAL-01.r, CAL-06.c tooltips).

Deferred (sprint 003 candidates): PBI-009 theme components, PBI-010 shared UI, PBI-011 drag and resize, CAL-06.a/b/d/e header right zone (needs Time Zone, 12/24, Print, Full page, + controls).

## How
Tasks are in [sprint_backlog.md](sprint_backlog.md).

## Gate
Weekly usage was 90% on 2026-11-21 (above the 85% warning level in [../usage.md](../usage.md)). Planning is recorded; execution waits for the Product Owner to confirm the sprint start.

## Open items
- Confirm availability and developer owners (still unassigned).
- No independent review of this plan.
