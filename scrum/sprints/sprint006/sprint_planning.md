# Sprint 006 Planning

**Status: proposed, awaiting Product Owner approval.** Planned 2026-11-23. Five days, **14 committed points** plus stretch. This is deliberately well below Sprint 005's 47: that sprint accepted 32, and its acceptance could not be traced to requirements or tests. The Product Owner never reviewed Sprint 005 because the preview would not render.

Planning used the Suzuki (PO), Tanaka (developer) and Kobayashi (reviewer) role definitions. Kobayashi first audited Sprint 005 against the code. `flutter analyze` is clean and 168 tests pass, so the problems are traceability, scope and verification, not a broken build.

## Sprint goal

The Product Owner can see and verify the running SuiteStream calendar in the VS Code preview, and Sprint 005's accepted work is made traceable and sound before more UI is added.

## What Sprint 005 got wrong (audit)

1. Delivered PBIs (015, 016, 022, 023, 021) are Done, but their requirement rows are still `backlog` with no test cited (CAL-04, CAL-06, SET-02.a, CLCL-*, UIC-14/16, THM-02). Done cannot be verified from `requirements/`.
2. Retirements went beyond colour: THM-02.e (4.5:1 contrast) was dropped though a test still exists; THM-05.d-g, THM-08 and THM-10 lost their concrete specs; the Google colour-ID table was deleted although sync needs it.
3. `lib/main.dart` gained untested startup logic (sample data, a silent migration that rewrites stored events, synthesized calendars) and an app-wide `ListenableBuilder`.
4. PBI-010 and PBI-019 were never split into testable slices. Several new tokens have one caller and no test.
5. Preview: nothing shows a stale build. Likely cause: CanvasKit loads from gstatic.com, which the VS Code browser may block, and `main()` has no error handling, so any startup failure is a blank page. The Review cites an Edge smoke test, not the Product Owner's environment.

The theme seed claim holds: the only `fromSeed` use is `0xFF93B4FF` (tokens.dart). The Product Owner's Sprint 005 instructions (sections in Settings, Full page retired, section folding retired, module folding kept, brand assets) are present in `requirements/`.

## What

| PBI | Work | Points |
|---|---|---:|
| PBI-026 (Critical) | Guard `main()` startup with a visible error page, add a loading/error fallback to `web/index.html`, bundle CanvasKit locally, document build and serve steps, verify in the VS Code browser. Record server checks and visual checks separately. Product Owner walkthrough of `#93B4FF` light/dark and reminder resize. This is also the re-acceptance of PBI-020/021 and the first real review of Sprint 005. | 3 |
| PBI-027 (new) | Reconcile requirements with Sprint 005: set row status and cite real tests for delivered rows; restore a contrast row for THM-02.e; restore the Google colour-ID mapping (UIC-20). List every Sprint 005 retirement for Product Owner decision. | 3 |
| PBI-028 (new) | Move startup, sample-data and migration logic from `main.dart` into a tested bootstrap. Remove the app-wide `ListenableBuilder`. | 2 |
| PBI-029 (slice of PBI-010) | `CancelSavePair` Saved/Cancelled sequence (UIC-27.a, .c, .e; THM-06.c): filled word, DEF-01 hold, idle, reduced motion. Dialogs close after the hold. Tested with intermediate frames. | 3 |
| PBI-030 (slice of PBI-019) | Shared size and radius tokens (THM-04.a-d) applied to existing dialogs and calendar header, replacing hardcoded radii. Tests read the sizes. | 2 |
| Hygiene (SM and PO) | velocity.csv rows for 003 and 004, status vocabulary, backlog sizes, stray `Microsoft/` folder. | 1 |
| **Committed** | | **14** |

**Stretch, in order, only if PBI-026 is verified by day 3:** PBI-031 overflow audit and fixes at 320/400/800 px, 2x text (UIC-14, 3 points); PBI-032 closure of the 003/004 review items PBI-011, 013, 014, 018 (3 points).

**Out of scope:** PBI-017 (hosting decision), PBI-024, PBI-025, UIC-28 to UIC-35 and UIC-37, THM-05.d-g and THM-06.d-i (need screens that do not exist), any new features.

## Product Owner decisions needed

1. Approve the 14-point commitment and the PBI-026 gate below.
2. Decide each Sprint 005 requirement retirement: THM-02.e contrast, THM-04.f, THM-05.b, THM-10.a/b, the THM-08 border tints, the Google colour IDs, CGOW-10.b. The Full page and section-folding retirements are already approved.
3. Should the sample-data and migration behaviour in `main.dart` stay as product behaviour?

## How

- **Gate:** if PBI-026 is not diagnosed and fixed by the end of day 2, UI work (PBI-029/030) stops and the team supports PBI-026.
- **One editor per shared file** (Sprint 005 retro action):

| File area | Owner |
|---|---|
| `cancel_save_pair.dart`, `confirm.dart`, `suite_dialog.dart`, `tokens.dart`, `suite_theme.dart` | Tanaka |
| `event_dialog.dart`, `main.dart` and bootstrap | Ito |
| `settings_dialog.dart`, `calendar_print_dialog.dart`, `local_calendars_dialog.dart`, requirements reconciliation | Yamamoto |
| `web/index.html`, build and serve docs, calendar page radii | Nakamura |
| Backlog hygiene, facilitation | Takahashi |

- **Order:** tokens (PBI-030) land on day 1 before other token users. `CancelSavePair` is built before dialog integration.
- **Capacity:** about 75 net hours for four developers; the tasks total about 55 hours, leaving slack for the uncertain PBI-026 fix. Velocity (26, 15, 32) is not a reliable guide.
- **Definition of Done:** each PBI cites requirement rows with passing tests, and the Review records server checks and visual checks separately.

## Review

Kobayashi's audit supplied the findings above. The plan itself still needs Kobayashi's review and Product Owner approval before the sprint starts.

## Update 2026-11-23: Product Owner direction

The Product Owner reviewed the running app, kept the ad hoc changes already made, and asked that the rest of the work proceed through the sprint process with the developer agents. Feedback is recorded in the [Sprint 005 retrospective](../sprint005/sprint_retrospective.md).

**Already in the working tree (made outside the sprint process; each needs developer verification and tests):** Save pulse and activated Save fill (PBI-029 partly); 12/24 badge inversion; right-zone icon sizing; title-bar and calendar-title padding; Settings left menu and content pane; month event chips; resize bar removed (requirement rows retired as R42); Print preview, Add calendar and delete confirmation on the shared Cancel | Save / No | Yes pair with a shared dialog wrapper; spacing tokens in the theme (PBI-030 partly); local CanvasKit in the web build (PBI-026 partly).

**Added:** PBI-033, a compact, aligned Add/Edit event dialog matching `reference/add_event_target.png` (3 points). Committed total is now **17 points**.

**Rules for this sprint:** all padding and gaps come from theme tokens except alignment fixes; Cancel | Save is the only dialog action pair; one editor per file as in the ownership table.
