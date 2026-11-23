# Sprint 008 plan review (Kobayashi, before the sprint starts)

Read-only review of `sprint_planning.md`, `sprint_backlog.md`, `daily_scrum.md`, PBI-040 to PBI-054, the Sprint 007 retrospective and review, `definition_of_done.md`, the backlog-refinement Epics section and the cited rows in `requirements/`.

**Verdict: approve with changes.** The scope matches what the Product Owner asked for and the hours add up, but usage, the epic splits, three missing requirement rows and the file ownership of two rows must be fixed before developers start.

## Findings

### High
1. **Usage will cross Warning, not only Caution.** The plan uses the 53% reading; the latest reading is 65% session. 65% plus the plan's own 25 to 30 points gives 90 to 95%, above Warning (85%), so running agents would stop mid-sprint. The weekly reading is unknown (98% at sprint 003). Change: re-anchor `sprint_planning.md` Usage on 65%; the Product Owner supplies a weekly reading before start; either reduce scope to what fits under 85% (about 20 points of session: cut order items PBI-053 header fit, PBI-048 beyond strict modes, PBI-054 print out first) or the Product Owner accepts a stop at Warning and a carry-over. Say which in Product Owner decision 2.
2. **Per-person load is far above the per-person net.** 79 h against about 80 h net is true only in total. Four developers give about 20 h each: Yamamoto 28 h (140%) and Ito 26 h (130%) are over, Nakamura 6 h (30%) under, Tanaka 19 h. The plan says overflow shifts to Nakamura "through Takahashi", but Nakamura cannot edit Ito's or Yamamoto's files. Change: move work to Nakamura that his files allow, and move other work away from Ito and Yamamoto by ownership, not by hand-off. Concrete moves: (a) Yamamoto's 1 h Reset use and the PBI-047 skill edits (4 h) to Takahashi or Kobayashi's own role file as the PBI says (the skills and role file are process files, not code; assign by Takahashi), (b) PBI-050 back-button wiring (1 h, Nakamura) is fine, add Nakamura as owner of the Admin pane auto-save (`settings_admin_pane.dart`, his file) and of the Reset in `settings_admin_pane.dart` if any, (c) Ito: keep PBI-052 and PBI-054 views; give the PBI-048 lint pass of Ito's files a cap of 2 h and put print in the cut order (already there). Update the table to show hours by owner against 20 h.
3. **Epic and story splits do not follow the Epics rules** (`backlog-refinement/SKILL.md`, Epics). Rules: the original PBI becomes an epic, status `Epic (split into PBI-x to PBI-y)`, size is the sum of its children, never counted; each child has its own id, a size, criteria, a status, names its parent at the start of its description ("Part of PBI-040: ..."), and cites the rows it meets.
   - PBI-040: status is `Backlog (split; slice 1 is PBI-054; remainder 9 points)` and size 9. Slices 2 (5) and 3 (4) have no PBI ids. Change: PBI-040 becomes `Epic (split into PBI-054 to PBI-056)`, size 13; create PBI-055 (audit of 47 rows with CAL-04.d and CAL-09.e/f, 5, Backlog) and PBI-056 (placeholders, 4, Backlog); PBI-054 description starts "Part of PBI-040: ".
   - PBI-045: status `Backlog (remainder after PBI-053 ...)`, size 6, no children. PBI-045 is a child of the epic PBI-039 already, so it cannot be an epic that keeps 6 points and also a story. Change: either keep PBI-045 as the story it was and move Reset buttons and header zone fit out of it (PBI-053 stays a child of PBI-039, "Part of PBI-039"; PBI-045 re-sized 6), or make PBI-045 an epic with children PBI-053 (2) and a new PBI-057 (6). Do not use "slice of PBI-045" as the only link.
   - PBI-053 and PBI-054 do not cite row IDs in the CSV; add (PBI-053: new UIC rule for Reset and the header-zone UIC-14 rule; PBI-054: CAL-09.c, EVT-03.b).
