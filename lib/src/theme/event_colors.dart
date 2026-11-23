/// One named palette color (UIC-10): [key] names it in tests and keys, [messageKey]
/// is its arb key, [name] its English fallback, [argb] its opaque color.
class PaletteColor {
  const PaletteColor(this.key, this.messageKey, this.name, this.argb);
  final String key;
  final String messageKey;
  final String name;
  final int argb;
}

/// THM-09.b: the default event color, when an event, its rule and its calendar have none.
const int defaultEventColor = 0xFF1D4ED8;

/// THM-09.a: Google Calendar's eleven event colors.
const List<PaletteColor> eventPalette = [
  PaletteColor('tomato', 'eventColorTomato', 'Tomato', 0xFFD50000),
  PaletteColor('flamingo', 'eventColorFlamingo', 'Flamingo', 0xFFE67C73),
  PaletteColor('tangerine', 'eventColorTangerine', 'Tangerine', 0xFFF4511E),
  PaletteColor('banana', 'eventColorBanana', 'Banana', 0xFFF6BF26),
  PaletteColor('sage', 'eventColorSage', 'Sage', 0xFF33B679),
  PaletteColor('basil', 'eventColorBasil', 'Basil', 0xFF0B8043),
  PaletteColor('peacock', 'eventColorPeacock', 'Peacock', 0xFF039BE5),
  PaletteColor('blueberry', 'eventColorBlueberry', 'Blueberry', 0xFF3F51B5),
  PaletteColor('lavender', 'eventColorLavender', 'Lavender', 0xFF7986CB),
  PaletteColor('grape', 'eventColorGrape', 'Grape', 0xFF8E24AA),
  PaletteColor('graphite', 'eventColorGraphite', 'Graphite', 0xFF616161),
];

const _calendarNames = [
  'Cocoa', 'Rose clay', 'Red', 'Vermilion', 'Orange', 'Amber', 'Mint', 'Green', 'Lime', 'Pistachio', 'Butter', 'Gold',
  'Seafoam', 'Aqua', 'Sky', 'Blue', 'Periwinkle', 'Lilac', 'Silver', 'Dust', 'Mauve', 'Pink', 'Orchid', 'Violet',
];

const _calendarValues = [
  0xFFAC725E, 0xFFD06B64, 0xFFF83A22, 0xFFFA573C, 0xFFFF7537, 0xFFFFAD46, 0xFF42D692, 0xFF16A765, 0xFF7BD148,
  0xFFB3DC6C, 0xFFFBE983, 0xFFFAD165, 0xFF92E1C0, 0xFF9FE1E7, 0xFF9FC6E7, 0xFF4986E7, 0xFF9A9CFF, 0xFFB99AFF,
  0xFFC2C2C2, 0xFFCABDBF, 0xFFCCA6AC, 0xFFF691B2, 0xFFCD74E6, 0xFFA47AE2,
];

/// DEF-01: Google's twenty-four calendar colors, numbered 1 to 24.
final List<PaletteColor> calendarPalette = List.unmodifiable([
  for (var i = 0; i < _calendarValues.length; i++)
    PaletteColor('cal${i + 1}', 'calendarColor${(i + 1).toString().padLeft(2, '0')}', _calendarNames[i], _calendarValues[i]),
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
