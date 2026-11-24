
## 2026-11-24 Nakamura
- model landed: scrum/scrumboard/lib/src/api/models.dart (`BoardItem`, with `BoardItem.question` and `BoardItem.verification` kind constants; `text`, `choices`, `answer` default to empty, `pbi` null for questions). Check: `flutter analyze lib/src/api/models.dart` -> No issues found.

## 2026-11-24 Tanaka

Tasks 2 and 3 (PBI-126) done: 44 PBIs have status In Review in `scrum/product_backlog.csv`; items 1-8 already covered 8 of them; verifications 9-44 added to `scrum/verifications.md` (one each, oldest first). For task 4 (Takahashi), PBI -> verification:

PBI-108 -> 1, PBI-107 -> 2, PBI-109 -> 3, PBI-106 -> 4, PBI-119 -> 5, PBI-120 -> 6, PBI-122 -> 7, PBI-092 -> 8,
PBI-011 -> 9, PBI-013 -> 10, PBI-014 -> 11, PBI-018 -> 12, PBI-037 -> 13, PBI-046 -> 14, PBI-047 -> 15, PBI-048 -> 16,
PBI-050 -> 17, PBI-051 -> 18, PBI-052 -> 19, PBI-053 -> 20, PBI-054 -> 21, PBI-057 -> 22, PBI-058 -> 23, PBI-059 -> 24,
PBI-060 -> 25, PBI-061 -> 26, PBI-062 -> 27, PBI-063 -> 28, PBI-068 -> 29, PBI-069 -> 30, PBI-070 -> 31, PBI-071 -> 32,
PBI-072 -> 33, PBI-077 -> 34, PBI-078 -> 35, PBI-079 -> 36, PBI-080 -> 37, PBI-081 -> 38, PBI-090 -> 39, PBI-097 -> 40,
PBI-098 -> 41, PBI-099 -> 42, PBI-101 -> 43, PBI-105 -> 44.

Checks taken from sprint review files where listed (Sprints 009 to 013). Suzuki: please read the wording of 9-44.

Task 9 (PBI-086) done: `ScrumBoardPage` has `required Widget questions`, shown in `scbColumnQuestions` (key already existed). `lib/main.dart` passes `const SizedBox.shrink()` until task 10b. No file outside mine constructs `ScrumBoardPage`; nothing needed from other owners.
- fake writes landed: scrum/scrumboard/lib/src/api/scrumboard_api.dart. `ScrumBoardApi` has `boardItems()`, `answerQuestion(number, heading, answer)`, `setVerificationResult(number, heading, result, status)`. `FakeScrumBoardApi(questionList:, verificationList:)` answers the lists as given (give them in column order); writes match number AND heading, set `answered` / `accepted` / `returned` and the answer, give `(ok: false, reason: 'gone')` when no item matches, and throw `ScrumBoardApiException` with statusCode 400 for an empty answer, a line break, or `returned` with an empty result (as the HTTP client will). Calls are in `answerCalls` and `resultCalls`; a write changes `changeStamp()`. `HttpScrumBoardApi` writes answer `(ok: false, reason: boardWritesNotAvailable)` until task 14. No other file implements `ScrumBoardApi`, so nothing outside my files needed a change.
- GET /api/questions landed (task 7): `lib/server/board_items.dart` (`readBoardItems`, `parseBoardItems`, `orderBoardItems`); route and stamp in `lib/server/server.dart`. `BoardItem.heading` is the text after `## <n>. `; `pbi` is the heading's first word when it is `PBI-<n>`.
- Tests: `flutter analyze lib test` -> No issues found; `flutter test` (in scrum/scrumboard) -> +207: All tests passed!

