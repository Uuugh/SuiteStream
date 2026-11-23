# Sprint 007 review (draft, Takahashi/Tanaka)

No requirement is `done`: every row stays `planned` (or `backlog`) until the Product Owner verifies it in the browser.

## Results per PBI
| PBI | Result | Server checks (flutter test, analyze) | Visual checks still needed |
|---|---|---|---|
| 034 colors | Built: shared picker, event and calendar palettes, default color | event_logic, event_dialog, local_calendar, popup_shadow tests | Week all-day chip ignores event color (known gap): THM-09.b and EVT-03.i not complete |
| 035 theme mode | Built: Light / Dark / Match system menu and saved choice | theme_mode_test (stored choice, menu, early script text) | Hard refresh with Dark on a light OS and the reverse (no flash, SHL-03.a) |
| 036 calendar and theme panes | Built: Calendar and Theme panes, default time zone, default start time and length | settings tests, ux_test | Open both panes and change each setting |
| 041 admin test data | Built: add and remove test calendars (Work, Family, Travel) | admin_test_data_test, bootstrap_test | Add twice, remove, answer No then Yes |
| 042 popup shadow | Partly built: dialogs, dropdown menu, color picker | popup_shadow_test | Opened event shadow not built (CAL-10.d backlog, THM-10.d planned); hour-density menu does not yet scale with the setting (Ito) |
| 043 control height | Built: 34 px controls in event, settings, local calendars, zone picker | control_height_test, event_dialog_test | Look at widths from phone to desktop |
| 044 theme settings | Partly built: six settings plus default theme and Reset | settings_theme_test, theme_settings_test | Status chip time has no visible effect until UIC-28 exists |

## Known limitations
- CAL-10.d / THM-10.d: the opened event in the hourly grid has no shadow yet.
- Week all-day chips ignore event color.
- SET-03.k / UIC-44: only six settings exist; control height, swatch size, long-press, module grips, time notation, color picker and dialog padding are backlog.
- SET-03.j: Status chip time is saved but unread until the UIC-28 chip exists.
- SET-03.c (animation intensity percent) stays backlog; the built setting is Animation time (SET-03.g).
- English `orElse` fallbacks and literal sizes in event_dialog.dart remain in places (Ito, Nakamura clearing).
- SET-10 stale test names (Ito, Nakamura renaming to SET-03.g); CAL-05 cited by tests but absent (not Sprint 007).

## What the Product Owner must verify
1. Theme flash on start (Dark on a light OS, and the reverse), theme menu icon and choices.
2. Color picker in the event and calendar dialogs; popup shadow on each popup type; Popup shadow setting scales it.
3. Settings > Calendar, Theme, Admin: each control, Reset, add and remove test calendars.
4. Layout of the event dialog at phone width and larger text.
5. Then say which rows may become `done`.

## Verification record
- Server checks (done by tests): see the table above; Kobayashi's run: analyze clean, 259 tests pass. Tanaka's round 3 re-run is below the table in the final report.
- Visual checks (not yet done): everything in the PO list; the web build passed in commit 4f77ad1 and was not rebuilt in round 3.

## Kobayashi findings status
| # | Finding | Status |
|---|---|---|
| 1 | SET-03.k, UIC-44 over-stated | Fixed: wording narrowed, status `backlog` |
| 2 | Status chip time unread | Fixed: SET-03.j `backlog`, DEF-01 row named, animation rows reconciled |
| 3 | English fallbacks after arb merge | Open (Nakamura, Ito) |
| 4 | Opened event shadow, UIC-43 | Rows corrected; build and test pending Ito's week_view change |
| 5 | SET-10 dangling | Open (Ito, Nakamura) |
| 6 | Resize bar literal | Fixed: `suiteResizeBarSize` |
| 7 | Literal sizes | Tokens added; picker and resize bar cleared; local_calendars_dialog, list_view, main.dart, event_dialog open (Ito, Nakamura) |
| 8 | Theme flash string-checked only | PO visual check listed |
| 9 to 11 | Low | Not addressed this sprint |
