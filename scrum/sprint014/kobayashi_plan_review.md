# Sprint 014 Plan Review (Kobayashi)

I checked `sprint_planning.md` and `sprint_backlog.md` against `scrum/order/order003.md`, `scrum/product_backlog.csv` (PBI-084, PBI-102 to PBI-109), `scrum/definition_of_done.md`, `scrum/velocity.csv`, `scrum/usage/usage.log`, `requirements/scrumboard.md` and the code in `scrum/scrumboard/`.

**Verdict: revise.** Four must-fix findings (1 to 4). The rest can be fixed in the plan text or accepted by Takahashi.

## Verified, no finding

- **Scope and order.** The scope follows the Ready order in `order003.md` (PBI-107, PBI-102, PBI-103 with PBI-108, PBI-109, PBI-104, PBI-106). It stops before PBI-085. The backlog adds up to 9 points (1+1+1+1+1+1+3), matching the CSV sizes. All seven items are `In Sprint`, sprint 014.
- **Velocity.** Sprints 011 to 013 planned and completed 8, 8 and 10 points (`velocity.csv`). Planning 9 points is within that range.
- **Usage numbers.** I reran the script myself (`bash scrum/usage/usage.sh project "Sonnet 5.5" N 23 49`):

  | Points | Session after | Week after |
  |---:|---:|---:|
  | 9 | 41.6 % | 51.6 % |
  | 10 | 43.6 % | 51.9 % |
  | 11 | 45.7 % | 52.2 % |

  All three stay below 70 %. `estimate` gives 2.062 session % and 0.287 week % per point, from 2 used rows (low confidence). `trend` says falling for both. The plan's figures (about 42/52 and 46/52) are correct.

  Worst case: the highest logged ratio is 3.875 (sprint011, discarded as an outlier). At 11 points it still gives 23 + 42.6 = 65.6 %, below Caution.
- **PBI-106 against PBI-084 and SCB-14.l.** PBI-106 is built before PBI-084, which `order003.md` allows ("before or with"). SCB-14.l is already gone from `requirements/scrumboard.md`:
  - SCB-14 already names `usage.sh estimate` and `trend` run by the server.
  - SCB-14.n says readings are entered with `usage.sh`.
  - The PBI-084 row no longer cites SCB-14.l.
- **In Review dependencies.** Every item names the In Review item it builds on (PBI-097, PBI-098, PBI-101, PBI-105), plus the rule for a rejection, as `order003.md` asks.
- **Wave order.** Each item is ready before the work that needs it:
  - Ito's helper (wave 0) comes before Yamamoto's column (wave 1).
  - Tanaka's `scrumBlockWidth` (wave 0) comes before Ito's `BoardTokens.blockWidth` (wave 1).
  - Nakamura's fake comes in wave 0.

  No file has two owners. `features_column.dart` (Yamamoto) already imports from `lib/src/board/`, so adding the helper creates no new cross-owner edit.

## Must-fix

1. **must-fix: SCB-13.b is not in the list of rows to rewrite.**
   - **Finding:** SCB-13.b lists the only requests the server answers, and says any other request gets "not found". `GET /api/usage/estimate` and `GET /api/usage/trend` are not on that list. The same gap was finding 1 in the Sprint 013 plan review.
   - **Fix:** Add SCB-13.b to Takahashi's statement cells. Add a server test that both routes answer and are not "not found". Give the new usage row its own fresh ID (for example SCB-14.o). Do not reuse the dropped SCB-14.l. The row should name the two endpoints, the `{ok, output, reason}` answer, and that a missing, failing or timed-out script gives `ok: false` with a reason.

2. **must-fix: `BrowserBoardPrefs` through `dart:js_interop` will not compile under `flutter test`.**
   - **Finding:** `flutter test` runs on the Dart VM. I checked with Dart 3.12.2: a file that imports `dart:js_interop` fails with "Dart library 'dart:js_interop' is not available on this platform".
     - `main.dart` (`ScrumBoardApp`) is pumped by `test/integration/app_test.dart`, three times, with no `prefs`.
     - So if `main.dart` or `lib/src/app/*` imports the web file directly, every app, page and integration test stops compiling.
   - **Fix:** Use a conditional import inside Tanaka's `lib/src/app/`:
     - The default is a stub file that gives `MemoryBoardPrefs`, or a no-op store.
     - `board_prefs_web.dart` is used only `if (dart.library.js_interop)`.
     - `ScrumBoardApp(prefs: null)` must not touch browser storage on the VM.

     Add a test that an existing integration call (no `prefs`) still starts with the default theme and zoom. The real local-storage path cannot be tested on the VM. It stays an Executive browser check, which the Done list already names.

