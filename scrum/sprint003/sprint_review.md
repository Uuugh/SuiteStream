# Sprint 003 Review (2026-11-21)

Goal: A user can open an event and add, edit and remove their own events, which are kept on the device, and can look at the calendar in another time zone and clock format.

Result: about 22 of the 47 planned points were built. The goal is met for the event dialog, the store and the header controls; the theme, shared UI and calendar height work was not started.

## Rows ready for acceptance (43, status `planned`)
- Events: EVT-01.a, b, e, l, m, p, q; EVT-02.a, b, d, e, f, g, i, l; EVT-03.a, b, d, e, i, k, l; EVT-07.a, b, h, k
- Header: CAL-02.a, CAL-06.e
- Moving events: CAL-03.a, b, c, d
- Shared: CAP-02, UIC-06, THM-09, THM-09.a, THM-09.b
- Added after the Product Owner's review: EVT-02.n, SET-08 (new rows), EVT-06.a, CAL-01.p (reworded)

## Not claimed (partly built or needs features that do not exist yet)
- CAL-02 stays `backlog` until its other rows; CAL-06.a, b, c, d: the right zone has Time Zone, View and the clock, but Print, Full page and + do not exist.
- EVT-01.d, f, g, i, j, k, n, o, r; EVT-02.c, h, j, k, m; EVT-03.c, f, g, h, j, m; EVT-07.c to g, i, j: they need History, sources, rules, links, templates or the info popover.
- SET-02.a: there is no Settings screen yet.
- UIC-19, UIC-39 are used by the dialog but not fully built (no stored-choice clearing for the zone picker, no unknown-zone message).

## Definition of Done check
| Criterion | Result |
|---|---|
| Items map to agreed acceptance criteria | Yes, rows above |
| Pass/fail verification | `flutter test`: 138 pass; `dart run tool/req_coverage.dart` |
| Code quality | `flutter analyze` clean; Dart and Flutter only |
| Runtime behavior | Builds for the web and runs at localhost:8080; the Product Owner reviewed the event dialog and requested a readable short end-zone label and horizontally aligned time fields, which were fixed and covered by targeted tests |
| Security and privacy | Events and settings are kept only on the device; no network access except opening a map or meeting link on a click |
| Documentation | README unchanged and still correct |

## Known limitations
- Undo of a deletion works in the controller (CAP-02); the Undo button comes with History / the log (Product Owner).
- Opening a map or meeting link uses `url_launcher` and has not been tried by hand.
- A dragged event shows a lifted copy and the landing spot; the move itself happens on release.
- The header keeps 40 px of right padding while its controls fit on one line.
- Events from sources (sync) do not exist yet, so the "event of a source" paths are tested with events marked as not custom.
