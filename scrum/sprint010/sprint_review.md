# Sprint 010 Review (2026-11-23)

Not a usage epic; branch `sprint010` is not merged until the Product Owner approves the retrospective. All rows stay `planned` / In Review until the Product Owner verifies in the browser.

| PBI | Result | Status |
|---|---|---|
| PBI-057 Settings layout | No resize bar is drawn in the dialog (guard test; nothing in `lib/` draws one: see question 1); Reset sits beside Close with an icon (Theme page only); menu: Calendar, Sources, Feeds, All Rules, Event Templates, History, then a rule, then General, Theme, Admin; narrow widths scroll the menu. Tests at 320, 400, 800 px. | In Review |
| PBI-058 timing | Press-and-hold default 0.2 s and "Saved or Cancelled shown" 1 s (Theme setting SET-03.m) now live in `calendar_defaults.dart`; `CancelSavePair` reads the setting live. The slow first press did NOT reproduce in widget tests (`first_press_test.dart`); the drag ghost was made lighter (suspected first-use cost); needs the Product Owner's browser check. | In Review (cause not proven) |
| PBI-059 gray events | Week, 5-day, Day, List and Month fill with the event color and readable text; one test per view (light and dark) fails on gray or a tint. Month chips changed from an 18% tint to the full color per EVT-03.b. | In Review |
| PBI-060 resize | Bottom-edge handle in Week, 5-day, Day (CAL-12.a to f); 14 tests; does not conflict with press-and-hold move. | In Review |
| PBI-061 title bar | AppBar uses the page color, no tint; light and dark test. | In Review |
| PBI-062 labels | Dash only across midnight in the shown zone; List no longer shows start-end for single-day events; print too; zone-move tests both ways. | In Review |
| Defects | ZonedRow ends text with a triple dot (no scroll below 320 px); info popover has a close transition; the 26 px literal is the token `suiteCompactIconBox`; CSV row 8 fixed. | In Review |
| DEF-01 fold | One storage rule; about 20 device-storage rows reworded; new rows SET-03.m, SET-15, CAL-12, CAL-09.g, SET-01.f/g, SHL-01.h; defaults 0.2 s and 1 s. ACC rows say Authentik does the sign-in (list in `handoffs.md` and the Suzuki report). | In Review |
| PBI-063 stack | `server/` Dart API (health, me, settings, Authentik OIDC code flow with PKCE, sessions, memory and Postgres stores) with 27 tests on a fake provider; Dockerfile, `docker/docker-compose.yml` (app, Postgres, Authentik, Watchtower), `.env.example`, README written. | In Review (partly built) |
| PBI-037 settings in the database | `SettingsSync` (pull at start, debounced push, device fallback, retry), allowlist of Settings keys, header keys never sent, General status row with Sign in, `http` dependency; 6 + UI tests on mock clients. | In Review (partly built) |

## Verification

- Server checks: `flutter analyze lib test` 0 issues; `flutter test` 518 tests pass; `dart test` and `dart analyze` in `server/` pass (27 tests); `flutter build web --release --no-web-resources-cdn` succeeds (after `tool/update_icon_font.sh` added the Reset glyph).
- NOT verified (no Docker, Postgres or Authentik here): the Docker image build and stack start; the Postgres store (written against postgres 3.7.0, untested); a real Authentik login and logout; Watchtower's update; Redis need of the pinned Authentik tag; settings sync against the real server in a browser.
- Visual checks for the Product Owner (browser, hard-refresh): Settings dialog layout at narrow and wide widths and Reset beside Close; Theme page "Saved or Cancelled shown" and press-and-hold; first press-and-hold timing after a page load; Cancel/Save word time; events in color in Week, 5-day, Day, List, Month (light and dark); dragging an event's bottom edge; the title bar without a tint; labels with a changed display zone; header at 320 px; info popover close; the Reset glyph.

## Known limits and open defects

- First press-and-hold about 1 s: cause not found (see PBI-058).
- `flutter run` has no `/api`; sync is notConfigured there.
- Admin pane does not call the sync push yet; `localCalendars.v1` is not synced (Takahashi: not a Setting).
- New dependencies need Product Owner approval: app `http` 1.6.0; server shelf 1.4.3, shelf_router 1.1.5, shelf_static 1.2.0, postgres 3.7.0, http 1.6.0, crypto 3.0.7; Docker images (Authentik 2025.10.1 unchecked; Flutter, Dart and Watchtower unpinned).
- Logout does not end the Authentik session (ACC-02.c partly).
