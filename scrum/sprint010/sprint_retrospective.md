# Sprint 010 Retrospective (DRAFT, awaiting Product Owner approval; then Takahashi merges `sprint010` into `main`)

**Went well:** four developers plus Suzuki and Kobayashi ran in parallel waves with one editor per file and no restores; Kobayashi's plan review caught ownership gaps and the unrealistic stack scope before work began (split into 063a built and tested, 063b written not verified); the fifth-retrospective audit (due since Sprint 006) finally ran with the flutter-dart-code-review checklist; cheap findings were fixed in the same sprint; 518 Flutter and 27 server tests pass, analyze 0 issues, web build green.

**Did not go well:** the first-press delay could not be reproduced and is unproven; the scope grew mid-sprint (Authentik, Watchtower, settings sync) so points are not comparable with earlier velocity; the web build broke on a new icon glyph until the font subset script was run (the check was left to the end); the stack could not be run at all; PBI-057's "resize bar" is ambiguous (see questions); Takahashi had to edit shared constants before wave 1 to unblock four owners (a planning gap).

## Kobayashi audit (fifth retrospective; full text `kobayashi_audit.md`)

Fixed this sprint (cheap): SHL-01.h test path; 26 rows without a test cell; CAP-02 status; DEF-01 header-controls exception; unused `suiteListColorBar*` tokens, `ResizeBar`-free dialog guard; duplicate limit constants; English fallbacks (calendars dialog, print iframe title, dropdown label, palette names); unread status chip setting removed; `isNotNull` test assertions tightened; print IDs; `SwipeDetector.holdTime` default.

Backlogged (prioritized): 1 PBI-064 write `req_check.sh` (README rules unenforced, High); 2 PBI-065 spacing and icon tokens and the rule 1 theme-size exception (about 60 literals; 326 candidate lines outside DEF-01, Medium); 3 PBI-066 verify the Docker stack and a real sign-in (High); 4 PBI-067 split `event_dialog.dart` and trace 85 untraced tests, PBI-041 requirement row (Medium). `lib/src/l10n/*` is now Yamamoto's.

## Actions for the next sprint

Product Owner browser check of the review list (first press-and-hold timing first); decide the open questions; approve the new dependencies; PBI-066 on a machine with Docker; Admin pane push and localCalendars sync decision; SET-05 updater rows reworded for Watchtower; the remaining `Settings stored` rows are fully real only after PBI-066.

## Definition of Done

Proposed change: items that need a running environment that the team lacks (Docker, identity provider) are reported as "built, not verified" and stay In Review; no DoD wording change made.

## Questions for the Product Owner

1. PBI-057 "no resize bar in Settings": no resize bar is drawn there; do you mean the Theme setting "Resize bar size" (it sizes the event bottom-edge handle)? Remove it?
2. First press-and-hold takes 1 s in your browser: is the stored delay stale (Settings > Theme Reset or clear site data) or does it happen after a clean load?
3. Month chips now use the full event color (EVT-03.b, no pale tint): correct?
4. Approve the new dependencies and unchecked image tags (list in the review).
5. Is the header time zone picker a device-only header control (assumed yes), and is language a database setting (assumed yes)?
6. Are local calendars (`localCalendars.v1`) a Setting for the database or event data?

## Product Owner decisions after the sprint

- Dependencies approved: app `http` 1.6.0; server shelf 1.4.3, shelf_router 1.1.5, shelf_static 1.2.0, postgres 3.7.0, http 1.6.0, crypto 3.0.7; Authentik tag 2025.10.1 (not yet checked against a running stack) and the Flutter, Dart and Watchtower images as written (unpinned).
- Resize bar size setting removed from Settings > Theme (PBI-070).
- Language is a database setting (DEF-01: anything in Settings). Still open: whether the header time zone picker is device-only.
- Month chips fill with the full event color: yes (Product Owner: every event is its chosen color in every view). The text rule is PBI-069.
- The header time zone picker is a calendar header control, so it stays on the device (Product Owner: the header icons are stored on the device).
- Local calendars: managed in Settings, so the DEF-01 rule applies and they are stored in the database (applied from the rule; the Product Owner did not answer separately).
- Database retry: DEF-01 now says every 5 seconds for up to 60 seconds (Product Owner); DEP-01.e already points to DEF-01; the server code still uses 2 s (PBI-071).
- Retrospective approval: still pending.

