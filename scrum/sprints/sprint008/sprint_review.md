# Sprint 008 Review (2026-11-23)

First slice (8 points) of the Sprint 008-009 usage epic. Completed automatically under the epic rule; the Product Owner reviews after the epic.

| PBI | Result | Status |
|---|---|---|
| PBI-052 event text contrast | `eventTextColorOn` in `event_colors.dart` (4.5:1, light and dark); applied to the Month chip and the Week all-day bar; test over all 35 palette colors (142 tests). Week timed block, List row and print use neutral text with a color strip or border, so unchanged. THM-10.h `planned`. | In Review |
| PBI-050 Settings auto-save and back button | Back button in the Settings header left; a page change, Close, the back button and the barrier save the open pane; invalid values are not saved; Save buttons removed from General and Calendar; Theme already applied live; Sources and Feeds untouched; Admin pane has nothing to save. UIC-45 `planned`. | In Review |
| PBI-048 stricter analysis | Strict modes and seven lints enabled at info severity; 252 findings listed by owner in `analyzer_findings.md` for Sprint 009. | In Review |

## Verification

- Server checks: `flutter analyze lib test` has 0 errors and 0 warnings (192 info lints from the new rules); `flutter test` passes 427 tests; `flutter build web --release --no-web-resources-cdn` succeeds.
- Visual checks: not done. The Product Owner verifies after the epic (pale colors readable in light mode; Settings back button and auto-save).
- Requirement rows stay `planned` until then.

## Known limits

- `event_details.dart` has no event-colored fill, so nothing to change there for THM-10.h.
- The new lints are at info severity until Sprint 009 fixes the findings.
