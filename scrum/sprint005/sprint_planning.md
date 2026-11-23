# Sprint 005 Planning

**Approved and started on 2026-11-22.** Planned load is **47 points over up to five days**, matching [Sprint 003’s planned load](../sprint003/sprint_planning.md). The velocity ledger has no completed-points entry for Sprint 003.

Planning review by Scrum Master Takahashi, Product Owner agent Suzuki, and Developer Tanaka, using the project’s agent definitions. The Product Owner approved the sprint after reviewing the revised plan.

## Sprint goal

Keep event editing steady when notifications resize the popup, unify the Flutter theme, and improve how users manage and view their calendars.

## What

| Item | Work | Estimate |
|---|---|---:|
| PBI-020 · Event note jitter | Stabilize the note field when adding or removing a notification resizes the event popup. | 2 points |
| PBI-021 · Flutter color theming | Replace the old color requirements with a single Material 3 seed requirement. Generate both brightness variants with `ColorScheme.fromSeed(seedColor: const Color(0xFF93B4FF), brightness: brightness)` and use Flutter theme defaults and semantic roles for app colors. | 5 points |
| PBI-010 · Shared UI for existing screens | Responsive control zones, an accessible shared resize bar, shared Cancel/Save and confirmation, and consistent dialog controls. | 8 points |
| PBI-019 · Non-color theme components | Apply the active icon, sizing, spacing, shape, and interaction requirements to existing components, including reduced motion. | 7 points |
| PBI-016 · Calendar sizing | Implement the active CAL-04 requirements after the shared resize bar is available. | 8 points |
| PBI-015 · Remaining time-zone and header work | Persist the device's system or fixed time-zone preference, keep temporary calendar overrides independent, and wire the responsive header to the delivered controls. | 5 points |
| PBI-022 · Calendar Print Preview | Preview and print the current visible calendar period and view with active filters, time zone, and automatic orientation. Cancel returns to the unchanged calendar view. | 5 points |
| PBI-023 · Local calendar management | Provide a default local calendar, let users create and rename calendars, switch defaults, and safely delete calendars. Persist the changes and reflect them in the event editor and calendar filter. | 7 points |
| **Total** | | **47 points** |

PBI-020 through PBI-023 are proposed IDs. PBI-010 and PBI-015 are scoped slices. The print slice covers the visible period only. The local calendar slice covers device-local calendars. Estimates for the additional slices are provisional.

## How

The likely cause of the jitter is an intermediate fallback note height before the dialog measures its final layout. Reproduce it with a widget test that checks intermediate frames before changing the resize path. See the [draft sprint backlog](sprint_backlog.md) for the task breakdown and the [Definition of Done](../definition_of_done.md) for completion criteria.

Do the requested jitter and theming work first. Build shared controls before calendar sizing. Confirm the remaining time-zone behavior against the current Settings implementation before changing it, then wire Print Preview into the header. Review remaining scope against the five-day timebox after the shared controls are in place.

## Acceptance criteria

- On desktop and narrow layouts, adding or removing notifications yields the final layout without an intermediate note-field jump or oscillation. Note text, caret or selection, and unsaved edits survive the resize. Scroll moves only as needed to keep it within bounds or keep the focused field visible. Controls remain reachable in a short viewport.
- Light and dark themes both derive from `#93B4FF` via Flutter's `ColorScheme.fromSeed`. App-owned colors resolve through the active Flutter theme. The event color picker uses theme-derived choices, and the default comes from the active theme. Explicit colors already saved by users or supplied by external sources are preserved as data.
- Active requirements and backlog acceptance criteria retire the previous seed, fixed palettes and hex values, prescribed status hues, and custom color recipes. Non-color requirements on mixed rows are retained.
- Add a widget regression check for the notification resize and update affected theme and event tests, including saved and imported color round trips. Run Flutter analysis and tests, visually check the popup at desktop and narrow widths in both brightness modes, and record acceptance results and limitations in the Sprint Review.

## Product Owner changes

Sources, Feeds, All Rules, Event Templates and History belong in Settings. Sections show their bodies directly, and modules retain their fold behavior. Full page was retired. Use the supplied brightness-specific logo and web icons. The original point baseline remains the sprint comparison.
