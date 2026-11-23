# Sprint 007 review (Kobayashi, independent audit)

Branch `sprint007`, six commits ahead of `main` (9d2262c to c5916b8). Read-only audit: no code, test or requirement was changed.

## Results
- `flutter analyze lib test`: No issues found.
- `flutter test`: All tests passed (259 tests, final count +259).
- `dart run tool/req_coverage.dart`: 1425 rows, 127 with a test; tests name IDs not in `requirements/`: CAL-05, CAL-05.a, PBI-041, SET-10 (see finding 5).
- The handoff note "10 overflow failures in `event_dialog_layout_test.dart`" no longer reproduces: that file passes today. `daily_scrum.md` still lists it as open; update it.

## Findings, ranked

### High
1. **Settings > Theme controls are partly decorative; UIC-44 and SET-03.k are stated more broadly than built.** The pane (`lib/src/calendar/settings_theme_pane.dart:92-101`) has six numbers (animation, popup shadow, resize bar, dropdown text, date picker, status chip) plus default theme. SET-03.k (`requirements/settings.md:27`) and UIC-44 (`requirements/common.md:68`) say every common UI element has a setting, status `planned`. Not built: control height, swatch size, long-press (SET-03.b), module grips (SET-03.d), time notation (SET-03.a), color picker, dialog padding. The tests (`test/calendar/settings_theme_test.dart:72`) only prove the six listed. This is the known catch-all gap; the rows must say what is delivered (or stay `backlog`) until PBI-044 finishes.
2. **Status chip time (SET-03.j) is set and saved but nothing reads it.** `statusChipTime` is referenced only in `theme_settings.dart` and the pane (grep over `lib/`). The UIC-28 chip is `backlog`, so the setting changes nothing visible. SET-03.j is `planned` and says "its default and range are in DEF-01", but DEF-01 has no Status chip row (the 2.4 s default and 0.5 to 10 s range live only in `theme_settings.dart:11-13`, and the 500 ms to 2 s animation range is in DEF-01 line 152 only). Rows to fix: SET-03.j status, and a DEF-01 row for Status chip time.
3. **English fallbacks left in code after the arb merge (arb-only rule).** All six arb files now hold the admin, theme-menu and palette keys (for example `adminAddTestCalendars`, `themeName`, `eventColorTomato`, `calendarDefault` in `requirements/messages/app_en.arb`), yet `m.orElse('key', 'English')` is still used 10 times in `lib/src/calendar/settings_admin_pane.dart:28,33,40,50,59,64` and `lib/src/calendar/calendar_page.dart` (theme menu, TODO at line 272), plus the shim in `lib/src/theme/theme_mode_controller.dart:68-77`. `paletteColorName` (`lib/src/ui/color_picker.dart:15`) falls back to the English `PaletteColor.name`. These literals are dead code today but violate "all text in arb" and hide missing keys from tests. Owner: Nakamura (admin pane, `calendar_page.dart`, `theme_mode_controller.dart`), Ito (`color_picker.dart`).