## Round 2 (mini-sprint on the Product Owner's retrospective issues)

Fixed: PBI-068 (Reset on its own side with a shared inline "Are you sure?" confirm), PBI-069 (pure black or white event text, 7:1 where reachable), PBI-070 (Resize bar size setting removed; answers question 1), PBI-071 (server retry 5 s / 60 s from one constant, answers question 7). Still open: questions 2 to 6, first press-and-hold timing, Docker verification (PBI-066). Process note: one agent reformatted many test files, which inflates the diff; ask owners not to run `dart format` over files they do not own.
- ScrumBoard (SCB) page layout decided by the Executive: top row the sprint board (SCB-06); middle row the usage chart and the running agents each with a completion bar of done jobs over total jobs (the sprint backlog gets a Done column) and points; bottom row three columns Features, Issues and Questions. Questions: an answer space after each question and an Answered button; agents read `scrum/questions.md` before making changes, record the decision and delete the answered pair. Requirements SCB-12, SCB-14, SCB-15.a and SCB-17 rewritten; `scrum/questions.md` created.
- Sprint 011 is the ScrumBoard as an epic; each of its sprints needs the Executive's approval before the next one starts (not a usage-split auto epic). A sub-agent plays the orchestrator role for it, as the test of the rules.
- Before approving this retrospective the Executive and the orchestrator clarify the button states; the answers are recorded here.
- ScrumBoard mockup answers (Executive): every section with an add feature has a `+` in its header right zone, the board included (SCB-16.a); top and bottom rows 40 % each, the middle 20 % (SCB-15.a); the Backlog holds features and/or issues and is the queue for a sprint, dragging in or out changes the status in the requirement file or issue tracker while the item stays in its own column (SCB-06.a, SCB-07.i); scrolling reaches older sprints, loaded lazily (SCB-06.f); one Accept per sprint to the right of its usage metric (SCB-08); agent progress as drawn and in two columns; Issues grouped under feature rows (SCB-11.g); Answered to the right of the answer text (SCB-17.b); chips as drawn.
- Assumed, to confirm: dragging out of the Backlog returns the status to `proposed` (SCB-07.i). Corrected by the Executive: the sprints are a timeline, older to the left and newer to the right (SCB-06, SCB-06.e, SCB-06.f); the Backlog position at the right end is my assumption.
- ScrumBoard bottom row: Features, Issues and Questions are each a third of the page width (SCB-15.a).
- ScrumBoard: the Backlog block is as wide as a sprint block (SCB-06.g).
- Decisions from the questions file (Executive): the retrospective is approved after the button states are discussed; the Backlog block is fixed at the left of the board and the sprint timeline scrolls in from behind it (SCB-06, SCB-06.e); dragging out of the Backlog restores the previous status (SCB-07.i); the mockup is to be redrawn; the orchestrator may plan the next sprint at once from the backlog the Executive has contributed to (planning always uses that backlog, so no new rule); the stray folders were already handled by the Executive; the Google credentials belong to the Google module (no action now).
- Mockup v2 answers (Executive): Backlog content and width right; the sprint's Accept becomes a lifecycle button: Start on a planned sprint (inactive unless it is the next to run), Stop while running, then after the work is complete Accept for the retrospective (SCB-08 to SCB-08.e). Pressing Start on the board is the Executive's word "start". Usage over 100 re-asked in plain words.
- Usage over 100 (Executive): 100 is the session break. A projection past 100 is drawn to 100 with a break mark and continues from 0 on a second track for the next session (SCB-14.f rewritten); it is not an error and not warn-colored. The CalendarStream triangle-and-tooltip is not what the Executive wants; the other projection bars (lighter estimate band from the before reading; half-opaque projection ending in a mark) stay as in SCB-14.d and SCB-14.e.
