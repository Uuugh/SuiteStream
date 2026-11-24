# Sprint 012 Review

Slice 2 of the ScrumBoard epic (PBI-049): PBI-081 (drag and drop and status writes, requirements only), PBI-090 (heading), PBI-092 (shared filter bar). 8 points built; acceptance pending the Executive.

## Server check (recorded separately; done by Nakamura on a temp copy of requirements/, port 18431)
- backlog to planned: `{"ok":true}`, only that row's status cell changed.
- planned to proposed: refused with a reason. Foreign Host 403. Unknown path 404.
- Port 8081 was held by a server started at 9:09 PM before this session; not stopped, so the real page on 8081 still serves the old build until the Executive restarts it.

## Tests
- `scrum/scrumboard`: analyze 0 issues; 111 tests pass. Root: analyze 0 issues; 596 tests pass.

## Visual check the Executive must do (not done here; no browser)
Restart the server (README command), hard-refresh, then in light and dark at the DEF-01 sizes: (1) the Features column heading reads "Features & Requirements"; (2) long-press and drag a requirement from the Features column or the Backlog block onto a story: it turns planned and appears in the story; (3) drag it back to the Backlog block: status backlog; (4) a refused drop (for example a done item to Backlog) shows the refusal banner; (5) the Backlog block has the same filter bar as the Features column.

## Known limits
- SCB-07.c to h say "requirement or issue": only requirements are built (issues come with PBI-082 and PBI-094). SCB-07.a, b, i not built.
- The Members write and the status write are two calls; the board sends the Members write only after the status write succeeded (Ito).
