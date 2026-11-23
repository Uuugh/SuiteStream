# Sprint 007 Planning

**Status: proposed, awaiting Product Owner approval and Kobayashi review.** Planned 2026-11-23 by Takahashi after the Product Owner approved the Sprint 006 retrospective (commit 6299d34) and said "Start the next sprint". Five days, **22 committed points**, no stretch.

Pre-check read: Sprint 006 planning, backlog, daily scrum and the Sprint 005 carryover note; `product_backlog.csv`; `velocity.csv`; `usage.md`; the requirement rows cited below. Suzuki (PO), Ito, Tanaka and Kobayashi were not run as separate sub-agents: the Product Owner set the scope, and the orchestrator can run Kobayashi on this file. Velocity (26, 15, 32 accepted; 003 and 004 unknown) is only a reference.

## Sprint goal

The Product Owner can set up the calendar the way they want it to look and behave: events and calendars use the agreed Google color palette, Settings has its Calendar and Theme panes (Light / Dark / Match system, and a setting for every common UI element), every popup and every text box or dropdown looks the same everywhere, and test calendars can be added and removed from Settings > Admin so the Product Owner can review the app with real-looking data.

## Scope (22 points)

| PBI | Work | Points |
|---|---|---:|
| PBI-034 | Restore the event color palette: 11 event colors and 24 calendar colors in one shared picker, nearest-color mapping, EVT-03.i defaults; theme seed stays app-theme only (THM-09, UIC-10, UIC-20, EVT-03.i) | 5 |
| PBI-036 | Settings > Calendar (default event length with unit of time, default time, default time zone) and Settings > Theme (animation time moved from General, default theme setting); reconcile SET-03.c, SET-03.g, SET-10 | 3 |
| PBI-035 | Light / Dark / Match system icon menu like the view picker; saved on the device; no flash of another theme on start (SHL-03 to SHL-03.c) | 3 |
| PBI-041 | Settings > Admin at the bottom: Add test calendars (3 calendars, about 8 events each across November 2026, timed, all-day, multi-day, overlapping, some with reminders; adding twice does not duplicate), Remove test data (confirmation, removes only test calendars and their events), first-run automatic samples removed, all text in arb files | 3 |
| PBI-039 | Split into three testable slices (8 points): | |
| PBI-042 | Popup shadow as a common UI (UIC-43, THM-10.d; a test finds every popup type) | 2 |
| PBI-043 | One 34 px height for text boxes and dropdowns verified site-wide incl. reminder rows (THM-04.b, THM-01.e) | 3 |
| PBI-044 | Settings > Theme settings for common UIs (UIC-44, SET-03.e to SET-03.k: popup shadow, resize bar size, dropdown text size, date picker size, status chip time, animation time; DEF-01 defaults; Reset) | 3 |
| **Committed** | | **22** |

PBI-039's other items (per-control sizes, state and status animations, header zone fit standard, delete-occupied-calendar, placeholder panes) become PBI-045, a Sprint 008 candidate. PBI-037, PBI-038 and PBI-040 stay Sprint 008 candidates. PBI-017 stays blocked; PBI-031, 032, 024, 025 untouched.

Why 22: it is above the 17 of Sprint 006, but the tasks are small and mostly additive (a palette, panes, a menu, a data generator, tokens). The task total is about 80 hours (92 with the shared day 5 check) against about 80 net hours (four developers, five days, no leave reported to the Scrum Master; Kobayashi must confirm availability with the Product Owner). If it slips, the items in the cut order below move out, not the tests.

**Cut order if capacity runs short (first to go first):** PBI-044 controls for the lesser elements (keep popup shadow and animation time), PBI-041 admin pane polish, PBI-043 audit of non-event dialogs.

## Definition of Done for this sprint

