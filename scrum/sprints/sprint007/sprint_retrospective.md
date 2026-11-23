# Sprint 007 Retrospective (draft for Product Owner approval, 2026-11-23)

Approving this retrospective means: analyze and test, commit, push `sprint007`, merge it into `main` and push `main`, then start Sprint 008 on a new branch.

## Sprint result

Planned 22 points: PBI-034 palette (5), 036 Calendar and Theme panes (3), 035 Light/Dark/Match theme (3), 041 Admin test data (3), 042 popup shadow (2), 043 one 34 px control height (3), 044 Theme settings (3). Built in three waves by Ito, Tanaka, Yamamoto and Nakamura; Kobayashi reviewed (see `kobayashi_review.md`) and round 3 fixed his findings. `flutter analyze` is clean and 264 tests pass. Requirement rows stay `planned` until the Product Owner has verified in the browser.

| PBI | Result | Accepted? |
|---|---|---|
| 034 palette | Built (11 event, 24 calendar colors, picker, nearest color). Defect found: pale colors unreadable in light mode (PBI-052). | Product Owner to decide; recommend not yet |
| 035 theme choice | Built (menu, saved on device, early script). No-flash start needs a browser check. | Pending visual check |
| 036 panes | Built (Calendar with default length and unit, time, zone; Theme). | Pending |
| 041 Admin test data | Built (Work, Family, Travel; 24 events; remove asks first). | Pending |
| 042 popup shadow | Built, including the opened event in Week (round 3). | Pending |
| 043 control height | Built and tested site-wide (34 px). Reminder rows verified. | Pending |
| 044 Theme settings | Partly: six settings plus Reset; the rest is PBI-045. | Partly |

Points accepted are not recorded until the Product Owner decides. Server checks (tests, build, serve) are done; visual checks (the walkthrough) are not.

## What went well

- File ownership with one editor per file held; wave handoffs through `handoffs.md` worked.
- Kobayashi's first review found real gaps (hardcoded English fallbacks, overstated rows, an unbuilt shadow) and they were fixed in the same sprint.
- Rows stayed `planned` instead of `done`, so Sprint 005's false-done problem did not repeat.
- The icon-font build failure was found and fixed (new glyphs added to the font subset).

## What did not go well

- I (the orchestrator) built the Admin feature during the Sprint 006 retrospective and stopped an agent mid-work; the Product Owner corrected both. Rules now written into the role files.
- Planning skipped Kobayashi's plan review again; Takahashi planned alone.
- Tanaka overwrote Ito's unsaved edits to `color_picker.dart` by restoring from HEAD (two agents touched one file).
- Usage could not be read in the VS Code extension; estimates ran about 10 points high.
- An existing git policy (worktrees, template paths) was missed until late; now replaced by the sprint branch rule.
- Many Product Owner inputs arrived mid-sprint; all were captured as Sprint 008 backlog (PBI-045 to PBI-052) rather than built.

## Process decisions made this sprint (already written down)

- After a sprint, conversation is the retrospective; during a sprint, input is for the next sprint (role files).
- Each sprint runs on a branch `sprintNNN`; commit and push often; approval of the retrospective merges to `main` (planning and retrospective skills, Takahashi's role file, `scrum/git-operation-policy.md`).
- Kobayashi owns the every-fifth-retrospective audit using the `flutter-dart-code-review` skill (PBI-047 to finish the wiring).
- Usage is estimated from the last reading plus agent tokens when the status line file is stale (`scrum/usage.md`).
- Role files are in English.
- The ScrumBoard (SBD, imported from CalendarStream) is built in Sprint 011.

## Improvement actions

| Action | Owner | When |
|---|---|---|
| Kobayashi reviews each plan before the sprint starts | Takahashi | Sprint 008 |
| Run the every-fifth-retrospective audit (due now; Sprint 006 was the fifth) with stricter analysis first (PBI-048) | Kobayashi | Sprint 008 |
| Agents never restore a file from HEAD while another agent owns it; ask the owner | Takahashi | Sprint 008 |
| Settings auto-save, back button, Theme layout (PBI-050, 051) | Yamamoto, Tanaka | Sprint 008 |
| Event text contrast bug (PBI-052) | Ito | Sprint 008 (high) |

## Sprint 008 candidates (from Product Owner input)

PBI-045 remaining shared UI (incl. Reset buttons look), 046 popup transitions, 047 Kobayashi ownership, 048 stricter analysis, 050 Settings auto-save and back button, 051 Theme layout, 052 event text contrast; plus 037 (settings in the database), 038 (print), 040 (finish calendar requirements) as larger candidates.

## Definition of Done review

No change proposed. Reminder: a PBI is `Done` only after the Product Owner has verified it in the browser.
