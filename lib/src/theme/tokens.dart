import 'package:flutter/material.dart';

/// THM-02: every color is a named token with a light value and a dark value.
@immutable
class SuiteTokens extends ThemeExtension<SuiteTokens> {
  const SuiteTokens({
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
    required this.titleCalendar,
    required this.titleStream,
  });

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

  /// THM-02.m: the two colors of the title's words.
  final Color titleCalendar;
  final Color titleStream;

  /// THM-02: the light palette is the Soft palette.
  static const light = SuiteTokens(
    bg: Color(0xFFF7F6F3),
    card: Color(0xFFFDFCFA),
    soft: Color(0xFFF1EFEB),
    line: Color(0xFFE8E4DE),
    text: Color(0xFF2B2F36),
    muted: Color(0xFF626C7C),
    accent: Color(0xFF40609C),
    onAccent: Color(0xFFFFFFFF),
    ok: Color(0xFF2F7D62),
    okBg: Color(0xFFEEF5F0),
    run: Color(0xFF40609C),
    runBg: Color(0xFFEEF1F7),
    warn: Color(0xFF946A24),
    warnBg: Color(0xFFFAF3E6),
    bad: Color(0xFFB4483C),
    badBg: Color(0xFFFAEEEB),
    titleCalendar: Color(0xFF0B1F44),
    titleStream: Color(0xFF1A8CFF),
  );

  static const dark = SuiteTokens(
    bg: Color(0xFF0F1218),
    card: Color(0xFF171B23),
    soft: Color(0xFF1D222C),
    line: Color(0xFF2A303B),
    text: Color(0xFFE6E8EC),
    muted: Color(0xFF98A2B3),
    accent: Color(0xFF93B4FF),
    onAccent: Color(0xFF0F1218),
    ok: Color(0xFF4ADE80),
    okBg: Color(0xFF0F2A20),
    run: Color(0xFF93B4FF),
    runBg: Color(0xFF14203D),
    warn: Color(0xFFFBBF24),
    warnBg: Color(0xFF2B2110),
    bad: Color(0xFFF87171),
    badBg: Color(0xFF2D1414),
    titleCalendar: Color(0xFFE6E8EC),
    titleStream: Color(0xFF4AA8FF),
  );

  /// THM-02.l: each section has its own border color, shown as 35% of the
  /// color mixed with [line], on [card].
  Color sectionBorder(SuiteSection section) =>
      Color.alphaBlend(section.color.withValues(alpha: 0.35), line);

  @override
  SuiteTokens copyWith() => this;

  @override
  SuiteTokens lerp(ThemeExtension<SuiteTokens>? other, double t) => t < 0.5 ? this : (other as SuiteTokens? ?? this);
}

/// THM-02.l: the sections and their colors.
enum SuiteSection {
  calendar(Color(0xFF5B6F9A)),
  calendars(Color(0xFF2A9D8F)),
  feeds(Color(0xFF2F86C8)),
  allRules(Color(0xFF9B8AD6)),
  eventTemplates(Color(0xFFB8733A)),
  history(Color(0xFF8A8F98));

  const SuiteSection(this.color);
  final Color color;
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
