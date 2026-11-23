import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/tokens.dart';

void main() {
  final l = SuiteTokens.light;
  final d = SuiteTokens.dark;

  test('THM-01.a: IBM Plex Sans is the font for everything', () {
    for (final b in Brightness.values) {
      final theme = buildSuiteTheme(b);
      expect(theme.textTheme.bodyMedium!.fontFamily, 'IBM Plex Sans');
      expect(theme.textTheme.titleLarge!.fontFamily, 'IBM Plex Sans');
      expect(theme.textTheme.labelSmall!.fontFamily, 'IBM Plex Sans');
    }
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: IBM Plex Sans'));
    expect(File('assets/fonts/IBMPlexSans-Variable.ttf').existsSync(), isTrue);
  });

  test('THM-01.b: IBM Plex Mono is only for exactly typed or copied text', () {
    expect(SuiteText.mono(l).fontFamily, 'IBM Plex Mono');
    expect(SuiteText.body(l).fontFamily, isNot('IBM Plex Mono'));
    expect(SuiteText.label(l).fontFamily, isNot('IBM Plex Mono'));
    expect(File('assets/fonts/IBMPlexMono-Regular.ttf').existsSync(), isTrue);
  });

  test('THM-01.c: the module kind is 17 px at weight 700 (15 px in a phone-width window)', () {
    final wide = SuiteText.moduleKind(l, windowWidth: 1200);
    expect([wide.fontSize, wide.fontWeight], [17, FontWeight.w700]);
    final phone = SuiteText.moduleKind(l, windowWidth: 700);
    expect([phone.fontSize, phone.fontWeight], [15, FontWeight.w700]);
    expect(SuiteText.moduleKind(l, windowWidth: 701).fontSize, 17);
  });

  test('THM-01.d: default text is 14 px, labels weight 600, notes 13 px in the muted color', () {
    expect(SuiteText.body(l).fontSize, 14);
    expect(SuiteText.label(l).fontWeight, FontWeight.w600);
    expect(SuiteText.note(l).fontSize, 13);
    expect(SuiteText.note(l).color, l.muted);
    expect(SuiteText.note(d).color, d.muted);
  });

  test('THM-02: light and dark use the Material 3 scheme from the shared seed', () {
    for (final brightness in Brightness.values) {
      final expected = ColorScheme.fromSeed(
        seedColor: const Color(0xFF93B4FF),
        brightness: brightness,
      );
      final theme = buildSuiteTheme(brightness);
      final tokens = theme.extension<SuiteTokens>()!;

      expect(theme.colorScheme.primary, expected.primary);
      expect(theme.colorScheme.secondary, expected.secondary);
      expect(theme.colorScheme.tertiary, expected.tertiary);
      expect(theme.colorScheme.error, expected.error);
      expect(theme.scaffoldBackgroundColor, expected.surface);
      expect(theme.colorScheme.surfaceContainerLow, expected.surfaceContainerLow);
      expect(tokens.scheme.primary, expected.primary);
    }
  });

  test('THM-02: app tokens map to Material 3 color roles', () {
    for (final tokens in [l, d]) {
      final scheme = tokens.scheme;
      expect(
        [
          tokens.bg,
          tokens.card,
          tokens.soft,
          tokens.line,
          tokens.text,
          tokens.muted,
        ],
        [
          scheme.surface,
          scheme.surfaceContainerLow,
          scheme.surfaceContainerHighest,
          scheme.outlineVariant,
          scheme.onSurface,
          scheme.onSurfaceVariant,
        ],
      );
      expect([tokens.accent, tokens.onAccent], [scheme.primary, scheme.onPrimary]);
      expect([tokens.ok, tokens.okBg], [scheme.secondary, scheme.secondaryContainer]);
      expect([tokens.run, tokens.runBg], [scheme.primary, scheme.primaryContainer]);
      expect([tokens.warn, tokens.warnBg], [scheme.tertiary, scheme.tertiaryContainer]);
      expect([tokens.bad, tokens.badBg], [scheme.error, scheme.errorContainer]);
    }
  });

  test('THM-02: generated muted text reaches 4.5:1 against app surfaces', () {
    for (final t in [l, d]) {
      for (final surface in [t.card, t.bg, t.soft]) {
        expect(contrastRatio(t.muted, surface), greaterThanOrEqualTo(4.5), reason: '${t.muted} on $surface');
      }
    }
  });

}
