# Sprint 003 Planning (2026-11-21)

Duration: up to 5 days. Sprint 001 finished 26 points and sprint 002 finished 15 in one day each; this sprint is about three times sprint 002. Roles are played by one Claude session (no agent files, no independent review).

## Why (Sprint Goal)
A user can open an event and add, edit and remove their own events, which are kept on the device, and can look at the calendar in another time zone and clock format.

## Constraint
All code is Dart with Flutter (order001). Tests are Dart tests named by requirement ID.

## What
PBI-013, PBI-014, PBI-015, PBI-009, PBI-010, PBI-011 (47 points, all `backlog` rows).
- PBI-013 Event dialog (13): EVT-01 to EVT-03, EVT-07 and their sub-rows: add, edit, remove, start/end with time zones, place, color, reminders, online meeting address; clicking an event opens its details.
- PBI-014 Local event store (5): events kept across restarts in UTC with their zones (TIM-01); a removed custom event can be undone (CAP-02).
- PBI-015 Header time zone and clock controls (8): CAL-02, CAL-06.a, b, c, d, e, SET-02.a; removes the temporary 40 px header padding.
- PBI-009 Theme components (8): THM-03 to THM-09.
- PBI-010 Shared UI components (8): UIC-14 to UIC-17, UIC-27 to UIC-37 (save/cancel pairs, resize bar and the rest).
- PBI-011 Drag and resize (5): CAL-03.a-d, CAL-04.b-f.

## Risks
- This is the first sprint above one day's work in one session, and the event dialog (EVT) has many sub-rows with messages that need keys in six languages.
- Check linked shared rows (UIC, THM) before building each control (retrospective action 1).
- Rows that need Print, Full page or rules are left out.

## Gate
Weekly usage was 92% on 2026-11-21 (above the 85% warning level in [../usage.md](../usage.md)). Estimated cost: sprint 002 used about 11 points of the 5-hour window for 15 points, so this sprint would use roughly 30 to 40 points, enough to push the week close to 100%. Execution waits for the Product Owner to confirm the start.
