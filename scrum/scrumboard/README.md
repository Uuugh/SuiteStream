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
| `--root <dir>` | `../..` | The repository. The server reads `requirements/`, `scrum/sprint.md` and `scrum/usage/usage.log` there and refuses any path outside it |
| `--web <dir>` | `build/web` | The built page |

The server writes one file only: `scrum/sprint.md` (`PUT /api/sprint`). It runs no shell and no process, and holds
no token or secret.

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

## Check

```
flutter analyze
flutter test
```