3. **must-fix: PBI-108 is not a pure refactor, and the helper's fixed signature is incomplete.**
   - **Finding (behavior):** The two 'backlog' paths differ today for a `planned` requirement that is in a story:
     - The Backlog block (`backlog_timeline.dart`, `_status`) calls `moveRequirement`. That sets `backlog` and removes the requirement's Members rows from the sprint file, as SCB-07.f requires.
     - The Features column (`features_column.dart`, `_choose`) calls only `api.setStatus`. That leaves a Members row naming a `backlog` requirement.

     So the shared helper changes the column's behavior. This is a fix that matches SCB-07.f, but PBI-108's acceptance says "no change in behavior". The plan leaves this for Ito to find out in a handoff, and the answer is already known.
   - **Finding (signature):** `applyStatusChoice(api, {id, status, storyId})` has no current status and no `SprintFile`, and `moveRequirement` needs both. `status` is ambiguous: it could be the chosen status or the current one.
   - **Fix:**
     - State the change in the plan and in the PBI-108 row: the column's "backlog" choice now also removes Members rows.
     - Add it to the Executive's review checks.
     - Add a test: in the column, choosing backlog for a planned story member removes its Members row.
     - Fix the signature. Either rename the parameter to `choice` and say the helper fetches requirements and the sprint file itself (as `assignRequirementToSprint` does), or pass `required String current, required SprintFile sprint`.

4. **must-fix: part of PBI-106's acceptance needs the chart, which is out of scope.**
   - **Finding:** PBI-106's acceptance criteria say two things that only the chart can show:
     - "the usage chart (SCB-14) shows the script output and no longer reads the estimate columns itself"
     - "a script that fails or is missing shows an error and not an empty chart"

     The chart is PBI-084, which is not in this sprint. As written, PBI-106 cannot meet the Definition of Done ("maps to agreed acceptance criteria") this sprint.
   - **Fix:** Before wave 0, Takahashi or Suzuki moves those two clauses to PBI-084's acceptance. PBI-106 then ends at the server, API, fake and tests. The plan should say so in one line, so 3 points are not reported as "usage on the board".

## Should-fix

5. **should-fix: running `bash` on Windows.**
   - **Finding:** The Executive runs Windows. A plain `bash` command can resolve to `C:\Windows\System32\bash.exe` (WSL) instead of Git Bash. WSL then fails on Windows paths, or reads a different checkout.
   - **Fix:** Say how the server finds bash. For example, a `--bash <path>` start option next to `--usage-script`, defaulting to `bash`. Make "bash not found" give `ok: false` with a reason. Run the real-script test row on the Executive's machine.

6. **should-fix: the time limit and the failure rules are not fixed.**
   - **Finding:** "With a time limit" gives no value. `usage.sh estimate` exits 0 when the model has no usable rows (it prints "no usable rows"), while `trend` exits 1 ("No rows for ...").
   - **Fix:**
     - Fix the time limit as a named constant or a DEF-01 value.
     - Name tests for: missing script, non-zero exit, timeout, and exit 0 with output.
     - Say that changing `usage.sh` is out of scope, because nobody owns it this sprint and PBI-105 is In Review.

7. **should-fix: no availability statement.**
   - **Finding:** The skill says the review must confirm availability. The plan does not say whether Ito, Tanaka, Yamamoto and Nakamura are all available, or whether anyone is on leave. It also gives no timebox (the skill plans 5 days).
   - **Fix:** Add one line: all four developers are available, and Yamamoto and Nakamura are absent from planning only. Give the timebox.