### Medium
4. **CAL-10.d and THM-10.d (opened event shadow) are not built, but UIC-43 is `planned` with `test/ui/popup_shadow_test.dart` as its only test.** UIC-43 lists "an opened event" as a popup type; no test covers it and `week_view.dart` has no expanded block with elevation. CAL-10.d is honestly `backlog`; THM-10.d (`requirements/theme.md:51`) is `planned` and cites the same test, which does not test it. Also `hour-density` `PopupMenuButton` (`lib/src/calendar/week_view.dart:161`) has no `elevation:` so the Popup shadow setting does not scale it (handoff request to Ito still open). Owners: Ito (week_view), Tanaka (test, THM-10.d row).
5. **Dangling ID SET-10.** Tests (`test/calendar/ux_test.dart:642,653`) and code comments cite SET-10, which was renamed to SET-03.g (`requirements/oldkey.md:1463`). The planning commitment to "reconcile SET-10" is done in the rows but the tests and comments still use the old ID. Owner: Ito (ux_test.dart rename in test names). Also CAL-05, CAL-05.a are cited by tests but missing (not Sprint 007, noted).
6. **Resize bar size ignores the token rule.** `lib/src/ui/resize_bar.dart:126` uses the literal `Size(29, 8)` scaled by the setting. The date picker, dropdown and popup-shadow consumers are wired (`date_picker.dart:65`, `suite_dropdown.dart:196,217`, `suite_theme.dart:71`). Owner: Tanaka (token).
7. **Tokens-only rule: new literals.** Added this sprint: `color_picker.dart` swatch `SizedBox(width: 260)` and avatar `radius: 6` (`lib/src/ui/color_picker.dart:56,63`); `local_calendars_dialog.dart:165` `width: 440`; `list_view.dart:58` `Container(width: 4, height: 18, EdgeInsets.only(right: 8))`; `local_calendars_dialog.dart:217` `BorderRadius.circular(8)`; `main.dart:71-91` (`StartupErrorApp`, fontSize 20, padding 24, gaps 12) and `main.dart:185` `Text('SuiteStream')`. `event_dialog.dart` still carries many literal radii, gaps and `fontSize: 12` (lines 566, 594, 631-640, 678, 747-757, 796, 1127, 1222-1346); most pre-date this sprint, but Sprint 007 edited the file and did not clear them. `Colors.transparent` at `color_picker.dart:93` is acceptable. Owners: Ito (event_dialog, color_picker, local_calendars_dialog, list_view if his), Tanaka (add tokens), Nakamura (main.dart).
8. **Theme flash on start (SHL-03.a) is only string-checked.** `test/theme/theme_mode_test.dart:103` reads `web/index.html` for the script; the no-flash behavior is browser-only. Row is `planned`; fine, but it needs the Product Owner's hard-refresh check (Dark on light OS, and the reverse).

### Low
9. **Catching too broadly.** `lib/main.dart:27` `catch (_)` falls back to UTC (commented, acceptable); `main.dart:48` and `lib/src/app/bootstrap.dart:29` catch all and show an error screen (acceptable at startup, but narrow with `on Exception` if possible).
10. **`late` fields and `late SharedPreferences? _prefs`** in `settings_calendar_pane.dart:29,63-70` defer initialization errors to runtime; fine functionally. Long `_Setting`/setter one-liners in `theme_settings.dart:55-60` and `settings_theme_pane.dart:92-101` exceed readable width; consider a small helper.
11. **`ThemeSettingsScope._defaults` is a static mutable `ChangeNotifier`** (`theme_settings.dart:121`): a setter on it in a test would leak across tests. Unused that way today.
12. **Checklist items that pass:** no `print()` in files reviewed; `ThemeModeController`, `ThemeSettings` and `CalendarDefaults` clamp and validate stored values; widgets are Stateless where possible; colors in new panes come from tokens; the picker has Semantics labels, selected state and tooltips; `ThemeSettings` and `ThemeModeController` persist and Reset forgets saved keys (tested).

## PBI readiness for Product Owner verification
| PBI | Verdict | Notes |
|---|---|---|
| 034 colors | Ready, with note | Rows THM-09, THM-09.a, UIC-10, UIC-10.a, UIC-20, EVT-03.b, .d, .i are `planned` with real tests (event_logic_test, event_dialog_test, local_calendar_test, popup_shadow_test). Week all-day chip ignores event color (known gap, Ito/Nakamura): the PO will see it in the browser; THM-09.b/EVT-03.i should not be called done until fixed. Arb names not used yet (finding 3). |
| 035 theme mode | Ready after PO visual check | SHL-03, .a, .b `planned`; SHL-03.c honestly `backlog`. Needs browser flash check (finding 8). |
| 036 calendar and theme panes | Ready | SET-08 to SET-08.d, SET-03.g, SET-03.l, EVT-01.m, EVT-02.n covered. Default time zone path has a test. |
| 041 admin test data | Ready | SET-14 and `admin_test_data_test.dart` (add twice, remove only test data, old demo ids, widget No/Yes) honest; bootstrap sample removal tested. Fix `orElse` literals first (finding 3). |
| 042 popup shadow | Not ready | Opened event shadow and hour-density menu missing (finding 4); UIC-43 and THM-10.d over-stated. |
| 043 control height | Ready | THM-04.b and THM-01.e covered by `test/ui/control_height_test.dart` (event, settings, local calendars, zone picker, 320 to 967 px) and the reminder-row test. Date picker has no text boxes (asserted). |
| 044 theme settings | Partly ready | Six settings plus Reset work and are tested; status chip has no consumer, SET-03.k and UIC-44 over-stated (findings 1, 2). Lesser elements are the planned cut. |

