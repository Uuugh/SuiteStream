# Usage log

Values are percentages 0-100; `?` or `-` means unknown. Points are optional (`-`): such a row is logged but not used in the estimate. Bad input prints one error and exits 1; nothing is logged, so fix it and run again.

```
bash scrum/usage/usage.sh <model> <session_before> <session_after> <week_before> <week_after> [points] [note]
bash scrum/usage/usage.sh estimate [model]
bash scrum/usage/usage.sh trend [model]
bash scrum/usage/usage.sh project <model> <points> <session_now> [week_now]
```

The first adds one line to `usage.log` and prints the estimate. `estimate` prints it without adding a row. `trend` shows whether the estimate is rising, falling or flat (last 3, within 5%). `project` prints the expected after-reading and whether it crosses a level; with `week_now` it checks the week too. `USAGE_LOG` and `USAGE_TIME` override the log file and the time.

Readings come from the Executive, who pastes `/usage` or the status line. `usage-now.json` is refreshed only by a terminal session, not VS Code.

## When

- The orchestrator asks the Executive for a reading first, before it launches any sub-agent (before Step 1 of `execute-sprint`), and runs `project`. That reading is the sprint's before-reading. The orchestrator also takes the after-reading at the sprint's end and logs both.
- Takahashi fits the sprint to the usage period during sprint planning (Topic 2, scope), using the sprint's before-reading plus an assumed 5% of the session already used by Steps 1 to 3 (and the weekly equivalent, found with the ratio of week to session % per point in `estimate`), and `project`. A scope that does not fit is split; the split stories form an agent-driven epic (`scrum/team_working_agreement.md`).
- Other agents never ask; they read `usage.log` and use `estimate`, `trend` and `project`.
- The model column names the model the orchestrator runs on (for example "Sonnet 5.5"), so that one model's usage data is never used to predict another's (Claude data for GPT). Sub-agent models are not logged separately.
- Caution (70%): tell the Executive, then continue.
- Warning (85%): launch nothing; split or wait for the reset (an epic decides alone, otherwise ask the Executive). Stop and report if a real reading reaches 85% during a sprint.

## How the estimate works

`usage.log` is append-only; `used` says `auto`, and `est_session` and `est_week` hold the estimate after that row. Each run recomputes from rows with a known delta: a row more than 1 standard deviation from the mean of the others is discarded. Under 3 used rows the estimate is low-confidence. A window reset (after below before) makes the delta `?`.