4. **Requirement rows the plan relies on do not exist, and their owner is unclear.**
   - PBI-050: UIC-45 (auto-save and back button) already exists in `common.md:69` (status `backlog`), so "one UIC rule" is done and a new SET row duplicates it, which the PBI itself forbids ("no per-page rows"). Change: PBI-050 cites UIC-45; delete the "new SET row" from the plan, the backlog task ("One SET row and one UIC rule", 3 h) and the CSV text, or state what the SET row says that UIC-45 does not. Status change of UIC-45 is in `common.md`, which Tanaka owns; Yamamoto must send the wording through Takahashi or Tanaka edits it. Fix the ownership table.
   - PBI-046: no row exists for popup open and close transitions (UIC-43 is the shadow; SET-03.g is only the time). The plan says "a UIC popup transition row" but nobody owns writing it except Tanaka (`common.md`); add that as a Tanaka task (30 min) and add the id to the PBI.
   - PBI-053: no row exists for the Reset button look or the header-zone-fit standard (search for "Reset" and "header zone" in `requirements/` finds none). The backlog assigns "row" to Tanaka; make the row id part of the commitment before building.
   - Existing and fine: THM-10.h (`theme.md:53`, backlog), CAL-09.c (`calendar.md:63`, backlog), EVT-03.b (`events.md:25`, planned), SET-01.e, SET-03.b, SET-09, SET-03.g, UIC-43. SBD rows are not needed (Sprint 011).

