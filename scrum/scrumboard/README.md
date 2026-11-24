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

The server writes one file only: `scrum/sprint.md` (`PUT /api/sprint`). It holds no token or secret.

It runs one process only: the usage script through bash, as `<bash> <usage script> estimate` or
`<bash> <usage script> trend`, in the repository folder (SCB-14.o, `lib/server/usage_script.dart`). These two
arguments are fixed in the server; nothing from the page or the request reaches the process. It is not started
through a shell. A run that takes over 10 seconds is stopped.

## Build

```
cd scrum/scrumboard
flutter pub get
tool/sync_messages.sh
flutter build web --release --no-web-resources-cdn
```

`tool/sync_messages.sh` copies `requirements/messages/*.arb` into `assets/messages/`. Run it before every build.

## API

All answers are JSON in UTF-8. An error is `{"error": "<reason>"}`: 403 for a wrong Host or Origin, 404 for any
other request, 413 for a body over the limit, 400 for a sprint body that is not valid.

| Request | Answer |
|---|---|
| `GET /api/requirements` | `[{id, status, statement, feature, file}]` |
| `GET /api/sprint` | `{exists, blocks, members}` |
| `PUT /api/sprint` | the same shape; written at once, keeping the text the board does not edit |
| `GET /api/progress` | `[{label, done, total}]` |
| `GET /api/usage` | `{exists, rows}` |
| `GET /api/usage/estimate` | `{ok, output, reason}`: runs the usage script with `estimate` |
| `GET /api/usage/trend` | `{ok, output, reason}`: runs the usage script with `trend` |
| `GET /api/questions` | `{"questions":[item],"verifications":[item]}`, each item `{kind, number, heading, status, text, choices, pbi, answer}` |

`GET /api/questions` reads `scrum/questions.md` (kind `question`) and `scrum/verifications.md` (kind `verification`)
for the Questions and Verifications column (SCB-17, `lib/server/board_items.dart`). Each item is one `## <n>. <heading>`
section; the heading inside the ``` Format block is skipped, and CRLF and LF files both read. `status` is the item's
Status line in lower case, `text` its Question or Verify text, `choices` the indented lines under a question (empty
for a verification), `pbi` the heading's first word when it is `PBI-<n>` (verifications only, else null), and
`answer` its Answer or Result text. Each list holds every status: open items first, then answered or closed ones,
newest first (reverse file order) within each (SCB-17.c). A missing file gives an empty list. Both files are part of
the change stamp (`GET /api/changes`, SCB-22), so a change to either reloads the board.

For the two usage-script requests, `ok` is true when the script exits with 0, and `output` is what it printed.
Otherwise `ok` is false and `reason` says why: the script's own output for another exit code, or that bash or the
script was not found, bash could not start, or the run timed out. Both answer with 200.

## Check

```
flutter analyze
flutter test
```
