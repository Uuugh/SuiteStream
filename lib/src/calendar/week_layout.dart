/// One event placed in the hourly grid.
class PlacedEvent<E> {
  PlacedEvent(this.event, this.column, this.columns, this.startMinute, this.endMinute);
  final E event;
  final int column;

  /// How many columns the overlapping group needs; the event takes 1/columns of the width.
  final int columns;
  final int startMinute;
  final int endMinute;
}

/// CAL-01.h: events are placed by their time, side by side when they overlap.
/// [spans] gives each event's start and end in minutes of the day (end is
/// clamped to at least [minLength] so a short event stays visible).
List<PlacedEvent<E>> layoutOverlaps<E>(
  List<E> events,
  (int start, int end) Function(E) spans, {
  int minLength = 20,
}) {
  final items = [
    for (final e in events)
      () {
        final s = spans(e);
        final end = s.$2 - s.$1 < minLength ? s.$1 + minLength : s.$2;
        return (e: e, start: s.$1, end: end);
      }(),
  ]..sort((a, b) => a.start != b.start ? a.start.compareTo(b.start) : b.end.compareTo(a.end));

  final out = <PlacedEvent<E>>[];
  var group = <({E e, int start, int end, int col})>[];
  var groupEnd = -1;

  void flush() {
    if (group.isEmpty) return;
    final cols = group.map((g) => g.col).reduce((a, b) => a > b ? a : b) + 1;
    for (final g in group) {
      out.add(PlacedEvent(g.e, g.col, cols, g.start, g.end));
    }
    group = [];
  }

  final colEnds = <int>[];
  for (final it in items) {
    if (it.start >= groupEnd) {
      flush();
      colEnds.clear();
    }
    var col = colEnds.indexWhere((end) => end <= it.start);
    if (col < 0) {
      col = colEnds.length;
      colEnds.add(it.end);
    } else {
      colEnds[col] = it.end;
    }
    group.add((e: it.e, start: it.start, end: it.end, col: col));
    if (it.end > groupEnd) groupEnd = it.end;
  }
  flush();
  return out;
}
