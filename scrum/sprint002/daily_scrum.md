# Sprint 002 Daily Scrum

## Day 1 (2026-11-21)
- Done: all 10 tasks. Messages from `requirements/messages/*.arb` with English fallback (11 new keys added to all six languages); Day, 5-day and List views; header (Today, steps by view, localized titles, month picker with year list); phone-width List default; "+n more" in day cells; touch swipe; Calendar filter (dropdown with Select all/none, saved choices).
- Tests: 75 pass, `flutter analyze` clean; 22 requirement rows `planned` with tests.
- Impediments: none. Weekly usage was 90% at the start (above the 85% warning level); the Product Owner told us to go.

## Later (2026-11-21)
- Product Owner: the filter is good; remove the Calendars and Key legend under the calendar. Removed FLT-01.f, g, h and j from the requirements, the legend from the app, its tests, 3 message keys and the "Calendar key name length" default. 72 tests pass.
- Product Owner: the date picker only went down to the month. It is now a small month calendar (UIC-09) where a day can be picked; the title opens the month list and the year list. New row CAL-01.t. 75 tests pass.
