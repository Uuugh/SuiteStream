# Sprint 010 handoffs

Append sections as "## From X to Y (topic)". Do not edit others' sections.

## Takahashi to all (constants)
`lib/src/calendar/calendar_defaults.dart` now holds `defaultLongPress` (0.2 s), `minLongPress`, `maxLongPress`, `clampLongPress`, `defaultStatusWordTime` (1 s), `minStatusWordTime` (0.5 s), `maxStatusWordTime` (10 s), `clampStatusWordTime` (DEF-01). They were removed from `event_drag.dart`; imports fixed in controller, theme pane and `drag_test.dart`. Yamamoto owns the file from now.
Tanaka: `savedCancelledHold` in `cancel_save_pair.dart` (3 s) must become the Settings value; the Settings value reaches the pair through a scope you define (like `SuiteAnimationScope`); Nakamura sets it in `main.dart` from the controller; Yamamoto adds the Theme setting SET-03.m. Agree names here.

## From Tanaka to all (tokens and scope, ready)
- `suiteCompactIconBox` = 26 (double) in `lib/src/theme/suite_theme.dart`. Ito: use it for the 26 px `BoxConstraints(minWidth/minHeight)` of the duplicate button in `event_dialog.dart`.
- `SuiteStatusWordScope(duration: ..., child: ...)` in `suite_theme.dart`; `SuiteStatusWordScope.of(context)` defaults to `defaultStatusWordTime`. Nakamura: wrap it in `main.dart` next to `SuiteAnimationScope`, value from the controller. Yamamoto: SET-03.m feeds that value (use `clampStatusWordTime`).

## From Yamamoto to Tanaka (Reset icon)
SET-01.g / UIC-46 need an icon beside the Reset label. Please add `static const restartAlt = IconData(0xf053, fontFamily: fontFamily);` to `SuiteIcons` (Material Symbols restart_alt) in `lib/src/theme/suite_icons.dart`. Optional: an `icon` parameter on `ResetButton` (it is a `TextButton`; with an icon use `TextButton.icon`). Until then `settings_dialog.dart` builds its own `TextButton.icon` with `suiteResetButtonStyle(context)` and `SuiteIcons.restartAlt`, so analyze fails there until the glyph exists.

## From Tanaka to Yamamoto (Reset icon, done)
`SuiteIcons.restartAlt` (0xf053, Material Symbols restart_alt) added to `suite_icons.dart`. I did not add an `icon` parameter to `ResetButton`; use your own `TextButton.icon` as you planned (tell me if you want the parameter).

## From Tanaka to Takahashi, Nakamura (ui results)
- ResizeBar: `lib/src/ui/resize_bar.dart` is imported by nothing in `lib/` (only `test/ui/resize_bar_test.dart`). The Settings dialog shows no resize bar (SET-01.f). UIC-16 / SET-03.f (size setting) only reach `suiteResizeBarSize` used by the event drag handle in `event_drag.dart`. Takahashi: decide whether UIC-16 stays backlog or the widget is dropped; I changed no UIC-16 rows.
- ZonedRow (UIC-14 step 3): control zones no longer scroll (NeverScrollableScrollPhysics); plain `Text` children become Flexible and end in a triple dot, other overflow is clipped at the zone edge. Nakamura: `header_test.dart` and `header_narrow_test.dart` pass unchanged; none depend on scrolling.
- InfoPopoverButton is now an OverlayPortal popup (not MenuAnchor) with `SuitePopupMotion`: fades out over the animation time, none with reduced motion; outside tap, Escape or the button close it. Tests in `test/ui/popup_motion_test.dart`.
- CancelSavePair hold: `holdDuration` > `SuiteStatusWordScope` (default 1 s). `savedCancelledHold` removed. `test/flutter_test_config.dart` (debugHold = zero) untouched. Test rows UIC-27.a -> `test/ui/cancel_save_pair_test.dart` (real). UIC-28.c has no test ("—") because no status-word widget exists yet; SET-03.m names `test/calendar/settings_theme_test.dart` (Yamamoto to add the test).
- `SuiteIcons.restartAlt` glyph 0xf053 not verified against the bundled font file (no font tooling here); check it renders.

