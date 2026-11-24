import 'dart:io';

import 'package:scrumboard/server/markdown_table.dart';
import 'package:scrumboard/server/paths.dart';

/// Files in `requirements/` (at any depth) that hold no requirements
/// (SCB-03.a).
const Set<String> excludedRequirementFiles = {
  'readme.md',
  'oldkey.md',
  'open-questions.md',
};

final RegExp _idPattern = RegExp(r'^[A-Z]{2,5}-\d+[A-Za-z0-9.]*$');

/// Reads every requirement row of every feature file under
/// `<root>/requirements`, including the folders ending `.d` (`connections.d`,
/// `plugins.d`). A blank status is read as `backlog` (SCB-03.b).
/// Each row is `{id, status, statement, feature, file}`.
List<Map<String, String>> readRequirements(Directory root) {
  final dirPath = resolveInside(root, 'requirements');
  final rootPath = root.resolveSymbolicLinksSync();
  final dir = Directory(dirPath);
  if (!dir.existsSync()) return const [];
  final files = <File>[];
  _collect(dir, files, top: true);
  final prefix = '${rootPath.replaceAll(r'\', '/')}/';
  final paths = {
    for (final f in files) f: f.path.replaceAll(r'\', '/'),
  };
  files.sort((a, b) => paths[a]!.compareTo(paths[b]!));
  final rows = <Map<String, String>>[];
  for (final f in files) {
    final relative = paths[f]!.startsWith(prefix)
        ? paths[f]!.substring(prefix.length)
        : paths[f]!;
    final name = relative.split('/').last;
    final feature = name.substring(0, name.length - 3);
    for (final line in f.readAsLinesSync()) {
      final cells = splitRow(line);
      if (cells.length < 4 || !_idPattern.hasMatch(cells[0])) continue;
      final status = cells[1].toLowerCase();
      rows.add({
        'id': cells[0],
        'status': status.isEmpty ? 'backlog' : status,
        // The statement is everything between the status and the test cell.
        'statement': cells.sublist(2, cells.length - 1).join('|'),
        'feature': feature,
        'file': relative,
      });
    }
  }
  return rows;
}

void _collect(Directory dir, List<File> out, {required bool top}) {
  for (final e in dir.listSync(followLinks: false)) {
    final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (e is File) {
      final lower = name.toLowerCase();
      if (lower.endsWith('.md') && !excludedRequirementFiles.contains(lower)) {
        out.add(e);
      }
    } else if (e is Directory && name.endsWith('.d')) {
      _collect(e, out, top: false);
    }
  }
}
