# Sprint 005 Review (2026-11-22)

Sprint 005 started after Product Owner approval of a 47-point plan. The Scrum Master, Product Owner agent, and Developer contributed from the project’s role definitions.

| Item | Result |
|---|---|
| PBI-020 · Stable event notes | Adding or removing notifications lays out each size once and keeps the existing scroll viewport, text selection, and mouse focus. Regression tests sample intermediate frames at desktop/light and narrow/dark sizes. |
| PBI-021 · Flutter color theming | Light and dark schemes use seed `#93B4FF`. The picker uses scheme colors. Existing explicit event and imported colors survive edits and storage. The prior color requirements were retired from the active spec and backlog. |
| PBI-010 · Shared UI | Delivered a keyboard- and pointer-accessible resize bar, badge layout, improved responsive zones, a full-label popover, and shared dialog controls. General control overflow and post-action Cancel/Save feedback remain open. |
| PBI-019 · Non-color theme components | Delivered Material Symbols Rounded and shared geometry and popup, resize-toggle, and Save pulse motion that respects reduced-motion settings. Remaining theme rows are listed below. |
| PBI-016 · Calendar sizing | Calendar and hour heights persist in event-line units. The resize bar retains the active filters. |
| PBI-015 · Device time zones and header | Follow System and Fixed Time Zone are device settings. The calendar's temporary zone remains independent. The header includes Print Preview. |
| PBI-022 · Calendar Print Preview | Preview covers the visible view and period in the selected time zone and time format with active filters. Preview is available on native platforms. Browser printing uses the same snapshot on web. |
| PBI-023 · Local calendar management | Add, rename, choose a default, and delete empty calendars. The last calendar can be cleared with confirmation while keeping its identity. Deletion of other occupied calendars is disabled to protect events. |

## Carryover

- PBI-010 retains the general overflow behavior for arbitrary controls and the full Saved/Cancelled confirmation sequence. Existing text labels scale and expose full text through an accessible popover.
- PBI-019 retains remaining per-control size and spacing requirements, and the remaining state and status animations. Status/action and module animation rows also depend on their future screens.
- Full paper-range and Itinerary printing are in the follow-up print backlog. Native printing and deleting an occupied, non-last local calendar are outside the delivered paths.

## Sprint accounting

Suzuki accepted six items totaling 32 of 47 planned points during the Scrum review. The remaining 15 points for PBI-010 and PBI-019 returned to the product backlog. The Product Owner approved the sprint start and directed the scope changes below.

## Verification

- Flutter analysis reported no issues. The full suite passed 167 tests. The subsequent Settings navigation test and all five tests in its target file passed.
- The release web build succeeded. Edge smoke testing opened the note editor, added a reminder while preserving the typed note, opened Print Preview and rendered its browser print document to PDF.
- The local preview responded on port 8080. The supplied favicon, light and dark title-bar marks and Apple touch icon are built into the web output.
- Follow-up on 2026-11-23 found the VS Code integrated preview showing a blank page. Port 8080 served the rebuilt JavaScript after the restart, but rendering in that tab was not confirmed.

## Product Owner changes during implementation

Settings groups Sources, Feeds, All Rules, Event Templates and History. Sources opens local calendar management. The other destinations are visible and disabled until their features are implemented. The calendar uses the normal layout at every size. Section folding and Full page were retired. Module folding stays required. The header and web metadata use the provided brand assets.
