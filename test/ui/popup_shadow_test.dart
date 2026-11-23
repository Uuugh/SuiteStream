import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/event_colors.dart';
import 'package:suitestream/src/ui/color_picker.dart';
import '../calendar/test_support.dart';
import 'package:suitestream/src/theme/theme_settings.dart';
import 'package:suitestream/src/ui/overflow_info.dart';
import 'package:suitestream/src/ui/suite_dialog.dart';
import 'package:suitestream/src/ui/suite_dropdown.dart';

/// UIC-43, THM-10.d, CAL-10.d: every popup type opens with the shared shadow, and the
/// Popup shadow setting (SET-03.e) scales it.
Widget host(Widget child, {ThemeSettings? settings}) {
  final app = MaterialApp(
    theme: buildSuiteTheme(Brightness.light),
    home: Scaffold(body: Center(child: child)),
  );
  return settings == null ? app : ThemeSettingsScope(settings: settings, child: app);
}

double shadowOf(WidgetTester tester, Finder inside) {
  final material = find.ancestor(of: inside, matching: find.byType(Material)).evaluate().map((e) => e.widget as Material).firstWhere((m) => m.elevation > 0, orElse: () => const Material());
  return material.elevation;
}

void main() {
  test('the theme gives dialogs and menus the popup shadow', () {
    final theme = buildSuiteTheme(Brightness.dark);
    expect(theme.dialogTheme.elevation, suitePopupElevation);
    expect(theme.menuTheme.style!.elevation!.resolve({}), suitePopupElevation);
    expect(theme.popupMenuTheme.elevation, suitePopupElevation);
    expect(suitePopupElevation, greaterThan(0));
  });

  for (final percent in [100.0, 50.0, 0.0, 200.0]) {
    final expected = suitePopupElevation * percent / 100;

    testWidgets('dialog shadow at $percent %', (tester) async {
      final s = ThemeSettings()..popupShadow = percent;
      await tester.pumpWidget(host(
        Builder(builder: (context) => TextButton(
          onPressed: () => showSuiteDialog<void>(context: context, builder: (_) => const AlertDialog(content: Text('dialog body'))),
          child: const Text('go'),
        )),
        settings: s,
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      final dialog = tester.widget<Material>(find.descendant(of: find.byType(AlertDialog), matching: find.byType(Material)).first);
      expect(dialog.elevation, expected);
      expect(dialog.shadowColor, isNot(Colors.transparent));
    });

    testWidgets('menu (dropdown) shadow at $percent %', (tester) async {
      final s = ThemeSettings()..popupShadow = percent;
      await tester.pumpWidget(host(
        SuiteDropdown(
          items: const [DropdownItem(value: 'a', label: 'Alpha')],
          selected: const {},
          onChanged: (_) {},
          icon: Icons.filter_list,
          tooltip: 'open',
        ),
        settings: s,
      ));
      await tester.tap(find.byTooltip('open'));
      await tester.pumpAndSettle();
      expect(shadowOf(tester, find.text('Alpha')), expected);
    });

    testWidgets('popover (overflow info) shadow at $percent %', (tester) async {
      final s = ThemeSettings()..popupShadow = percent;
      await tester.pumpWidget(host(const InfoPopoverButton(text: 'More text'), settings: s));
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(shadowOf(tester, find.text('More text')), expected);
    });
  }

  testWidgets('color picker (UIC-10, UIC-43) opens with the popup shadow', (tester) async {
    await tester.pumpWidget(appFor(Builder(builder: (context) => TextButton(
      onPressed: () => showColorPicker(context, palette: eventPalette),
      child: const Text('go'),
    ))));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    final dialog = tester.widget<Material>(find.descendant(of: find.byType(ColorPickerDialog), matching: find.byType(Material)).first);
    expect(dialog.elevation, suitePopupElevation);
  });
}
