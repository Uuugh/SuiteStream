# Sprint 008 Planning

**Status: replanned 2026-11-23 as the first slice of the Sprint 008-009 usage epic, applying Kobayashi's plan review (`kobayashi_plan_review.md`).** By Takahashi on branch `sprint008`. **8 committed points**, about 2 working days, no stretch. Under the Product Owner's rule (backlog-refinement "Epics split to fit usage", sprint-retrospective "Automatic completion inside a usage epic") this sprint and Sprint 009 complete and start automatically: no Product Owner approval between them, feedback after the epic.

The earlier 22-point plan (eight PBIs) would have ended above Warning (85%) from a 65% start. It is split: this slice and Sprint 009 together carry the same scope.

## Sprint goal

Event text is readable on every palette color, Settings saves automatically and has a back button, and the analyzer is stricter (options only).

## Scope (8 points)

| PBI | Work | Points | Lead |
|---|---|---:|---|
| PBI-052 | Event text readable on pale colors (THM-10.h): text color derived from the chip fill, 4.5:1 in the Week all-day bar, Month chip, List dot and bar (print: layout check only); tests over 11 event and 24 calendar colors in both brightnesses. High bug; PBI-034 is not accepted until this is fixed. | 3 | Ito |
| PBI-050 | Settings auto-save and back button, citing **UIC-45** (already in `common.md`; no new SET row). Back button in the left header zone of Settings. Saves on page change, on close and on the back button, in the General, Calendar, Theme and Admin panes; an invalid value is not saved and shows its note. | 3 | Yamamoto |
| PBI-048 | Stricter static analysis: `analysis_options.yaml` strict modes and the seven lints, plus one analyzer run whose findings are listed. Fixes go to Sprint 009 unless trivial. | 2 | Tanaka |
| **Committed** | | **8** | |

## Epic: Sprint 008-009 usage epic

Split to fit usage, not for size. The PBI rows are marked "Part of the Sprint 008-009 usage epic" in `product_backlog.csv`.

- Sprint 008 (this slice): PBI-052, PBI-050, PBI-048 options.
- Sprint 009 (starts automatically after the session window resets at 11:50 AM): PBI-051, PBI-046, PBI-053, PBI-054, PBI-047, the PBI-048 lint fixes and the Sprint 007 findings still open. See `scrum/sprint009/`.
- PBI-040 is now an epic (children PBI-054, PBI-055, PBI-056; PBI-055 and PBI-056 stay in the backlog). PBI-045 stays a story of the epic PBI-039 (6 points); PBI-053 is also a story of PBI-039.
- Usage-epic rules: at the end of each sprint in it, analyze and test, commit, push, merge into `main`, push `main`, create the next branch from the updated `main`, and start. A failing analyze or test run stops the run. Rows stay `planned` until the Product Owner verifies after the epic.

## Usage (re-anchored on 65%)

`usage.md`: last reading 65% session (resets 11:50 AM); weekly reading unknown. Calibration: about 4 session points per 100k agent tokens. Estimate for this slice: about 8 session points, so the projected end is about **73%**: above Caution (70%), below Warning (85%). Takahashi notifies the Product Owner of Caution and tells running agents to commit at each task; no Warning stop is expected. Sprint 009 starts only after the session reset (about 11:50 AM), from a low session reading. The weekly reading must be checked (98% at sprint 003; reset Wed 2026-11-25 17:00): if it is at Warning the run waits and asks.

## Definition of Done for this sprint

Per `scrum/definition_of_done.md`:
- Rows stay `planned` until the Product Owner verifies in the browser; a PBI is In Review after the server checks.
- Each PBI cites its rows: PBI-052 THM-10.h; PBI-050 UIC-45 (status set by Tanaka in `common.md`); PBI-048 `analysis_options.yaml`.
- `flutter analyze lib test` clean (the new rules produce a listed report; fixes follow in Sprint 009); full `flutter test` including `test/tool/req_coverage_test.dart`; web build; all text in the six arb files; no hardcoded sizes or colors outside tokens.
- Known limitations recorded: the Sprint 007 findings still open (English `orElse` fallbacks and the `TODO(arb)` shim, over-stated rows UIC-43, THM-10.d, SET-03.k, UIC-44 and DEF-01, SET-10 test names, tokens-only literals) are carried into Sprint 009.
- Testability: PBI-050 tests change a value, then leave by page change, by close and by the back button, in each of the four panes, and check it is stored; PBI-052 checks that the text color is derived from the chip fill in the Week all-day bar, Month chip and List dot and bar.

## Process rules

1. Kobayashi's plan review is applied here; the Product Owner's instruction is to follow the epic rules, so developers start without a further approval step.
2. **One editor per file** (table below). A developer needing a change in another owner's file asks the owner through Takahashi. No agent restores a file from HEAD while another owns it.
3. All work on `sprint008`; commit and push after each task when tests are green; the sprint completes automatically (see the epic rules).
4. Velocity row at the end of each sprint (also inside the epic).
5. Product Owner input during the epic is next-epic backlog, not built.
6. **Order:** (a) Nakamura's header hook for the back button (1 h, day 1) before Yamamoto's back button. (b) Ito's `eventTextColorOn(fill, brightness)` in `event_colors.dart` by day 1 hour 4 before Tanaka's `event_details.dart` use. (c) PBI-052 before PBI-054 (Sprint 009) because both edit `month_view`, `week_view` and `list_view`.

## File ownership (one editor per file)

| Owner | Files |
|---|---|
| Ito | `lib/src/theme/event_colors.dart`; `month_view.dart`, `week_view.dart`, `week_layout.dart`, `list_view.dart` and the other event view files; `requirements/events.md`, `calendar.md`, `print.md`; contrast tests. Ito sends the THM-10.h wording to Tanaka through Takahashi and does not edit `theme.md`. |
| Tanaka | `analysis_options.yaml`; `lib/src/theme/*` except `event_colors.dart` and `theme_mode_controller.dart`; `lib/src/ui/*` except `color_picker.dart`; `event_details.dart`; **`requirements/theme.md` (whole file, only editor) and `requirements/common.md`** (sets UIC-45 status from Yamamoto's tests; sets THM-10.h from Ito's text) |
| Yamamoto | `settings_dialog.dart`, `settings_calendar_pane.dart`, `settings_theme_pane.dart`, `calendar_defaults.dart`; all six arb files; `requirements/settings.md`, `shell.md`; settings tests |
| Nakamura | `calendar_page.dart` (header hook), `settings_admin_pane.dart` (Admin pane auto-save and leave), `main.dart`, `lib/src/app/*` and his other files |
| Takahashi | everything under `scrum/`; the skills and the Kobayashi role file (PBI-047, Sprint 009) |

Arb files: Yamamoto only; others send keys in `scrum/sprint008/strings_<name>.md` by day 1 hour 2. No `orElse` fallbacks or `TODO(arb)` shims.

## How

See `sprint_backlog.md` for tasks, hours and owners. Day 1: Nakamura hook, Ito `eventTextColorOn` and views, Tanaka options and analyzer run, Yamamoto back button and auto-save. Day 2: remaining views, Admin pane auto-save, tests, `event_details.dart`, rows. Then analyze, test, build, retrospective, automatic completion.

## Risks

1. Usage crosses Caution (about 73%); mitigation: slice kept small, commit per task, Warning not expected.
2. PBI-050 reaches four panes in three owners' files; mitigation: Nakamura edits only the Admin pane and header hook; order line (a).
3. Visual checks need the Product Owner after the epic; rows stay `planned`.
4. Weekly usage unknown; check before Sprint 009 starts.
