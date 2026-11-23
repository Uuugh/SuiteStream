# Sprint 007 handoffs

## Nakamura to Yamamoto (day 1)

1. `lib/src/calendar/settings_admin_pane.dart` exists. Constructor is `SettingsAdminPane({required CalendarController controller})`; the first 30-minute stub had no argument, so pass the dialog's controller: `SettingsAdminPane(controller: widget.controller)`. It is a plain `Column` (no scroll, no heading, no Cancel | Save: its buttons act at once; Remove asks No | Yes). Put your pane heading around it.
2. Theme mode controller (for the Theme pane's "default theme choice"): `lib/src/theme/theme_mode_controller.dart`. `ThemeModeScope.of(context)` returns the `ThemeModeController` (`mode` is a Flutter `ThemeMode`; setting it saves to the device and notifies). `ThemeModeScope` sits in `MaterialApp.builder` in `main.dart`, so dialogs see it. Icons and names: `ThemeModeIcons.of(mode)`, `themeModeMessageKey(mode)`. Tests that open the Theme pane must wrap in `ThemeModeScope(controller: ThemeModeController(), child: ...)`.
3. Strings: `scrum/sprint007/strings_nakamura.md` (keys, English and drafts for the other five). Please also add the `settingsAdmin` heading.
4. Requirement rows (shell.md and settings.md are yours). Tests pass now:
   - SHL-03: tests `test/theme/theme_mode_test.dart` (stored choice, default Match system); set done after the Product Owner's visual check of the theme menu.
   - SHL-03.a: `test/theme/theme_mode_test.dart` (Dark applies; early script reads `flutter.theme.mode` in `web/index.html`). The no-flash start itself is browser-only: needs the Product Owner's visual check (hard refresh with Dark chosen and a light OS, and the reverse). Suggest status `built` until then.
   - SHL-03.b: `test/theme/theme_mode_test.dart` (one icon, menu with Light / Dark / Match system, selected one marked and shown as the icon).
   - SHL-03.c: sign-in and initial-setup pages do not exist yet; leave backlog (they will follow the saved theme because `themeMode` is applied to the whole `MaterialApp`).
   - New Admin row in settings.md (wording is yours): Settings > Admin has Add test calendars and Remove test data; three calendars Work, Family, Travel with 8 events each across November 2026; stable ids so adding twice does not duplicate; Remove asks No | Yes and deletes only test calendars by id, their events and the old automatic samples (ids demo-1 to demo-3); first start adds no sample data. Tests: `test/calendar/admin_test_data_test.dart`, `test/app/bootstrap_test.dart`.

## Nakamura to Tanaka

None required. `ThemeModeIcons` (light_mode, dark_mode, brightness_auto) live in `theme_mode_controller.dart` because `suite_icons.dart` has no owner in the table; move them there if you want them with the other icons.

## Nakamura to Ito

`lib/src/app/test_data.dart` gives the three test calendars fixed ARGB colors (Peacock 0xFF039BE5, Sage 0xFF33B679, Banana 0xFFF6BF26). If PBI-034 changes the calendar palette values or names, tell me and I will change them to the new palette entries. `CalendarController.addCalendarData` and `removeCalendarData` (my file) add and remove calendars by id without the canDeleteCalendar check.

## Ito to Nakamura (calendar_controller.dart, test_data.dart)
1. PBI-034 needs a calendar color and `saveCalendar` has none. Please change it to `Future<bool> saveCalendar(String name, {String? id, int? color})`. New calendar (id == null): `color: color ?? nextCalendarColor(_calendars.map((c) => c.color))`. Edit: `color: color ?? c.color`. `nextCalendarColor`, `calendarPalette`, `nearestCalendarColor`, `defaultEventColor` are in `lib/src/theme/event_colors.dart` (landed). My `local_calendars_dialog.dart` will pass `color:`.
2. Test calendars: calendar colors are the 24 calendar-palette colors (DEF-01), not the 11 event colors. Use `calendarPalette[15].argb` (Blue 0xFF4986E7), `calendarPalette[7].argb` (Green 0xFF16A765), `calendarPalette[11].argb` (Gold 0xFFFAD165) or your own picks from `calendarPalette`.
3. `colorOf(e)` stays (own, else calendar, else null). Views (`month_view`, `week_view`, `list_view`, print) fall back to theme roles for null; THM-09.b wants `Color(defaultEventColor)`. Those are not my files.

## Ito to Tanaka
- 34 px: `suiteControlHeight` (suite_theme.dart). Reminder rows already use it through `_decoration()`; `test/events/event_dialog_test.dart` ("THM-04.b, THM-01.e ... reminder row") asserts method, number and unit are 34 px.
- `lib/src/ui/color_picker.dart` has three private size constants (swatch 30, check 18, gap 8; `TODO(tokens)`). Please move them to tokens; I cannot edit tokens.

## Ito to Yamamoto (PBI-036)
- `event_dialog.dart` already reads `CalendarController.defaultLength` (a `Duration`) for a new event and for an empty end time (EVT-02.n). The unit of time is only how Settings shows and edits it: `calendar_defaults.dart` should convert value + unit (minutes, hours) to and from that Duration (setter clamps 5 min to 24 h and stores minutes). Nothing else needed from me; I do not read calendar_defaults.dart.
- Strings: `scrum/sprint007/strings_ito.md` (palette names and two labels; the picker falls back to English names until merged).
- Rows in your files for my tests (please set status and cite): UIC-10, UIC-10.a, UIC-20: `test/events/event_dialog_test.dart` (picker, nearest color), `test/events/event_logic_test.dart` (nearest-color mapping, palettes), `test/calendar/local_calendar_test.dart` (calendar picker). THM-04.b, THM-01.e (reminder rows): `test/events/event_dialog_test.dart`.
