# Sprint 001 Review (2026-11-21)

Goal: A runnable Flutter app renders a themed Month and Week calendar with events stored in UTC and shown in the Local time zone.

## Definition of Done check
| Criterion | Result |
|---|---|
| Items map to agreed acceptance criteria | Yes: 34 requirement rows, each with a test named by its ID |
| Pass/fail verification | Yes: `flutter test` (43 tests pass), `dart run tool/req_coverage.dart` |
| Code quality | `flutter analyze` clean; Dart and Flutter only |
| Runtime behavior | Builds for web (`flutter build web`); the Product Owner viewed it at localhost:8080 and gave feedback (dropdown icon alignment, year picker), both fixed and approved |
| Security and privacy | No network access, secrets or personal data in this sprint's code |
| Documentation | README has run and test steps; known limits below |

## Known limitations
- Events are held in memory (no database): TIM-01 is verified on the stored JSON form.
- CAL-01.b: Month and Week only; 5-day, Day and List are not built.
- English month and weekday names only; the week starts on Sunday.
- Windows desktop is not available on this machine; Android was not built or run.
- The view dropdown has 40 px of right padding in the header so its menu stays on screen; remove it when the other header controls exist.
- Only tests and a web build back the visual result; no screenshot or accessibility review.

## For acceptance
The 34 `planned` rows (TIM-01 to TIM-08, TIM-10, THM-01.a-d, THM-02.a-m, UIC-12, UIC-13, CAL-01.a-d, h, i) become `done` when the Product Owner accepts them.
