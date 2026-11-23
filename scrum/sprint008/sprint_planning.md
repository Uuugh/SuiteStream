# Sprint 008 Planning

**Status: proposed, awaiting Kobayashi's plan review (before the sprint starts) and Product Owner approval.** Planned 2026-11-23 by Takahashi on branch `sprint008` (created from `main` at b672888 after the Sprint 007 retrospective was approved). Five days, **22 committed points**, no stretch.

Pre-check read: Sprint 007 retrospective, review and Kobayashi review; `product_backlog.csv`; `velocity.csv`; `usage.md`; `git-operation-policy.md`. Suzuki, Ito, Tanaka and Kobayashi were not run as separate sub-agents: the Product Owner set the scope; the orchestrator runs Kobayashi on this file. Velocity (26, 15, 32; Sprint 007 delivered 22 built, acceptance pending) is only a reference.

## Sprint goal

The Product Owner can read every event in every view and can configure and leave Settings the way the app should work: event text is readable on every palette color, multi-day events carry their start and end labels, Settings saves automatically and has a back button, the Theme pane is compact and grouped, popups animate in and out with the one animation time, and the team's review and static-analysis checks are stricter.

## Scope (22 points)

| PBI | Work | Points | Lead |
|---|---|---:|---|
| PBI-052 | Event text readable on pale colors (THM-10.h): text color derived from the chip fill, 4.5:1 in every view and print, tests over 11 event and 24 calendar colors in both brightnesses. High bug; PBI-034 is not accepted until this is fixed. | 3 | Ito |
| PBI-054 | New, slice 1 of PBI-040: CAL-09.c labels (18:00- first day, -04:00 last day) and EVT-03.b event color in Month, Week, 5-day, Day, List and print | 4 | Ito |
| PBI-050 | Settings auto-save and back button: one general UIC rule plus one SET row (no per-page Save rows); back button in the left header zone; invalid value not saved | 3 | Yamamoto |
| PBI-051 | Settings > Theme layout: press-and-hold moves from General to Theme, two columns (one when narrow), groups titled on a horizontal rule; SET-03.b and SET-09 merged | 3 | Yamamoto |
| PBI-046 | Popup open and close transitions on the one animation time (SET-03.g), shared in `showSuiteDialog` and popup menus; tested with intermediate frames; zero with reduced motion | 3 | Tanaka |
| PBI-053 | New, slice of PBI-045: Reset buttons use the delete/error-role look (one shared style); header zone fit as a common standard | 2 | Tanaka |
| PBI-047 | Kobayashi owns plan reviews and the every-fifth-retrospective audit: update the two skills and the Kobayashi role file | 2 | Yamamoto |
| PBI-048 | Stricter static analysis: strict modes and the listed lints; each owner fixes findings in their files | 2 | Tanaka |
| **Committed** | | **22** | |

### Split decisions (backlog changes)

- **PBI-045 (sized 8):** PBI-053 (2) is pulled. The remaining 6 (per-control sizes, state and status animations, delete-occupied-calendar, placeholder Settings panes) stay in the backlog as PBI-045, a Sprint 009 candidate.
- **PBI-040 (13):** split into slice 1 = PBI-054 (4, pulled); slice 2 = audit of the 47 rows against tests with CAL-04.d hour height and CAL-09.e/f marks (5); slice 3 = placeholders for rows that need other features (4). PBI-040 keeps the remaining 9 points.
- PBI-037, PBI-038, PBI-049 (Sprint 011), PBI-017 (blocked), PBI-031, 032, 024, 025 are not in this sprint.

### Why 22

Same as Sprint 007's commitment, with four developers. Every item is a small, mostly separable change. The heaviest risk is the PBI-048 lint churn across all owners' files (kept to 2 points by fixing only what the new rules report and justifying suppressions). If capacity runs short the **cut order** (first out first): PBI-053 header zone fit (keep the Reset look), PBI-048 lints beyond the three strict modes, PBI-054 print slice (keep the six views), PBI-047 skill wording polish.

## Usage

`usage.md`: last reading 53% session (the weekly reading was last recorded at 98% in sprint 003 and resets Wed 2026-11-25 17:00; the current weekly reading is unknown). Estimate for 22 points: about 25 to 30 session points (Sprint 007 estimates ran about 10 high), so the projected end is about 78 to 83%: above Caution (70%), below Warning (85%). Takahashi notifies the Product Owner of Caution; the Product Owner supplies a weekly reading before developers start. Agents commit at each task; at Warning running agents stop.

## Definition of Done for this sprint

