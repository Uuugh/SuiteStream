# Sprint 008 Backlog

Replanned 2026-11-23: first slice of the Sprint 008-009 usage epic. Committed 8 points over about two days. Hours are estimates; no task is over 4 hours. Owner = the one editor of the files in `sprint_planning.md`. Rows stay `planned` until the Product Owner verifies in the browser after the epic.

| Item | Task | Hours | Owner |
|---|---|---:|---|
| PBI-052 | `eventTextColorOn(fill, brightness)` in `event_colors.dart`: text derived from the chip fill, 4.5:1 | 3 | Ito |
| PBI-052 | Apply in Month, Week, List, event chips and all-day bars; print layout check | 4 | Ito |
| PBI-052 | `event_text_contrast_test.dart` over 11 event and 24 calendar colors, light and dark; THM-10.h wording sent to Tanaka | 3 | Ito |
| PBI-052 | Apply the color in `event_details.dart`; set THM-10.h in `theme.md` (after Ito's function) | 1.5 | Tanaka |
| PBI-050 | Header hook for the back button in `calendar_page.dart` (first) | 1 | Nakamura |
| PBI-050 | Auto-save and leave behavior in `settings_admin_pane.dart` | 2 | Nakamura |
| PBI-050 | Back button in the left header zone of `settings_dialog.dart`; leaving saves the open section | 3 | Yamamoto |
| PBI-050 | Auto-save on page change, close and back button in General, Calendar and Theme; invalid value not saved and shown with its note | 4 | Yamamoto |
| PBI-050 | Tests per pane (change, leave three ways, check stored); arb intake for the back button label | 3 | Yamamoto |
| PBI-050 | Set UIC-45 status in `common.md` from the tests | 0.5 | Tanaka |
| PBI-048 | `analysis_options.yaml`: strict modes and seven lints | 2 | Tanaka |
| PBI-048 | First analyzer run: list findings by owner for Sprint 009 (trivial fixes only) | 1 | Tanaka |
| All | Analyze, full tests, build, retrospective, automatic completion | 3 | Takahashi |

## Hours by owner (about 20 h each is the net)

| Owner | Hours | Against 20 h |
|---|---:|---:|
| Ito | 10 | 50% |
| Yamamoto | 10 | 50% |
| Tanaka | 5 | 25% |
| Nakamura | 3 | 15% |
| Takahashi | 3 | |

The slice is small by design (usage, not hours). Nakamura takes the Admin pane and the header hook in his own files.

## Waves

1. Day 1: Nakamura header hook first; in parallel Ito (`eventTextColorOn`, views), Tanaka (options, analyzer run), Yamamoto (back button, auto-save).
2. Day 2: remaining views, Admin pane auto-save, `event_details.dart`, tests, rows, analyze, test, build; retrospective and automatic completion; Sprint 009 starts after the session reset.
