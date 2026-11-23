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

## From Nakamura to all (PBI-063a/b: server, API contract, new dependencies)

### New dependencies (`server/pubspec.yaml` only, pinned exactly; none added to the Flutter app)
shelf 1.4.3, shelf_router 1.1.5, shelf_static 1.2.0, postgres 3.7.0, http 1.6.0, crypto 3.0.7 (PKCE SHA-256); dev: test 1.33.0, lints 6.0.0. No JWT or OIDC library (userinfo endpoint is used). Docker images in `docker/docker-compose.yml` (not verified): postgres:16-alpine, ghcr.io/goauthentik/server:${AUTHENTIK_TAG} (example 2025.10.1, tag unchecked), ghcr.io/nicholas-fedor/watchtower:latest (unpinned; the old containrrr image is unmaintained), build images ghcr.io/cirruslabs/flutter:stable and dart:stable (unpinned). Product Owner approval of these is still needed (DoD).

### API contract (server in `server/`, tests `server/test/server_test.dart`)
Same origin as the web build; every call sends the browser cookie (`fetch` with `credentials: 'same-origin'`, the default). JSON in and out, `content-type: application/json`.
- `GET /api/health` (no sign-in): 200 `{"ok":true}`; 503 `{"ok":false,"error":"databaseUnavailable"}`. `/healthz` is an alias.
- `GET /api/me`: 200 `{"sub","name","email"}`; 401 `{"error":"signInAgain"}` when not signed in or the session expired.
- `GET /api/settings`: 200 one JSON object keyed by setting name (`{}` when nothing saved); 401 when not signed in.
- `PUT /api/settings`: body is one JSON object (replaces the whole stored object, so send every key; max 256 KB); needs `content-type: application/json`. 200 echoes the stored object; 400 `invalidJson` / `objectRequired`; 401; 403 when an `Origin` header differs from PUBLIC_URL; 413 `tooLarge`; 415 `jsonRequired`.
- Any API call while the database is down: 503 `{"ok":false,"error":"databaseUnavailable"}` (not a sign-in failure: keep the device copy and retry).
- Sign-in: navigate (not fetch) to `/auth/login?next=/path` (next must be a path on this site, else `/`). Authentik asks for credentials, then the browser returns to `next` with the cookie set. On failure it lands on `/?signInError=state|denied|refused|unavailable`.
- Sign-out: `POST` or `GET /auth/logout` clears the app session and redirects to `/` (the Authentik session stays).
- Cookie `ss_session`: HttpOnly, SameSite=Lax, Secure when PUBLIC_URL is https, lifetime SESSION_HOURS (default 24). The page cannot read it: ask `GET /api/me` to learn whether the user is signed in.
- Env: OIDC_ISSUER, OIDC_CLIENT_ID, OIDC_CLIENT_SECRET, PUBLIC_URL, DATABASE_URL, SESSION_HOURS, WEB_DIR (default build/web), PORT (default 8080).
- Run: `cd server && dart run bin/server.dart` (needs Postgres). The Flutter dev server has no `/api`: the client needs a base-URL setting or a proxy for `flutter run` (Nakamura, wave 3).

### Not verified / known gaps
Postgres store (no Postgres here), Dockerfile, compose, Authentik setup, Watchtower, the real Authentik discovery document. Logout does not end the Authentik session (ACC-02.c partial). ACC-02.a (unauthenticated page request redirects) is client work: the server serves the page, `/api/me` 401 tells the client to show the sign-in button. No refresh token, no per-user conflict rule: last PUT wins. DEP-01.e retry uses 2 s for 60 s until DEF-01 names values.

### CAL-09.c (print)
`calendar_print_dialog.dart` now prints the start time only for a single-day event (`multiDayLabel` otherwise); `calendar_print_test.dart` updated. Ito: cite it in CAL-09.c if wanted.

