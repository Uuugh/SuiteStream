# Sprint 007 Daily Scrum

## Sprint goal
The Product Owner can set up the calendar the way they want it to look and behave: the agreed Google color palette, Settings Calendar and Theme panes with Light / Dark / Match system and a setting for every common UI element, one popup shadow and one 34 px control height everywhere, and test calendars that can be added and removed from Settings > Admin.

## Day 1 (2026-11-23)
- Planning written, awaiting Product Owner approval and Kobayashi review. Commitment 22 points; see `sprint_planning.md` and `sprint_backlog.md`.
- Developers not started yet on Day 1 (planning only).

| Developer | Since last scrum | Next | Blockers |
|---|---|---|---|
| Ito | | | |
| Tanaka | | | |
| Yamamoto | | | |
| Nakamura | | | |

### Impediments
- IMP-002 stays open until the Product Owner verifies Sprint 007 in the browser.
- Usage readings missing (planning risk 1).

## Days 2 to 5 (as worked)

## Sprint 007 wave 1 status (Tanaka, round 2)
Delivered in wave 1: shared color picker and the two palettes (Ito); Settings Calendar, Theme and Admin panes, theme mode controller (Light / Dark / Match system), test calendars add and remove (Nakamura, Yamamoto); popup shadow through `showSuiteDialog` and `popupElevationOf`, 34 px control height, tokens and shared icons (Tanaka). Requirement rows UIC-10, UIC-10.a, UIC-20, THM-04.b and THM-01.e are `planned` with test citations.

Left: opened event in the hourly grid with shadow (CAL-10.d, change written in `handoffs.md`); hour-density menu shadow scaling; 10 overflow failures in `test/events/event_dialog_layout_test.dart`; SHL-03.a browser check and Product Owner visual checks; usage readings (planning risk 1).

### Day 2
- Ito: shared color picker and the two palettes (UIC-10, UIC-20); event and calendar colors. Nakamura: theme mode controller (SHL-03), Settings > Admin test calendars (SET-14). Yamamoto: Settings Calendar and Theme panes. Tanaka: popup shadow through `showSuiteDialog` and `popupElevationOf`, 34 px control height, shared icons and swatch tokens.
- Impediment: 10 overflow failures in `test/events/event_dialog_layout_test.dart`.

### Day 3
- Ito: default start time (EVT-01.m), default event color, stale tests updated for the Calendar and Theme panes. Tanaka: theme settings wired (animation time, popup shadow, resize bar, dropdown text, date picker, status chip time). Rows stay `planned` until the Product Owner checks them.

### Day 4
- Web build passes with the theme-mode glyph subset; PBI-049 dashboard (ScrumBoard) added. Layout failures in `event_dialog_layout_test.dart` resolved: the file passes (Kobayashi re-ran it; 259 tests pass, analyze clean).

### Day 5
- Kobayashi's independent review read. Round 3 fixes: new tokens for the remaining literal sizes (named in `handoffs.md`), narrowed wording and status for SET-03.k, UIC-44, SET-03.j, UIC-43 and THM-10.d, DEF-01 reconciled (Status chip time row, percent animation duration row removed), this file and `sprint_review.md` written. Ito and Nakamura clear their literals, arb fallbacks and SET-10 names in parallel.
- Impediment closed: the event dialog overflow failures. IMP-002 stays open until the Product Owner verifies in the browser.
