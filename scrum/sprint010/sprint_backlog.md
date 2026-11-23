# Sprint 010 Backlog

Hours are estimates; Owner = the one editor (see `sprint_planning.md`). Rows stay planned until the Product Owner verifies.

| Item | Task | Hours | Owner |
|---|---|---:|---|
| PBI-057 | Remove resize bar from Settings; Reset beside Close with icon; menu order and hr; tests 320, 400, 800 | 8 | Yamamoto |
| PBI-058 | Status word time setting SET-03.m; Long-press default in pane; arb keys | 5 | Yamamoto |
| PBI-058 | Find and fix the slow first press (controller, `calendar_page.dart`); test | 5 | Nakamura |
| PBI-058 | `CancelSavePair` reads status word time scope; drop 3 s constant | 4 | Tanaka |
| PBI-059 | Fill with event color and `eventTextColorOn` in Week, 5-day, Day; check List and Month; test per view fails on gray | 8 | Ito |
| PBI-060 | Bottom-edge resize in Week, 5-day, Day (CAL-12); `event_resize_test.dart` | 12 | Ito |
| PBI-061 | Title bar transparent; `title_bar_test.dart` light and dark | 3 | Nakamura |
| PBI-062 | Dash only across midnight in the shown zone; tests moving the zone both ways | 6 | Ito |
| Defects | ZonedRow ends text with triple dot below 320 px; info popover close transition | 8 | Tanaka |
| Defects | Replace the 26 px literal in `event_dialog.dart` with a token (Tanaka adds it) | 1 | Ito |
| PBI-063 | `server/` API, Dockerfile, compose (app, Postgres, Authentik, Watchtower), `.env.example` | 16 | Nakamura |
| PBI-063 | Sign-in through Authentik (OIDC code flow) with fake identity provider tests | 10 | Nakamura |
| PBI-037 | Settings API client, load and save, device fallback; header view and filter stay device | 14 | Yamamoto, Tanaka, Nakamura |
| Reviews | Plan review, audit, cheap fixes | 8 | Kobayashi, owners |
| All | Analyze, tests, build, review, retrospective, velocity | 6 | Takahashi |
