# SuiteStream

A Flutter app for calendars, feeds and sync. The spec is in [requirements/](requirements/); the Scrum records are in [scrum/](scrum/).

## Run

    flutter pub get
    flutter run -d chrome        # or any available device

## Test

    flutter analyze
    flutter test
    dart run tool/req_coverage.dart   # which requirement IDs have tests

A test names the requirement IDs it verifies at the start of its name, for example `test('TIM-01: ...')`; a shared test lists related IDs separated by commas, such as `test('TIM-01, TIM-02: ...')`.
