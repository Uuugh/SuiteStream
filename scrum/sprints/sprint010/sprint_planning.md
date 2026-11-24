# Sprint 010 Planning

**Status: running.** The Product Owner said "start sprint 10" and "wrap everything into sprint 10". Branch `sprint010` (not an epic: no merge to `main`; the Product Owner approves the retrospective, then Takahashi merges). Rows stay `planned` / In Review until the Product Owner verifies in the browser.

## Sprint goal

The Product Owner sees a tidy Settings dialog, events in their chosen color in every view, correct press-and-hold and status-word timing, clean labels and title bar, plus the first running pieces of the single Docker stack (app, Postgres, Authentik, Watchtower) with settings stored in the database through an API.

## Scope

| Wave | PBI | Work | Points | Owner |
|---|---|---|---:|---|
| 0 (done) | DEF-01 fold | Suzuki: one storage rule in DEF-01, duplicates folded, new rows (CAL-12, CAL-09.g, SET-03.m, SET-01.f/g, SHL-01.h); Authentik and Watchtower rows (DEP, ACC, DIA); PBI-063; CSV row 8 fixed | 3 | Suzuki, Takahashi |
| 1 | PBI-057 | Settings layout: no resize bar; Reset inline with Close with icon; General, Theme, Admin at bottom of the left menu under an hr | 3 | Yamamoto |
| 1 | PBI-058 | Press-and-hold 0.2 s first press; status word time 1 s setting (constants in `calendar_defaults.dart`) | 3 | Yamamoto (setting), Nakamura (controller, first press), Tanaka (CancelSavePair), Ito (drag) |
| 1 | PBI-059 | Event fills with its color in Week, 5-day, Day, List, Month; test per view fails on gray | 3 | Ito |
| 1 | PBI-060 | Drag bottom edge to change end time (CAL-12) | 5 | Ito |
| 1 | PBI-061 | Title bar without background color; light and dark test | 2 | Nakamura |
| 1 | PBI-062 | Dash only when the event spans midnight in the shown zone (CAL-09.c, CAL-09.g) | 2 | Ito |
| 1 | Defects | Header zone scroll below 320 px (UIC-14 step 3); info popover close transition; 26 px literal in `event_dialog.dart` | 3 | Tanaka, Ito |
| 2 | PBI-063 | Stack: lightweight app image (serves web build and API), Postgres, Authentik, Watchtower; `server/` Dart API; sign-in through Authentik (OIDC); tests on local fakes | 8 | Nakamura |
| 3 | PBI-037 | Settings load and save through the API; header view and filter stay on the device | 8 | Yamamoto, Tanaka, Nakamura |
| 4 | Reviews | Kobayashi plan review; fifth-retrospective audit; cheap findings fixed | 3 | Kobayashi |

## Order

Wave 0 requirements first. Wave 1 in parallel (one editor per file; the shared constants in `calendar_defaults.dart` are already in place). Wave 2 starts after wave 1 is green; wave 3 after wave 2. Commit and push after every wave. Audit after wave 3, then review and retrospective draft.

## File ownership (one editor per file)

| Owner | Files |
|---|---|
| Ito | `week_view.dart`, `month_view.dart`, `list_view.dart`, `week_layout.dart`, `event_drag.dart`, `event_dialog.dart`, `event_colors.dart`, `lib/src/time/*` (labels), `requirements/calendar.md`, `events.md`, `print.md`; tests for views, resize, labels |
| Tanaka | `lib/src/theme/*` (except `event_colors.dart`, `theme_mode_controller.dart`), `lib/src/ui/*`, `event_details.dart`, `requirements/theme.md`, `common.md` |
| Yamamoto | `settings_dialog.dart`, `settings_*_pane.dart` (except admin), `calendar_defaults.dart`, six arb files, `requirements/settings.md`, `shell.md`, settings tests |
| Nakamura | `lib/main.dart`, `lib/src/app/*`, `calendar_page.dart`, `calendar_controller.dart`, `settings_admin_pane.dart`, `server/`, Docker files, `requirements/deployment.md`, `account.md`, `diagnostics.md`, `connections.md` |
| Takahashi | everything under `scrum/` |
| Kobayashi | `scrum/sprint010/kobayashi_*.md` only (reports) |

