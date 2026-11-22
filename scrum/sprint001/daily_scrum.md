# Sprint 001 Daily Scrum

## Day 1 (2026-11-21)
- Done: requirements approved (1,433 rows `backlog`); evidence column and oracle removed; Flutter project created (web, Android; `flutter analyze` and `flutter test` pass).
- Today: finish T01 (per-requirement test reporting), start T02 (UTC event model).
- Impediments: the Windows desktop target is not supported on this machine (Flutter reports missing desktop support).

## Day 1, later (2026-11-21)
- Done: T01 to T12. Time model (TIM-01 to TIM-08, TIM-10), theme tokens and IBM Plex fonts (THM-01.a-d, THM-02.a-m), shared dropdown (UIC-12, UIC-13), Month view (CAL-01.a, d, i), Week view (CAL-01.c, h), view switching (CAL-01.b for Month and Week). 41 tests pass, `flutter analyze` is clean, `flutter build web` succeeds. 34 requirement rows are `planned` with their test file recorded (`dart run tool/req_coverage.dart`).
- Not verified: the app has not been run and looked at in a browser; Windows desktop is unavailable here.
- Known limits: events are held in memory only (no database yet, so TIM-01 is verified on the stored JSON form); CAL-01.b covers Month and Week only; month names and weekday labels are English only; week starts on Sunday (as PRT-02.a says for print).
- Left for T13: Definition of Done pass and the Review with the Product Owner. Rows become `done` only after acceptance.
