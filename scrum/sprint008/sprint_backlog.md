# Sprint 008 Backlog

Proposed 2026-11-23. Committed 22 points over five days. Hours are estimates; no task is over 6 hours. Owner = the one editor of the files in `sprint_planning.md`. All rows stay `planned` until the Product Owner verifies in the browser.

| Item | Task | Hours | Owner |
|---|---|---:|---|
| PBI-052 | `eventTextColorOn(fill, brightness)` in `event_colors.dart`: text derived from the chip fill, 4.5:1 | 3 | Ito |
| PBI-052 | Apply in Month, Week, List, event chips and all-day bars; print | 4 | Ito |
| PBI-052 | `event_text_contrast_test.dart` over 11 event and 24 calendar colors, light and dark; THM-10.h row | 3 | Ito |
| PBI-052 | Apply the color in `event_details.dart` | 1 | Tanaka |
| PBI-054 | CAL-09.c labels 18:00- first day and -04:00 last day (`time_format.dart`, views); `multiday_label_test.dart` | 5 | Ito |
| PBI-054 | EVT-03.b: event color in Month, Week, 5-day, Day, List and print with tests; rows set | 5 | Ito |
| PBI-050 | Back button in the left header zone of `settings_dialog.dart`; leaving saves the open section | 3 | Yamamoto |
| PBI-050 | Auto-save on page change and close; invalid value not saved and shown with its note; no Save on auto-save sections | 4 | Yamamoto |
| PBI-050 | One SET row and one UIC rule in `settings.md`; tests change a value, leave, and check it is stored | 3 | Yamamoto |
| PBI-050 | Back-button support in the header (`calendar_page.dart` hooks if needed) | 1 | Nakamura |
| PBI-051 | Move press-and-hold from General to Theme; merge SET-03.b and SET-09; SET-01.e reworded | 3 | Yamamoto |
| PBI-051 | Theme pane in two columns, one when narrow; groups titled on a horizontal rule | 5 | Yamamoto |
| PBI-051 | Tests and arb keys for group names; arb intake and final merge | 3 | Yamamoto |
| PBI-046 | Shared open/close transition in `showSuiteDialog` on the one animation time; zero for reduced motion | 4 | Tanaka |
| PBI-046 | Popup menus, pickers, palette, zone picker and event details use it; tests with intermediate frames | 5 | Tanaka |
| PBI-053 | Shared Reset button style (theme error role) in `lib/src/ui`; row | 2 | Tanaka |
| PBI-053 | Use it in the Theme pane Reset and every other Reset | 1 | Yamamoto |
| PBI-053 | Header zone fit as a common standard (`common.md` row, test at narrow widths) | 2 | Tanaka |
| PBI-053 | Header zone fit in `calendar_page.dart` | 2 | Nakamura |
| PBI-047 | Update sprint-planning and sprint-retrospective skills and the Kobayashi role file (plan review, audit step 8, fifth-retrospective audit) | 4 | Yamamoto |
| PBI-048 | `analysis_options.yaml`: strict modes and seven lints | 2 | Tanaka |
| PBI-048 | Fix findings in own files or justify each suppression | 3 | Tanaka |
| PBI-048 | Same, own files | 3 | Ito |
| PBI-048 | Same, own files (`main.dart`, `bootstrap.dart`, `calendar_page.dart` and others) | 3 | Nakamura |
| PBI-048 | Same, own files (settings panes, l10n code) | 2 | Yamamoto |
| All | Day 5: analyze, full tests, build, handoff for the Product Owner walkthrough | 4 | Takahashi |

Task hours by owner (PBI-048 fix tasks included): Ito 26, Tanaka 19, Yamamoto 28 (including PBI-047), Nakamura 6; Takahashi 4. About 79 developer hours against about 80 net (four developers, five days), but uneven: tight for Yamamoto and Ito, light for Nakamura: overflow tasks (lint help, header work) shift to Nakamura through Takahashi, and the cut order in `sprint_planning.md` applies. Kobayashi must confirm this load at the plan review.

## Waves

1. Wave 1, day 1, all four in parallel: Ito (`eventTextColorOn`, Month and Week), Tanaka (options, Reset style, transition), Yamamoto (back button, auto-save, PBI-047 edits), Nakamura (header support).
2. Wave 2, days 2 and 3: remaining views and print; popup menus and details; Theme pane layout; auto-save tests.
3. Wave 3, day 4: lint fixes in own files, cross-checks, rows and tests, arb merge, audit input for Kobayashi. Day 5: Review.
