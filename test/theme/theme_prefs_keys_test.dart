import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/theme/theme_mode_controller.dart';
import 'package:suitestream/src/theme/theme_settings.dart';

void main() {
  test('PBI-037: the keys the theme setters and the mode write are exactly themeSettingsPrefsKeys', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    ThemeSettings(prefs: p)
      ..popupShadow = 150
      ..resizeBar = 150
      ..dropdownText = 120
      ..datePicker = 120
      ..statusChipTime = const Duration(seconds: 3)
      ..animationTime = const Duration(milliseconds: 700);
    ThemeModeController(prefs: p).mode = ThemeMode.dark;
    expect(p.getKeys(), themeSettingsPrefsKeys);
  });
}