Per `scrum/definition_of_done.md`, applied this way:
- Each PBI lists the requirement rows it delivers (PBI-034: THM-09, THM-09.a-b, UIC-10, UIC-10.a, UIC-20, EVT-03.i; PBI-035: SHL-03 to SHL-03.c; PBI-036: SET-03.c, SET-03.g, SET-10 reconciliation, new Calendar-defaults rows; PBI-041: a new Admin row in settings.md; PBI-042: UIC-43, THM-10.d, CAL-10.d; PBI-043: THM-04.b, THM-01.e; PBI-044: UIC-44, SET-03.e to SET-03.k).
- Every cited row has its `status` set and its test file cited in `requirements/*.md`, and the test passes (`flutter test`, including `test/tool/req_coverage_test.dart`). No row is marked done without a passing test.
- `flutter analyze` is clean; no new hardcoded paddings, sizes or colors outside the theme tokens; all text in the six arb files.
- The Review records server checks (analyze, tests, build) and visual checks (VS Code browser, with the Product Owner) separately. A PBI is **In Review**, not Done, until the Product Owner has verified it in the browser; completed points count only after that (lesson of IMP-002).
- Work is done in this sprint, not in the retrospective; the retrospective only reflects on it.

## Process rules

1. **Commit on retrospective approval (new rule):** when the Product Owner approves a sprint retrospective, the Scrum Master commits everything for that sprint (code, tests, requirements, scrum files) in one commit before the next sprint is planned. The Sprint 007 retrospective, once approved, ends with that commit.
2. **One editor per file** (table below). A developer who needs a change in another owner's file asks that owner (through the Scrum Master); nobody edits a file they do not own.
3. **Velocity row:** `velocity.csv` gets its Sprint 007 row only at the end of the sprint, after the Review.
4. **Usage:** `usage-now.json` has no readings (null, last written 2026-11-21) and the last recorded weekly reading was 98% (sprint 003); weekly reset is Wed 2026-11-25 17:00. `usage.md` says no job projected to end at 85% or above may start without the Product Owner's permission. The Product Owner must supply current session and weekly readings before developers start (see Risks).
5. **Order gate:** Tanaka's control-height token and theme-settings model (`tokens.dart`, `theme_settings.dart`) land by the end of day 1; Yamamoto's Theme pane and Ito's dialogs depend on them. If they slip, Yamamoto and Ito start on the parts that do not need them.

## File ownership (one editor per file)

| Owner | Files |
|---|---|
| Tanaka | `lib/src/theme/tokens.dart`, `suite_theme.dart`, new `theme_settings.dart`; `lib/src/ui/*` (`suite_dialog.dart`, `confirm.dart`, `cancel_save_pair.dart`, `suite_dropdown.dart`, `zone_picker.dart`, `popup_size_lock.dart`, `anchored_badge.dart`, `resize_bar.dart`, `overflow_info.dart`, `zoned_row.dart`, `stepper_arrows.dart`); `lib/src/calendar/date_picker.dart`, `event_details.dart`; `lib/src/time/length_input.dart`, `time_input.dart`; `requirements/common.md`, `requirements/theme.md` (except the THM-09 rows); `test/ui/*`, `test/theme/*`, new `test/ui/control_height_test.dart` |
| Ito | `lib/src/theme/event_colors.dart`; new `lib/src/ui/color_picker.dart`; `lib/src/calendar/event_dialog.dart` (incl. reminder rows), `local_calendars_dialog.dart`, `local_calendar_store.dart`, `event_store.dart`; `requirements/events.md`, `requirements/calendar.md`, the THM-09 rows in `theme.md`; `test/events/*`, `test/calendar/local_calendar_test.dart` |
| Yamamoto | `lib/src/calendar/settings_dialog.dart` (becomes the pane host), new `settings_calendar_pane.dart`, `settings_theme_pane.dart`, `calendar_defaults.dart`; all six `lib/src/l10n/app_*.arb` (key intake, below); `requirements/settings.md`, `requirements/shell.md`; `test/l10n/*`, new `test/calendar/settings_*_test.dart` |
| Nakamura | `lib/main.dart`, `lib/src/app/bootstrap.dart`; new `lib/src/theme/theme_mode_controller.dart`, `lib/src/calendar/settings_admin_pane.dart`, `lib/src/app/test_data.dart`; `lib/src/calendar/calendar_page.dart` (header theme menu), `calendar_controller.dart`; `web/index.html`; `test/app/*`, new `test/calendar/admin_test_data_test.dart`, `test/theme/theme_mode_test.dart` |
| Takahashi | everything under `scrum/` |

