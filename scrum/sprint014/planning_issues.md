# Sprint 014 planning issues (kept after the plan was reverted)

The Executive reverted Sprint 014 to its pre-sprint state (held, draft plan, PBI-094, PBI-086 and PBI-087 back to Backlog). These are the problems the first planning attempt found, so the next attempt starts with them solved. A copy of the revised plan, sprint backlog, handoffs and requirement edits is in the orchestrator's scratchpad, not in the repository.

## Kobayashi's plan review

`scrum/sprint014/kobayashi_plan_review.md` (22 findings: 6 High, 10 Medium, 6 Low) is kept as written. The High ones:

- F1 The usage estimate must use the Executive's latest reading and say when it reaches the 70% Caution.
- F2 The wave 2 integration test needs an owner for the ScrumBoard `pubspec.yaml` and a memory-store entry point in `server/`.
- F3 `Store` needs `getIssue`; the status-move check and write must not race.
- F4 Issues API security: refuse `http://` to a non-local host, constant-time token compare, minimum token length, no redirects and a timeout, field and body limits (numbers go in DEF-01).
- F5 The question number was not stable. Rewritten below.
- F6 The Accept effect needs an order, a failure rule and idempotence.

Others: F7 `PUT /api/sprint` can bypass lifecycle rules; F8 two new sprint-file columns break the writer (`_parseBlock`, `_sameCells` require 7 cells); F9 numbers belong in DEF-01 and `requirements/common.md` has no owner; F10 a wave 1 dependency between Tanaka's `main.dart` and Yamamoto's file; F12 SCB-17.e is not met by an in-memory "new" flag; F13 an answer can inject lines into `scrum/questions.md`; F17 and F18 unowned files (`reload_scope.dart`, `docker/*`, README).

## F5 under the Executive's rule (corrected)

Question numbers do not change while a question is open; when its pair is deleted the number is free and a new question takes the lowest free number (`AGENTS.md`, "Questions"). So a number can be reused for a different question between the page's read and the Executive's click. The answer call must send the number and the heading text and refuse with a reason when they differ; test: "pair deleted and number reused after the page read it".

## Executive's decisions (2026-11-24)

- F2: the integration test runs against `server/tool/memory_server.dart` (in-memory store, fixed token, free port), added by Tanaka and started by Nakamura's test; skipped with a recorded reason when `dart` is missing.
- F12: no `Seen:` line. A question is new because it was just asked: the column's count badge is the "new" marker, and the plan must not add a persistent seen mark. SCB-17.e's wording ("until the Product Owner has seen it") no longer fits and needs a requirement change, to be written in the statement edits.
- F15: Start on a paused sprint lifts the pause and starts the sprint in one press (pressing Start is the Executive's word "start", `AGENTS.md`, "Start").
- F19: not a question. Takahashi writes the statement cells and DEF-01 rows before wave 0, as in Sprint 013.
- F4: only the basic token check, a timeout on the board's call and size caps stay in this sprint. The `http://` refusal, no-redirect rule, constant-time comparison and minimum token length are deferred until there is an install script and a deployment; they still need a backlog item.

## Suzuki's consult

- Lead the goal with the Questions column and the lifecycle buttons; the issue database is the base, not the value.
- PBI-086 says SCB-17.a to e but SCB-17.e is partly met; correct the row.
- SCB-02 says `SCRUM.d/sprint.md` while the server reads `scrum/sprint.md` (F22): settle which.

## Tanaka's task check

Wave 0 at 3 points is tight (about 1.2 days). `createdAt` is described inconsistently; the `issues` table has no migration home; DEF-01 row names are not fixed; `Store.createIssue` needs a stated number rule (serial); `ServerConfig.fromEnv` needs `issuesToken`; `server/pubspec.yaml` needs `crypto`; `server/tool/` does not exist; the `PORT=<n>` line of `memory_server.dart` must be fixed because Nakamura's test relies on it.

## Ito's task check

Wave 0 is a full day with no slack; wave 1 chip and button is 0.5 not 1. The chip and button go in `_BlockCard` (`backlog_timeline.dart`) and need an `onSprintAction` callback plus a page call to `api.sprintAction` (page is Tanaka's). `nextToRun` needs a fixed signature (`List<Map<String, dynamic>>`). Decide who writes `scrum/questions.md` through a temporary file (answerQuestion stays pure text). The client may import `lib/server/sprint_lifecycle.dart` only while it has no `dart:io`. Wave 1 needs Yamamoto's keys in the generated l10n first.

## Process findings

- The planning meeting needs Suzuki, Ito and Tanaka before Kobayashi's review, as `sprint-planning` says; one agent wrote the first plan alone.
- Agents were launched without the model names the skills give.
- Usage: the file `scrum/usage.md` now has "Asking for a reading"; ask for a reading at every sprint start.
