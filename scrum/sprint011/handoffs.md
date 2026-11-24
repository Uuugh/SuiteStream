# Sprint 011 Handoffs

Owners publish here what others need. Package: `scrum/scrumboard` (name `scrumboard`, imports are
`package:scrumboard/...`). Written by Nakamura, wave 0.

## Dependencies

| Package | Version | Where | Why |
|---|---|---|---|
| `http` | 1.6.0 (exact; the root app pins the same) | `dependencies` | API client |
| `flutter_lints` | ^6.0.0 | `dev_dependencies` | same as the root app |

No other package. The server uses only `dart:io` and `dart:convert`. Nobody adds a package without naming it here
with an exact version first.

`pubspec.yaml` declares the asset folder `assets/messages/` (Yamamoto's generated copies; `assets/messages/.gitkeep`
keeps the folder present until the copies exist). Nakamura owns the pubspec; ask for any further asset or font entry.

## Commands

- `flutter analyze` and `flutter test` in `scrum/scrumboard`.
- Server: `dart run bin/server.dart [--port 8081] [--progress <dir>] [--root ../..] [--web build/web]`.
- Strict analysis (same options as the root app): `strict-casts`, `strict-inference`, `strict-raw-types`, and
  `always_use_package_imports` (use `package:scrumboard/...`, never a relative import). Write `<Object>[]` or a typed
  list for an empty list in a `Map` literal.

## API contract

