# Sprint 011 Planning

**Status: running.** The Executive said "do sprint 11", and that counts as the start (Kobayashi finding 12 is accepted this way). Branch `sprint011`. This is the first sprint of the ScrumBoard epic PBI-049 (children PBI-077 to PBI-088). It is **not** a usage-split epic: the Executive approves this sprint's retrospective before the next ScrumBoard sprint starts. The SCB rows this slice meets go to `planned` and stay there until the Executive verifies them in the browser.

## Sprint goal

The Executive starts the ScrumBoard with one command and opens 127.0.0.1:8081. The page has three rows. The top row has the Backlog block fixed at the left and the sprint timeline (read only) beside it. The bottom row has a Features column that lists every requirement as an outline the Executive can filter. Reload reads the data again, and the page says clearly when data cannot be read.

## Scope (8 points)

| Wave | PBI | Work | Points | Owner |
|---|---|---|---:|---|
| 0 | PBI-077 | Set up the standard Flutter web project `scrum/scrumboard` (lib, test, web, bin, tool). It has **no dependency on the root app**. Write the API client and its fake. Publish the fixed widget names in `handoffs.md` | (in 077) | Nakamura |
| 0 | PBI-080 | Add the scb keys to the six arb files. Write `tool/sync_messages.sh`, which copies `requirements/messages/*.arb` into `scrum/scrumboard/assets/messages/`. Write the ScrumBoard message loader `lib/src/l10n/*`. Gate: one key loads in a web build before wave 1 starts | (in 080) | Yamamoto |
| 1 | PBI-077 | Server `bin/server.dart`: serves `build/web` and the API on 127.0.0.1 with `--port` (default 8081), `--progress <dir>` and `--root` (the repo, default `../..`). Checks Host and Origin (SCB-13.a). Answers only the endpoints below and 404 for anything else (SCB-13.b, this slice). Answers in UTF-8 (SCB-13.i). Writes the sprint file back keeping the text it does not edit (SCB-02.a-f). Security rules below. Write the README with the one start command | 3 | Nakamura |
| 1 | PBI-078 | Page layout `ScrumBoardPage`: three rows of 40/20/40 (SCB-15.a). The middle row and the Issues and Questions columns are empty placeholders. Each part scrolls on its own (SCB-15.b) and nothing is clipped at the DEF-01 sizes (SCB-15.c). Reload (SCB-01.c). msg:scbLoadFailed in each place (SCB-01.f) and msg:scbServerUnreachable (SCB-13.h). A theme built from the THM-02 colors in `lib/src/theme/*` (SCB-01.g). New DEF-01 rows: sub-requirement indent, ScrumBoard window sizes, ScrumBoard request body limit | 1 | Tanaka |
| 1 | PBI-079 | `BacklogTimeline`: the Backlog block fixed at the left (SCB-06.a). The timeline scrolls sideways under it and opens at its right end (SCB-06.e). Every top-level block has the same width and scrolls inside (SCB-06.g). Blocks nest (SCB-06.c). A story shows each member's ID and title (SCB-06.d). Read only | 2 | Ito |
| 1 | PBI-080 | `FeaturesColumn`: SCB-03 and SCB-03.a-c. The feature, requirement and status filters with the shown-of count (SCB-04.a-d). The outline with triangles, the expand-all switch at the right end of the filter row, and the column opens collapsed (SCB-11.a-f) | 2 | Yamamoto |
| 2 | all | Nakamura wires `BacklogTimeline` and `FeaturesColumn` into `ScrumBoardPage` in `lib/main.dart` and runs an integration test. Then: sync messages, `flutter build web --release --no-web-resources-cdn` in `scrum/scrumboard`, start the server on 8081. The server check and the visual check are recorded separately | – | Nakamura (wiring, build, server check), Takahashi (records) |

Not in this sprint (the next stories of the epic):
- PBI-081 drag and drop
- PBI-082 issues
- PBI-083 add popup
- PBI-084 usage chart
- PBI-085 agent bars and block usage
- PBI-086 questions
- PBI-087 lifecycle buttons
- PBI-088 pointer actions and older sprints

PBI-076 is not in this sprint.

## Decisions (answers to Kobayashi's findings)

1. **Messages (finding 1).** The ScrumBoard reads arb copies from `scrum/scrumboard/assets/messages/`. Yamamoto's `tool/sync_messages.sh` makes the copies. Nobody edits a copy by hand, and the source stays the six arb files. The loader `lib/src/l10n/*` belongs to Yamamoto. There is no path dependency, so finding 10 no longer applies.
2. **Paths (finding 2).** This sprint uses `scrum/sprint.md` and `scrum/usage.md`, as PBI-049 says. The SCB-02 and SCB-14 rows still say `SCRUM.d/`. **Note for Suzuki:** change those two paths to `scrum/` before the review. Until then, tests that cite SCB-02 say "path per PBI-049".
3. **Usage endpoint (finding 2).** `GET /api/usage` returns the first table in `scrum/usage.md` whose header has the SCB-14.a columns. The file has no such table yet, so the answer is `{exists:true, rows:[]}`. A missing file gives `{exists:false, rows:[]}`. Nothing on the page shows usage this sprint.
4. **Integration (finding 3).** Nakamura owns the integration. The fixed names are `ScrumBoardPage({required Widget board, required Widget features})` (Tanaka), `BacklogTimeline(api:)` (Ito) and `FeaturesColumn(api:)` (Yamamoto).
5. **Sub-requirement parent (finding 4).** The parent comes from the ID: drop the last `.segment` (the parent of SCB-11.a is SCB-11). The client works it out, and the server adds no field.
6. **SCB-12.e (finding 5).** Owners mark Done with `x` as a process rule only. Nothing counts the marks yet, and SCB-12.e stays `backlog` (PBI-085).
7. **SCB-13.b (finding 6).** Its test cell will say "slice: read endpoints and sprint write; the rest 404"; Takahashi sets it.
8. **Coverage (finding 7).** New tests: an SCB-01.d scan that finds no string literal in a Text widget (Tanaka). SCB-03.a covering `connections.d`, `plugins.d` and the three excluded files (Nakamura). SCB-06.d (Ito). SCB-15.c at the DEF-01 window sizes (Tanaka).
9. **Security (finding 8).** The server:
   - listens on 127.0.0.1 only and checks Host and Origin;
   - limits the request body to the DEF-01 value;
   - resolves every path and refuses any path outside `--root`; the progress folder must exist;
   - runs no shell and no process;
   - holds no token or secret.

   Each rule has a test named after SCB-13.a, SCB-13.b or SCB-01.a. Watanabe reviews `bin/server.dart` in wave 2 and writes `scrum/sprint011/watanabe_server_review.md`.