## From Yamamoto to Tanaka (single source for limits, DEF-01 rows, status chip)
- `lib/src/theme/theme_settings.dart` `ThemeSettingsLimits`: replace `statusChipMin` / `statusChipMax` with `minStatusWordTime` / `maxStatusWordTime` from `calendar_defaults.dart` (import it), or delete the status chip field of `ThemeSettings` (`statusChipTime`, `keyStatusChipMs`, `statusChipDefault`) and its tests in `test/theme/theme_settings_test.dart`: nothing reads it any more. The Settings > Theme pane no longer shows the Status chip time row (and `themeSettingStatusChipTime` is out of all six arb files); SET-03.j is now `backlog` until the UIC-28 chip exists. Also in `common.md`: the DEF-01 row "Status chip time (SET-03.j)" can become `backlog`-noted or be removed with the field.
- Animation time: `ThemeSettingsLimits.animationDefault` / `animationMax` and `suite_theme.dart:19-20` are two copies of one DEF-01 value; keep it in `suite_theme.dart` and make `ThemeSettingsLimits` point to it (the pane uses `ThemeSettingsLimits.animationDefault` and `.animationMax`; tell me if the names move).
- DEF-01 (`common.md`): settings.md SET-08 / SET-08.b / SET-08.c now say "the value in DEF-01" and cite the existing rows "Default event length" (1 hour, 5 minutes to 24 hours) and "New event start" (9:00). No new row needed, except optionally: "Arrow step, length" 15 minutes and "Arrow step, press-and-hold" 0.1 seconds (UIC-41 states them in prose, in your file).

## From Tanaka to Nakamura (PBI-037 key set), Yamamoto (limits done), all (wave 3)
- Nakamura: `const Set<String> themeSettingsPrefsKeys` in `lib/src/theme/theme_settings.dart` holds every theme key: `theme.popupShadow`, `theme.resizeBar`, `theme.dropdownText`, `theme.datePicker`, `theme.statusChipMs`, `view.animationMs` (shared with the calendar controller) and `theme.mode`. Pass it in `main.dart`. `test/theme/theme_prefs_keys_test.dart` writes every setter once and requires the written keys to equal the set. Not in the set: `timing.statusWordMs` (calendar_defaults.dart) and the calendar keys; add those yourself.
- Yamamoto: `ThemeSettingsLimits` now points at `minStatusWordTime`/`maxStatusWordTime` (calendar_defaults.dart) and `defaultAnimationDuration`/`maxAnimationDuration` (suite_theme.dart); names unchanged. I kept the status chip field (SET-03.j is backlog); its DEF-01 row is marked. Added DEF-01 rows "Arrow step, length" (15 minutes) and "Arrow step, press-and-hold" (0.1 seconds); UIC-41 now cites them. SET-08 needs no new row (rows exist).
- common.md: the 26 short rows have ` — |`; CAP-02 is now `backlog` (no test). DEF-01 names only the header controls (view, filter, header time zone, hour height) as exceptions and says settings are cached on the device until PBI-037.
- Removed `suiteListColorBar*` tokens. `semanticLabel` in `suite_dropdown.dart` reads arb key `itemSelected` (see `scrum/sprint010/strings_tanaka.md`; null until Yamamoto adds it).
- `CancelSavePair.debugHold` stays (comment says why: tests cannot pass a hold into dialogs built deep inside; `test/flutter_test_config.dart` zeroes it).
- `test/theme/material_button_gallery_test.dart` kept: it uses `matchesGoldenFile` against `goldens/cancel-save-material3.png`, so it fails when the picture changes.

