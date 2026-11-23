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
