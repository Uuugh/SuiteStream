import 'package:flutter/material.dart' show Brightness, Color;

/// One named palette color (UIC-10): [key] names it in tests and keys, [messageKey]
/// is its arb key (the shown name), [argb] its opaque color.
class PaletteColor {
  const PaletteColor(this.key, this.messageKey, this.argb);
  final String key;
  final String messageKey;
  /// Diagnostic label for test output only; the shown name comes from [messageKey].
  String get name => key;
  final int argb;
}

/// THM-09.b: the default event color, when an event, its rule and its calendar have none.
const int defaultEventColor = 0xFF1D4ED8;

/// THM-09.a: Google Calendar's eleven event colors.
const List<PaletteColor> eventPalette = [
  PaletteColor('tomato', 'eventColorTomato', 0xFFD50000),
  PaletteColor('flamingo', 'eventColorFlamingo', 0xFFE67C73),
  PaletteColor('tangerine', 'eventColorTangerine', 0xFFF4511E),
  PaletteColor('banana', 'eventColorBanana', 0xFFF6BF26),
  PaletteColor('sage', 'eventColorSage', 0xFF33B679),
  PaletteColor('basil', 'eventColorBasil', 0xFF0B8043),
  PaletteColor('peacock', 'eventColorPeacock', 0xFF039BE5),
  PaletteColor('blueberry', 'eventColorBlueberry', 0xFF3F51B5),
  PaletteColor('lavender', 'eventColorLavender', 0xFF7986CB),
  PaletteColor('grape', 'eventColorGrape', 0xFF8E24AA),
  PaletteColor('graphite', 'eventColorGraphite', 0xFF616161),
];


const _calendarValues = [
  0xFFAC725E, 0xFFD06B64, 0xFFF83A22, 0xFFFA573C, 0xFFFF7537, 0xFFFFAD46, 0xFF42D692, 0xFF16A765, 0xFF7BD148,
  0xFFB3DC6C, 0xFFFBE983, 0xFFFAD165, 0xFF92E1C0, 0xFF9FE1E7, 0xFF9FC6E7, 0xFF4986E7, 0xFF9A9CFF, 0xFFB99AFF,
  0xFFC2C2C2, 0xFFCABDBF, 0xFFCCA6AC, 0xFFF691B2, 0xFFCD74E6, 0xFFA47AE2,
];

/// DEF-01: Google's twenty-four calendar colors, numbered 1 to 24.
final List<PaletteColor> calendarPalette = List.unmodifiable([
  for (var i = 0; i < _calendarValues.length; i++)
    PaletteColor('cal${i + 1}', 'calendarColor${(i + 1).toString().padLeft(2, '0')}', _calendarValues[i]),
]);

/// UIC-20: the palette color with the least squared difference in red, green and
/// blue to [argb] (the first one on a tie); alpha is ignored.
PaletteColor nearestPaletteColor(int argb, List<PaletteColor> palette) {
  final r = (argb >> 16) & 0xFF, g = (argb >> 8) & 0xFF, b = argb & 0xFF;
  PaletteColor? best;
  var bestDistance = 1 << 30;
  for (final p in palette) {
    final dr = r - ((p.argb >> 16) & 0xFF), dg = g - ((p.argb >> 8) & 0xFF), db = b - (p.argb & 0xFF);
    final d = dr * dr + dg * dg + db * db;
    if (d < bestDistance) {
      best = p;
      bestDistance = d;
    }
  }
  return best!;
}

/// The nearest of Google's event colors (UIC-20).
int nearestEventColor(int argb) => nearestPaletteColor(argb, eventPalette).argb;

/// The nearest of Google's calendar colors (UIC-20).
int nearestCalendarColor(int argb) => nearestPaletteColor(argb, calendarPalette).argb;

/// The first calendar color not yet used by [used] (colors are compared after
/// UIC-20 mapping), or, when all 24 are used, the least used one, in palette order.
int nextCalendarColor(Iterable<int?> used) {
  final counts = <int, int>{for (final p in calendarPalette) p.argb: 0};
  for (final u in used) {
    if (u == null) continue;
    final n = nearestCalendarColor(u);
    counts[n] = counts[n]! + 1;
  }
  final least = counts.values.reduce((a, b) => a < b ? a : b);
  return calendarPalette.firstWhere((p) => counts[p.argb] == least).argb;
}

/// An opaque ARGB value as #RRGGBB (lower case).
String hexOf(int argb) => '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Minimum contrast ratio of event text on its chip fill (THM-10.h, WCAG AA).
const double eventTextMinContrast = 4.5;

/// Contrast ratio (1 to 21) between two opaque colors.
double eventContrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// THM-10.h: the text color for an event chip or bar filled with [fill] (opaque; blend
/// a translucent fill over its surface first). The text is the fill's own hue moved
/// toward black (light [brightness]: dark text on pale fills) or toward white (dark
/// [brightness]) in the fewest steps that reach 4.5:1; when that direction cannot
/// reach it, it moves the other way.
Color eventTextColorOn(Color fill, Brightness brightness) {
  final opaque = fill.withValues(alpha: 1);
  final light = brightness == Brightness.light;
  final first = Color(light ? 0xFF000000 : 0xFFFFFFFF);
  final second = Color(light ? 0xFFFFFFFF : 0xFF000000);
  for (final target in [first, second]) {
    if (eventContrastRatio(opaque, target) < eventTextMinContrast) continue;
    for (var i = 0; i <= 100; i++) {
      final candidate = Color.lerp(opaque, target, i / 100)!;
      if (eventContrastRatio(opaque, candidate) >= eventTextMinContrast) return candidate;
    }
  }
  return eventContrastRatio(opaque, first) >= eventContrastRatio(opaque, second) ? first : second;
}
