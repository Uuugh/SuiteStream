# Sprint 009 handoffs

Append sections as "## From to To (topic)". Do not edit others' sections.

## From Nakamura to Tanaka (tokens, wave 1)
Literals left in my files that need tokens in `suite_theme.dart`: `_shortTitleWidth` = 160 in `calendar_page.dart` (header room for a short title before the zones stack; private const for now, TODO), clock badge font size 9 and horizontal padding 2 (`calendar_page.dart`), app bar toolbar height 44 and logo size 26 (`main.dart`). Tell me the names and I replace them. `ZonedRow` still scrolls a control zone below about 300 px of content width instead of clipping with the triple dot (UIC-14 step 3); that is in your file. My header test is `test/calendar/header_narrow_test.dart` (320, 360, 400, 700 px and 1.5x text); it does not use your helper yet.

## From Nakamura to Yamamoto (failures seen in your area)
`test/app/message_keys_test.dart` reports `settingsGeneralEmpty` (used in `settings_dialog.dart`) missing from the arb files; `settings_autosave_test.dart` UIC-45 invalid-value tests fail at `enterText` (field not found). Not from my files.

## Ito to Tanaka (Sprint 007 wording, wave 1)
- THM-10.d (`theme.md`) and UIC-43 (`common.md`): the opened event in Week/Day IS built (`week_view.dart`: `Material(key: ValueKey('opened-event'), elevation: popupElevationOf(context))` on the top layer, and `hour-density` menu has `elevation: popupElevationOf(context)`). The test that covers it is `test/events/week_event_style_test.dart` ("CAL-10.d, THM-10.d" and "SET-03.e"), not `test/ui/popup_shadow_test.dart`. Correct both rows to cite `test/events/week_event_style_test.dart` next to `test/ui/popup_shadow_test.dart`; CAL-10.d stays mine (still `backlog`, only the shadow part is built).
- `test/ui/popup_shadow_test.dart:23` (yours) still uses `firstWhere(..., orElse: () => const Material())`; use `where(...).firstOrNull` so a missing popup fails instead of passing on a fake Material.

## Ito (wave 1 status, for Takahashi, Yamamoto)
- PBI-054 built: `multiDayLabel` in `lib/src/time/time_format.dart`; Month, Week/5-day/Day, List and print use it. `msg:cont` already exists in the arb files; no new strings (no `strings_ito.md`).
- Event color (EVT-03.b) already showed in every view; added `test/events/event_color_views_test.dart`. Rows: CAL-09.c, EVT-03.b, PRT-02.m set to planned.
- PBI-048: package imports and catch clauses fixed in all my files and `lib/src/time/*`; `analysis_options.yaml` `errors:` block can be removed once all owners finish.
- Sprint 007 `orElse`/`TODO(arb)`/English palette fallback: already gone from `lib/` (`paletteColorName` uses `m(color.messageKey)`).

## Tanaka to Yamamoto, Nakamura (Reset style, PBI-053, landed)
`import 'package:suitestream/src/ui/reset_button.dart';`
- `ResetButton(label: m('themeSettingsReset'), onPressed: _reset)` (a `TextButton` in the error role, 34 px high). Add your own `key:`. Use it in `settings_theme_pane.dart` in place of the `OutlinedButton` (key `setting-theme-reset`).
- Or `suiteResetButtonStyle(context)` -> `ButtonStyle` for a button you build yourself.
- No new arb keys (UIC-46, UIC-14.c rows are in `requirements/common.md`, status planned).

## Tanaka to Ito, Nakamura (popup transition, PBI-046, landed)
`import 'package:suitestream/src/ui/popup_motion.dart';` (`showSuiteDialog` in `suite_dialog.dart` is unchanged in signature). Time = Settings animation time (SET-03.g), 0 with reduced motion; row UIC-47.
- Every dialog opened with `showSuiteDialog` already has it (event_dialog.dart, local_calendars_dialog.dart, calendar_print_dialog, settings dialog need no change).
- Ito, `ui/color_picker.dart` passes `animate: false` to `showSuiteDialog`; delete that argument so the picker animates.
- Ito, `week_view.dart:167` `PopupMenuButton<int>`: add `popUpAnimationStyle: suitePopupAnimationStyle(context),`.
- Nakamura, `calendar_page.dart` theme menu: if it is a `PopupMenuButton` or `showMenu`, add `popUpAnimationStyle: suitePopupAnimationStyle(context)` (`showMenu` has the same parameter). If it is an overlay you build, wrap the panel in `SuitePopupMotion(open: _open, onClosed: hide, child: panel)` (open false runs the close, then `onClosed` removes it).
- `suitePopupDuration(context)` gives the time; `suitePopupAnimationStyle(context)` returns `AnimationStyle.noAnimation` for zero.
- Done by me: `SuiteDropdown` (open and close), `InfoPopoverButton` (open only; MenuAnchor has no close hook), zone picker, date picker, event details, confirm (all via `showSuiteDialog`). Tests: `test/ui/suite_dialog_test.dart`, `test/ui/popup_motion_test.dart`.

## Tanaka to Nakamura (tokens and header zones)
Added to `suite_theme.dart`: `suiteHeaderShortTitleWidth` (160), `suiteClockBadgeFontSize` (9), `suiteClockBadgePadding` (2), `suiteToolbarHeight` (44), `suiteLogoSize` (26). Replace your literals. `ZonedRow` still scrolls a control zone instead of ending the text in a triple dot (UIC-14 step 3); I did not change it this wave because three header tests depend on the layout. My fit test: `test/ui/header_zone_fit_test.dart` (320, 400, 800 px).

## Tanaka: status
- Rows: UIC-14.c, UIC-46, UIC-47 added (planned); UIC-43, THM-10.d (Ito's wording and tests), UIC-44, DEF-01 reworded to what is built and not met; popup start scale row added to the DEF table.
- `analysis_options.yaml`: `errors:` info block removed, the seven lints now warnings; `flutter analyze lib test` reported 0 issues at 2026-11-23 after my edit. Anyone adding an issue now fails analyze.
- `test/ui/popup_shadow_test.dart`: `orElse` fake Material removed (Ito's finding).

## Yamamoto (wave 1: PBI-051, PBI-048, 007 findings)
- Theme pane: press-and-hold moved from General to Theme (key `setting-press-delay` kept; stored by the controller, not `calendar_defaults.dart`). Groups on titled rules (keys `theme-group-theme|times|scales`); two columns above `settingsThemeTwoColumnWidth` (400, a named constant in `settings_theme_pane.dart`, measured on the pane, not the window; no Tanaka token needed). General now shows `settingsGeneralEmpty`.
- Arb: added themeSettingPressDelay, themeGroupTimes, themeGroupScales, settingsGeneralEmpty (6 languages); removed pressDelay and pressDelayInvalid; fixed the pt and nl tails that were swapped between the two files (themeName to adminFailed).
- Wave 2 pending: Reset in the Theme pane still `OutlinedButton` (key `setting-theme-reset`); I will switch it to the shared style.
- SET-09 row merged into SET-03.b; tests renamed to SET-03.b. `oldkey.md` (not mine) may want R-row SET-09 to SET-03.b.
- UIC-44 and DEF-01 rows are in `common.md` (Tanaka): UIC-44 should now also list the press-and-hold delay as built and cite `test/calendar/settings_theme_test.dart`.
