import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/event_colors.dart';

void main() {
  final all = [...eventPalette, ...calendarPalette];
  test('palettes hold 11 event and 24 calendar colors', () {
    expect(eventPalette.length, 11);
    expect(calendarPalette.length, 24);
  });

  for (final brightness in Brightness.values) {
    for (final p in all) {
      test('${p.key} ${brightness.name}: opaque fill reaches 4.5:1', () {
        final fill = Color(p.argb);
        final text = eventTextColorOn(fill, brightness);
        expect(eventContrastRatio(fill, text), greaterThanOrEqualTo(eventTextMinContrast));
      });
      test('${p.key} ${brightness.name}: tinted chip fill reaches 4.5:1', () {
        final surface = brightness == Brightness.light ? Colors.white : const Color(0xFF121212);
        final fill = Color.alphaBlend(Color(p.argb).withValues(alpha: 0.18), surface);
        final text = eventTextColorOn(fill, brightness);
        expect(eventContrastRatio(fill, text), greaterThanOrEqualTo(eventTextMinContrast));
      });
    }
  }

  for (final brightness in Brightness.values) {
    for (final p in all) {
      test('${p.key} ${brightness.name}: text is pure black or white, the higher contrast, 7:1 when reachable', () {
        final fill = Color(p.argb);
        final text = eventTextColorOn(fill, brightness);
        const black = Color(0xFF000000), white = Color(0xFFFFFFFF);
        expect(text == black || text == white, isTrue);
        final cb = eventContrastRatio(fill, black), cw = eventContrastRatio(fill, white);
        expect(eventContrastRatio(fill, text), max(cb, cw));
        if (cb >= 7 || cw >= 7) expect(eventContrastRatio(fill, text), greaterThanOrEqualTo(7));
      });
    }
  }

  test('pale fill gets black, deep fill gets white, in both brightnesses', () {
    for (final b in Brightness.values) {
      expect(eventTextColorOn(const Color(0xFFFBE983), b), const Color(0xFF000000));
      expect(eventTextColorOn(const Color(0xFF2A2F3A), b), const Color(0xFFFFFFFF));
    }
  });
}