## 2026-11-24 Yamamoto
- keys landed: the 13 keys of the Keys table in the six `requirements/messages/app_*.arb` (all six languages), synced with `bash tool/sync_messages.sh` into `scrum/scrumboard/assets/messages/`.
- bar landed: `lib/src/features/scb_filter_bar.dart` has `ScbFilterFields<T>`, `const requirementFilterFields`, `ScbFilterBar<T>({items, fields, hidden, onChanged, trailing})` (null `fields` = requirements, asserted) and `ScbHiddenFilters.applyWith<T>(items, fields)`; `apply` and `shows` unchanged; widget keys unchanged. For Ito (task 10): give `fields: questionFilterFields` with `groupName: 'scbFilterKind'`, `idName: 'scbFilterItem'`, and filter the list with `hidden.applyWith(items, questionFilterFields)`. Note: `find.byType(ScbFilterBar)` no longer matches (the type is `ScbFilterBar<Requirement>` or `ScbFilterBar<BoardItem>`); find it with `find.descendant` of the column key and `find.byType(ScbFilterBar<BoardItem>)`.
- SCB-04 bar test on `BoardItem` is in `test/features/scb_filter_bar_test.dart`; the questions column is not built yet, so the bar sits under a stand-in `KeyedSubtree` keyed `scbColumnQuestions` and is found with `find.descendant` of it.
- Check: `flutter test` in scrum/scrumboard -> +199 All tests passed!

## 2026-11-24 Suzuki
- Verifications 9-44 read against their backlog rows: wording fixed in 12, 22 (light and dark added), 34, 41 (hard refresh added), 32 (names the SuiteStream server, `server/bin/server.dart`). Numbers, statuses and format unchanged.
- Decision, order in the Questions and Verifications column (task 10, SCB-17.c): one order across both kinds, as decided in planning ("Order in the column (Suzuki)", `sprint_planning.md`) and as SCB-17.c says for "the items": all open items first (open questions, then open verifications, each newest first, reverse file order), then all answered or closed items (answered questions, then accepted or returned verifications, each newest first). The API keeps its two lists; the column merges them in this order.
- Decision, SCB-04 and SCB-01.a: agreed, both stay status backlog. Each also covers Issues work (SCB-04 for the Issues column, PBI-082; SCB-01.a issue writes through the SuiteStream API, PBI-094) not in this sprint; setting them planned would let an accepted PBI-086 or PBI-125 mark them done with that part unbuilt. Their tests for this sprint's part still run and pass.

## 2026-11-24 Day 2 Yamamoto
- For Ito (task 10): the stand-in `scbColumnQuestions` in `test/features/scb_filter_bar_test.dart` stays as is (that SCB-04 test checks the bar on `BoardItem`, not the column); your column tests in `test/questions/` cover the bar inside the real column; the file stays mine.

## 2026-11-24 Day 2 Ito
- column landed (task 10): `scrum/scrumboard/lib/src/questions/questions_column.dart`. For Tanaka (task 10b), in `lib/main.dart`: `import 'package:scrumboard/src/questions/questions_column.dart';` and pass `questions: QuestionsColumn(api: api)` to `ScrumBoardPage` (the same `api` the Features column gets). No new theme token needed (task 6b: nothing from wave 1).
- For task 15 (mine, wave 2): the column already reloads when its `api` changes; the merge is `questionColumnOrder(questions, verifications)`.
- Check: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +219: All tests passed!

## 2026-11-24 Day 2 Tanaka
- Task 12b done: verifications written in `scrum/verifications.md`. For Takahashi (In Review in `scrum/product_backlog.csv`): PBI-126 -> 45, PBI-086 -> 46. Verification 46 says the Windows and web check is ready only after task 17b (Kobayashi finding 2).

