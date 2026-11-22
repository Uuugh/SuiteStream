# Sprint 003 Daily Scrum

## Day 1 (2026-11-21)
- Started at the Product Owner's "go" with weekly usage at 92% (above the 85% warning level).
- Done: local event store (kept on the device, deletions can be undone in the controller); event dialog to add, edit and remove events (title, calendar, all-day, start and end with time zones, place, color, reminders, meeting address, notes); typed-time reading; click a day to add, click an event for its details; header Time Zone picker and 12h/24h control (kept on the device); long-press-drag to move events in Month, Week and Day.
- Tests: 125 pass, `flutter analyze` clean; 37 requirement rows `planned` with tests.
- Not built: theme components THM-03 to THM-08, shared UI components (UIC-14 to UIC-17, UIC-27 to UIC-37), the calendar resize bar and Full page (CAL-04), and the Settings Time Zones item (SET-02.a). Those PBIs go back to the backlog.
- Impediments: the requirements conflict on an empty time (EVT-01.c says leaving a time out blocks saving; EVT-02.h says an empty time means 0:00). The dialog follows EVT-02.h. The Product Owner should decide.

## Later (2026-11-21 and 22), Product Owner review changes
- Event details now open in a popup instead of a footer panel, so the calendar is not resized (EVT-07 reworded).
- Add/Edit event dialog rebuilt to the Product Owner's screenshot: labels over the fields, two columns with Notes as tall as the fields, a color button that opens the palette, a joined Cancel | Save pair (130 × 34) shared with the No | Yes question (UIC-27).
- Date picker: month and year now go back down to the days of a month.
- Click to add an event works in every view (day in Month, empty spot in Week/5-day/Day with the start time at the click, all-day cell, List day title, and a + button); a copy (Duplicate) icon sits next to the Calendar name in the dialog and in the event tools (EVT-06.a).
- Empty start time uses now, empty end time uses the default event length; the default length is a user setting (new Settings dialog from the app bar, SET-08). This settled the EVT-01.c / EVT-02.h conflict.
- Dragging an event now shows a lifted copy that follows the pointer, dims the original and shows the landing day or time.
- Dropdowns no longer resize when items are chosen or cleared (UIC-12).
- Product Owner: Undo will come with History / the log, so there is no Undo button until then.
- Tests: 138 pass; 43 requirement rows `planned`.
