# Sprint 009 Planning

**Status: planned, starts automatically** after Sprint 008 completes and the session window resets (about 11:50 AM). Second and last slice of the Sprint 008-009 usage epic; branch `sprint009` from the updated `main`. No Product Owner approval between Sprint 008 and 009 (backlog-refinement "Epics split to fit usage"); the Product Owner reviews after this sprint. Takahashi re-checks the usage reading and the Sprint 008 results when it starts and adjusts hours.

## Sprint goal

The Product Owner sees event labels and color in every view, a compact grouped Theme pane with Reset buttons in the error look, animated popups, and a clean stricter analysis.

## Scope (14 points plus named remainders)

| PBI | Work | Points | Lead |
|---|---|---:|---|
| PBI-053 | Part of PBI-039: Reset buttons in the error role (one shared style, new UIC row) and header zone fit (UIC-14 rule, test at narrow widths) | 2 | Tanaka |
| PBI-054 | Part of PBI-040: CAL-09.c labels and EVT-03.b event color in every view; case list in the PBI | 4 | Ito |
| PBI-051 | Settings > Theme layout: press-and-hold moves to Theme (stored in `calendar_defaults.dart`), two columns above a named width token, titled rules; tests at 320, 400, 800 px | 3 | Yamamoto |
| PBI-046 | Popup open and close transitions on the one animation time; new UIC row (Tanaka); each owner adds one call in their files | 3 | Tanaka |
| PBI-047 | Kobayashi ownership of reviews and audit: update the two skills and the role file | 2 | Takahashi |
| PBI-048 (remainder) | Fix the analyzer findings per owner (Ito capped at 2 h) | in the 2 points of PBI-048 | each owner |
| Sprint 007 findings | `orElse` fallbacks and `TODO(arb)` shim; over-stated rows (UIC-43, THM-10.d, SET-03.k, UIC-44, DEF-01); SET-10 test names; tokens-only literals | named tasks under 1 h each | Nakamura, Ito, Yamamoto, Tanaka |
| **Committed stories** | | **14** | |

Not in the epic: PBI-045 (6, story of PBI-039), PBI-055 (5) and PBI-056 (4) of the epic PBI-040, PBI-049 (Sprint 011), PBI-037, 038, 017, 031, 032, 024, 025.

## Order

1. Tanaka's shared Reset style (day 1) before Yamamoto's, Nakamura's or Ito's use of it.
2. PBI-052 (done in Sprint 008) before PBI-054.
3. Tanaka's transition API in `showSuiteDialog` before each owner's call (day 2).
4. Tanaka writes the popup-transition, Reset and header-zone rows before building.

## Usage

Starts after the reset, so the session begins low. About 14 points plus lint fixes: estimate about 16 to 20 session points (4 per 100k tokens), projected end about 25%, below Caution. The weekly reading must be checked first; at Warning the run waits and asks. Agents commit at each task.

## Ownership and arb

Same table as Sprint 008, one editor per file; `theme.md` only Tanaka; arb only Yamamoto. Cross-owner calls (popup transition, Reset style) are one call each in the owner's own files: Ito `event_dialog.dart`, `week_view.dart`, `local_calendars_dialog.dart` (1 h); Nakamura `calendar_page.dart` (1 h).

## Definition of Done

As Sprint 008. Rows stay `planned` until the Product Owner verifies after the epic; the retrospective and completion (commit, push, merge, push `main`) run automatically if analyze and tests pass. The epics PBI-040 and PBI-039 stay open (PBI-055, PBI-056, PBI-045 remain).

## Risks

1. Lint churn across all owners (medium): fixes in own files only, no HEAD restores.
2. Sprint 008 results unknown (low): the plan is adjusted at start.
3. View files shared by PBI-052 and PBI-054 (low): order line 2.
