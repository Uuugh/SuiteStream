# Sprint 011 Backlog

Hours are estimates. Owner is the one editor (see `sprint_planning.md`). Done: the owner writes `x` when the task is finished. This is a process rule; the server counts nothing this sprint (SCB-12.e is PBI-085). Rows stay planned until the Executive verifies.

| Item | Task | Hours | Owner | Done |
|---|---|---:|---|---|
| PBI-077 | Set up `scrum/scrumboard` (Flutter web, no root dependency, analysis options); API client and fake; widget names in `handoffs.md` | 3 | Nakamura | x |
| PBI-080 | scb keys in the six arb files; `tool/sync_messages.sh`; loader `lib/src/l10n`; one key loads in a web build (wave 0 gate); test that the copies match their sources | 3 | Yamamoto | |
| PBI-077 | Server: 127.0.0.1, `--port`, `--progress`, `--root`; serves `build/web`; Host and Origin check; 404 for anything else; UTF-8; body limit; paths kept inside `--root`; no shell; tests SCB-13.a, SCB-13.b (slice), SCB-13.i, SCB-01.a | 5 | Nakamura | x |
| PBI-077 | Readers: requirements (SCB-03.a with `connections.d` and `plugins.d`, the three excluded files, blank status as backlog); sprint file read and write keeping unedited text (SCB-02.a-f); progress; usage (decision 3) | 6 | Nakamura | x |
| PBI-077 | README in `scrum/scrumboard` with the one start command | 1 | Nakamura | x |
| PBI-078 | `ScrumBoardPage`: three rows 40/20/40 with placeholders; each part scrolls on its own; theme from the THM-02 colors; tests SCB-15.a, SCB-15.b, SCB-15.c, SCB-01.g | 3 | Tanaka | |
| PBI-078 | Reload; load-failed message in each place; server-unreachable message; label scan test; tests SCB-01.c, SCB-01.f, SCB-13.h, SCB-01.d | 2 | Tanaka | |
| PBI-078 | DEF-01 rows in `common.md`: sub-requirement indent, ScrumBoard window sizes, request body limit | 1 | Tanaka | |
| PBI-079 | `BacklogTimeline`: Backlog block fixed at the left; the timeline scrolls under it and opens at its right end; equal widths with inner scroll; nesting; story members with ID and title; tests SCB-06.a, SCB-06.c, SCB-06.d, SCB-06.e, SCB-06.g | 6 | Ito | |
| PBI-080 | `FeaturesColumn`: rows with ID, status message, statement and feature; heading msg:scbRequirements; tests SCB-03, SCB-03.b, SCB-03.c | 3 | Yamamoto | |
| PBI-080 | Filters (choices in memory) and the shown-of count; outline with parent by ID prefix; triangles; expand-all switch; opens collapsed; tests SCB-04.a-d, SCB-11.a-f | 5 | Yamamoto | |
| PBI-077 | Wire both panes into `ScrumBoardPage` in `lib/main.dart`; integration test; sync messages; web build; server on 8081; server check | 2 | Nakamura | |
| PBI-077 | Security review of `bin/server.dart` (`watanabe_server_review.md`) | 1 | Watanabe | |
| All | Analyze and tests (scrumboard and root); AGENTS.md web-check line; visual check record; SCB status and test cells; review; retrospective; velocity | 3 | Takahashi | |
