import 'dart:io';

import 'package:scrumboard/server/markdown_table.dart';
import 'package:scrumboard/server/paths.dart';

/// Reads the progress folder: one file per agent, named by the agent's label,
/// holding `done/total`. A file that does not read that way is left out.
/// With no folder the answer is empty.
List<Map<String, Object>> readProgress(Directory? dir) {
  if (dir == null || !dir.existsSync()) return const [];
  final dirPath = dir.resolveSymbolicLinksSync();
  final out = <Map<String, Object>>[];
  final files = dir.listSync(followLinks: false).whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final f in files) {
    final real = f.resolveSymbolicLinksSync();
    if (!isInside(dirPath, real)) continue;
    final match = RegExp(r'^\s*(\d+)\s*/\s*(\d+)\s*$')
        .firstMatch(f.readAsStringSync());
    if (match == null) continue;
    out.add({
      'label': f.uri.pathSegments.last,
      'done': int.parse(match.group(1)!),
      'total': int.parse(match.group(2)!),
    });
  }
  return out;
}

num? _percent(String cell) {
  final t = cell.replaceAll('%', '').trim();
  return num.tryParse(t);
}

/// Reads `<root>/scrum/usage.md`: the first table whose header has the
/// SCB-14.a columns (block, estimate session and weekly, before session and
/// weekly, after session and weekly). A missing file gives
/// `{exists: false, rows: []}`; a file with no such table
/// `{exists: true, rows: []}`.
Map<String, Object> readUsage(Directory root) {
  final path = resolveInside(root, 'scrum/usage.md');
  final f = File(path);
  if (!f.existsSync()) return {'exists': false, 'rows': <Object>[]};
  final lines = f.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (!isTableLine(lines[i])) continue;
    var end = i;
    while (end < lines.length && isTableLine(lines[end])) {
      end++;
    }
    if (_isUsageHeader(splitRow(lines[i]))) {
      final rows = <Map<String, Object?>>[];
      var j = i + 1;
      if (j < end && isSeparatorRow(lines[j])) j++;
      for (; j < end; j++) {
        final c = splitRow(lines[j]);
        if (c.length != 7 || c[0].isEmpty) continue;
        rows.add({
          'block': c[0],
          'estimateSession': _percent(c[1]),
          'estimateWeekly': _percent(c[2]),
          'beforeSession': _percent(c[3]),
          'beforeWeekly': _percent(c[4]),
          'afterSession': _percent(c[5]),
          'afterWeekly': _percent(c[6]),
        });
      }
      return {'exists': true, 'rows': rows};
    }
    i = end;
  }
  return {'exists': true, 'rows': <Object>[]};
}

bool _isUsageHeader(List<String> h) {
  if (h.length != 7) return false;
  final l = h.map((s) => s.toLowerCase()).toList();
  bool has(int i, String a, String b) => l[i].contains(a) && l[i].contains(b);
  return l[0].contains('block') &&
      has(1, 'estimate', 'session') &&
      has(2, 'estimate', 'week') &&
      has(3, 'before', 'session') &&
      has(4, 'before', 'week') &&
      has(5, 'after', 'session') &&
      has(6, 'after', 'week');
}
