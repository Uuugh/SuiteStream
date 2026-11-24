---
name: execute-sprint
description: Orchestrator for executing one complete Scrum sprint. Performs user requirement analysis, backlog refinement, sprint planning, five days of daily Scrum and development, the sprint review, and the sprint retrospective in sequence.
---

# Execute the Full Sprint

Execute the following steps in order. (Do not execute them in parallel.)

## Before Step 1: Usage
Before any sub-agent starts, ask the Executive for a usage reading and run `project`, as `scrum/usage/README.md` ("When") says.

## Step 1: Organize the User Requirements
Start a sub-agent with Opus and execute the `order-create` skill procedure.

## Step 2: Perform Backlog Refinement
Start a sub-agent with Opus and execute the `backlog-refinement` skill procedure.

## Step 3: Perform Sprint Planning
Start a sub-agent with Opus and execute the `sprint-planning` skill procedure.

## Step 4: Perform the Daily Scrum and Development (5 Days)

- **DAY1**: Perform the daily Scrum and development.
 (Start a sub-agent with Opus and execute the `one-day-in-scrum` skill procedure.)
- **DAY2**: Perform the daily Scrum and development.
 (Start a sub-agent with Opus and execute the `one-day-in-scrum` skill procedure.)
- **DAY3**: Perform the daily Scrum and development.
 (Start a sub-agent with Opus and execute the `one-day-in-scrum` skill procedure.)
- **DAY4**: Perform the daily Scrum and development.
 (Start a sub-agent with Opus and execute the `one-day-in-scrum` skill procedure.)
- **DAY5**: Perform the daily Scrum and development.
 (Start a sub-agent with Opus and execute the `one-day-in-scrum` skill procedure.)

## Step 5: Perform the Sprint Review
Start a sub-agent with Opus and execute the `sprint-review` skill procedure.

## Step 6: Perform the Sprint Retrospective
Start a sub-agent with Opus and execute the `sprint-retrospective` skill procedure.

## Web check and icon glyphs

- Web check: `flutter build web --release --no-web-resources-cdn`, served from `build/web` on port 8080. The service worker caches, so ask the Executive to hard-refresh.
- New icon glyphs: add them to `lib/src/theme/suite_icons.dart`, then run `tool/update_icon_font.sh` (it rebuilds the font subset; Tanaka owns icons and the font assets).