## Rows mis-stated or needing a change
- SET-03.k (`settings.md:27`) and UIC-44 (`common.md:68`): `planned` covers only six elements; narrow the text or set `backlog` for the rest.
- SET-03.j (`settings.md:26`): "default and range in DEF-01" but no DEF-01 row; setting has no consumer.
- THM-10.d (`theme.md:51`) and UIC-43 (`common.md:67`): promise an opened event shadow with no test or build; CAL-10.d (`calendar.md:71`) honestly `backlog`.
- THM-09.b (`theme.md:48`) and EVT-03.i (`events.md:51`): `planned` is honest only while Week all-day chips ignore color.
- SET-03.c (`settings.md:19`) remains `backlog` ("Animation intensity") while DEF-01 lines 137 to 138 still define percent animation rows that no longer match the 0 to 2 s time; reconcile.
- Test names citing SET-10 (ux_test.dart) need SET-03.g.
- No status is `done` for anything, which is correct before PO verification.

## Definition of Done check
- Requirements and tests: met for 034, 035, 036, 041, 043; PBI-042 and 044 partly.
- Tests pass: yes (analyze clean, 259 tests).
- Code quality: ownership respected per handoffs (one editor per file; Tanaka's one-line requests were routed through handoffs); tokens-only and arb-only rules broken by findings 3 and 7.
- Runtime: web build reported passing in commit 4f77ad1 (not re-run by me); browser checks pending.
- Documentation: `daily_scrum.md` has only Day 1 and a wave status; Days 2 to 5 not filled; known limitations (CAL-10.d, Week all-day color, catch-all) not recorded in a sprint file. This DoD item is open.

## Gaps (known and new)
- CAL-10.d opened event shadow not built.
- Week all-day chip ignores event color.
- SET-03.k catch-all and PBI-044 lesser-element controls not built.
- New: status chip time unused; hour-density menu unscaled; English fallbacks and literal sizes remain; SET-10 stale test names; sprint notes stale.

## Recommended actions
| # | Action | Owner |
|---|---|---|
| 1 | Replace `orElse` calls and delete the shim, `TODO(arb)` and the English palette fallback; add a test that every used key exists in all six arb files | Nakamura, Ito |
| 2 | Build the opened event block with `popupElevationOf` and a test; add `elevation:` to the hour-density menu | Ito (Tanaka writes test and THM-10.d row) |
| 3 | Make the Week all-day chip use `colorOf(e) ?? defaultEventColor` with a test | Ito |
| 4 | Narrow SET-03.k and UIC-44 wording and status; add DEF-01 row for Status chip time; fix SET-03.j and reconcile DEF-01 animation rows | Yamamoto (settings.md), Tanaka (common.md), Takahashi to confirm |
| 5 | Rename SET-10 to SET-03.g in test names and comments | Ito, Nakamura |
| 6 | Add tokens for 260/440 widths, picker avatar radius, resize bar size, list color bar, startup screen; clear literals in the Sprint-007 diff of event_dialog | Tanaka (tokens), Ito, Nakamura |
| 7 | Update `daily_scrum.md` (Days 2 to 5, layout failures resolved), record known limitations in the Review notes | Takahashi |
| 8 | PO browser walkthrough: theme flash, picker, panes, admin add/remove; keep rows `planned` until PO verifies | Product Owner, Takahashi |
