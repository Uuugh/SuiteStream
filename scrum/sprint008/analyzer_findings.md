# Analyzer findings for Sprint 009 (PBI-048)

First run of `flutter analyze lib test` with the options in `analysis_options.yaml` (strict-casts, strict-inference, strict-raw-types and the seven lints). Run on 2026-11-23 on branch `sprint008` after Tanaka's trivial fixes. All new lints are set to severity info so the suite stays green; Sprint 009 fixes them and then removes the `errors:` block from `analysis_options.yaml` (keeps the lints, which then become warnings by default only if raised; raise them to warning at that point).

Totals before fixes: 252 issues (231 always_use_package_imports, 13 prefer_const_constructors, 4 avoid_catches_without_on_clauses, 1 prefer_final_locals, 1 strict-casts error). strict-inference and strict-raw-types found nothing. No finding for print, unawaited futures or missing return types.

Fixed by Tanaka (own files): package imports in `lib/src/ui/*` (except `color_picker.dart`), `suite_theme.dart`, `date_picker.dart`, `event_details.dart`; `prefer_final_locals` in `event_details.dart`; `prefer_const_constructors` in `test/theme/material_button_gallery_test.dart`.

Fix recipe: `always_use_package_imports` is mechanical (replace `'../x.dart'` with `'package:suitestream/src/.../x.dart'`); `avoid_catches_without_on_clauses` needs the right exception type (`on Exception` or a specific one); `prefer_const_constructors` is `dart fix --apply` on the file.

## Ito
- `lib/src/ui/color_picker.dart`: 6 always_use_package_imports.
- `lib/src/calendar/event_dialog.dart`: 21 always_use_package_imports.
- `lib/src/calendar/local_calendars_dialog.dart`: 9 always_use_package_imports.
- `lib/src/calendar/local_calendar_store.dart`: 1 always_use_package_imports.
- `lib/src/calendar/event_store.dart`: 1 always_use_package_imports, 1 avoid_catches_without_on_clauses (line 39).
- Views (event view files, owned by Ito in Sprint 008): `month_view.dart` 10, `week_view.dart` 13, `list_view.dart` 8, `event_drag.dart` 2, `event_filter.dart` 1, `filter_panel.dart` 5, `calendar_print_dialog.dart` 9 (all always_use_package_imports).
- Tests: `test/events/event_dialog_test.dart:438`, `test/events/week_event_style_test.dart:51`, `test/calendar/local_calendar_test.dart:151` (prefer_const_constructors).

## Yamamoto
- `lib/src/calendar/settings_dialog.dart` 14, `settings_calendar_pane.dart` 10, `settings_theme_pane.dart` 8, `calendar_defaults.dart` 2 (always_use_package_imports).
- `settings_dialog.dart` and `settings_calendar_pane.dart`: 1 curly_braces_in_flow_control_structures each (flutter_lints, present in the working copy during PBI-050 edits).

## Nakamura
- `lib/main.dart`: 11 always_use_package_imports, 2 avoid_catches_without_on_clauses (lines 27 and 48).
- `lib/src/app/bootstrap.dart` 8, `lib/src/app/test_data.dart` 2, `lib/src/theme/theme_mode_controller.dart` 1, `lib/src/calendar/calendar_controller.dart` 11, `lib/src/calendar/calendar_page.dart` 22, `lib/src/calendar/settings_admin_pane.dart` 5 (always_use_package_imports).
- `test/calendar/header_test.dart:18` strict-casts: the helper parameter `List events` is a raw list, so `[for (final e in events) e]` is `List<dynamic>` for `List<SuiteEvent>` (error `list_element_type_not_assignable`, set to info for now). Fix: type it `List<SuiteEvent>`.

## Unassigned (no owner in the ownership tables; Takahashi assigns)
- `lib/src/time/local_zone.dart` 1, `suite_event.dart` 1, `time_format.dart` 1 (always_use_package_imports); `lib/src/time/zones.dart:26` 1 avoid_catches_without_on_clauses.

## Tanaka
- Nothing open.