8. **should-fix: the scope table counts PBI-108 twice.**
   - **Finding:** The waves add up to 10 points: 1+1+1+1+3 in wave 0, then 2+1 in wave 1. The header and the backlog say 9.
   - **Fix:** Make the wave 1 "PBI-108, PBI-103" row 1 point (PBI-103), and mark PBI-108's column part as "(in 108)".

## Notes

9. **note: which model the sprint runs on.** The estimate is for "Sonnet 5.5", and the log is "estimated per model, never mixed". If Sprint 014's orchestrator runs on another model, say that the Sonnet figure is borrowed. That model's first row will then have no estimate.

10. **note: test coverage per requirement row.**
    - SCB-22, SCB-20 and SCB-20.a, and the helper each have a named test.
    - SCB-23: the token-position test should also cover a sub-row and the narrowest DEF-01 width (SCB-15.c).
    - SCB-24: name the tests that PBI-104 asks for:
      - theme and zoom survive a new `ScrumBoardApp` built on the same `MemoryBoardPrefs`;
      - filters and outline do not survive;
      - an unreadable store, and a zoom out of range or off-step, give the defaults.
    - SCB-06.g: `backlog_timeline_test.dart` compares the width with `BoardTokens.blockWidth`, so it passes whatever the token is. Assert against `scrumBlockWidth`, or against 360.

11. **note: Tanaka's load.** Tanaka has three items plus the token in wave 0, all in `scrumboard_page.dart`, `main.dart` and `scrum_theme.dart`, and is on Ito's wave 1 critical path. Tanaka should land the `scrumBlockWidth` token first.

    The one-icon design (minus subscript, plus superscript) has no Material icon. Say whether it is two hit areas inside one custom-drawn control, and keep keys `scbZoomOut` and `scbZoomIn` on the halves so the existing tests keep finding them.

12. **note: the `--usage-script` start option.** Any production server start can use it, not only tests. That is acceptable for a local, 127.0.0.1-only server whose page cannot set it. Narrow the SCB-01.a test to the runner file and assert that it runs only the configured path with `estimate` or `trend`.

13. **note: PBI status before the review.** `product_backlog.csv` already marks the seven items `In Sprint` before this review. That is consistent with the Recording step. The plan header correctly says no agent starts before the review.

## Re-review

I checked the revised `sprint_planning.md`, `sprint_backlog.md` and the PBI-084, PBI-106 and PBI-108 rows of `product_backlog.csv` (plus PBI-102 to PBI-104, PBI-107 and PBI-109) against findings 1 to 13. I checked the claims in the code (`sprint_assign.dart`, `backlog_timeline.dart`, `features_column.dart`, `main.dart`, `test/integration/app_test.dart`), in `requirements/scrumboard.md` and in `scrum/usage/usage.sh`, and ran checks with Dart 3.12.2 on the Executive's Windows machine.

**Verdict: revise.** One new must-fix (14), which needs one line in the plan. Findings 1 to 8 are resolved. Once Takahashi adds that line and accepts or rejects assumptions A and B, the plan can start without another full review.

### Earlier findings

| # | Resolved | Evidence |
|---|---|---|
| 1 | yes | "Requirement rows" names SCB-13.b (rewritten) and a new SCB-14.o. SCB-14.o is free: `scrumboard.md` has SCB-14.a to k, m and n. SCB-14.l is not reused. The named tests cover "not found", a missing script, bash not found, non-zero exit, timeout, and exit 0. |
| 2 | yes | I compiled a stub and a web file under `import 'stub.dart' if (dart.library.js_interop) 'web.dart'`. On the VM, `dart run` picks the stub and `dart.library.js_interop` is false. `dart analyze` reports no issues. `dart compile js` picks the web file. The SCB-24 tests include a no-`prefs` start. `dart:js_interop` is part of the SDK, so `pubspec.yaml` needs no new package. |
| 3 | yes | "Behaviour change" and the PBI-108 row state the column change. It is in the Executive's checks, with a column test. The signature now has `choice`, and the helper fetches the requirements and the sprint file itself, which `moveRequirement` needs (`sprint_assign.dart`). |
| 4 | yes | PBI-084 carries both chart clauses. PBI-106 says it ends at the server, API, fake and tests. The sprint goal says the board shows no usage this sprint. |
| 5 | partly | A `--bash` option and a "bash not found" result were added. The default is still wrong on this machine; see 14. |
| 6 | yes | `usageScriptTimeout = Duration(seconds: 10)`; the exit rules match `usage.sh`. `estimate` exits 0, including "no usable rows". `trend` exits 1 on "No rows for ...", which I checked with `trend "Opus 5.5"`. Changing `usage.sh` is out of scope. |
| 7 | text yes; fact unconfirmed | See assumption A. |
| 8 | yes | Wave 0 is 1+1+1+1+3 = 7 and wave 1 is 1+1 = 2, so 9. `sprint_backlog.md` gives 1+1+1+1+1+1+3 = 9. PBI-108 is counted once. The CSV sizes match. All eight rows checked have 10 fields. |
| 9 to 12 | yes | The model note, the per-row tests (sub-row, narrowest width, SCB-24 cases, `scrumBlockWidth` 360), the token landing first, and the two-hit-area zoom control are all in the plan. |

