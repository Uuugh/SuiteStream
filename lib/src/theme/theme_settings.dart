import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UIC-44, SET-03.e to SET-03.k: the user's settings for the common UI elements, kept on
/// the device. Defaults and ranges are the DEF-01 rows (percent values: 100 = as designed).
class ThemeSettingsLimits {
  const ThemeSettingsLimits._();

  static const double popupShadowDefault = 100, popupShadowMin = 0, popupShadowMax = 200;
  static const double resizeBarDefault = 100, resizeBarMin = 50, resizeBarMax = 200;
  static const double dropdownTextDefault = 100, dropdownTextMin = 75, dropdownTextMax = 150;
  static const double datePickerDefault = 100, datePickerMin = 75, datePickerMax = 150;
  static const Duration statusChipDefault = Duration(milliseconds: 2400);
  static const Duration statusChipMin = Duration(milliseconds: 500);
  static const Duration statusChipMax = Duration(seconds: 10);
  static const Duration animationDefault = Duration(milliseconds: 500);
  static const Duration animationMax = Duration(seconds: 2);
}

/// The settings model. Each setter clamps to its DEF-01 range, saves, and notifies.
/// [reset] restores every default (the Reset button in Settings > Theme).
class ThemeSettings extends ChangeNotifier {
  ThemeSettings({SharedPreferences? prefs}) : _prefs = prefs {
    final p = prefs;
    if (p == null) return;
    _popupShadow = _clampPercent(p.getDouble(keyPopupShadow), ThemeSettingsLimits.popupShadowMin, ThemeSettingsLimits.popupShadowMax, _popupShadow);
    _resizeBar = _clampPercent(p.getDouble(keyResizeBar), ThemeSettingsLimits.resizeBarMin, ThemeSettingsLimits.resizeBarMax, _resizeBar);
    _dropdownText = _clampPercent(p.getDouble(keyDropdownText), ThemeSettingsLimits.dropdownTextMin, ThemeSettingsLimits.dropdownTextMax, _dropdownText);
    _datePicker = _clampPercent(p.getDouble(keyDatePicker), ThemeSettingsLimits.datePickerMin, ThemeSettingsLimits.datePickerMax, _datePicker);
    final chip = p.getInt(keyStatusChipMs);
    if (chip != null) _statusChip = _clampDuration(Duration(milliseconds: chip), ThemeSettingsLimits.statusChipMin, ThemeSettingsLimits.statusChipMax);
    final anim = p.getInt(keyAnimationMs);
    if (anim != null) _animation = _clampDuration(Duration(milliseconds: anim), Duration.zero, ThemeSettingsLimits.animationMax);
  }

  static const keyPopupShadow = 'theme.popupShadow';
  static const keyResizeBar = 'theme.resizeBar';
  static const keyDropdownText = 'theme.dropdownText';
  static const keyDatePicker = 'theme.datePicker';
  static const keyStatusChipMs = 'theme.statusChipMs';

  /// The same key the calendar controller uses for the animation time (SET-10), so the
  /// two never disagree.
  static const keyAnimationMs = 'view.animationMs';

  final SharedPreferences? _prefs;

  double _popupShadow = ThemeSettingsLimits.popupShadowDefault;
  double _resizeBar = ThemeSettingsLimits.resizeBarDefault;
  double _dropdownText = ThemeSettingsLimits.dropdownTextDefault;
  double _datePicker = ThemeSettingsLimits.datePickerDefault;
  Duration _statusChip = ThemeSettingsLimits.statusChipDefault;
  Duration _animation = ThemeSettingsLimits.animationDefault;

  /// Percent of the designed popup shadow (0 to 200).
  double get popupShadow => _popupShadow;
  /// Percent of the designed resize bar size (50 to 200).
  double get resizeBar => _resizeBar;
  /// Percent of the designed dropdown text size (75 to 150).
  double get dropdownText => _dropdownText;
  /// Percent of the designed date picker size (75 to 150).
  double get datePicker => _datePicker;
  /// How long a good status word shows before it shrinks (0.5 to 10 seconds).
  Duration get statusChipTime => _statusChip;
  /// The one animation time (0 to 2 seconds, 0 = none).
  Duration get animationTime => _animation;