### Medium
5. **File-ownership conflicts.**
   - `requirements/theme.md`: Ito owns THM-09 and THM-10.h, Tanaka owns the rest: two editors in one file. Change: split by row is not enforceable in git; assign the whole file to Tanaka and have Ito send THM-10.h text through Takahashi, or give Ito only `events.md`, `calendar.md`, `print.md` plus a note that THM-10.h status is set by Tanaka.
   - `requirements/common.md`: Tanaka only, but PBI-050 (UIC-45) is Yamamoto's task and PBI-046 popup rows touch it; see finding 4.
   - PBI-046 "popup menus, pickers, palette, zone picker and event details use it" reaches files owned by others: `week_view.dart` hour-density `PopupMenuButton` (Ito), the theme menu in `calendar_page.dart` (Nakamura), `event_dialog.dart` pickers (Ito), `local_calendars_dialog.dart` (Ito). Tanaka cannot edit them. Change: say in the plan that the shared transition is built in `lib/src/ui` and each owner adds one call in their own file by day 3, with 0.5 to 1 h in their task lists (Ito and Nakamura).
   - PBI-053 "Use it in every other Reset" crosses owners; same fix (each owner uses the style in their file; only the Theme pane is Yamamoto's).
   - PBI-051: press-and-hold is stored by `calendar_defaults.dart` (Yamamoto) but the Theme settings model is `theme_settings.dart` (Tanaka). If the setting moves into `ThemeSettings`, Tanaka edits it; say which store holds it and who edits it.
   - `settings_admin_pane.dart` (Nakamura) must also auto-save/leave cleanly under PBI-050; not mentioned.
   - Arbitration: arb only through Yamamoto is stated and consistent. New keys (back button label, group titles, Reset label) need the `strings_<name>.md` intake; Yamamoto's 3 h arb merge covers it, but his load is the issue (finding 2).
6. **Dependencies and order.** The gate "Ito provides `eventTextColorOn` by day 1 hour 4" is good. Missing: (a) the shared Reset style (Tanaka, day 1) before Yamamoto's use and before Nakamura/Ito use it; (b) the transition API in `showSuiteDialog` before other owners add their call; (c) PBI-054 views and PBI-052 views edit the same files (`month_view`, `week_view`, `list_view`) sequentially: schedule PBI-052 views first, PBI-054 after, written in the plan; (d) the back button and auto-save depend on the Settings dialog header zone (UIC-14) and Nakamura's hook: state who goes first (Nakamura 1 h on day 1 before Yamamoto's back button); (e) PBI-048: options land day 1 but lint fixes in day 4 collide with the Sprint 007 findings still open (see 8).
7. **Acceptance criteria that are not fully testable.**
   - PBI-050: "saves automatically when it loses focus" needs a definition for tests (page change, close, back button; and the Admin and Calendar panes). Name the panes covered.
   - PBI-051: "two columns to save space", "narrow windows fall back" need a width (use the existing breakpoint token or name one) and a test at 320, 400, 800 px.
   - PBI-046: "intermediate frames" is fine; add which popup types are enumerated (a test that finds every popup type, as UIC-43 does).
   - PBI-052: 4.5:1 is testable; add "text color is derived from the chip fill" check for the Week all-day bar, the chip in Month, List dot/bar and print (print is only a layout check; say so).
   - PBI-054: CAL-09.c labels need a case list: timed multi-day in 12 h and 24 h formats, an event ending at 00:00, three-day events (middle `msg:cont`), and Month view clipping.
8. **Sprint 007 findings not carried into this plan.** Still open and not scheduled: English `orElse` fallbacks and the `TODO(arb)` shim (finding 3 of the 007 review, owners Nakamura and Ito), THM-10.d opened-event shadow and hour-density menu elevation (finding 4; UIC-43 and THM-10.d are over-stated), SET-10 test names (finding 5), SET-03.k and UIC-44 over-statement and DEF-01 rows (findings 1, 2), tokens-only literals (finding 7). The plan mentions only the arb rule. Change: put findings 3, 5 and the over-stated rows into PBI-048 or Wave 3 as named tasks (each is under 1 h) and record the others as backlog items in the Review, so DoD "known limitations recorded" is met.
9. **PBI-034 acceptance gate and usage of PBI-048.** The rule "PBI-034 not accepted until PBI-052" is good. PBI-048 adds `avoid_catches_without_on_clauses`, which will flag `catch (_)` in `main.dart`, `bootstrap.dart`; that is Nakamura's and already budgeted. Confirm 2 h for Tanaka's options covers a first analyzer run; the fixes are budgeted at 11 h overall, which is optimistic for seven lints across the whole tree: put the cut order's "lints beyond the three strict modes" at the front of the cut order (it is second now).

### Low
10. Plan item "Kobayashi must confirm no leave" is addressed to Kobayashi; he cannot know it. Ask the Product Owner (decision 3 already does).
11. `daily_scrum.md` is only Day 1 and correct; the Sprint 007 stale line about overflow failures is gone. Add a Waves line and the 65% reading.
12. Definition of Done in the plan matches `scrum/definition_of_done.md`; add the line "known limitations recorded" explicitly (carry the open items from finding 8).
13. The cut order lists PBI-054 print slice before PBI-047 polish; the Product Owner asked for color in print (EVT-03.b), so cutting it needs the Product Owner's consent; state that.

## Product Owner requests since Sprint 007 started: coverage
| Request | In plan? |
|---|---|
| Multi-day labels 18:00- and -04:00 (CAL-09.c) | Yes, PBI-054 |
| Event color in every view (EVT-03.b) | Yes, PBI-054 (Week all-day chip gap included) |
| Reset buttons error-role look | Yes, PBI-053 (row missing) |
| Settings back button | Yes, PBI-050 (UIC-45 exists) |
| Auto-save | Yes, PBI-050 |
| Theme: press-and-hold to Theme, two columns, titled rules | Yes, PBI-051 |
| Popup transitions | Yes, PBI-046 (row missing) |
| Pale-color contrast | Yes, PBI-052 (THM-10.h) |
Nothing the Product Owner asked for is missing.

## Exact changes needed before the sprint starts
1. Re-anchor Usage on 65%; get the weekly reading; reduce scope or get the Product Owner's explicit acceptance of stopping at Warning (finding 1).
2. Rebalance hours by owner against 20 h each (finding 2); update `sprint_backlog.md` totals.
3. Make PBI-040 an epic (children PBI-054, PBI-055, PBI-056) and fix PBI-045/PBI-053 as in finding 3; add row ids to PBI-053 and PBI-054; start child descriptions with "Part of PBI-xxx:".
4. PBI-050 cites UIC-45 and drops the extra SET row; add rows for popup transitions (PBI-046) and the Reset look and header-zone fit (PBI-053) with named owners (finding 4).
5. Fix the ownership table: `theme.md` single editor; who edits `common.md` rows; cross-owner popup and Reset calls get hours in each owner's list; where the press-and-hold setting lives (finding 5).
6. Add the order lines in finding 6 and the testability details in finding 7.
7. Schedule the Sprint 007 findings 3, 5 and the over-stated rows (finding 8).
8. Product Owner approves the changed plan; only then do developers start.
