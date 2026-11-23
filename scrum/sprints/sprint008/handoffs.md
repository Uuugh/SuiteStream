# Sprint 008 handoffs

## Nakamura to Yamamoto (PBI-050 header hook, landed)

In `lib/src/calendar/calendar_page.dart` (public, import it):
- `HeaderBackButton({required VoidCallback onPressed, required String tooltip})`: an `IconButton` (key `header-back`, `SuiteIcons.arrowBack`, `suiteIconButtonStyle`).
- `PageHeader({required Widget title, required VoidCallback onBack, required String backTooltip, List<Widget> right = const []})`: a `ZonedRow` with the back button first in the left zone, then `title` (Flexible). Use it in `settings_dialog.dart` in place of the plain `Text(m('settings'))` title: `PageHeader(title: Text(m('settings'), style: ...), onBack: () { /* save open pane, then */ Navigator.of(context).pop(); }, backTooltip: m('settingsBack'))`.
- Saving is yours: onBack must save the open pane before popping. The tooltip is passed in, so I add no strings; key `settingsBack` ("Back") is in `scrum/sprints/sprint008/strings_nakamura.md` for you to merge into the arb files.

## Nakamura: Admin pane and UIC-45 (auto-save does not apply)

The Admin pane has no value to save: it has only two actions that act at once (Add test calendars; Remove test data after No | Yes). Nothing is held that could be lost or saved on leaving, so there is nothing to auto-save and no invalid value. The pane has no Cancel | Save (UIC-45 exception for actions). Test: `test/calendar/admin_test_data_test.dart` "UIC-45: leaving the Admin pane changes nothing". `settings_admin_pane.dart` is unchanged. Yamamoto: leaving Admin by page change, close or back needs no call into the pane.

## Ito to Tanaka: `eventTextColorOn` exists (PBI-052, THM-10.h)
`Color eventTextColorOn(Color fill, Brightness brightness)` in `lib/src/theme/event_colors.dart`. `fill` is the opaque chip fill (blend a translucent fill over `scheme.surface` first with `Color.alphaBlend`). Result: the fill's hue moved toward black (light) or white (dark) to reach 4.5:1; flips direction when needed. Apply in `event_details.dart`. Helper `eventContrastRatio(a, b)` and `eventTextMinContrast` (4.5) are exported too. Applied by me in Month chip, Week all-day bar; Week timed blocks and List use neutral text with a color strip, and print uses a color border only (no fill), so nothing to change there.

## Tanaka: PBI-048, PBI-052 (details) and PBI-050 status
- `analysis_options.yaml`: strict-casts, strict-inference, strict-raw-types on; the seven lints on, all at severity info (`analyzer: errors:`), plus `list_element_type_not_assignable: info` for one strict-casts finding in `test/calendar/header_test.dart` (raw `List` parameter). Findings by owner: `scrum/sprints/sprint008/analyzer_findings.md` (Sprint 009). Trivial fixes done in Tanaka's files only.
- `event_details.dart`: not changed for `eventTextColorOn`. The details panel has no event-colored fill (text sits on `tokens.soft` in neutral token styles, already readable), so there is no chip fill to derive from. THM-10.h is set to `planned` in `theme.md`, citing Ito's `test/events/event_text_contrast_test.dart`.
- UIC-45: set to `planned` in `common.md`, citing `test/calendar/settings_autosave_test.dart` (Yamamoto), `admin_test_data_test.dart` and `test/app/page_header_test.dart` (Nakamura).
# Sprint 008 handoffs

## Yamamoto to Nakamura (PBI-050)
- `settings_dialog.dart` now has its own back button (key `settings-back`, arb key `settingsBack`) in the left of the Settings dialog's own header row, and a Close button (`settings-close`). Both pop the dialog. A `PopScope` in the dialog runs the open pane's save for every way of leaving (back, Close, barrier) and a page change runs it too.
- General, Calendar and Theme are done (no Save buttons; Theme already applied at once). Sources/Feeds untouched.
- Admin pane: its buttons act at once, so it needs no save. If you want a hook anyway: `SettingsLeaveHook` (settings_dialog.dart) has `register(VoidCallback)`/`unregister`; the dialog owns one and passes it to panes. `SettingsAdminPane(controller:)` is unchanged; tell me if you want a `leave` argument added to the dialog's call.
- No header change is needed from `calendar_page.dart` for the dialog's back button; if the app header (UIC-14 left zone) must also carry it, that is your hook.