Per `scrum/definition_of_done.md`:
- **Rows stay `planned` until the Product Owner verifies in the browser.** Completed points count only after that. A PBI is In Review, not Done, after the server checks.
- **PBI-034 (Sprint 007 palette) is not accepted until PBI-052 is fixed** and the Product Owner has seen readable text on pale colors in light mode.
- Each PBI cites its rows: PBI-052 THM-10.h; PBI-054 CAL-09.c, EVT-03.b; PBI-050 a new SET row and one UIC rule; PBI-051 SET-01.e, SET-03.b, SET-09 (merged); PBI-046 a UIC popup transition row and SET-03.g; PBI-053 the UIC/THM Reset and header-zone rows; PBI-047 and PBI-048 process rows in the skills and `analysis_options.yaml`.
- `flutter analyze lib test` clean under the stricter options; full `flutter test` (including `test/tool/req_coverage_test.dart`); web build; all text in the six arb files; no hardcoded sizes or colors outside tokens.
- The Review records server checks and visual checks separately.

## Process rules

1. **Kobayashi reviews this plan before the sprint starts** (the orchestrator runs the review: scope, capacity, availability and leave, file ownership, usage). Developers do not start until findings are resolved.
2. **One editor per file** (table below). A developer needing a change in another owner's file asks that owner through Takahashi. **No agent restores or checks out a file from HEAD while another agent owns it; ask the owner** (Sprint 007 lesson).
3. **Sprint branch:** all work on `sprint008`; commit and push after each wave and whenever tests are green; merge into `main` after the retrospective is approved.
4. **Kobayashi audit:** the every-fifth-retrospective audit (due now) runs after PBI-048 lands, in wave 3, so it uses the stricter analysis.
5. **Velocity row** is added only at the end of the sprint after the Review.
6. **Product Owner input during the sprint** is captured as next-sprint backlog, not built.
7. **Order gate:** Ito provides `eventTextColorOn(fill, brightness)` in `event_colors.dart` by day 1 hour 4; Tanaka's `event_details.dart` uses it only after that. Tanaka lands the new `analysis_options.yaml` on day 1 so owners see findings early but fix them in wave 3 after feature edits.

## File ownership (one editor per file)

| Owner | Files |
|---|---|
| Ito | `lib/src/theme/event_colors.dart` (text-color derivation); `lib/src/ui/color_picker.dart`; `lib/src/calendar/month_view.dart`, `week_view.dart`, `week_layout.dart`, `list_view.dart`, `event_drag.dart`, `event_dialog.dart`, `local_calendars_dialog.dart`, `local_calendar_store.dart`, `event_store.dart`, `calendar_print_dialog.dart`, `calendar_print_platform*.dart`; `lib/src/time/suite_event.dart`, `time_format.dart` (label text); `requirements/events.md`, `calendar.md`, `print.md`, the THM-09 and THM-10.h rows in `theme.md`; `test/events/*`, `test/calendar/views_test.dart`, `calendar_print_test.dart`, `local_calendar_test.dart`, `drag_test.dart`, new `test/events/event_text_contrast_test.dart`, `test/calendar/multiday_label_test.dart` |
| Tanaka | `lib/src/theme/tokens.dart`, `suite_theme.dart`, `theme_settings.dart`, `suite_icons.dart`; `lib/src/ui/*` except `color_picker.dart`; `lib/src/calendar/date_picker.dart`, `event_details.dart`; `lib/src/time/length_input.dart`, `time_input.dart`; `analysis_options.yaml`; `requirements/common.md`, `requirements/theme.md` (except THM-09 and THM-10.h); `test/ui/*`, `test/theme/*` (except `theme_mode_test.dart`) |
| Yamamoto | `lib/src/calendar/settings_dialog.dart`, `settings_calendar_pane.dart`, `settings_theme_pane.dart`, `calendar_defaults.dart`; all six `lib/src/l10n/app_*.arb`, `messages.dart`, `dates.dart`; `requirements/settings.md`, `shell.md`; `test/l10n/*`, `test/calendar/settings_*_test.dart`; `.github/skills/sprint-planning/SKILL.md`, `.github/skills/sprint-retrospective/SKILL.md`, `.github/agents/reviewer.kobayashi.agent.md` (PBI-047, reviewed by Takahashi) |
| Nakamura | `lib/main.dart`, `lib/src/app/*`; `lib/src/theme/theme_mode_controller.dart`; `lib/src/calendar/calendar_page.dart` (header zones, back-button support, header zone fit), `calendar_controller.dart`, `event_filter.dart`, `filter_panel.dart`, `swipe_detector.dart`, `settings_admin_pane.dart`; `lib/src/time/zones.dart`, `local_zone.dart`; `web/index.html`; `test/app/*`, `test/calendar/calendar_test.dart`, `header_test.dart`, `filter_test.dart`, `ux_test.dart`, `popup_size_test.dart`, `admin_test_data_test.dart`, `test_support.dart`, `test/theme/theme_mode_test.dart`, `test/time/*` |
| Takahashi | everything under `scrum/` |

