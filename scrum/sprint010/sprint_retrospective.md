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
