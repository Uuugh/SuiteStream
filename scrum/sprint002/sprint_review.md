# Sprint 002 Review (2026-11-21)

Goal: All five calendar views work, with messages read from the message files and the Calendar filter limiting what is shown.

## Rows ready for acceptance (23, status `planned`)
- CAL-01.e, f, g, j, k, l, m, n, o, p, q, r, s, t (t is new: the date picker picks a day; added at the Product Owner's request)
- FLT-01.a, b, e, i, k, l, m
- UIC-21 (shared filter), SHL-02.f (values escaped in messages)

## Not claimed (they need features that do not exist yet)
- FLT-01.c (kept when leaving Full page: no Full page) and FLT-01.d (Print is not built). FLT-01.f, g, h and j (the Calendars and Key legend under the calendar) were removed from the requirements by the Product Owner. FLT-01 and CAL-01 parents stay `backlog` until their sub-rows are done.
- CAL-06.c: only the view picker part is built (icons, tooltip, accessible name); the 12h|24h, Time Zone and wrapping parts are not. The row stays `backlog`.
- SHL-02.a and SHL-02.b: messages and fallback work, but no language chooser or automatic browser/device language per the rows beyond the app start.

## Definition of Done check
| Criterion | Result |
|---|---|
| Items map to agreed acceptance criteria | Yes, rows above |
| Pass/fail verification | `flutter test`: 75 pass; `dart run tool/req_coverage.dart` |
| Code quality | `flutter analyze` clean; Dart and Flutter only |
| Runtime behavior | Builds and runs on the web server at localhost:8080; not yet viewed by the Product Owner |
| Security and privacy | No network access; filter choices stored on the device only |
| Documentation | README unchanged and still correct; limits below |

## Known limitations
- Calendars and events are demo data in `main.dart`; there is no database or source yet.
- The view dropdown keeps 40 px of header padding so its menu stays on screen.
- Month and weekday names come from `intl`; other texts from the message files; only English, Spanish, French, German, Portuguese and Dutch exist.
- No screenshot or accessibility review.
