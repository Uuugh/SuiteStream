import 'dart:io';

import 'package:scrumboard/server/markdown_table.dart';
import 'package:scrumboard/server/paths.dart';
import 'package:scrumboard/server/requirements_reader.dart';

/// The reason written for every retirement from the board (SCB-19.a).
const String retireReason = 'retired from the ScrumBoard by the Executive';

/// SCB-19.a: moves the whole row of requirement [id] from its requirement
/// file to `requirements/retired.md`, with [today] (`yyyy-mm-dd`) and the
/// reason. Each file is replaced whole through a temp file and a rename, or
/// not at all. Returns `{ok, reason}`; `reason` is empty when ok.
Map<String, Object?> retireRequirement(
  Directory root,
  String id,
  String today,
) {
  final row = readRequirements(root).where((r) => r['id'] == id).firstOrNull;
  if (row == null) return {'ok': false, 'reason': 'no requirement $id'};
  final path = resolveInside(root, row['file']!);
  final retiredPath = resolveInside(root, 'requirements/retired.md');
  final source = File(path);
  final lines = source.readAsStringSync().split('\n');
  final index = lines.indexWhere((l) {
    final cells = splitRow(l);
    return cells.length >= 4 && cells[0] == id;
  });
  if (index < 0) return {'ok': false, 'reason': 'no requirement $id'};
  final original = lines[index].trim();
  final kept = [...lines]..removeAt(index);

  final retired = File(retiredPath);
  final before = retired.existsSync()
      ? retired.readAsStringSync()
      : '# Retired requirements\n\n| ID | Date | Reason | Row as it was |\n'
          '|---|---|---|---|\n';
  final entry = '| $id | $today | $retireReason | '
      '${original.replaceAll('|', r'\|')} |';
  final after = '${before.endsWith('\n') ? before : '$before\n'}$entry\n';

  final tmpRetired = File('$retiredPath.tmp');
  final tmpSource = File('$path.tmp');
  var retiredRenamed = false;
  try {
    tmpRetired.writeAsStringSync(after);
    tmpSource.writeAsStringSync(kept.join('\n'));
    tmpRetired.renameSync(retiredPath);
    retiredRenamed = true;
    tmpSource.renameSync(path);
  } on Object {
    if (retiredRenamed) retired.writeAsStringSync(before);
    rethrow;
  } finally {
    if (tmpRetired.existsSync()) tmpRetired.deleteSync();
    if (tmpSource.existsSync()) tmpSource.deleteSync();
  }
  return {'ok': true, 'reason': ''};
}
