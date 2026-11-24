import 'dart:io';

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

/// Reads `<root>/scrum/usage/usage.log` (pipe-separated, columns in
/// `scrum/usage/README.md`): the rows of [model] only, other models and tools
/// share the log but are never mixed in. The estimate columns are the ones
/// `usage.sh` wrote; the board never computes an estimate. A cell that is `?`
/// or `-` is null. A missing file gives `{exists: false, rows: []}`; a file
/// with no row of the model `{exists: true, rows: []}`.
Map<String, Object> readUsage(Directory root, {String model = 'Sonnet 5.5'}) {
  final path = resolveInside(root, 'scrum/usage/usage.log');
  final f = File(path);
  if (!f.existsSync()) return {'exists': false, 'rows': <Object>[]};
  final rows = <Map<String, Object?>>[];
  for (final line in f.readAsLinesSync()) {
    if (line.startsWith('#')) continue;
    final c = line.split('|');
    if (c.length < 13 || c[1] != model) continue;
    rows.add({
      'block': c[9].trim().isEmpty ? c[0] : c[9].trim(),
      'estimateSession': _percent(c[11]),
      'estimateWeekly': _percent(c[12]),
      'beforeSession': _percent(c[2]),
      'beforeWeekly': _percent(c[5]),
      'afterSession': _percent(c[3]),
      'afterWeekly': _percent(c[6]),
    });
  }
  return {'exists': true, 'rows': rows};
}
