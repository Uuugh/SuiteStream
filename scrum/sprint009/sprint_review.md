# Sprint 009 Review (2026-11-23)

Second and last slice (14 points) of the Sprint 008-009 usage epic. Completed automatically; the Product Owner reviews after the epic.

| PBI | Result | Status |
|---|---|---|
| PBI-053 Reset buttons and header fit | Shared `ResetButton` (theme error role, 34 px) in `lib/src/ui/reset_button.dart`, used in the Theme pane; rows UIC-46 and UIC-14.c; header minimum widths reduced; tests at 320, 360, 400, 700 px. ZonedRow still scrolls a control zone below about 320 px instead of ending with a triple dot (UIC-14 step 3). | In Review |
| PBI-054 labels and event color | `multiDayLabel` (18:00- / cont. / -04:00; 12 h and 24 h; 00:00 end) in Month, Week, 5-day, Day, List, print; event color already present in all views, now tested (21 new tests). CAL-09.c, EVT-03.b, PRT-02.m `planned`. | In Review |
| PBI-051 Theme layout | Press-and-hold in Theme; three titled groups; two columns above 400 px pane width; tests at 320, 400, 800; SET-03.b merged with SET-09; SET-01.e reworded; pt and nl arb tails that had been swapped were fixed. | In Review |
| PBI-046 popup transitions | `popup_motion.dart`; `showSuiteDialog`, `SuiteDropdown`, week hour-density menu, color picker animate on the Settings animation time (zero for reduced motion); row UIC-47. The info popover has no close transition. | In Review |
| PBI-047 Kobayashi ownership | Sprint-planning and sprint-retrospective skills and the Kobayashi role file updated. The fifth-retrospective audit (due Sprint 006) is still owed. | In Review |
| PBI-048 lint fixes | All findings fixed by owners; `flutter analyze lib test` has 0 issues; the seven lints are raised to warning. | In Review |
| Sprint 007 findings | `orElse` and shim gone from `lib/`; UIC-43, THM-10.d, UIC-44, DEF-01, SET-03.k rows corrected; SET-10 names gone. | In Review |

## Verification

- Server checks: `flutter analyze lib test` 0 issues; `flutter test` 472 tests pass; `flutter build web --release --no-web-resources-cdn` succeeds.
- Visual checks (Product Owner, not done): Reset button look in Settings > Theme; popup open and close animations (dialogs, dropdowns, color picker, hour-density menu); Theme pane in one and two columns with titled rules; multi-day labels in Month and Week; event color in every view and print; header at narrow widths; pale-color text (Sprint 008); Settings back button and auto-save (Sprint 008).
- Rows stay `planned` until then.

## Known limits

- Single-day "start-end" labels in Month and Week are not built (existing tests keep start only); the Product Owner may decide.
- Press-and-hold is stored by `CalendarController` (`view.longPressMs`), not `calendar_defaults.dart`.
- ZonedRow below 320 px scrolls; the info popover has no close transition; clock-badge, logo and a few literals moved to tokens, one `BoxConstraints(26)` in `event_dialog.dart` may remain.
- No Kobayashi plan or retrospective audit was run in this automatic sprint.
