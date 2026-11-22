import 'package:flutter/material.dart';

/// THM-09: the event color palette (UIC-10) is Google Calendar's eleven colors.
class EventColor {
  const EventColor(this.name, this.value);
  final String name;
  final int value;
  Color get color => Color(value);
}

const List<EventColor> eventPalette = [
  EventColor('Tomato', 0xFFD50000),
  EventColor('Flamingo', 0xFFE67C73),
  EventColor('Tangerine', 0xFFF4511E),
  EventColor('Banana', 0xFFF6BF26),
  EventColor('Sage', 0xFF33B679),
  EventColor('Basil', 0xFF0B8043),
  EventColor('Peacock', 0xFF039BE5),
  EventColor('Blueberry', 0xFF3F51B5),
  EventColor('Lavender', 0xFF7986CB),
  EventColor('Grape', 0xFF8E24AA),
  EventColor('Graphite', 0xFF616161),
];

/// THM-09.b: the default event color.
const int defaultEventColor = 0xFF1D4ED8;

/// UIC-20: a color that is not in the shared palette is represented by the
/// nearest palette color wherever it is shown or sent.
int nearestPaletteColor(int argb) {
  if (eventPalette.any((p) => p.value == argb)) return argb;
  int distance(int a, int b) {
    final ar = (a >> 16) & 0xFF, ag = (a >> 8) & 0xFF, ab = a & 0xFF;
    final br = (b >> 16) & 0xFF, bg = (b >> 8) & 0xFF, bb = b & 0xFF;
    return (ar - br) * (ar - br) + (ag - bg) * (ag - bg) + (ab - bb) * (ab - bb);
  }

  var best = eventPalette.first.value;
  var bestD = distance(argb, best);
  for (final p in eventPalette) {
    final d = distance(argb, p.value);
    if (d < bestD) {
      best = p.value;
      bestD = d;
    }
  }
  return best;
}

/// EVT-03.i: an event's color is its own color, else the color of the rule that
/// gave it one, else its calendar's color, else the default event color.
int resolveEventColor({int? own, int? rule, int? calendar}) =>
    own ?? rule ?? calendar ?? defaultEventColor;
