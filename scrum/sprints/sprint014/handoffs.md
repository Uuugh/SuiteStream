# Sprint 014 Handoffs

## Tanaka (Day 1)

- `scrumBlockWidth` (360) is in `scrum/scrumboard/lib/src/theme/scrum_theme.dart`: Ito's wave 1 (PBI-109) can use it in `BoardTokens.blockWidth`.
- The zoom halves keep the keys `scbZoomOut` and `scbZoomIn`; each half is an `InkWell` (enabled = `onTap != null`), inside the one control keyed `scbZoom` (`lib/src/app/zoom_control.dart`).
- Zoom icon sizes are tokens in `scrum_theme.dart` (`scrumZoomIconWidth`, `scrumZoomIconHeight`, `scrumZoomGlyphSize`, `scrumZoomMarkSize`, `scrumZoomStroke`).
- `ScrumBoardApp({BoardPrefsStore? prefs})`: tests pass a `MemoryBoardPrefs`; with none, the VM uses memory and the web uses local storage (`board_prefs_web.dart`, the only file importing `dart:js_interop`). `flutter build web` compiles it.
- The page reads the change stamp once at start (PBI-107): a test that counts `changeStamp` calls sees one more than the number of intervals.

## Ito (Day 1)

- `applyStatusChoice` is in `scrum/scrumboard/lib/src/board/status_choice.dart` with the fixed signature; the Backlog block uses it. Yamamoto's wave 1: in `features_column.dart` `_choose`, call `applyStatusChoice(widget.api, id: r.id, choice: status, storyId: storyId)` (it never throws; `ok: false` carries the reason).

## Nakamura (Day 1)

- Decision: the Windows bash lookup does not run `git --exec-path`; it finds `git.exe` on PATH and takes `<git>\bin\bash.exe`, then `C:\Program Files\Git\bin\bash.exe`, then the first `bash.exe` on PATH outside `System32` and `WindowsApps`. This keeps bash the only process the server starts (the narrowed SCB-01.a test checks it).
- Fake scripts: `scrum/scrumboard/test/server/fixtures/usage_ok.sh`, `usage_fail.sh`, `usage_sleep.sh`.
- `FakeScrumBoardApi.estimateAnswer` and `trendAnswer` set what the fake answers (for PBI-084 later).
- Checked once against the real `scrum/usage/usage.sh` on this machine (server on port 8099): both routes answered `ok: true` with the script's output. The Executive's own test row stays in the review.

## Yamamoto (Day 2)

- `features_column.dart`: `_choose` calls `applyStatusChoice`; the first line of a row is a `Row` with the ID and feature in an `Expanded` `Wrap` and the status token (`scb-status-<id>`) last, so the token ends `scrumPartGap` from the row's right edge (SCB-23). For PBI-082: the Issues column can use the same layout.

## Ito (Day 2)

- `BoardTokens.blockWidth` is `scrumBlockWidth`; `backlog_timeline_test.dart` checks the width against `scrumBlockWidth`.