Shared-file arrangements:
- **arb files:** edited by Yamamoto only. Each developer sends Yamamoto a list of keys with English text (and a draft for the other locales) in `scrum/sprints/sprint007/strings_<name>.md` by the end of hour 2 of day 1, and again at the end of days 2 and 3. Yamamoto merges them and runs the l10n generation. Until merged, developers use placeholder constants behind a single `TODO(arb)` line. (Takahashi creates no code; the strings files are scrum notes.)
- **`settings_dialog.dart`:** Yamamoto splits it into pane files on day 1 (hours 1 to 3). Nakamura creates `settings_admin_pane.dart` with an empty `SettingsAdminPane` widget in the first 30 minutes so Yamamoto can reference it; it is Nakamura's from then.
- **`calendar_page.dart`:** only Nakamura (header menu). Popup shadow (PBI-042) is applied through the shared theme and Tanaka's own files; a one-line change in a file Tanaka does not own is requested from its owner.
- **`requirements/theme.md`:** Tanaka for all rows except THM-09 (Ito).

## How: order of work

See `sprint_backlog.md` for task hours and owners.

- **Day 1, in parallel:** Tanaka: tokens (control height, shadow, theme-settings model). Ito: palette model and nearest-color mapping, picker widget. Yamamoto: pane split, `calendar_defaults.dart`, arb intake. Nakamura: empty admin pane, `ThemeModeController`, test-data generator, `web/index.html` early-theme script.
- **Days 2 and 3:** integrations: Ito into the event and calendar dialogs; Yamamoto fills the Calendar and Theme panes (needs Tanaka's model and Nakamura's controller); Nakamura header menu and admin pane; Tanaka applies shadow and height across `ui/` and writes the site-wide height test.
- **Day 4:** cross-checks (reminder rows, all dialogs at 34 px, shadow on every popup), requirement rows set with cited tests, final arb merge.
- **Day 5:** `flutter analyze`, full `flutter test`, web build; Product Owner walkthrough in the VS Code browser; Review with server and visual checks separate. Takahashi writes `sprint_review.md`; the velocity row is added only after.

## Risks

1. **Claude usage limits (high):** earlier sprints were cut by limits (sprint 003); weekly was 98% at the last reading and the reading file is empty. Mitigation: Product Owner readings before start; developers commit work at each task; the cut order above.
2. **Shared files:** `settings_dialog.dart`, the arb files and `suite_theme.dart` are touched by several features. The pane split and the key-intake process remove the overlap; the cost is a handoff delay of up to a few hours on day 1.
3. **PBI-043 reach:** "site-wide" includes reminder rows (Ito's file) and time and length inputs (Tanaka's). The widget test must open every dialog; a dialog missed by the test is not verified.
4. **PBI-041 and first-run samples:** removing sample data changes `bootstrap_test.dart` expectations; adding twice must not duplicate (stable test ids); Remove deletes by test calendar id only, never user events.
5. **PBI-034 sync mapping:** nearest-color mapping for Google sync has no sync target yet; verified by unit tests on the mapping only.
6. **Theme flash on start (PBI-035):** an early script in `web/index.html` reads the saved choice before Flutter starts; it is browser-only, so a visual check is required.
7. **Capacity at or over full:** about 80 to 92 task hours against about 80 net hours (Claude developers have exceptionally high productivity, but this is the tightest point of the plan; the cut order applies); no known leave, to be confirmed.
8. **Kobayashi review pending**, including availability.

## Product Owner decisions needed

1. Approve the 22-point commitment and the cut order.
2. Supply current session and weekly usage readings (usage.md levels).
3. Confirm no developer leave this week.
4. Confirm the team may choose the test calendar names and colors (default: Work, Family, Travel, with three different calendar palette colors).
