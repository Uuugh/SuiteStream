# Sprint 006 Daily Scrum

## Day 1 (2026-11-23)

Sprint goal: the Product Owner can see and verify the running SuiteStream calendar in the VS Code preview, and Sprint 005's accepted work is made traceable and sound before more UI is added.

### Done before development started
- Planning round with Suzuki (Product Owner role), Tanaka (developer) and Kobayashi (reviewer). Commitment: 17 points (14 plus PBI-033), see `sprint_planning.md` and `sprint_backlog.md`.
- Kobayashi audited Sprint 005 against the code: `flutter analyze` clean, 168 tests pass; the problems are traceability, scope and verification (see planning).
- The Product Owner kept the ad hoc changes made outside the process (uncommitted edits in `lib/`, `requirements/`, `test/`).
- Developers were started in parallel: Ito on PBI-033, Tanaka on PBI-029, Yamamoto on PBI-027, Nakamura on PBI-026 and PBI-028.

### File ownership (one editor per shared file)
| File area | Owner |
|---|---|
| `cancel_save_pair.dart`, `confirm.dart`, `suite_dialog.dart`, `tokens.dart`, `suite_theme.dart` | Tanaka |
| `event_dialog.dart`, `main.dart` and bootstrap | Ito |
| `settings_dialog.dart`, `calendar_print_dialog.dart`, `local_calendars_dialog.dart`, requirements reconciliation | Yamamoto |
| `web/index.html`, build and serve docs, calendar page radii | Nakamura |
| Backlog hygiene, facilitation (`scrum/` velocity, usage, impediments) | Takahashi |

### Gate
If PBI-026 is not diagnosed and fixed by the end of day 2, UI work (PBI-029/030) stops and the team supports PBI-026.

### Impediments
- IMP-002: Sprint 005 was accepted without the Product Owner verifying it in a browser (Open, addressed by PBI-026).
- Ad hoc changes were made outside the process; the Product Owner kept them, so they are in the working tree without a sprint record.
- No other impediments.

### Animation standard (Tanaka)
- One animation time (`defaultAnimationDuration`, 0.5 s; Settings > General "Animations", 0 = none; reduced motion = 0) now drives all Cancel | Save slide, pulse and hover. `pairWordFade` removed. DEF-01 hold kept (3 s, counted from the press, so it includes the slide).
- Files: `cancel_save_pair.dart`, `suite_theme.dart` (`SuiteAnimationScope`), `main.dart`, `calendar_controller.dart`, `settings_dialog.dart`, `length_input.dart`, six `app_*.arb`, tests.

### Hygiene notes
- Velocity rows for sprint003 and sprint004 added; status vocabulary added to `usage.md`.
- Untracked `Microsoft/` at the repo root contains only `Windows/PowerShell/ModuleAnalysisCache` (10 KB, written 2026-11-22 22:59): a PowerShell module analysis cache, apparently created when PowerShell ran with the repo as its data root. It is not project content. Not deleted; the Product Owner decides whether to delete it or add it to `.gitignore`.
