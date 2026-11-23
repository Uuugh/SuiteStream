import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'suite_icons.dart';

/// SHL-03: the page theme is Light, Dark or Match system (the default); the
/// choice is a user setting kept on the device.
class ThemeModeController extends ChangeNotifier {
  ThemeModeController({SharedPreferences? prefs}) : _prefs = prefs, _mode = _read(prefs);

  /// Preference key. The early script in `web/index.html` reads the same value
  /// (shared_preferences on the web stores it as `flutter.theme.mode`).
  static const prefsKey = 'theme.mode';

  final SharedPreferences? _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;
  set mode(ThemeMode value) {
    if (value == _mode) return;
    _mode = value;
    _prefs?.setString(prefsKey, value.name);
    notifyListeners();
  }

  static ThemeMode _read(SharedPreferences? prefs) {
    final saved = prefs?.getString(prefsKey);
    return ThemeMode.values.where((m) => m.name == saved).firstOrNull ?? ThemeMode.system;
  }
}

/// Gives the [ThemeModeController] to every widget below it and rebuilds them when it changes.
class ThemeModeScope extends InheritedNotifier<ThemeModeController> {
  const ThemeModeScope({super.key, required ThemeModeController controller, required super.child})
    : super(notifier: controller);

  static ThemeModeController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeModeScope>()?.notifier;

  static ThemeModeController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No ThemeModeScope above this widget');
    return controller!;
  }
}

/// The icon of each theme choice (glyphs live in [SuiteIcons]).
abstract final class ThemeModeIcons {
  static const light = SuiteIcons.lightMode;
  static const dark = SuiteIcons.darkMode;
  static const system = SuiteIcons.brightnessAuto;

  static IconData of(ThemeMode mode) => switch (mode) {
    ThemeMode.light => light,
    ThemeMode.dark => dark,
    ThemeMode.system => system,
  };
}

/// Message key of each choice's name.
String themeModeMessageKey(ThemeMode mode) => switch (mode) {
  ThemeMode.light => 'themeLight',
  ThemeMode.dark => 'themeDark',
  ThemeMode.system => 'themeSystem',
};
