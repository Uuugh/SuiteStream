# Sprint 014 Review

Slice 4 of the ScrumBoard epic (PBI-049): PBI-102, PBI-103, PBI-104, PBI-106, PBI-107, PBI-108, PBI-109. All 7 built, 9 of 9 points; acceptance pending the Executive.

## Sprint goal (Takahashi)
- Met to the extent testable here. Definition of Done met except the Executive's browser checks and a real `usage.sh` run on the Executive's Windows machine (PBI-106).

## Demonstration (Ito, Tanaka)
- Each PBI shown by its named tests. Reported by Ito and Tanaka in the review (not recorded in a file): Ito re-ran three test files (34 tests pass), Tanaka five (88 pass).
- Verified counts, measured in `kobayashi_code_review.md`: 186 ScrumBoard tests and 596 root tests pass; analyze clean; web build done.

## Code review (Kobayashi)
- `kobayashi_code_review.md`: verdict revise. The must-fix (README) is fixed in 068d515. Findings 2 to 5 are low; recorded as PBIs.
- Sources of the new PBIs: code review findings 2 to 6 are PBI-110 to PBI-113 and PBI-117; PBI-114 comes from Suzuki's README audit; PBI-115 from Kobayashi's plan review note 17.
- The `scrum/scrumboard` README is still incomplete: it says the server writes only `scrum/sprint.md`, and its API table lacks `GET /api/changes`, `PUT /api/requirements/{id}/status` and `POST /api/requirements/{id}/retire`. Left to PBI-114.

## Stakeholder feedback (Sato): conditional accept
- Zoom: each half of the icon is a small click target. No PBI yet: it waits on Executive check 1.
- Features column: the backlog choice quietly removes the requirement from its story (PBI-108).
- Theme and zoom are kept per browser and address only.
- Value is polish and plumbing.
- Later: show the reason when usage fails.

## Decisions (Suzuki)
- All 7 PBIs stay In Review pending the Executive; none Done.
- New PBIs in `scrum/product_backlog.csv`: PBI-110 to PBI-117.

## How the sprint ran
- Planning and development days ran with roles collapsed (IMP-003); this review ran with separate role agents.
- GPT-5.5 and Opus 4.7 were not selectable, so Kobayashi and the others ran on the available opus model.
- Environment changes: the Executive set a pause at Sprint 015 (`scrum/order/order003.md`, 2026-11-24); no other changes.
- Usage note (`scrum/usage/usage.log`, sprint014 row): session 23 to 76 percent, week 49 to 56 percent for 9 points; 5.9 session points per story point, discarded as an outlier; the session is above the 70 percent Caution level.
- No cap on items In Review and no separate acceptance session were decided: both were proposed after the review and the Executive withdrew them.

## Checks the Executive must do (light and dark, hard refresh)
1. Zoom icon: both halves work at 80 %.
2. Status token at the row end, compared with `scrum/deliverables/scrumboard_mockup.png`, in light and dark.
3. Theme and zoom kept after a reload and after a server restart at the same address.
4. Features column backlog choice: see its effect (the Executive chose a visible effect, undo later with history; PBI-116).
5. A file change in the first seconds after a reload shows on the board.
6. Block widths look right.
7. PBI-106 against the real `usage.sh` on Windows (SCB-14.o).

## Executive check results (2026-11-24, after the sprint)

- Check 1 (zoom icon, SCB-20, SCB-20.a, PBI-102): good. The Executive wants the look changed to a boxed font size between minus and plus: PBI-123.
- Check 2 (status token, SCB-23, PBI-103): good. The Executive does not need the name after an ID: PBI-124.
- PBI-102 and PBI-103 accepted and moved to `scrum/product_backlog_done.csv`; SCB-20, SCB-20.a and SCB-23 set to `done`.
- Check 3 (theme and zoom kept, SCB-24, PBI-104): good. PBI-104 accepted and moved to `scrum/product_backlog_done.csv`; SCB-24 set to `done`.
- Still to be reported: Features column backlog choice (PBI-108), first change (PBI-107), block widths (PBI-109), real `usage.sh` (PBI-106).
