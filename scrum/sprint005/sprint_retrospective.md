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