## From Nakamura to Yamamoto, Ito, Tanaka (PBI-061, PBI-058 status)
- **Yamamoto (shell.md):** change the test cell of SHL-01.h from `test/ui/title_bar_test.dart` to `test/app/title_bar_test.dart` (test/ui is Tanaka's folder; the test is in my test/app). The test checks light and dark: the AppBar Material color equals the page color, surface tint transparent, elevation and scrolled-under elevation 0.
- **Done in `lib/main.dart`:** AppBar `backgroundColor: t.bg`, `surfaceTintColor: Colors.transparent`. `SuiteStreamApp` has a new optional `timingSettings` (`TimingSettings` from `calendar_defaults.dart`; `main()` creates it from prefs). It wraps `TimingSettingsScope` and `SuiteStatusWordScope(duration: timing.statusWordTime)` (rebuilt on every change), so the Settings value reaches `CancelSavePair` live. Yamamoto: read it in the pane with `TimingSettingsScope.maybeOf(context)`.

## From Nakamura to Ito (CAL-03.d first press)
- New test: `test/calendar/first_press_test.dart` (first press after the page opens: held 250 ms starts the drag, held 150 ms does not; a stored 600 ms delay is used from the first press). Cite it in CAL-03.d (calendar.md is yours). All three pass.
- Cause not reproduced in the widget tests: the controller reads `view.longPressMs` synchronously in its constructor (prefs are loaded before `runApp`), `calendar_page.dart` passes `c.longPress` to the views, `DragMovable` makes its recognizer with that duration on the first build. No code in my files delays it. Remaining suspects, none verifiable without the browser: (1) first-use jank on the web when the drag ghost is inserted (`Overlay` entry with `BoxShadow` + `Opacity`: shader compile on first use, about 1 s): Ito could build the ghost before the delay ends (warm it up) or avoid the blur shadow; (2) a stored `view.longPressMs` of 1000 left from earlier testing (Settings > Theme > Reset or clearing site data fixes). Please check (1) in the browser.

## Ito to all (PBI-059, 060, 062, defect)
- PBI-059: Week, 5-day, Day blocks, List rows and Month chips now fill with the event color (`eventTextColorOn` text; Month was a 18% tint, now full color to meet EVT-03.b "never a pale fill"). The List color bar is gone (the row is the fill); `suiteListColorBar*` tokens in `suite_theme.dart` are now unused (Tanaka may remove). `test/events/event_color_views_test.dart` asserts fill and contrast per view, light and dark.
- PBI-062: `multiDayLabel` already depended on the shown zone; List showed "start – end" for single-day events, now start only. Tests in `multiday_label_test.dart` move the zone both ways. Not mine: `calendar_print_dialog.dart` (Nakamura) still prints "start – end" for single-day events and `test/calendar/calendar_print_test.dart` expects it; CAL-09.c says start only, so Nakamura decides.
- Defect: `event_dialog.dart` uses `suiteCompactIconBox`.
- PBI-060: `ResizeHandle`, `resizeEventEnd`, `resizedEndMinute` in `event_drag.dart`; handle in `week_view.dart` (key `resize-<id>`, height `suiteResizeBarSize.height`); saves through `upsertEvent`, no controller change. `test/calendar/event_resize_test.dart`.
- Seen failing, not mine: ux_test (UIC-41 settings arrows, SET-03.b press-and-hold 0.3) and settings_theme_test at 320/400 (Yamamoto's work in progress).

## From Yamamoto to Nakamura (status word time API) and all (Settings layout)
- `TimingSettings` (ChangeNotifier) and `TimingSettingsScope(settings:, child:)` are in `lib/src/calendar/calendar_defaults.dart`. In `main.dart`: create `TimingSettings(prefs: prefs)` once, wrap the app in `TimingSettingsScope(settings: timing, child: ...)` and, below it, `ListenableBuilder(listenable: timing, builder: (_, __) => SuiteStatusWordScope(duration: timing.statusWordTime, child: ...))`. Without the scope the Theme pane makes its own `TimingSettings` from the prefs it is given, so a scope is needed for the app to hear changes. Key `timing.statusWordMs` (int ms, on the device until PBI-037 wave 3). `statusWordTime` is always clamped to 0.5 to 10 s; `reset()` restores 1 s. Setting label key: `themeSettingStatusWordTime`; the old chip label now reads "Status chip time" (key `themeSettingStatusChipTime`, all six arb files).
- Press-and-hold default 0.2 s: the Theme pane still reads and writes `CalendarController.longPress`.
- PBI-057: the cause of the "resize bar" in Settings: nothing in `lib/` draws `ResizeBar` in the Settings dialog today (no use of `ResizeBar` outside `resize_bar.dart`), so the test just guards it (`find.byType(ResizeBar)` findsNothing). Reset is now in the dialog footer (`SettingsResetHook`; the Theme pane registers its action), as `TextButton.icon` with `suiteResetButtonStyle` and `SuiteIcons.restartAlt` (thanks Tanaka); keys unchanged (`setting-theme-reset`). Narrow menu scrolls inside 40 % of the height, so tests tap menu entries after `ensureVisible`.
- Stale tests not mine: `test/calendar/ux_test.dart` still expects press-and-hold 0.3 s (`pressDelayTests` line ~597, `stepperTests` line ~765 expects 0.4 s after one step); DEF-01 says 0.2 s. Owner of ux_test: please update (0.2 s, step gives 0.3 s).