Arb: Yamamoto only; others send keys in `scrum/sprint010/strings_<name>.md`. Tokens only; one 34 px single-line control height.

## Usage

Session 18% and weekly 20% at the start (Product Owner reading). Estimate 0.5 to 0.8 % per minute of active work; Caution (70%) is reported in the final summary; stop only at a real reading of 85%.

## Risks

1. The stack cannot be run here (no Docker, no Authentik): tests use fakes; "not verified" is said plainly in the review.
2. Press-and-hold constants moved to `calendar_defaults.dart` by Takahashi before wave 1 (done, analyze clean).
3. Many agents on `settings_*` and controller: handoffs in `handoffs.md`.

## Plan review response (Takahashi, 2026-11-23; findings in `kobayashi_plan_review.md`)

Accepted and applied (no re-review needed for wording; a second review runs at the audit):
1. **Dates and capacity (1, 12):** Sprint 010 runs 2026-11-23 to 2026-11-27 (five days). Day 1 wave 0 and wave 1; day 2 wave 1 finish, audit, wave 2a; day 3 wave 2b (stack files, marked not verified); days 4 and 5 wave 3, review, retrospective. Developers are agents working in parallel; hours are estimates, capacity is limited by usage rather than hours. Points are not claimed as velocity until the Product Owner accepts. Wave 0 and reviews carry no points.
2. **PBI-063 split (8):** 063a (Dart API in `server/`, Authentik OIDC client and a fake provider, tests; Nakamura) is built and tested; 063b (Dockerfile, compose with app, Postgres, Authentik and its Redis if the pinned Authentik version needs it, Watchtower, `.env.example`, README) is written but **not verified** (no Docker or Authentik here). New packages are listed in `handoffs.md` and pinned in `pubspec.yaml` / `server/pubspec.yaml` before use.
3. **Ownership (4 to 6):** `calendar_controller.dart` stays Nakamura's; the status word time lives in `calendar_defaults.dart` (Yamamoto), not in the controller, so no second editor; Yamamoto asks Nakamura by handoff for any controller change. `theme_settings.dart` is Tanaka's; PBI-037 theme storage is Tanaka's task. Every other file under `lib/src/calendar/` not named above belongs to Nakamura; test files belong to the owner of the feature under test (new files to their author). `reset_button.dart` and `suite_dialog.dart` are used by Yamamoto, not edited; a needed change comes by handoff. PBI-058: Ito only removes any use of the moved constants (done by Takahashi); no Ito task. Status word scope: Tanaka defines `SuiteStatusWordScope` (a `Duration`) in `lib/src/theme/suite_theme.dart`; Nakamura wraps it in `main.dart`; Yamamoto's SET-03.m sets it through the pane. Names are fixed here, not "agreed later".
4. **Order (7):** Ito does PBI-059 before PBI-060 (same file `week_view.dart`). PBI-058 chain: Tanaka's scope first (hour 1), then Yamamoto and Nakamura. PBI-037 API contract: `GET /api/settings` and `PUT /api/settings` returning and taking one JSON object keyed by setting name; Nakamura publishes it in `handoffs.md` before wave 3.
5. **PBI-037 (9):** device fallback when the API is unreachable or the user is not signed in (settings stay on the device, then are sent on the next successful call); a requirement row and a test; Nakamura owns the store layer (`lib/src/app/settings_api.dart`), Yamamoto and Tanaka only call it.
6. **Coverage (10):** Yamamoto creates `settings_layout_test.dart`; Ito creates `event_resize_test.dart` including CAL-12.e/f and the interplay with press-and-hold drag; the resize bar setting stays for the resize bars that remain (event dialog); the ACC rows used by the API are tested on fakes only and marked so.
7. **DoD (11):** new dependencies are named in `handoffs.md` with pinned versions; a README for the stack is part of 063b.
8. **Audit (12):** Kobayashi's audit runs right after wave 1, fixes land in wave 2.
9. **CSV (3):** PBI-063 and PBI-037 set to sprint 010; PBI-058 wording updated.
