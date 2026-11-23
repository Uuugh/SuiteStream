import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/theme/theme_settings.dart';

/// UIC-44, SET-03.e to SET-03.k, DEF-01: the theme settings model.
void main() {
  Future<SharedPreferences> prefs([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('DEF-01 defaults', () {
    final s = ThemeSettings();
    expect(
      [s.popupShadow, s.resizeBar, s.dropdownText, s.datePicker],
      [100, 100, 100, 100],
    );
    expect(s.statusChipTime, const Duration(milliseconds: 2400));
    expect(s.animationTime, const Duration(milliseconds: 500));
    expect(s.isDefault, isTrue);
  });

  test('SET-03.e-j: values are clamped to the DEF-01 ranges', () {
    final s = ThemeSettings()
      ..popupShadow = 500
      ..resizeBar = 1
      ..dropdownText = 500
      ..datePicker = 1
      ..statusChipTime = const Duration(milliseconds: 100)
      ..animationTime = const Duration(seconds: 9);
    expect([s.popupShadow, s.resizeBar, s.dropdownText, s.datePicker], [200, 50, 150, 75]);
    expect(s.statusChipTime, const Duration(milliseconds: 500));
    expect(s.animationTime, const Duration(seconds: 2));
    s.popupShadow = -5;
    expect(s.popupShadow, 0);
    s.statusChipTime = const Duration(minutes: 5);
    expect(s.statusChipTime, const Duration(seconds: 10));
    s.animationTime = Duration.zero;
    expect(s.animationTime, Duration.zero);
  });

  test('UIC-44: settings are saved on the device and loaded again', () async {
    final p = await prefs();
    ThemeSettings(prefs: p)
      ..popupShadow = 150
      ..resizeBar = 80
      ..dropdownText = 120
      ..datePicker = 90
      ..statusChipTime = const Duration(seconds: 5)
      ..animationTime = const Duration(milliseconds: 1200);
    final again = ThemeSettings(prefs: p);
    expect([again.popupShadow, again.resizeBar, again.dropdownText, again.datePicker], [150, 80, 120, 90]);
    expect(again.statusChipTime, const Duration(seconds: 5));
    expect(again.animationTime, const Duration(milliseconds: 1200));
    expect(again.isDefault, isFalse);
  });

  test('a saved value outside the range is clamped on load', () async {
    final p = await prefs({ThemeSettings.keyPopupShadow: 900.0, ThemeSettings.keyAnimationMs: 99999});
    final s = ThemeSettings(prefs: p);
    expect(s.popupShadow, 200);
    expect(s.animationTime, const Duration(seconds: 2));
  });

  test('UIC-44: Reset restores every default, forgets the saved values and notifies', () async {
    final p = await prefs();
    final s = ThemeSettings(prefs: p)
      ..popupShadow = 0
      ..animationTime = Duration.zero
      ..datePicker = 140;
    var notified = 0;
    s.addListener(() => notified++);
    s.reset();
    expect(s.isDefault, isTrue);
    expect(notified, 1);
    expect(p.getKeys().where((k) => k.startsWith('theme.') || k == ThemeSettings.keyAnimationMs), isEmpty);
    expect(ThemeSettings(prefs: p).isDefault, isTrue);
  });

  testWidgets('the scope offers the settings, rebuilds on change, and falls back to defaults', (tester) async {
    final s = ThemeSettings();
    double? seen;
    final probe = Builder(builder: (context) {
      seen = ThemeSettingsScope.of(context).popupShadow;
      return const SizedBox();
    });
    await tester.pumpWidget(probe);
    expect(seen, 100);
    await tester.pumpWidget(ThemeSettingsScope(settings: s, child: probe));
    s.popupShadow = 40;
    await tester.pump();
    expect(seen, 40);
  });
}