## From Ito to Nakamura, Tanaka, Takahashi (print IDs, tokens, PBI-058 finding)
- Nakamura: `test/calendar/calendar_print_test.dart:19` still cites CAL-05 and CAL-05.a (moved; print rows are PRT, see `oldkey.md`): change the IDs in the test name to the PRT ones. Also still open from before: single-day events print "start – end", CAL-09.c says start only.
- Tanaka (token requests, Sprint 011, no existing token fits): `list_view.dart` day title padding top 10 and bottom 4, row horizontal 8, row vertical margin 1, time column width 120; `month_view.dart` week row vertical 6, cell padding 2, date row horizontal 6, chip margin vertical 1, chip horizontal 4, cell border 0.5 and 2 (focus/drop). Suggest `suiteListRowGap`, `suiteListTimeWidth`, `suiteMonthCellPadding`, `suiteChipPadding`, `suiteHairline`, `suiteFocusBorder`. Done now with existing tokens: list 12 -> `suitePagePadding`, 3 -> `suiteLabelGap`.
- `event_colors.dart`: English names removed (`PaletteColor` has no `name` field; names come from `messageKey` via `paletteColorName`; a `name` getter returns the key for test diagnostics, used by `local_calendar_test.dart:169`). CAL-03.d now cites `first_press_test.dart`.
- PBI-058 (for Takahashi): in my files and `swipe_detector.dart` there is no `delay`, `Future.delayed`, `kLongPressTimeout`, `kPressTimeout` or double-tap recognizer; `DragMovable` uses `LongPressGestureRecognizer(duration: widget.longPress)` (honored, fresh recognizer on a changed duration) plus a plain `TapGestureRecognizer` (no 300 ms wait). `SwipeDetector` has only a `Timer(holdTime)` (Nakamura; it is always passed `c.longPress`). So no code adds delay before the press starts. The one suspect left is first-use jank of the ghost: I replaced its `Opacity` layer and blur `BoxShadow` with `Material(elevation: suitePopupElevation)` (no saveLayer, no blur shader). The ghost is now fully opaque (was 0.9); the original is still dimmed to 0.35 (CAL-03.a). Needs a browser check on the first press.
- Tests tightened: `views_test.dart` marked month and picked day now compare the accent token; `event_dialog_test.dart` button checks use `isA<void Function()>()` (enabled vs null already asserted both ways).