10. **Documentation (finding 9).** Nakamura writes the README in `scrum/scrumboard` with the start command. Takahashi updates the web-check line in AGENTS.md with port 8081.
11. **Filter (finding 11).** The board builds its own filter in `lib/src/features`, with the UIC-21 behavior and look. Its choices stay in memory only and are not stored.
12. **Epic status (finding 13).** The value `Epic (split into ...)` is defined in the `backlog-refinement` skill and is used as written.
13. **Heading (finding 15).** The column heading shown is msg:scbRequirements. "Features" is only the layout name in SCB-15.a, so no extra key is added.

## API contract

All answers are JSON in UTF-8. An error is `{"error": "<reason>"}` with a 4xx or 5xx code. A wrong Host or Origin gets 403, an unknown path 404, and a body over the limit 413.

| Request | Answer |
|---|---|
| `GET /api/requirements` | `[{id, status, statement, feature, file}]`; a blank status is read as `backlog` (SCB-03.a, SCB-03.b) |
| `GET /api/sprint` | `{exists, blocks:[{id, kind, name, parent, assignee, estimate, usage}], members:[{block, item}]}` from `scrum/sprint.md` |
| `PUT /api/sprint` | the same shape. It is written at once and keeps the text it does not edit (SCB-02.d, SCB-02.f), and it creates the file when it is missing (SCB-02.e). No UI writes it this sprint |
| `GET /api/progress` | `[{label, done, total}]` from the `--progress` folder; empty when there are none |
| `GET /api/usage` | see decision 3 |

## Messages (SCB-01.d)

Every label is an arb key, with no English fallbacks. Only Yamamoto edits the six arb files.

Keys for this sprint:
- scbReload, scbLoadFailed, scbServerUnreachable
- scbRequirements, scbBacklog
- scbStatusProposed, scbStatusBacklog, scbStatusPlanned, scbStatusDone
- scbFilterFeature, scbFilterRequirement, scbFilterStatus, scbShownOf
- scbExpandRow, scbCollapseRow, scbExpandAll

Anyone who needs another key sends it in `scrum/sprint011/strings_<name>.md`.

## File ownership (one editor per file; paths under `scrum/scrumboard/` unless rooted)

| Owner | Files |
|---|---|
| Nakamura | `pubspec.yaml`, `analysis_options.yaml`, `README.md`, `web/*`, `bin/*`, `lib/server/*` (pure Dart), `lib/src/api/*`, `lib/main.dart`, `test/server/*`, `test/api/*`, `test/integration/*`, `build/` |
| Tanaka | `lib/src/app/*`, `lib/src/theme/*`, `test/app/*`, `requirements/common.md` (the DEF-01 rows) |
| Ito | `lib/src/board/*`, `test/board/*` |
| Yamamoto | the six arb files, `tool/sync_messages.sh`, `assets/messages/*` (generated), `lib/src/l10n/*`, `lib/src/features/*`, `test/l10n/*`, `test/features/*` |
| Watanabe | `scrum/sprint011/watanabe_*.md` only |
| Takahashi | `scrum/sprint011/*`, `scrum/product_backlog.csv`, `scrum/velocity.csv`, `scrum/usage.md`, `AGENTS.md` (the web-check line), the status and test cells of `requirements/scrumboard.md` |
| Kobayashi | `scrum/sprint011/kobayashi_*.md` only |

Only the server writes `scrum/sprint.md`; tests write temp copies. Handoffs go through `scrum/sprint011/handoffs.md`. Any new package is named in `handoffs.md` with a pinned version before it is used. Sizes come from theme tokens and colors from `ColorScheme`.

## Done

- Every test is named with its SCB ID, for example `SCB-13.a refuses a foreign Host`. In `scrum/scrumboard`, `flutter analyze` and `flutter test` pass. At the root, `flutter analyze lib test` and `flutter test` still pass.
- Owners mark the Done column with `x` (process rule, decision 6).
- **Server check:** the server starts with the README command on 8081, each endpoint answers, a foreign Host gets 403 and an unknown path 404. Recorded in the review.
- **Visual check:** the page at 127.0.0.1:8081 in light and dark at the DEF-01 window sizes. Recorded separately from the server check. The Executive hard-refreshes and verifies.
- Nobody runs Docker.

## Usage

These are estimates; `usage-now.json` is null. The session is at 27% and the slice costs 8 + 3 = 11, so the sprint should end near 38%. The week is at 29% (the last reading) and should end near 30%. Both stay below Caution (70%).

## Risks

1. The root `flutter test` must not pick up `scrum/scrumboard/test`, which belongs to a separate package. Checked in wave 2.
2. The arb copies can go stale. Run `tool/sync_messages.sh` before every build; the SCB-01.d test compares the copies with their sources.
