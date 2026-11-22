import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/tokens.dart';

void main() {
  const l = SuiteTokens.light;
  const d = SuiteTokens.dark;

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

  test('THM-02.a: bg is the page', () {
    expect(l.bg, const Color(0xFFF7F6F3));
    expect(d.bg, const Color(0xFF0F1218));
    expect(buildSuiteTheme(Brightness.light).scaffoldBackgroundColor, l.bg);
    expect(buildSuiteTheme(Brightness.dark).scaffoldBackgroundColor, d.bg);
  });

  test('THM-02.b: card is sections, modules and pop-ups', () {
    expect(l.card, const Color(0xFFFDFCFA));
    expect(d.card, const Color(0xFF171B23));
  });

  test('THM-02.c: soft is quiet fills', () {
    expect(l.soft, const Color(0xFFF1EFEB));
    expect(d.soft, const Color(0xFF1D222C));
  });

  test('THM-02.d: line is every border and divider', () {
    expect(l.line, const Color(0xFFE8E4DE));
    expect(d.line, const Color(0xFF2A303B));
    expect(buildSuiteTheme(Brightness.light).dividerColor, l.line);
  });

  test('THM-02.e: text and muted', () {
    expect(l.text, const Color(0xFF2B2F36));
    expect(d.text, const Color(0xFFE6E8EC));
    expect(l.muted, const Color(0xFF626C7C));
    expect(d.muted, const Color(0xFF98A2B3));
  });

  test('THM-02.f: muted text reaches 4.5:1 against card, bg and soft in both palettes', () {
    for (final t in [l, d]) {
      for (final surface in [t.card, t.bg, t.soft]) {
        expect(contrastRatio(t.muted, surface), greaterThanOrEqualTo(4.5), reason: '${t.muted} on $surface');
      }
    }
  });

  test('THM-02.g: accent is for pressable buttons only, with its onaccent text', () {
    expect(l.accent, const Color(0xFF40609C));
    expect(d.accent, const Color(0xFF93B4FF));
    expect(l.onAccent, const Color(0xFFFFFFFF));
    expect(d.onAccent, const Color(0xFF0F1218));
  });

  test('THM-02.h: ok (green)', () {
    expect([l.ok, l.okBg], [const Color(0xFF2F7D62), const Color(0xFFEEF5F0)]);
    expect([d.ok, d.okBg], [const Color(0xFF4ADE80), const Color(0xFF0F2A20)]);
  });

  test('THM-02.i: run (pressed)', () {
    expect([l.run, l.runBg], [const Color(0xFF40609C), const Color(0xFFEEF1F7)]);
    expect([d.run, d.runBg], [const Color(0xFF93B4FF), const Color(0xFF14203D)]);
  });

  test('THM-02.j: warn (amber)', () {
    expect([l.warn, l.warnBg], [const Color(0xFF946A24), const Color(0xFFFAF3E6)]);
    expect([d.warn, d.warnBg], [const Color(0xFFFBBF24), const Color(0xFF2B2110)]);
  });

  test('THM-02.k: bad (red)', () {
    expect([l.bad, l.badBg], [const Color(0xFFB4483C), const Color(0xFFFAEEEB)]);
    expect([d.bad, d.badBg], [const Color(0xFFF87171), const Color(0xFF2D1414)]);
  });

  test('THM-02.l: each section has its own border color, 35% of the color mixed with line', () {
    expect(SuiteSection.calendar.color, const Color(0xFF5B6F9A));
    expect(SuiteSection.calendars.color, const Color(0xFF2A9D8F));
    expect(SuiteSection.feeds.color, const Color(0xFF2F86C8));
    expect(SuiteSection.allRules.color, const Color(0xFF9B8AD6));
    expect(SuiteSection.eventTemplates.color, const Color(0xFFB8733A));
    expect(SuiteSection.history.color, const Color(0xFF8A8F98));
    final expected = Color.alphaBlend(const Color(0xFF5B6F9A).withValues(alpha: 0.35), l.line);
    expect(l.sectionBorder(SuiteSection.calendar), expected);
  });

  test('THM-02.m: the title words use the logo colors', () {
    expect([l.titleCalendar, l.titleStream], [const Color(0xFF0B1F44), const Color(0xFF1A8CFF)]);
    expect([d.titleCalendar, d.titleStream], [const Color(0xFFE6E8EC), const Color(0xFF4AA8FF)]);
  });
}