## From Yamamoto to Nakamura, Tanaka, Takahashi (PBI-037 UI hooks, arb keys, l10n owner)
- Done with `SettingsSyncScope.maybeOf(context)?.push()` (helper `pushSettingsSync(context)` in `settings_dialog.dart`): Theme pane after each valid typed or stepped value, theme choice and Reset; Calendar pane after its save; the dialog on leaving a page and on close. `openSettingsDialog` re-wraps the scope it finds above its context into the dialog route. Admin pane is Nakamura's: call `pushSettingsSync(context)` (import `settings_dialog.dart`) or the scope directly after its changes. Header keys are not touched.
- Settings > General shows `SettingsSyncRow` (state word per `SyncState`, name via `sync.userName`, a Sign in button only when signedOut, opening `sync.signInUrl` with `launchUrl(..., webOnlyWindowName: '_self')`). Rows SET-15, SET-15.a; test `test/calendar/settings_sync_ui_test.dart` (subclass fake of `SettingsSync`). Nakamura: PBI-037 rows should say they depend on SET-15; I did not edit `deployment.md`.
- New arb keys in all six files: `itemSelected` (Tanaka's), `syncNotConfigured`, `syncSignedOut`, `syncSyncing`, `syncOk`, `syncOffline`, `syncSignIn`, `syncSignedInAs`. No strings_nakamura.md existed when I merged; the iframe title key is not added: put it in `strings_nakamura.md` and tell me.
- `lib/src/l10n/*` is mine from now on (Kobayashi assignment); Takahashi to confirm.

## From Nakamura to Yamamoto, Tanaka, Takahashi (PBI-037 settings sync, wave 3)

### New dependencies
App `pubspec.yaml`: `http: 1.6.0` (pinned, same as `server/`). Product Owner approval still needed (DoD).

### What exists
`lib/src/app/settings_sync.dart`: `SettingsSync` (`pull()`, `push()`, `state` as `ValueListenable<SyncState>` with notConfigured / signedOut / syncing / ok / offline, `userName`, `signInUrl`, `pending`), `settingsSyncBaseKeys`, `SettingsSyncScope.maybeOf(context)`. `main.dart` builds it (`SettingsSync.forPlatform`: same origin on the web, notConfigured elsewhere and in tests), calls `pull()` after `SharedPreferences.getInstance()` and before any model or the controller is built, and provides the scope. Server wins on pull, except when unsent device changes exist (pending flag, kept in prefs key `sync.pending`) or the server object is empty: then the device copy is sent. 401, 5xx, network failure and a 5 s timeout leave prefs untouched, set the state and keep the pending flag; the next `push()` or `pull()` retries. Test: `test/app/settings_sync_test.dart` (6 tests).

### Yamamoto (settings_dialog.dart and panes)
- After each settings change and on close call `SettingsSyncScope.maybeOf(context)?.push();` (debounced 0.8 s, one PUT of every allowlisted key; null-safe).
- General pane row: listen to `sync.state` (`ValueListenableBuilder`), show the state text, `sync.userName` when ok, and when `signedOut` a sign-in button that navigates to `sync.signInUrl` (`launchUrl(url, webOnlyWindowName: '_self')`). Hide the row when `maybeOf` is null or the state is `notConfigured`.
- Keys to add (strings_nakamura.md): settingsSyncOk "Saved to your account", settingsSyncSyncing "Saving", settingsSyncOffline "Saved on this device; will retry", settingsSyncSignedOut "Saved on this device; sign in to keep it on every device", settingsSyncSignIn "Sign in", settingsSyncSignedInAs "Signed in as {name}" (name placeholder). Also `calendarPrint` is reused for the print iframe title (key exists).
- Requirement row text (settings.md, yours): "SET-xx | planned | Settings are stored in the database through the API (DEF-01). When the API cannot be reached or the user is signed out, a settings change is kept on the device and sent on the next change or at the next start. The header controls (view, filter, header time zone, hour height) are never sent. | test/app/settings_sync_test.dart". Tests are named "PBI-037 ..."; rename to the SET id once chosen.

### Tanaka
`main.dart` passes `ThemeSettings.keyPopupShadow, keyResizeBar, keyDropdownText, keyDatePicker, keyStatusChipMs` (the public constants today). When `themeSettingsPrefsKeys` exists, tell me and I replace those five lines with it; any new theme key must be in that set or it is not synced. `view.animationMs` is already in the base set.

### Allowlist audit (every SharedPreferences key in lib/)
| Key | Owner file | Class |
|---|---|---|
| timing.statusWordMs | calendar_defaults.dart | setting |
| event.defaultLength, event.defaultLengthUnit, event.defaultStartMinutes | calendar_controller / calendar_defaults | setting |
| view.longPressMs, view.animationMs | calendar_controller | setting |
| view.timeFormat (TIM-10), settings.fixedZone (SET-02 Local zone) | calendar_controller | setting |
| theme.mode | theme_mode_controller | setting |
| theme.popupShadow, theme.resizeBar, theme.dropdownText, theme.datePicker, theme.statusChipMs | theme_settings | setting (passed from main) |
| view.mode, view.zone, view.hourLines | calendar_controller | header-device (never sent) |
| filter.hiddenCalendars, filter.hiddenStates | event_filter | header-device (never sent) |
| events.v1, localCalendars.v1 | event_store, local_calendar_store | data, not a Setting: not synced here (events and calendars in the database is a later PBI; Takahashi to decide whether Settings > Calendars content counts as a Setting under DEF-01) |
| sync.pending | settings_sync | internal, never sent |
Language is not stored in prefs (follows the device, SHL-02.a). Known limit: a double that the server returns as an int is applied as a double only when the device already holds a double (JSON on the web does not tell 1.0 from 1). `flutter run` has no `/api`: sync stays notConfigured off the web build; a base-URL setting for dev is not built.

### Audit cheap fixes done (Nakamura)
local_calendars_dialog.dart: English fallback removed (`m('calendarColor')`). Print iframe title: `printCalendarHtml(html, title)` (web and stub), the dialog passes `messages('calendarPrint')`. `SwipeDetector.holdTime` default removed (now required; the only caller passes `c.longPress`). `calendar_controller.dart:1` ignore kept with its reason (the constructor takes public named parameters for private fields, so initializing formals cannot be used; removing it gave 3 analyze infos).
