# Sprint 011 Retrospective (approved by the Executive)

## What went well

- Waves 0 to 2 built the project, server, page, Backlog timeline and Features column; all tests named with SCB IDs.
- Both reviews ran before the Executive saw anything.

## Reviews

- Kobayashi plan review (`kobayashi_plan_review.md`): findings were folded into the plan before the build.
- Watanabe server review (`watanabe_server_review.md`): findings were fixed in `bin/server.dart` (security fixes in the wave 1-2 commit); the server check above confirms Host 403 and 404.

## Executive messages

- Message 4 (PBI-076) and the mid-sprint message (PBI-089) were recorded as backlog and not built; the sprint scope stayed PBI-077 to PBI-080.

## Impediments

- Port 8081 was held by another process during the build, then free; the server check ran once it was free.
- The Nakamura tool run died once and was resumed.

## Rule gaps (for Suzuki to fix)

- SCB-02 and SCB-14 say `SCRUM.d/sprint.md`; the files live under `scrum/`. Reword.
- SCB-13.b lists a messages endpoint that this slice does not have; split or mark it.
- Start rule: the rule for "start" does not cover "do sprint 11" (a sprint start by number).

## Actions

- Suzuki: the three rule fixes above.
- Executive: the browser check in the review, then accept or return the slice.
- Usage: after-reading in `scrum/usage.md` is an orchestrator estimate; replace it with the real reading.

## Executive decisions at the close

- Approved by the Executive after the sprint: "because it was a weird sprint without our pause rule. accept the retro and merge." Sprint 011 was run before the sprint pause, the Start and Pause buttons and the sprint-limit rules existed, so the epic was treated as needing approval; from now on the epic runs under the sprint pause rule.
- New terms and rules written after this sprint: sprint pause (and "pause at N"); the Executive may move backlog items into sprints; the usage chart asks for and takes readings (SCB-14.l to SCB-14.n); the measured usage rate wins (2.7 points per 100k tokens).
- Rule test result: a fresh orchestrator found AGENTS.md first and followed it; the one block was the permission system denying a merge to main by a sub-agent.
