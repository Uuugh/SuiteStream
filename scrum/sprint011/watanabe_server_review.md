# Watanabe: ScrumBoard server review (Sprint 011, wave 2)

Scope: `scrum/scrumboard/bin/server.dart`, `scrum/scrumboard/lib/server/*` against SCB-01.a, SCB-13.a-f, SCB-13.i. Static review only; the live server check (foreign Host 403, unknown path 404) is not part of this file.

Verdict: no Critical or High finding. Two Medium/Low items to fix this sprint or next.

## Passes

| Check | Result |
|---|---|
| Bind (13.a) | `HttpServer.bind(loopbackIPv4)`: 127.0.0.1 only. Pass. |
| Host (13.a) | Exact match on `127.0.0.1:<port>` / `localhost:<port>`, missing Host refused. Covers DNS rebinding (rebound name is not in the list). Pass. |
| Origin (13.a) | Checked on every request; `null` and foreign origins refused; absent Origin allowed (non-browser). Pass. |
| CORS | No `Access-Control-*` header sent, OPTIONS gets 404, so no cross-origin read and no preflight success for PUT. Pass. |
| Path traversal | `/api/sprint` uses the fixed literal `scrum/sprint.md`; static files: segments checked for `..`, `.`, `\`, `:`, NUL, then `resolveInside` (symlinks resolved, `isInside` check). `%2e%2e` is decoded before the check. Pass. |
| Writes (01.a) | The only write is `writeSprintFile` to `scrum/sprint.md` (plus its temp file). Pass for this slice. |
| Body limit | `Content-Length` and streamed size both checked, chunked bodies covered. Pass (see SEC-S02). |
| No shell (13.f) | No `Process`, no `dart:io` run call, no token or secret in `lib/server` or `bin`. Pass. |
| UTF-8 (13.i) | Replies declare `charset=utf-8`; files are read and written as UTF-8. Pass. |
| Unknown path (13.b) | Anything else is 404 (non-GET/HEAD static refused too). Pass. |

## Findings

| ID | Severity | Where | Finding | Fix |
|---|---|---|---|---|
| SEC-S01 | Medium | `markdown_table.dart` `joinRow`, `sprint_file.dart` `_validate` | A PUT value (block `name`, `assignee`, `parent`, member `item`) may contain a newline. `joinRow` escapes only `\|`, so the text is written as new lines in `scrum/sprint.md`: it can add headings, table rows or free text that agents read as instructions (injection into the sprint file, CWE-74), and a cell ending in `\` before `\|` round-trips wrongly. Stays inside the one file, but breaks the whole-file integrity SCB-02.f relies on. | Reject (400) any cell containing CR, LF or other control characters; also reject or escape a trailing `\`. Add a test. |
| SEC-S02 | Low | `server.dart` `_readBody` | With an oversize `Content-Length` it calls `request.drain()`, which reads the whole body with no cap (the chunked path stops at 64x the limit). A local client can hold the loop reading an endless body. | Answer 413 and close the connection (`response.close()` then `detachSocket` or `Connection: close`) instead of draining; apply the same 64x cap. |
| SEC-S03 | Low | `sprint_file.dart` `writeSprintFile` | Fixed temp name `scrum/sprint.md.tmp`: two concurrent PUTs share it (one can rename the other's half-written file), and a failed write leaves it behind. It is a second path written beyond `scrum/sprint.md` (01.a says "the sprint file ... and nothing else"). Also `createSync(recursive: true)` can create `scrum/`. | Serialize PUTs (one in-flight at a time), delete the temp file in a `finally`, and name the temp file in the 01.a test. Do not create parent folders. |
| SEC-S04 | Low | `server.dart` `_handle` | `FileSystemException.message` is returned in the 500 body and can show absolute local paths (CWE-209). | Return a fixed `internal error`; log the detail on stderr. |
| SEC-S05 | Info | `server.dart` | No `X-Frame-Options` / `frame-ancestors`, no CSP. A foreign page could frame the board (clickjacking on a local tool). | Add `Content-Security-Policy: default-src 'self'; frame-ancestors 'none'` and `X-Frame-Options: DENY` to static replies (check Flutter web needs `wasm-unsafe-eval`/inline script first). |
| SEC-S06 | Info | `server.dart` `_static` | Windows reserved device names (`/con`, `/nul`) are not filtered; `existsSync` may answer true. Low reach (read-only, GET). | Reject segments whose base name is a reserved device name when `Platform.isWindows`. |
| SEC-S07 | Info | tests | The PUT needs no `Content-Type` check; harmless today because PUT is never a CORS "simple" request and Host/Origin are enforced, but a test that a foreign Origin on PUT gets 403 and nothing is written should exist (SCB-13.a / SCB-01.a). | Add the test. |

## Not yet in scope (check when added)

Requirement status writes (13.c, 13.d), issue commands (13.e, 13.f: `Process.run` with an argument list, `runInShell: false`, UTF-8 decoding of output per 13.i), and the questions file write (SCB-17.a, SCB-01.a) must each be re-reviewed when built. Status write must resolve the requirement file through `resolveInside` and accept only IDs from the reader, never a client-supplied path.