All answers are JSON in UTF-8. Error: `{"error": "<reason>"}`. 403 wrong Host or Origin, 404 any other request,
413 body over the limit (1 MiB; Tanaka's DEF-01 row "ScrumBoard request body limit" must say the same), 400 a
sprint body that is not valid.

| Request | Answer |
|---|---|
| `GET /api/requirements` | `[{id, status, statement, feature, file}]`. Order: files by path, rows in file order. `status` is lower case and never blank (a blank cell is `backlog`); an unknown word such as `defect` is passed as written. `feature` is the file name without `.md` (`ccs` for `connections.d/ccs.md`). `file` is relative to the repository (`requirements/connections.d/ccs.md`). Every `.md` under `requirements/` and under its `*.d` folders is read, except `README.md`, `oldkey.md`, `open-questions.md` |
| `GET /api/sprint` | `{exists, blocks:[{id, kind, name, parent, assignee, estimate, usage}], members:[{block, item}]}`. `kind` is `story`, `epic` or `sprint`; `parent`, `assignee` are a string or null; `estimate`, `usage` a number or null; `item` is a requirement ID or `#N`. A missing file is `{exists:false, blocks:[], members:[]}` |
| `PUT /api/sprint` | body `{blocks, members}` (the shape above); answer is the file as written. Creates the file. No UI writes it this sprint |
| `GET /api/progress` | `[{label, done, total}]` (empty with no `--progress`) |
| `GET /api/usage` | `{exists, rows:[{block, estimateSession, estimateWeekly, beforeSession, beforeWeekly, afterSession, afterWeekly}]}` (percent numbers, null for a dash). Always `rows: []` this sprint |

The sprint file is `scrum/sprint.md` under `--root` (path per PBI-049). Its Blocks table has the columns
ID, Kind, Name, Parent, Assignee, Estimate, Usage; its Members table has Block, Item.

## Client: `package:scrumboard/src/api/scrumboard_api.dart`

It exports the data classes (`models.dart`). Panes take the abstract type, never `HttpScrumBoardApi`.

```dart
abstract class ScrumBoardApi {
  Future<List<Requirement>> requirements();
  Future<SprintFile> sprint();
  Future<SprintFile> saveSprint(SprintFile file);
  Future<List<ProgressEntry>> progress();
  Future<UsageData> usage();
}

class HttpScrumBoardApi implements ScrumBoardApi {
  HttpScrumBoardApi({required Uri baseUri, http.Client? client}); // main.dart passes Uri.base
}

class FakeScrumBoardApi implements ScrumBoardApi {
  FakeScrumBoardApi({
    List<Requirement> requirementList = const [],
    SprintFile sprintFile = const SprintFile(exists: false),
    List<ProgressEntry> progressList = const [],
    UsageData usageData = const UsageData(exists: false),
    Exception? failWith,       // every call throws it (test SCB-01.f, SCB-13.h)
    Duration delay = Duration.zero,
  });
  final Map<String, int> calls; // 'requirements', 'sprint', 'saveSprint', 'progress', 'usage'
}
```

Errors (what a pane must catch, and the message it shows):

- `ScrumBoardApiException(reason, statusCode)`: the server answered with an error, or the page could not be read.
  Show `msg:scbLoadFailed` with `{reason}` = `e.reason` (SCB-01.f).
- `ScrumBoardUnreachableException(reason)`: no answer at all. Show `msg:scbServerUnreachable` with
  `{reason}` = `e.reason` (SCB-13.h).

Each pane shows its own message in its own area; the other panes keep working.

Data classes (all `const`, with `fromJson` and `toJson`):

```dart
class Requirement {
  const Requirement({required String id, required String status, required String statement,
      required String feature, required String file});
  String? get parentId; // drop the last '.segment': SCB-11.a -> SCB-11; null at the top (decision 5)
}
class SprintBlock {
  const SprintBlock({required String id, required String kind, required String name,
      String? parent, String? assignee, num? estimate, num? usage});
}
class SprintMember { const SprintMember({required String block, required String item}); }
class SprintFile {
  const SprintFile({required bool exists, List<SprintBlock> blocks = const [], List<SprintMember> members = const []});
}
class ProgressEntry { const ProgressEntry({required String label, required int done, required int total}); }
class UsageRow { const UsageRow({required String block, num? estimateSession, ... num? afterWeekly}); }
class UsageData { const UsageData({required bool exists, List<UsageRow> rows = const []}); }
```

## Reload (SCB-01.c): `package:scrumboard/src/api/reload_scope.dart`

`ScrumBoardPage` (Tanaka) creates one `ReloadController`, wraps its body in
`ReloadScope(controller: c, child: ...)`, and calls `c.reload()` from the Reload control (msg:scbReload).
Each pane (Ito, Yamamoto), in its `State.didChangeDependencies`, reads `ReloadScope.generationOf(context)` and loads
again when the number differs from the one it last loaded with (it also loads once at start). Without a scope the
number is 0, so a pane test needs no scope.

## Widget names and constructors (fixed)

| Widget | Owner | File | Constructor |
|---|---|---|---|
| `ScrumBoardPage` | Tanaka | `lib/src/app/scrumboard_page.dart` | `const ScrumBoardPage({super.key, required Widget board, required Widget features})` |
| `BacklogTimeline` | Ito | `lib/src/board/backlog_timeline.dart` | `const BacklogTimeline({super.key, required ScrumBoardApi api})` |
| `FeaturesColumn` | Yamamoto | `lib/src/features/features_column.dart` | `const FeaturesColumn({super.key, required ScrumBoardApi api})` |

- `ScrumBoardPage` puts `board` in the top row (40 %) and `features` in the first third of the bottom row (40 %); the
  middle row and the Issues and Questions columns are empty placeholders. It owns the `Scaffold`, the Reload control
  and the `ReloadScope`. It does not take the API (the panes do).
- A pane does not build its own `Scaffold` or `MaterialApp`; it fills the space the page gives it and scrolls inside
  (SCB-15.b). Widget tests wrap a pane in `MaterialApp(home: Scaffold(body: SizedBox(width: ..., height: ..., child: pane)))`
  with the messages delegate from `lib/src/l10n/*` (Yamamoto publishes its name below).
- The page theme: `lib/src/theme/*` (Tanaka). Messages: `lib/src/l10n/*` (Yamamoto). Both publish their entry
  points below before wave 1 starts.

## Wiring (wave 2, Nakamura), for reference

`lib/main.dart` builds the theme (Tanaka), the message delegates (Yamamoto) and
`ScrumBoardPage(board: BacklogTimeline(api: api), features: FeaturesColumn(api: api))` with
`api = HttpScrumBoardApi(baseUri: Uri.base)`.

## Entry points the other owners publish (fill in)

- Tanaka: theme builder name and file; `ScrumBoardPage` file.
- Yamamoto: delegate/loader name and file; how a test loads the messages; how a widget reads a message
  (`context`-based call).
- Ito: nothing more.

## Notes

- The usage endpoint is a stub this sprint (decision 3). Nothing on the page shows usage.
- `assets/messages/.gitkeep` was created by Nakamura only so the declared asset folder exists; Yamamoto may delete
  it once the copies are there.
