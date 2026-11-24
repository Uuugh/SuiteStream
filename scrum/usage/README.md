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

- Only the orchestrator asks the Executive for a reading: at the start of every sprint, and it records the before and after readings at the sprint's end. Other agents never ask; they read `usage.log` and use `estimate`, `trend` and `project` to plan sprints, stories and epics.
- Run `project` before starting any job.
- Caution (70%): tell the Executive, then continue.
- Warning (85%): do not start the job; split it or wait for the reset (an epic decides alone, otherwise ask).

## How the estimate works

`usage.log` is append-only; `used` says `auto`, and `est_session` and `est_week` hold the estimate after that row. Each run recomputes from rows with a known delta: a row more than 1 standard deviation from the mean of the others is discarded. Under 3 used rows the estimate is low-confidence. A window reset (after below before) makes the delta `?`.
