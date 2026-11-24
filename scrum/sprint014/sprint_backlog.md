# Sprint 014 Backlog

Sprint goal: the ScrumBoard fixes from the Executive's look at Sprint 013 (one zoom icon, token at the row end, theme and zoom kept, no missed first change) and the server giving the usage estimate and trend from `usage.sh`.

| PBI | Title | Points | Owner | Status |
|---|---|---:|---|---|
| PBI-107 | ScrumBoard sees a change in its first 2 seconds | 1 | Tanaka | Built Day 1; tests pass |
| PBI-102 | ScrumBoard zoom is one icon | 1 | Tanaka | Built Day 1; tests pass |
| PBI-103 | ScrumBoard status token at the end of the row | 1 | Yamamoto | To do (wave 1) |
| PBI-108 | One status choice helper for the column and the Backlog block | 1 | Ito, Yamamoto | Helper and Backlog block built Day 1; column use to do (wave 1) |
| PBI-109 | ScrumBoard block width from a theme token | 1 | Tanaka, Ito | Token built Day 1; `BoardTokens` use to do (wave 1) |
| PBI-104 | ScrumBoard remembers its theme and zoom between starts | 1 | Tanaka | Built Day 1; tests pass |
| PBI-106 | ScrumBoard runs usage.sh for estimate and trend | 3 | Nakamura | Built Day 1; tests pass |

Burndown (points not built): Day 0: 9; Day 1: 3. Wave 2 (integration run, web build, server check) and the Kobayashi review of wave 0 are still to do.

Total: 9 points. PBI-108 is counted once (Ito's helper and Yamamoto's column use); it changes one behaviour: the Features column's 'backlog' choice now also removes the requirement from its story (SCB-07.f). PBI-106 ends at the server, API, fake and tests; its two chart clauses moved to PBI-084.
