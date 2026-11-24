# ScrumBoard

A local web page (Flutter web) and a small Dart server. The server listens on 127.0.0.1 only, serves the built page
and gives it the requirements, the sprint file, the agent progress and the usage file (SCB-13).

This is a separate package. It has no dependency on the root app.

## Start

From the repository root, after the page is built (see Build):

```
cd scrum/scrumboard && dart run bin/server.dart
```

Then open http://127.0.0.1:8081.

Options:

| Option | Default | Meaning |
|---|---|---|
| `--port <n>` | 8081 | Port to listen on |
| `--progress <dir>` | none | Folder of agent progress files, each named by the agent's label and holding `done/total`. It must exist |
| `--root <dir>` | `../..` | The repository. The server reads `requirements/`, `scrum/sprint.md`, `scrum/usage/usage.log`, `scrum/questions.md` and `scrum/verifications.md` there and refuses any path outside it |
| `--web <dir>` | `build/web` | The built page |
| `--usage-script <path>` | `scrum/usage/usage.sh` | The usage script run for the estimate and the trend. A relative path is taken from `--root` |
| `--bash <path>` | Git Bash on Windows, `bash` elsewhere | The bash that runs the usage script. On Windows the default is `<git>\bin\bash.exe` for a `git.exe` on PATH, then `C:\Program Files\Git\bin\bash.exe`, then the first `bash.exe` on PATH; never a bash under `System32`, `Sysnative` or `WindowsApps` (the WSL launchers). With no Git Bash found, the usage answers say so |

The server writes these files, and no others (all under `--root`, one write at a time):

- `scrum/sprint.md` (`PUT /api/sprint`);
- the requirement file that holds the row (`PUT /api/requirements/{id}/status`), and that file plus
  `requirements/retired.md` (`POST /api/requirements/{id}/retire`);
- `scrum/questions.md` (`PUT /api/questions/{n}/answer`);
- `scrum/verifications.md` (`PUT /api/verifications/{n}/result`).

Each of these files is replaced whole through `<file>.tmp` and a rename. It holds no token or secret.

It runs one process only: the usage script through bash, as `<bash> <usage script> estimate` or
`<bash> <usage script> trend`, in the repository folder (SCB-14.o, `lib/server/usage_script.dart`). These two
arguments are fixed in the server; nothing from the page or the request reaches the process. It is not started
through a shell. A run that takes over 10 seconds is stopped.

## Build

```
cd scrum/scrumboard
flutter pub get
../../tool/sync_messages.sh
flutter build web --release --no-web-resources-cdn
```

The repository's `tool/sync_messages.sh` (`../../tool/sync_messages.sh` from `scrum/scrumboard`) copies `requirements/messages/*.arb` into `assets/messages/`. Run it before every build.

## API

All answers are JSON in UTF-8. An error is `{"error": "<reason>"}`: 403 for a wrong Host or Origin, 404 for any
other request, 413 for a body over the limit, 400 for a write body that is not valid (each write route below says
when). Nothing is written when the answer is 400 or 413.

| Request | Answer |
|---|---|
| `GET /api/requirements` | `[{id, status, statement, feature, file}]` |
| `GET /api/sprint` | `{exists, blocks, members}` |
| `PUT /api/sprint` | the same shape; written at once, keeping the text the board does not edit |
| `GET /api/progress` | `[{label, done, total}]` |
| `GET /api/usage` | `{exists, rows}` |
| `GET /api/usage/estimate` | `{ok, output, reason}`: runs the usage script with `estimate` |
| `GET /api/usage/trend` | `{ok, output, reason}`: runs the usage script with `trend` |
| `PUT /api/requirements/{id}/status` | body `{"status": "<status>"}`; answers `{ok, reason}` |
| `POST /api/requirements/{id}/retire` | no body; answers `{ok, reason}` |
| `GET /api/changes` | `{stamp}` |
| `GET /api/questions` | `{"questions":[item],"verifications":[item]}`, each item `{kind, number, heading, status, text, choices, pbi, answer}` |
| `PUT /api/questions/{n}/answer` | body `{"heading": "<text>", "answer": "<text>"}`; answers `{ok, reason}` |
| `PUT /api/verifications/{n}/result` | body `{"heading": "<text>", "result": "<text>", "status": "accepted" or "returned"}`; answers `{ok, reason}` |