## 2026-11-24 Day 3 Nakamura
- write routes landed (task 13), for Tanaka (task 14b) and Ito (task 15): `scrum/scrumboard/lib/server/server.dart` and `lib/server/board_item_write.dart`.
  - `PUT /api/questions/{n}/answer`, body `{"heading": "<text after '## <n>. '>", "answer": "<text>"}`.
  - `PUT /api/verifications/{n}/result`, body `{"heading": "...", "result": "<text, may be empty when accepted>", "status": "accepted" | "returned"}`.
  - `{n}` is 1 to 9 digits; any other verb or path under them is 404.
  - 200 `{"ok": true, "reason": ""}` when written; 200 `{"ok": false, "reason": "gone"}` when no item has that number AND heading (heading changed, number deleted, or file missing): nothing written, file byte-for-byte unchanged.
  - 400 `{"error": "..."}`: body not JSON or not an object; heading, answer or result missing or not a string; a line break (`\n` or `\r`) in heading, answer or result; an empty or blank answer; status not exactly `accepted` or `returned`; `returned` with an empty or blank result. 413 over the body limit. Nothing written in any of these.
  - File write format: the file is read again inside `_serialized`; only the matched item changes (an open one first if two match; the ``` Format block is never matched). Its `Status:` line becomes `Status: answered` (question) or `Status: accepted` / `Status: returned` (verification); its `Answer:` / `Result:` line becomes `Answer: <answer>` / `Result: <result>` on the same line, as the answered example in `scrum/questions.md` (`Result:` alone when an accepted result is empty); old continuation lines of that field are dropped. A missing `Status:` line is added after the heading, a missing field line after the item's last text line. Answer and result are written as typed (not trimmed). Every other byte stays; each line keeps its own line end, added lines take CRLF when the file has any CRLF (so a CRLF file stays CRLF on every line). The file is replaced through `<file>.tmp` and a rename; no temp stays.
- HTTP writes landed (task 14): `scrum/scrumboard/lib/src/api/scrumboard_api.dart`. `HttpScrumBoardApi.answerQuestion(number, heading, answer)` and `setVerificationResult(number, heading, result, status)` send the PUTs above and return `(ok, reason)`; a 400 throws `ScrumBoardApiException` with statusCode 400 and the server's error as `reason`, as `FakeScrumBoardApi` does; unreachable throws `ScrumBoardUnreachableException`. `boardWritesNotAvailable` is removed (nothing else used it).
- Tests: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test test/server test/api` -> +117: All tests passed!; `flutter test` -> +240: All tests passed!

## 2026-11-24 Day 3 Ito
- task 15 landed (PBI-125): `scrum/scrumboard/lib/src/questions/questions_column.dart`, tests in `scrum/scrumboard/test/questions/questions_column_test.dart`. Widget keys for task 17a/17b checks: `scb-choice-<kind>-<n>-<i>`, `scb-answer-field-<id>`, `scb-answered-<id>`, `scb-result-field-<id>`, `scb-accepted-<id>`, `scb-returned-<id>`, `scb-questions-notice` (id = `<kind>-<number>`).
- Picking a choice writes at once (no second press), as SCB-17.b reads ("picking a choice writes that choice line"). Answered is disabled while the typed text is blank; Accepted is always enabled (an empty result is allowed).
- Task 6b: no token asked (existing tokens only; the hint wraps up to three lines instead of being cut, DEF-01).
- For Suzuki / Yamamoto (next sprint, not this one): a refused write (400) shows only the server's reason, since no key says "write refused"; `scbLoadFailed` says "could not read" and `scbMoveRefused` says "move", neither fits. An unreachable server uses msg:scbServerUnreachable.
- Check: `cd scrum/scrumboard && flutter analyze lib test` -> No issues found!; `flutter test` -> +240: All tests passed!

## 2026-11-24 Day 3 Tanaka
- Task 14b done: `scrum/scrumboard/README.md` API table has the two write routes (bodies, `{ok, reason}`, `gone`, 400s, 413, line endings kept) and the missing `PUT /api/requirements/{id}/status`, `POST /api/requirements/{id}/retire` and `GET /api/changes` rows (Kobayashi Day 2 finding 4); "server writes" lists every file the server writes. For Nakamura (task 17b): the README is ready for the Windows and web check of the routes.
- Task 6b wave 2: none asked (Ito Day 3); `scrum_theme.dart` unchanged. Task 6b done.

## 2026-11-24 Day 3 Tanaka (16b)
- PBI-125 -> 47 (`scrum/verifications.md`), for Takahashi: set PBI-125 In Review with its acceptance field ending "waits for verification 47 (`scrum/verifications.md`)". The Windows and web check is ready only after task 17b (Kobayashi Day 2 finding 2, Day 3 task 16 review).

## 2026-11-24 Day 3 Suzuki
- Decisions on Kobayashi's Day 3 task 16 review (`kobayashi_code_review.md`, "Day 3: task 16 review (wave 2)"), for Takahashi:
  - Finding 1 (refused write shows the server's English reason alone): yes, a backlog item, next sprint, not this one. Reason: every line the board shows must come from a key (the load error already wraps its reason in msg:scbLoadFailed); a raw reason breaks that in five languages. Takahashi adds to `scrum/product_backlog.csv`: title "ScrumBoard Questions column wraps a refused write in a message key"; acceptance: a new key msg:scbWriteRefused (English "Nothing was written: {reason}") in all six languages; the Questions and Verifications column shows it with the server's reason as `{reason}` for a 400; a 413; a 500 and any `ok: false` other than `gone`; `gone` keeps msg:scbItemGone and an unreachable server keeps msg:scbServerUnreachable; the item stays open with its controls; one widget test each for a 400 and an `ok: false` reason checked against the English key text; rewrites SCB-17.b; no clipping at the DEF-01 window sizes; light and dark; priority Low; size 1; Ready.
  - Finding 2 (picking a choice writes at once): confirmed as built, no backlog item. Reason: SCB-17.b says picking a choice writes that choice line; one press is the point of the board; a mis-tap is still readable on the board (the item stays listed answered) and the Executive can correct it in chat before an agent acts on it.
  - Finding 3 (Answered disabled while the typed text is blank): accepted. Reason: it matches the server's 400 for a blank answer and the Returned rule. Takahashi adds it to the SCB-17.b statement in `requirements/scrumboard.md` (Answered is disabled while the answer is empty or blank) so the row and the named column test agree; this sprint, since it states what PBI-125 already built.
- Nothing here needs the Executive's judgment; no question for `scrum/questions.md`.

## 2026-11-24 Day 4 Nakamura
- Task 17b, to reproduce (Kobayashi). Git Bash, from the repository root. Scratch files outside the repo; `$S` is any scratch folder.
  - Build: `cd scrum/scrumboard && flutter pub get && ../../tool/sync_messages.sh && flutter build web --release --no-web-resources-cdn` (README's `tool/sync_messages.sh` path does not exist under `scrum/scrumboard`).
  - Scratch root: `mkdir -p $S/root17b/scrum && cp -r requirements $S/root17b/ && cp -r scrum/usage $S/root17b/scrum/ && cp scrum/questions.md $S/root17b/scrum/ && sed 's/$/\r/' scrum/verifications.md > $S/root17b/scrum/verifications.md`, then append open questions in the Format with 3-space indented choice lines. Edit the CRLF copy with `perl -pi`, not `sed -i` (Git Bash `sed -i` drops the CRs).
  - Server: `cd scrum/scrumboard && dart run bin/server.dart --port 8099 --root $S/root17b`. Stop: the `dartvm.exe` listening on 8099 (`netstat -ano | grep :8099`, `taskkill //PID <pid> //F`); killing the shell leaves it running.
  - Writes: `curl -X PUT -H 'Content-Type: application/json' --data '{"heading":"PBI-086 Questions and Verifications column","result":"","status":"accepted"}' http://127.0.0.1:8099/api/verifications/46/result`; questions: `--data '{"heading":"<heading>","answer":"a. Blue (recommended)"}' .../api/questions/1/answer`.
  - Line ends: count bytes, not lines (Git Bash `grep` hides CR): `tr -cd '\n' < f | wc -c`, `tr -cd '\r' < f | wc -c`, `od -An -c -v f | tr -s ' \n' ' ' | grep -o '\\r \\n' | wc -l`.
  - File held open: PowerShell `[System.IO.File]::Open($p, 'Open', 'Read', 'ReadWrite')` held during a PUT -> 500, rename "Access is denied"; same with share `ReadWrite, Delete`.
  - Screenshot: `"/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" --headless=new --disable-gpu --no-first-run --user-data-dir=<scratch profile> --window-size=1024,640 --virtual-time-budget=20000 --screenshot=<png> http://127.0.0.1:8099/`.
- For the Executive (verifications 46 and 47): still to check in a real browser: dark mode, the other DEF-01 sizes, the filter bar hiding, scrolling, live reload (SCB-22) and clicking a choice, Answered, Accepted and Returned on the page; none of that was clicked here.

## 2026-11-24 Day 4 Suzuki
- Decisions on Kobayashi's Day 4 review (`kobayashi_code_review.md`, "Day 4: wave 3 review"), for Takahashi (task 18):
  - Finding 1 (17b "done" says more than was done): accepted. Takahashi records 17b as done except the browser clicks and dark mode; those two are the Executive's check in verifications 46 and 47. PBI-086 and PBI-125 stay In Review. The last sentence of each verification is now stale ("ready only after task 17b"); Tanaka replaces it with exactly:
    - 46: "Task 17b built the web page and checked the server on Windows on copies (light only and no browser clicks); this check covers dark mode, the other window sizes, the filter bar, scrolling and live reload in a real browser."
    - 47: "Task 17b checked these writes on Windows with curl on copies (light only and no browser clicks); this check covers pressing a choice, Answered, Accepted and Returned on the page in a real browser, in light and dark."
    - No other change to 46 or 47.
  - Finding 2 (a write while another program holds the file answers 500): a backlog item, next sprint, not this one. Reason: the write fails visibly and leaves the file intact, so DoD holds this sprint. But a short-lived handle (indexer, antivirus, sync client) can cause it with no one holding the file, and a few retries cost little. The README note alone leaves the Executive pressing again by hand. Takahashi adds to `scrum/product_backlog.csv` (next free id, PBI-130):
    - title: "ScrumBoard write retries a refused rename on Windows"
    - description: "As the Executive I want a board write to succeed when another program holds the file for a moment so that I do not press again"
    - acceptance: "Sprint 015 Day 4 Kobayashi wave 3 review finding 2 (Suzuki decision in scrum/sprint015/handoffs.md): when the rename of <file>.tmp over scrum/questions.md or scrum/verifications.md is denied the server re-reads the file and tries the write again up to the count and delay added to DEF-01 in requirements/common.md (assumed 5 tries 200 ms apart); the gone check runs again on each try; after the last refused try it still answers 500 with the file unchanged and no .tmp left; the README Known limitation (Windows) bullet says a file held longer than the retries still answers 500; named server tests with an injected rename that fails once then succeeds (200 and only the item's lines changed) and one that always fails (500 and file unchanged and no .tmp); rewrites SCB-17.b; Windows check on a copy with a held handle released within the retries"
    - priority Low; size 1; status Ready; sprint empty; created and updated 2026-11-24; owner suggestion Nakamura (he wrote the write routes, task 13). Related to PBI-129 (that one words the 500 in a key; this one makes it rarer); either can go first.
  - Findings 3 to 5 are notes; Takahashi handles 5 in task 18. No PO decision needed.
- Nothing here needs the Executive's judgment; no question for `scrum/questions.md`. The Day 3 decision (a refused-write problem that fails visibly is a Low backlog item for the next sprint) covers finding 2.
