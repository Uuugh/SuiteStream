# Sprint 011 Review

Slice 1 of the ScrumBoard epic (PBI-049): PBI-077 to PBI-080, 8 points, all built and tested. Status In Review, pending the Executive.

## Server check (done by Nakamura and Takahashi, server on port 8081)

| Request | Result |
|---|---|
| `/` | 200 |
| `/main.dart.js` | 200 |
| `/canvaskit/canvaskit.wasm` | 200 |
| `/api/sprint` | 200 |
| Foreign `Host` header | 403 |
| Unknown path | 404 |

## Visual check (headless screenshot only)

`scrum/deliverables/scrumboard_sprint011_check.png` shows the three rows, the Backlog block and the Features column. This is not a browser check by a person.

## The Executive still must check in the browser

- Light and dark themes.
- Three window sizes (DEF-01 ScrumBoard sizes).
- Expand all (the switch at the right end of the filter row), and that the page opens collapsed.
- The feature, requirement and status filters and the shown-of count.
- Timeline opens at its right end once `scrum/sprint.md` exists (today there is no sprint file, so the timeline is empty).

## Not built this slice

SCB-06.b and 06.f, 07 to 10, 11.g to i, 12, 14, 16 to 18, the Issues and Questions columns, the messages endpoint (SCB-13.b rest). SCB rows built and tested are `planned` in `requirements/scrumboard.md`; the Executive's acceptance moves them to `done`.