`PUT /api/requirements/{id}/status` sets the status cell of that requirement's row, in its own file, and changes no
other character (SCB-13.c, SCB-13.d, `lib/server/requirement_status.dart`). The status is trimmed and taken in lower
case. Allowed moves are up through `proposed`, `backlog`, `planned`, `done`, and the one move down `planned` to
`backlog`; any other move, an unknown status or an unknown ID answers 200 with `ok` false and the reason. A body that
is not JSON, or has no string `status`, is 400.

`POST /api/requirements/{id}/retire` moves the whole row of that requirement from its file to
`requirements/retired.md` (created when missing), with today's date and a fixed reason (SCB-19.a,
`lib/server/requirement_retire.dart`). Both files are written, or neither. An unknown ID answers 200 with `ok` false.

`GET /api/changes` answers a stamp built from the names, modified times and sizes of the requirement files, the
sprint file, the usage file, the questions and verifications files and the progress files (SCB-22); the page reloads
when it changes.

`GET /api/questions` reads `scrum/questions.md` (kind `question`) and `scrum/verifications.md` (kind `verification`)
for the Questions and Verifications column (SCB-17, `lib/server/board_items.dart`). Each item is one `## <n>. <heading>`
section; the heading inside the ``` Format block is skipped, and CRLF and LF files both read. `status` is the item's
Status line in lower case, `text` its Question or Verify text, `choices` the indented lines under a question (empty
for a verification), `pbi` the heading's first word when it is `PBI-<n>` (verifications only, else null), and
`answer` its Answer or Result text. Each list holds every status: open items first, then answered or closed ones,
newest first (reverse file order) within each (SCB-17.c). A missing file gives an empty list. Both files are part of
the change stamp (`GET /api/changes`, SCB-22), so a change to either reloads the board.

`PUT /api/questions/{n}/answer` writes the answer of a question in `scrum/questions.md`, and
`PUT /api/verifications/{n}/result` the result of a verification in `scrum/verifications.md` (SCB-17.b,
`lib/server/board_item_write.dart`). `{n}` is the item number, 1 to 9 digits; any other method or path under these
routes is 404. `heading` is the text after `## <n>. `, as `GET /api/questions` gives it.

- Written: 200 `{"ok": true, "reason": ""}`. The file is read again for each write. Only the item with that number
  AND heading changes (an open one first when two match; the ``` Format block is never matched). Its `Status:` line
  becomes `Status: answered` (question) or `Status: accepted` / `Status: returned` (verification), and its `Answer:` /
  `Result:` line becomes `Answer: <answer>` / `Result: <result>` on one line (`Result:` alone for an empty accepted
  result); that field's old continuation lines are dropped. A missing `Status:` line is added after the heading, a
  missing field line after the item's last text line. The answer and result are written as sent, not trimmed.
- Gone: 200 `{"ok": false, "reason": "gone"}` when no item has that number AND heading (the heading changed, the
  item was deleted, or the file is missing). Nothing is written.
- 400 `{"error": "<reason>"}`: the body is not JSON or not an object; `heading`, `answer` or `result` is missing or
  not a string; `heading`, `answer` or `result` holds a line break (`\n` or `\r`); the answer is empty or blank;
  `status` is not exactly `accepted` or `returned`; or `returned` comes with an empty or blank result. 413 for a body
  over the limit. Nothing is written in any of these.
- Line endings: every other byte of the file stays, and each line keeps its own line end. An added line takes CRLF
  when the file has any CRLF, else LF, so a CRLF file stays CRLF (Windows) and an LF file stays LF.
- Known limitation (Windows): while another program holds `scrum/questions.md` or `scrum/verifications.md` open,
  a write answers 500 `{"error": "internal error"}` (the rename is denied). The file is unchanged and no `.tmp`
  stays; the same write succeeds once the file is closed.

For the two usage-script requests, `ok` is true when the script exits with 0, and `output` is what it printed.
Otherwise `ok` is false and `reason` says why: the script's own output for another exit code, or that bash or the
script was not found, bash could not start, or the run timed out. Both answer with 200.

## Check

```
flutter analyze
flutter test
```
