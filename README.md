# SuiteStream

A Flutter app for calendars, feeds and sync. The spec is in [requirements/](requirements/); the Scrum records are in [scrum/](scrum/).

## Run

    flutter pub get
    flutter run -d chrome        # or any available device

## Run and preview on the web

Build with the bundled CanvasKit, so the page needs no access to gstatic.com (a browser that blocks it, such as an embedded preview, otherwise shows a blank page):

    flutter build web --release --no-web-resources-cdn

Serve `build/web` as static files on 127.0.0.1:8080. Python is not installed on the development machine; `dhttpd` is a Dart package and needs only the Flutter SDK:

    dart pub global activate dhttpd          # once
    dart pub global run dhttpd --path build/web --host 127.0.0.1 --port 8080

Open http://127.0.0.1:8080/. (Alternative without the release build: `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080`.)

The page shows a loading indicator until the first frame. If the app cannot start, the page shows the error text (script failure, a failed startup step, or a 30 second timeout) instead of staying blank.

If the page shows an old version or stays blank after a rebuild, the service worker is probably serving stale files: hard refresh with Ctrl+Shift+R, or in the browser developer tools open Application, Service Workers, click Unregister, then Storage, Clear site data, and reload.

Record the check in two parts, as the retrospective requires:

- Server check: the server answers 200 for `/`, `/main.dart.js` and `/canvaskit/canvaskit.wasm` (for example with `curl -I`).
- Visual check: a person or a screenshot (headless Edge: `msedge --headless=new --window-size=1100,700 --virtual-time-budget=15000 --screenshot=out.png http://127.0.0.1:8080/`) confirms the calendar is drawn. A server check alone does not show that the page renders.

## Test

    flutter analyze
    flutter test
    dart run tool/req_coverage.dart   # which requirement IDs have tests

A test names the requirement IDs it verifies at the start of its name, for example `test('TIM-01: ...')`; a shared test lists related IDs separated by commas, such as `test('TIM-01, TIM-02: ...')`.