### New findings

14. **must-fix: the default `bash` is WSL on the Executive's machine, for the server and for the tests.**
    - **Finding:** `C:\Windows\System32\bash.exe` exists on this machine. A Dart `Process.run('bash', ...)` started from Git Bash ran WSL: `uname -s` printed `Linux`. Windows looks in System32 before PATH, so the shell the server is started from does not matter.
    - Under WSL, a Windows absolute script path fails with exit 127 (`C:UsersrfrieAppData...: No such file or directory`). The same script ran with `C:\Program Files\Git\bin\bash.exe`.
    - So the fake-script tests in `test/server/` fail on this machine when they use the default `bash` with an absolute fixture path. The Definition of Done needs `flutter test` to pass. The server also gives WSL results unless the Executive remembers `--bash`.
    - **Fix (one line in "Fixed names", Nakamura):**
      - On Windows the default bash is Git Bash: for example `<git install>\bin\bash.exe`, found from `git --exec-path` or the usual install path. It is never a bare `bash`.
      - If no Git Bash is found, the answer is `ok: false` with a reason. `--bash` still overrides the default.
      - The server tests use the same lookup.
      - Add a test that on Windows the lookup never returns a path under `System32`.

15. **note: the helper mapping.** "Fixed names" lists 'proposed' -> `api.setStatus`. Today both the Backlog block and the column send every other choice to `setStatus`. Write "any other choice -> `api.setStatus`" so the helper keeps that.

16. **note: the timeout test.**
    - A short test limit means the runner must take the limit as a parameter, defaulting to `usageScriptTimeout`. The plan names only the constant.
    - On Windows, killing `bash.exe` leaves a child `sleep` running, and the child keeps stdout open. After a timeout, the runner must not wait for stdout to close.
    - Keep the fake sleep short (a few seconds) so a leftover child ends quickly.

17. **note: the board always shows the Sonnet 5.5 figures.** The server runs `estimate` and `trend` with no further argument, and `usage.sh` then uses `Sonnet 5.5`. That fits the "fixed arguments" rule, but PBI-084 should know before it labels the chart. This links to note 9.

18. **note: two points for PBI-084's refinement, not this sprint.**
    - SCB-14.g (an empty chart that says msg:scbNoUsage) and the clause moved from PBI-106 ("an error and not an empty chart") need to be reconciled when PBI-084 is refined.
    - `usage.sh trend` passes `${sess[f]}` twice to `verdict`. It compares only the first of the last three estimates with the last one. This is out of scope here (finding 6), so it is a backlog candidate for Takahashi.

### Assumptions for Takahashi to accept or reject

- **A. No leave for Ito, Tanaka, Yamamoto or Nakamura.** "Availability and timebox" states this as a fact. The planner says it is unconfirmed, and I found no source for it. Accept it, or confirm it, before wave 0.
- **B. A 10-second script timeout.** I timed the runs with Git Bash on this machine: `estimate` took 0.09 s, `trend` 0.35 s (4 Sonnet rows), and `trend "Opus 5.5"` 0.09 s.
  - `trend` runs the estimate once per row and reads the whole log each time, so it gets slower as the log grows. It stays far below 10 s for any likely log size.
  - 10 s also covers a slow first start of bash.
  - I recommend accepting it.
