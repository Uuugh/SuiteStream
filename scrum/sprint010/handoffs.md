# Sprint 010 handoffs

Append sections as "## From X to Y (topic)". Do not edit others' sections.

## Takahashi to all (constants)
`lib/src/calendar/calendar_defaults.dart` now holds `defaultLongPress` (0.2 s), `minLongPress`, `maxLongPress`, `clampLongPress`, `defaultStatusWordTime` (1 s), `minStatusWordTime` (0.5 s), `maxStatusWordTime` (10 s), `clampStatusWordTime` (DEF-01). They were removed from `event_drag.dart`; imports fixed in controller, theme pane and `drag_test.dart`. Yamamoto owns the file from now.
Tanaka: `savedCancelledHold` in `cancel_save_pair.dart` (3 s) must become the Settings value; the Settings value reaches the pair through a scope you define (like `SuiteAnimationScope`); Nakamura sets it in `main.dart` from the controller; Yamamoto adds the Theme setting SET-03.m. Agree names here.
