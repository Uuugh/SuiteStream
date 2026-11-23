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

  test('dark text on a pale fill in light mode, light text in dark mode', () {
    const pale = Color(0xFFFBE983);
    expect(eventTextColorOn(pale, Brightness.light).computeLuminance(), lessThan(pale.computeLuminance()));
    const tinted = Color(0xFF2A2F3A);
    expect(eventTextColorOn(tinted, Brightness.dark).computeLuminance(), greaterThan(tinted.computeLuminance()));
  });
}