Shared-file arrangements:
- **arb files:** Yamamoto only. Others send keys with English text (and a draft for the other locales) in `scrum/sprint008/strings_<name>.md` by hour 2 of day 1 and at the end of days 2 and 3. No `orElse` English fallbacks and no `TODO(arb)` shims (Kobayashi's Sprint 007 finding); the key-exists test must pass.
- **Reset buttons:** Tanaka provides the shared Reset button style (error role) in `lib/src/ui`; Yamamoto uses it in the Theme pane.
- **Back button:** Yamamoto builds it in `settings_dialog.dart` (left header zone, like the Add event back arrow); header-zone fit in `calendar_page.dart` is Nakamura; the shared zone rule is Tanaka's (`common.md` row).
- **Lint fixes (PBI-048):** each owner fixes findings only in their own files; Tanaka sets the options and the rule that an `// ignore` needs a comment saying why.
- **Event text color:** Ito owns the derivation and applies it in all views and print; Tanaka applies it in `event_details.dart`.

## How: order of work

See `sprint_backlog.md` for task hours and owners.

- **Start order:** PBI-052 first (Ito, high bug); in parallel PBI-048 options (Tanaka), PBI-050 back button and PBI-047 edits (Yamamoto), header support (Nakamura); then the rest.
- **Day 1 (wave 1):** Ito: `eventTextColorOn` and the contrast test over all palette colors, then Month and Week. Tanaka: `analysis_options.yaml`, shared Reset style, transition definition in `showSuiteDialog`. Yamamoto: back button and auto-save rule, arb intake, PBI-047 edits. Nakamura: header support for the back button, header zone fit.
- **Days 2 and 3 (wave 2):** Ito: List, Day, 5-day, print and the CAL-09.c labels; Tanaka: popup menus transitions, `event_details.dart` colors, Reset look; Yamamoto: Theme pane layout and press-and-hold move, auto-save tests; Nakamura: tests and lint fixes in own files.
- **Day 4 (wave 3):** each owner clears lint findings in own files; cross-checks (every popup type animates, every view shows color and contrast); rows set with cited tests; final arb merge; input prepared for Kobayashi's every-fifth-retrospective audit.
- **Day 5:** `flutter analyze lib test`, full `flutter test`, web build; Product Owner walkthrough in the browser (rows stay `planned` until verified); Takahashi writes `sprint_review.md` and the velocity row afterwards.

## Risks

1. **Usage (medium):** projected end about 78 to 83% session; weekly unknown (98% at sprint 003; reset Wed 17:00). Mitigation: readings before start, commit per task, the cut order.
2. **PBI-048 churn (medium):** strict-casts, strict-inference, strict-raw-types and seven lints can touch many files across all owners and collide with feature edits. Mitigation: options land day 1, fixes on day 4 in own files only, no HEAD restores.
3. **Views share one set of files (medium):** PBI-052 and PBI-054 both change the view files; one owner (Ito) avoids conflict but makes Ito the busiest (7 points). Mitigation: the PBI-054 print slice is early in the cut order.
4. **Settings dialog is one file (medium):** PBI-050, PBI-051 and PBI-047 all belong to Yamamoto; sequence within one owner, back button first.
5. **Auto-save semantics (low):** invalid values must not be saved and must show their note; tested by leaving the page and closing Settings.
6. **Popup transitions and existing tests (low):** tests may rely on instant popups; Tanaka updates `test/ui` and asks other owners through Takahashi.
7. **Visual checks:** contrast, transitions and layout need the Product Owner in the browser; rows stay `planned`.
8. **Availability:** no leave reported to the Scrum Master; Kobayashi must confirm with the Product Owner. Yamamoto and Nakamura did not take part in planning (contract) and receive this plan as written.

## Product Owner decisions needed

1. Approve the 22-point commitment, the PBI-045 and PBI-040 splits, and the cut order.
2. Supply current session and weekly readings (the Caution level at 70% is projected to be crossed).
3. Confirm no developer leave this week.
4. Decide on PBI-034 acceptance after PBI-052 is fixed.
