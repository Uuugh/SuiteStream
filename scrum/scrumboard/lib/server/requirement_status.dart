import 'dart:io';

import 'package:scrumboard/server/markdown_table.dart';
import 'package:scrumboard/server/paths.dart';
import 'package:scrumboard/server/requirements_reader.dart';

/// The statuses a requirement can be moved between, lowest first (SCB-13.c).
const List<String> movableStatuses = ['proposed', 'backlog', 'planned', 'done'];

/// SCB-13.c: null when moving [from] to [to] is allowed, else the reason.
/// Only up moves are allowed, and the one move down is planned to backlog.
String? statusMoveRefusal(String from, String to) {
  final a = movableStatuses.indexOf(from);
  final b = movableStatuses.indexOf(to);
  if (b < 0) return 'unknown status: $to';
  if (a < 0) return 'the status $from cannot be changed here';
  if (a == b) return 'already $to';
  if (b > a) return null;
  if (from == 'planned' && to == 'backlog') return null;
  return '$from cannot move down to $to';
}

/// SCB-13.c and SCB-13.d: sets the status of requirement [id] under [root].
/// Edits only the status cell of that row, in its own file, and replaces the
/// file whole through a temp file and a rename. Returns `{ok, reason}`;
/// `reason` is empty when ok.
Map<String, Object?> setRequirementStatus(
  Directory root,
  String id,
  String status,
) {
  final target = status.trim().toLowerCase();
  final row = readRequirements(root).where((r) => r['id'] == id).firstOrNull;
  if (row == null) return {'ok': false, 'reason': 'no requirement $id'};
  final refusal = statusMoveRefusal(row['status']!, target);
  if (refusal != null) return {'ok': false, 'reason': refusal};
  final path = resolveInside(root, row['file']!);
  final file = File(path);
  final lines = file.readAsStringSync().split('\n');
  var changed = false;
  for (var i = 0; i < lines.length && !changed; i++) {
    final cells = splitRow(lines[i]);
    if (cells.length < 4 || cells[0] != id) continue;
    final edited = _replaceSecondCell(lines[i], target);
    if (edited == null) continue;
    lines[i] = edited;
    changed = true;
  }
  if (!changed) return {'ok': false, 'reason': 'no requirement $id'};
  final tmp = File('$path.tmp');
  try {
    tmp.writeAsStringSync(lines.join('\n'));
    tmp.renameSync(path);
  } finally {
    if (tmp.existsSync()) tmp.deleteSync();
  }
  return {'ok': true, 'reason': ''};
}

/// Replaces the text of the second cell of [line] (the status), keeping the
/// spaces around it and every other character as it was.
String? _replaceSecondCell(String line, String value) {
  final pipes = <int>[];
  for (var i = 0; i < line.length; i++) {
    if (line[i] == '|' && !(i > 0 && line[i - 1] == r'\')) pipes.add(i);
    if (pipes.length == 3) break;
  }
  if (pipes.length < 3) return null;
  final cell = line.substring(pipes[1] + 1, pipes[2]);
  final lead = cell.length - cell.trimLeft().length;
  final trail = cell.length - cell.trimRight().length;
  final padded = cell.trim().isEmpty
      ? ' $value '
      : '${cell.substring(0, lead)}$value${cell.substring(cell.length - trail)}';
  return line.substring(0, pipes[1] + 1) + padded + line.substring(pipes[2]);
}
