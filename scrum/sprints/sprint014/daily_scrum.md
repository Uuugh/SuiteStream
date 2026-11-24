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

## 2026-11-24 (Day 2)

### Participants
- Yamamoto, Ito (wave 1), Nakamura (wave 2), Takahashi (Scrum Master); Tanaka has no work left.
- How it ran: as on Day 1, one agent did every role's work in turn under the plan's file ownership; no separate sub-agents and no Kobayashi review (see Impediments).

### Progress and Plan
| Member | Work completed yesterday | Plan for today | Impediment |
|---|---|---|---|
| Tanaka | Wave 0: PBI-107, PBI-102, PBI-104, PBI-109 token | Nothing; done | None |
| Ito | PBI-108 helper and Backlog block | PBI-109: `BoardTokens.blockWidth` = `scrumBlockWidth`; `backlog_timeline_test.dart` checks the width against `scrumBlockWidth` (SCB-06.g) | None |
| Yamamoto | - | PBI-103: token at the end of the first line (`features_column.dart`), SCB-23 position test; PBI-108: `_choose` calls `applyStatusChoice`, column test that backlog removes the Members row (SCB-07.f, SCB-21) | None |
| Nakamura | PBI-106 | Wave 2: integration test, web build, server check | None |
| Takahashi | Day 1 record | Record; SCB-23 to `planned`; test cells of SCB-07.f and SCB-21 add `features_column_test.dart`; PBI-102 to PBI-109 (not 105) to In Review in `product_backlog.csv` | None |

### Results (Day 2)
- `flutter analyze` in `scrum/scrumboard`: no issues. `flutter test`: 186 passed, 0 failed (183 on Day 1; 3 new: one SCB-07.f column test, the SCB-23 test in light and dark at width 320, about a third of the narrowest DEF-01 window).
- `test/integration/app_test.dart`: 3 passed. `flutter build web`: built.
- Root: `flutter analyze` no issues; `flutter test` 596 passed, 0 failed.
- Server check (port 8099, this machine, `--root ../.. --web build/web`): `/api/changes`, `/api/requirements`, `/api/usage/estimate` and `/api/usage/trend` answered 200 (both usage routes `ok: true` with the script output); `/api/nope` 404; `/` serves the built page. Stopped after the check.
- Behaviour change (PBI-108, `sprint_planning.md`): the Features column's 'backlog' choice now removes the requirement from its story.

### Progress Toward the Sprint Goal
Burndown (points not yet built, of 9): Day 0: 9, Day 1: 3, Day 2: 0. All seven PBIs are In Review; requirement rows stay `planned` until the Executive's browser checks.

### Executive's checks for the review
1. Zoom: one icon; the minus half zooms out, the plus half zooms in; each half disabled at its limit (SCB-20, SCB-20.a).
2. Status token at the right end of the first line, sub-rows too, at the DEF-01 sizes, light and dark (SCB-23).
3. Theme and zoom kept after a page reload and a server restart; filters and outline not kept (SCB-24, local storage).
4. Features column: choosing 'backlog' for a story member removes it from the story (SCB-07.f, SCB-21).
5. A change made just after the page opens shows without a second change (SCB-22).
6. Block widths unchanged (SCB-06.g).
7. PBI-106 test row: `/api/usage/estimate` and `/api/usage/trend` against the real `usage.sh` on the Executive's Windows machine (SCB-14.o).

### Identified Impediments
- Process: the independent Kobayashi review (`.github/skills/one-day-in-scrum/SKILL.md`) has not run for wave 0 or wave 1. Not blocking the build; it should run before the sprint review. Logged as IMP-003 in `scrum/impediment_log.csv`.

---

<!-- Append a new entry each day. -->
