# Sprint 005 Retrospective

Completed 2026-11-23. The sprint closed with 32 accepted points out of 47 planned. PBI-010 and PBI-019 account for the 15 points returned to the backlog.

## What worked

- Checking intermediate frames made the note-resize regression observable. A final-frame assertion alone would miss the jump.
- Defining the shared resize control before calendar integration gave both changes a clear interface.
- The final test suite and release build caught regressions across changes that passed their individual checks.

## What to improve

- Parallel edits overlapped in the controller and dialog files. Review also exposed that the VS Code preview could load stale code or show a blank page while the build and server checks passed.
- The shared UI and theme estimates grouped work on existing screens with behavior that depends on future screens. That made it harder to judge what could be accepted independently.

## Actions for the next sprint

| Owner | Action | Checkpoint |
|---|---|---|
| Scrum Master | Assign one editor for each shared controller or dialog file and agree on integration points with the other developers. | Sprint planning |
| Product Owner and Developer | Refine PBI-010 and PBI-019 into independently testable changes and identify work that depends on future screens. | Backlog refinement |
| Developer | Prioritize PBI-026. The Product Owner was unable to verify Sprint 005 in the VS Code integrated browser. Restore the preview, verify it with the Product Owner, and record server and visual checks separately. | Next sprint planning |

## Product Owner feedback after Sprint 005 (2026-11-23)

The Product Owner reviewed the running app after the sprint closed. Sprint 005 was never verified in a browser before acceptance.

- Title bar: remove the background colour; trim the padding around the calendar title and the gap between the app bar and the calendar.
- Header: the right-zone icons are not evenly aligned (Sprint 005 shrank only some of them); keep them at one size, close together. The 12/24 badge inverts when 24-hour is on.
- Cancel | Save is one common element. It must be used in every dialog, with the action word substituted (Print for Save, No | Yes for questions). Print preview and Add calendar did not use it. An activated Save has a background, with a pulse that is a dimmer hover.
- Padding and margins are coded once in the theme and not hardcoded elsewhere, except to fix an alignment problem such as in Add/Edit event.
- Settings splits into a left menu and a right content pane, sized to hold the other sections.
- Month cells: date at top left, today as a small rounded badge in an outlined cell, events as rounded chips in their assigned colour (muted and struck through when hidden or deleted).
- The calendar resize bar requirement is removed and the bar no longer shows.
- Add/Edit event: more compact, with aligned text boxes, as in `sprint006/reference/add_event_target.png`.
- Process: code changes come from the developer agents through the sprint process, not from an ad hoc session.

## Status determined in the Sprint 006 retrospective (2026-11-23)

Six items were accepted, but only PBI-020 and PBI-015 are fully done; PBI-021, 016, 022 and 023 were changed or only partly delivered, and PBI-010 and PBI-019 were returned. Details and the carryover list are in [sprint005_status_and_carryover](../sprint006/sprint005_status_and_carryover.md). All unfinished Sprint 005 work is now Sprint 007 candidates.
