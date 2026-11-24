# Sprint 007 Backlog

Proposed 2026-11-23. Committed 22 points over five days. Hours are estimates; no task is over 6 hours. Owner = the one editor of the files listed in `sprint_planning.md`.

| Item | Task | Hours | Owner |
|---|---|---:|---|
| PBI-034 | `event_colors.dart`: 11 event colors and 24 calendar colors with names; nearest-color mapping; defaults (EVT-03.i); tests | 3 | Ito |
| PBI-034 | Shared `color_picker.dart` with both palettes, accessible names, selected mark | 4 | Ito |
| PBI-034 | Use the picker in `event_dialog.dart` (event color, "calendar default") | 2 | Ito |
| PBI-034 | Use the picker in `local_calendars_dialog.dart`; stop deriving colors from the theme | 2 | Ito |
| PBI-034 | Set THM-09, UIC-10, UIC-20, EVT-03.i rows and cite tests | 1.5 | Ito |
| PBI-043 | Reminder rows use the one control height in `event_dialog.dart` | 1.5 | Ito |
| PBI-036 | Default event length (value and unit) read by new events in `event_dialog.dart` | 1.5 | Ito |
| PBI-035 | `theme_mode_controller.dart` (Light / Dark / Match system, saved on the device) and wiring in `main.dart` | 3 | Nakamura |
| PBI-035 | Header icon button plus menu in `calendar_page.dart`, like the view picker | 3 | Nakamura |
| PBI-035 | Early theme script in `web/index.html`; no flash on start | 2 | Nakamura |
| PBI-035 | Tests (`theme_mode_test.dart`) and visual check | 2 | Nakamura |
| PBI-041 | `test_data.dart`: 3 test calendars, about 8 events each across November 2026 (timed, all-day, multi-day, overlapping, some with reminders), stable ids | 4 | Nakamura |
| PBI-041 | `settings_admin_pane.dart`: Add test calendars; Remove test data with the shared confirmation (`confirm.dart`) | 3 | Nakamura |
| PBI-041 | Remove first-run sample data from `bootstrap.dart`; update `bootstrap_test.dart` | 1.5 | Nakamura |
| PBI-041 | Tests: add twice gives no duplicates; remove deletes only test data (`admin_test_data_test.dart`) | 2 | Nakamura |
| PBI-043 | Control-height token (34 px) in `tokens.dart`; used by dropdown, time, length and zone inputs | 4 | Tanaka |
| PBI-043 | Site-wide widget test: open every dialog and assert 34 px for all text boxes and dropdowns (`control_height_test.dart`) | 4 | Tanaka |
| PBI-043 | Fix findings in owned files; set THM-04.b and THM-01.e rows | 2 | Tanaka |
| PBI-042 | Popup shadow token and shared popup decoration in `suite_theme.dart` / `suite_dialog.dart`; applied to dialogs, menus, pickers, popovers and the opened event | 4 | Tanaka |
| PBI-042 | Test finding every popup type; set UIC-43, THM-10.d, CAL-10.d rows | 2 | Tanaka |
| PBI-044 | `theme_settings.dart`: popup shadow, resize bar size, dropdown text size, date picker size, status chip time, animation time; DEF-01 defaults, persistence, Reset; elements read them | 6 | Tanaka |
| PBI-044 | Tests; UIC-44 row cited | 1 | Tanaka |
| PBI-036 | Split `settings_dialog.dart` into pane files; Admin entry at the bottom | 2 | Yamamoto |
| PBI-036 | `calendar_defaults.dart` and Settings > Calendar pane: default length with unit, default time, default time zone; tests | 5 | Yamamoto |
| PBI-036 | Settings > Theme pane: animation time moved from General (SET-03.g; SET-03.c and SET-10 reconciled), default theme choice using Nakamura's controller | 3 | Yamamoto |
| PBI-044 | Theme pane controls for each common UI element, and Reset; tests | 5 | Yamamoto |
| All | Merge strings from `strings_<name>.md` into the six arb files (days 1, 2, 3); run l10n generation | 4 | Yamamoto |
| PBI-035/036/041/044 | `settings.md` and `shell.md` rows (SET-03.c, e to k, g; SET-10; SHL-03; new Calendar and Admin rows) with tests cited | 2 | Yamamoto |
| All | Day 5: `flutter analyze`, full tests, web build; walkthrough with the Product Owner in the VS Code browser | 3 | All |
| Scrum | Backlog status, facilitation, daily scrum, Review draft, impediments, usage check | 4 | Takahashi |

Developer totals: Ito 15.5, Tanaka 23, Nakamura 20.5, Yamamoto 21 = 80 hours, plus the shared day 5 check (3 hours each, 12) and Takahashi 4. Against about 80 net developer hours this is full, not slack; Tanaka and Yamamoto are heaviest, and the cut order in the plan relieves them first. (The planning file's "about 76" is before the Yamamoto rebalancing; 80 plus the day 5 check is the number to use.)

## Start order

1. Wave 1, all four in parallel on day 1: Tanaka (tokens and theme-settings model first, hours 1 to 4), Ito (palette model), Yamamoto (pane split, then `calendar_defaults.dart`; arb intake from hour 2), Nakamura (empty admin pane in the first 30 minutes, then `ThemeModeController` and the test-data generator).
2. Wave 2, from day 2 (after Tanaka's tokens and Nakamura's controller land): Yamamoto Theme pane; Ito integration; Nakamura header menu and admin pane.
3. Wave 3, days 3 to 4: site-wide audits, rows, tests, final arb merge. Day 5: Review.
