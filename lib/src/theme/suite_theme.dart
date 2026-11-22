import 'package:flutter/material.dart';

import 'tokens.dart';

/// THM-01.a: IBM Plex Sans is the font for everything.
const String sansFamily = 'IBM Plex Sans';

/// THM-01.b: IBM Plex Mono is only for what is typed or copied exactly
/// (links, IDs, the Username, the client ID, the stream name).
const String monoFamily = 'IBM Plex Mono';

/// DEF-01: phone-width window, 700 px wide or narrower.
const double phoneMaxWidth = 700;

/// THM-01.c: the module kind is 17 px at weight 700 (15 px in a phone-width window).
double moduleKindSize({required double windowWidth}) => windowWidth <= phoneMaxWidth ? 15 : 17;

/// THM-01.d text styles. Default text is 14 px; labels are weight 600; notes are
/// 13 px in the muted color.
class SuiteText {
  const SuiteText._();

  static const double bodySize = 14;
  static const double noteSize = 13;

  static TextStyle body(SuiteTokens t) =>
      TextStyle(fontFamily: sansFamily, fontSize: bodySize, fontWeight: FontWeight.w400, color: t.text);
  static TextStyle label(SuiteTokens t) => body(t).copyWith(fontWeight: FontWeight.w600);
  static TextStyle note(SuiteTokens t) => body(t).copyWith(fontSize: noteSize, color: t.muted);
  static TextStyle moduleKind(SuiteTokens t, {required double windowWidth}) => body(t)
      .copyWith(fontSize: moduleKindSize(windowWidth: windowWidth), fontWeight: FontWeight.w700);
  static TextStyle mono(SuiteTokens t) => body(t).copyWith(fontFamily: monoFamily);
}

/// Builds the app theme for a palette. Every component uses it by default.
ThemeData buildSuiteTheme(Brightness brightness) {
  final t = brightness == Brightness.dark ? SuiteTokens.dark : SuiteTokens.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.accent,
    onPrimary: t.onAccent,
    secondary: t.accent,
    onSecondary: t.onAccent,
    error: t.bad,
    onError: t.card,
    surface: t.card,
    onSurface: t.text,
    outline: t.line,
    surfaceContainerHighest: t.soft,
    onSurfaceVariant: t.muted,
  );
  final base = SuiteText.body(t);
  final textTheme = TextTheme(
    displayLarge: base,
    displayMedium: base,
    displaySmall: base,
    headlineLarge: base,
    headlineMedium: base,
    headlineSmall: base,
    titleLarge: base.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
    titleMedium: SuiteText.label(t),
    titleSmall: SuiteText.label(t),
    bodyLarge: base,
    bodyMedium: base,
    bodySmall: SuiteText.note(t),
    labelLarge: SuiteText.label(t),
    labelMedium: SuiteText.label(t),
    labelSmall: SuiteText.note(t),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.card,
    dividerColor: t.line,
    fontFamily: sansFamily,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    extensions: <ThemeExtension<dynamic>>[t],
  );
}
