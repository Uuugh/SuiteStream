# Daily Scrum Record - Sprint 014

> The purpose of the Daily Scrum is to inspect progress toward the Sprint Goal, adapt the Sprint Backlog as needed, and adjust upcoming work. It is a 15-minute event for the Developers.
> — Scrum Guide 2020

Sprint goal (`sprint_planning.md`): one zoom icon, status tokens at the row end, theme and zoom kept across restarts, no missed first change, and the server giving the usage estimate and trend from `usage.sh`.

---

## 2026-11-24 (Day 1)

### Participants
- Tanaka, Ito, Nakamura (wave 0), Yamamoto (wave 1, waits on Ito's helper), Takahashi (Scrum Master).
- How it ran: one agent did every role's work in turn, keeping to the plan's file ownership; the roles were not run as separate sub-agents, and no separate Kobayashi review ran today (see Impediments).

### Progress and Plan
| Member | Work completed yesterday | Plan for today | Impediment |
|---|---|---|---|
| Takahashi | Sprint 014 planning | Plan status set to running; requirement rows written: SCB-20, SCB-20.a rewritten, SCB-13.b two usage requests, new SCB-14.o, SCB-23, SCB-24; built rows set to `planned` with tests | None |
| Tanaka | - | PBI-109 token `scrumBlockWidth`; PBI-107 baseline stamp at start; PBI-102 one drawn zoom icon with two halves; PBI-104 theme and zoom kept (`board_prefs*.dart`) | None |
| Ito | - | PBI-108 `applyStatusChoice` (`lib/src/board/status_choice.dart`); the Backlog block uses it; helper test | None |
| Nakamura | - | PBI-106 `usage_script.dart`, two routes, `--usage-script` and `--bash`, Git Bash lookup, API client and fake, fake scripts, SCB-01.a test narrowed | None |
| Yamamoto | - | Wave 1 (Day 2): PBI-103 token position (SCB-23), PBI-108 column use | Waits on Ito's helper (landed) |

### Results (Day 1)
- `flutter analyze` in `scrum/scrumboard`: no issues. `flutter test` in `scrum/scrumboard`: 183 passed, 0 failed (145 at the end of Sprint 013).
- `flutter build web` in `scrum/scrumboard`: built (compiles `board_prefs_web.dart`).
- Root: `flutter analyze` no issues; `flutter test` 596 passed, 0 failed.
- Real `usage.sh` through the server (port 8099, this machine): `/api/usage/estimate` and `/api/usage/trend` answered `ok: true` with the script output. The Executive's own test row stays for the review.
- Deviation from "Fixed names" (Nakamura): the bash lookup does not run `git --exec-path`; it finds `git.exe` on PATH instead, so bash stays the only process (`handoffs.md`).

### Progress Toward the Sprint Goal
Burndown (points not yet built, of 9): start 9, end of Day 1: 3 (PBI-103 1, PBI-108 1 for the column use, PBI-109 1 for `BoardTokens`). Wave 0 is complete.

### Identified Impediments
- No blocking impediment. Process note for Day 2: the independent Kobayashi review of the wave 0 increments has not run; run it before or with wave 1.

---

<!-- Append a new entry each day. -->