  set popupShadow(double v) => _set(keyPopupShadow, _popupShadow, v.clamp(ThemeSettingsLimits.popupShadowMin, ThemeSettingsLimits.popupShadowMax).toDouble(), (x) => _popupShadow = x);
  set resizeBar(double v) => _set(keyResizeBar, _resizeBar, v.clamp(ThemeSettingsLimits.resizeBarMin, ThemeSettingsLimits.resizeBarMax).toDouble(), (x) => _resizeBar = x);
  set dropdownText(double v) => _set(keyDropdownText, _dropdownText, v.clamp(ThemeSettingsLimits.dropdownTextMin, ThemeSettingsLimits.dropdownTextMax).toDouble(), (x) => _dropdownText = x);
  set datePicker(double v) => _set(keyDatePicker, _datePicker, v.clamp(ThemeSettingsLimits.datePickerMin, ThemeSettingsLimits.datePickerMax).toDouble(), (x) => _datePicker = x);
  set statusChipTime(Duration v) => _setMs(keyStatusChipMs, _statusChip, _clampDuration(v, ThemeSettingsLimits.statusChipMin, ThemeSettingsLimits.statusChipMax), (x) => _statusChip = x);
  set animationTime(Duration v) => _setMs(keyAnimationMs, _animation, _clampDuration(v, Duration.zero, ThemeSettingsLimits.animationMax), (x) => _animation = x);

  /// True when every setting has its DEF-01 default (the Reset button can be disabled).
  bool get isDefault =>
      _popupShadow == ThemeSettingsLimits.popupShadowDefault &&
      _resizeBar == ThemeSettingsLimits.resizeBarDefault &&
      _dropdownText == ThemeSettingsLimits.dropdownTextDefault &&
      _datePicker == ThemeSettingsLimits.datePickerDefault &&
      _statusChip == ThemeSettingsLimits.statusChipDefault &&
      _animation == ThemeSettingsLimits.animationDefault;

  /// Restores every setting to its default and forgets the saved values.
  void reset() {
    _popupShadow = ThemeSettingsLimits.popupShadowDefault;
    _resizeBar = ThemeSettingsLimits.resizeBarDefault;
    _dropdownText = ThemeSettingsLimits.dropdownTextDefault;
    _datePicker = ThemeSettingsLimits.datePickerDefault;
    _statusChip = ThemeSettingsLimits.statusChipDefault;
    _animation = ThemeSettingsLimits.animationDefault;
    final p = _prefs;
    if (p != null) {
      for (final k in [keyPopupShadow, keyResizeBar, keyDropdownText, keyDatePicker, keyStatusChipMs, keyAnimationMs]) {
        p.remove(k);
      }
    }
    notifyListeners();
  }

  void _set(String key, double old, double next, void Function(double) assign) {
    if (next == old) return;
    assign(next);
    _prefs?.setDouble(key, next);
    notifyListeners();
  }

  void _setMs(String key, Duration old, Duration next, void Function(Duration) assign) {
    if (next == old) return;
    assign(next);
    _prefs?.setInt(key, next.inMilliseconds);
    notifyListeners();
  }

  static double _clampPercent(double? v, double min, double max, double fallback) =>
      v == null ? fallback : v.clamp(min, max).toDouble();

  static Duration _clampDuration(Duration v, Duration min, Duration max) => v < min ? min : (v > max ? max : v);
}

/// Offers the settings to every widget below it. Without one, the defaults apply.
class ThemeSettingsScope extends InheritedNotifier<ThemeSettings> {
  const ThemeSettingsScope({super.key, required ThemeSettings settings, required super.child}) : super(notifier: settings);

  static final ThemeSettings _defaults = ThemeSettings();

  /// The settings in effect for [context] (rebuilds the caller when they change).
  static ThemeSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeSettingsScope>()?.notifier ?? _defaults;
}
