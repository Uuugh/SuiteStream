import 'package:flutter/material.dart';

/// THM-02: one seed generates the light and dark Material 3 color schemes.
const Color suiteThemeSeed = Color(0xFF93B4FF);

@immutable
class SuiteTokens extends ThemeExtension<SuiteTokens> {
  const SuiteTokens({
    required this.scheme,
    required this.bg,
    required this.card,
    required this.soft,
    required this.line,
    required this.text,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.ok,
    required this.okBg,
    required this.run,
    required this.runBg,
    required this.warn,
    required this.warnBg,
    required this.bad,
    required this.badBg,
  });

  factory SuiteTokens.fromColorScheme(ColorScheme scheme) => SuiteTokens(
    scheme: scheme,
    bg: scheme.surface,
    card: scheme.surfaceContainerLow,
    soft: scheme.surfaceContainerHighest,
    line: scheme.outlineVariant,
    text: scheme.onSurface,
    muted: scheme.onSurfaceVariant,
    accent: scheme.primary,
    onAccent: scheme.onPrimary,
    ok: scheme.secondary,
    okBg: scheme.secondaryContainer,
    run: scheme.primary,
    runBg: scheme.primaryContainer,
    warn: scheme.tertiary,
    warnBg: scheme.tertiaryContainer,
    bad: scheme.error,
    badBg: scheme.errorContainer,
  );

  static final light = SuiteTokens.fromColorScheme(
    ColorScheme.fromSeed(
      seedColor: suiteThemeSeed,
      brightness: Brightness.light,
    ),
  );
  static final dark = SuiteTokens.fromColorScheme(
    ColorScheme.fromSeed(
      seedColor: suiteThemeSeed,
      brightness: Brightness.dark,
    ),
  );

  final ColorScheme scheme;
  final Color bg;
  final Color card;
  final Color soft;
  final Color line;
  final Color text;
  final Color muted;
  final Color accent;
  final Color onAccent;
  final Color ok;
  final Color okBg;
  final Color run;
  final Color runBg;
  final Color warn;
  final Color warnBg;
  final Color bad;
  final Color badBg;

  @override
  SuiteTokens copyWith() => this;

  @override
  SuiteTokens lerp(ThemeExtension<SuiteTokens>? other, double t) => t < 0.5 ? this : (other as SuiteTokens? ?? this);
}

/// WCAG contrast ratio between two opaque colors.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

extension SuiteTokensContext on BuildContext {
  SuiteTokens get tokens => Theme.of(this).extension<SuiteTokens>()!;
}
