import 'package:flutter/material.dart';

/// THM-02: one seed generates the light and dark Material 3 color schemes
/// (the same seed as the root app; copied because this package has no
/// dependency on it).
const Color scrumThemeSeed = Color(0xFF93B4FF);

/// Spacing and shape tokens. Widgets use these and never a literal.
const double scrumPanelRadius = 12;
const double scrumPanelBorderWidth = 1;
const double scrumPagePadding = 8;
const double scrumPartGap = 3;
const double scrumToolbarHeight = 44;
/// Padding around a load-failed message.
const double scrumErrorPadding = 8;

/// SCB-15.a: the share of the page height of each row (percent).
const int scrumTopRowFlex = 40;
const int scrumMiddleRowFlex = 20;
const int scrumBottomRowFlex = 40;

/// The page theme for [brightness] (SCB-01.g): every color comes from the
/// [ColorScheme] built from [scrumThemeSeed].
ThemeData buildScrumTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: scrumThemeSeed, brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    dividerColor: scheme.outlineVariant,
  );
}

/// SCB-22: how often the page asks the server for the change stamp.
const Duration scrumPollInterval = Duration(seconds: 2);

/// SCB-20.a: the zoom default, limits and step (percent).
const int scrumZoomDefault = 100;
const int scrumZoomMin = 80;
const int scrumZoomMax = 160;
const int scrumZoomStep = 10;
