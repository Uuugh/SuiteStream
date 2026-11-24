import 'dart:io';

import 'package:scrumboard/server/markdown_table.dart';

/// The request body of `PUT /api/sprint` is not a valid sprint (400).
class SprintFormatException implements Exception {
  const SprintFormatException(this.reason);

  final String reason;

  @override
  String toString() => reason;
}

const List<String> _blockHeader = [
  'ID',
  'Kind',
  'Name',
  'Parent',
  'Assignee',
  'Estimate',
  'Usage',
];
const List<String> _memberHeader = ['Block', 'Item'];
const Set<String> _kinds = {'story', 'epic', 'sprint'};

Map<String, dynamic> emptySprint() => {
      'exists': false,
      'blocks': <Object?>[],
      'members': <Object?>[],
    };

/// One section's table inside the file: the line range of its table lines.
class _Table {
  _Table(this.start, this.end);

  /// First table line and one past the last (indexes into the lines).
  final int start;
  final int end;
}

/// Finds the table that follows the heading named [section] (the text of the
/// heading, any level, case-insensitive), or null.
_Table? _findTable(List<String> lines, String section) {
  final heading = RegExp(
    '^#{1,6}\\s+${RegExp.escape(section)}\\s*\$',
    caseSensitive: false,
  );
  for (var i = 0; i < lines.length; i++) {
    if (!heading.hasMatch(lines[i].trimRight())) continue;
    var j = i + 1;
    // Skip blank lines and prose until a table line or the next heading.
    while (j < lines.length && !isTableLine(lines[j])) {
      if (RegExp(r'^#{1,6}\s').hasMatch(lines[j])) return null;
      j++;
    }
    if (j >= lines.length) return null;
    var k = j;
    while (k < lines.length && isTableLine(lines[k])) {
      k++;
    }
    return _Table(j, k);
  }
  return null;
}

num? _number(String cell) {
  if (cell.isEmpty || cell == '-' || cell == '–' || cell == '—') return null;
  return num.tryParse(cell);
}

String? _text(String cell) => cell.isEmpty ? null : cell;

/// Reads the blocks and members from the sprint text. A row it cannot read is
/// skipped here and stays in the file (SCB-02.f).
Map<String, dynamic> parseSprint(String text) {
  final lines = text.split(RegExp(r'\r?\n'));
  final blocks = <Map<String, dynamic>>[];
  final members = <Map<String, dynamic>>[];
  final bt = _findTable(lines, 'Blocks');
  if (bt != null) {
    for (final b in _dataRows(lines, bt)) {
      final block = _parseBlock(b);
      if (block != null) blocks.add(block);
    }
  }
  final mt = _findTable(lines, 'Members');
  if (mt != null) {
    for (final m in _dataRows(lines, mt)) {
      final member = _parseMember(m);
      if (member != null) members.add(member);
    }
  }
  return {'exists': true, 'blocks': blocks, 'members': members};
}

/// The table lines after the header and the separator.
Iterable<String> _dataRows(List<String> lines, _Table t) sync* {
  var i = t.start;
  if (i < t.end) i++; // header
  if (i < t.end && isSeparatorRow(lines[i])) i++;
  for (; i < t.end; i++) {
    yield lines[i];
  }
}

Map<String, dynamic>? _parseBlock(String line) {
  final c = splitRow(line);
  if (c.length != 7 || c[0].isEmpty || !_kinds.contains(c[1].toLowerCase())) {
    return null;
  }
  final estimate = _number(c[5]);
  final usage = _number(c[6]);
  if ((c[5].isNotEmpty && estimate == null && !_isDash(c[5])) ||
      (c[6].isNotEmpty && usage == null && !_isDash(c[6]))) {
    return null;
  }
  return {
    'id': c[0],
    'kind': c[1].toLowerCase(),
    'name': c[2],
    'parent': _text(c[3]),
    'assignee': _text(c[4]),
    'estimate': estimate,
    'usage': usage,
  };
}

bool _isDash(String s) => s == '-' || s == '–' || s == '—';

Map<String, dynamic>? _parseMember(String line) {
  final c = splitRow(line);
  if (c.length != 2 || c[0].isEmpty || c[1].isEmpty) return null;
  return {'block': c[0], 'item': c[1]};
}

String _numText(num n) =>
    n == n.truncate() ? n.truncate().toString() : n.toString();

/// Checks a `PUT` body and returns the cell lists, or throws.
({List<List<String>> blocks, List<List<String>> members}) _validate(
  Object? body,
) {
  if (body is! Map<String, dynamic>) {
    throw const SprintFormatException('the body must be a JSON object');
  }
  final rawBlocks = body['blocks'];
  final rawMembers = body['members'];
  if (rawBlocks is! List<dynamic> || rawMembers is! List<dynamic>) {
    throw const SprintFormatException('blocks and members must be lists');
  }
  final blocks = <List<String>>[];
  final ids = <String>{};
  for (final b in rawBlocks) {
    if (b is! Map<String, dynamic>) {
      throw const SprintFormatException('a block must be an object');
    }
    final id = b['id'];
    final kind = b['kind'];
    final name = b['name'];
    if (id is! String || id.trim().isEmpty) {
      throw const SprintFormatException('a block needs an id');
    }
    if (!ids.add(id)) {
      throw SprintFormatException('duplicate block id $id');
    }
    if (kind is! String || !_kinds.contains(kind)) {
      throw SprintFormatException('block $id: kind must be story, epic or sprint');
    }
    if (name is! String) {
      throw SprintFormatException('block $id: name must be text');
    }
    String cell(String key) {
      final v = b[key];
      if (v == null) return '';
      if (v is String) return v;
      throw SprintFormatException('block $id: $key must be text or null');
    }

    String numCell(String key) {
      final v = b[key];
      if (v == null) return '';
      if (v is num && v.isFinite) return _numText(v);
      throw SprintFormatException('block $id: $key must be a number or null');
    }

    blocks.add([
      id,
      kind,
      name,
      cell('parent'),
      cell('assignee'),
      numCell('estimate'),
      numCell('usage'),
    ]);
  }
  final members = <List<String>>[];
  for (final m in rawMembers) {
    if (m is! Map<String, dynamic> ||
        m['block'] is! String ||
        m['item'] is! String ||
        (m['block'] as String).trim().isEmpty ||
        (m['item'] as String).trim().isEmpty) {
      throw const SprintFormatException('a member needs block and item');
    }
    members.add([m['block'] as String, m['item'] as String]);
  }
  return (blocks: blocks, members: members);
}

bool _sameCells(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final x = _isDash(a[i]) ? '' : a[i];
    final y = _isDash(b[i]) ? '' : b[i];
    if (x != y) return false;
  }
  return true;
}

/// Replaces the data rows of the table in [section] with [rows], keeping the
/// header, the separator and every row it could not read in their places
/// (SCB-02.f). Returns the new lines; creates the section when missing.
List<String> _replaceTable(
  List<String> lines,
  String section,
  List<String> header,
  List<List<String>> rows,
  bool Function(String line) readable,
) {
  final t = _findTable(lines, section);
  if (t == null) {
    // Add the section at the end (before trailing blank lines).
    final out = List<String>.of(lines);
    while (out.isNotEmpty && out.last.trim().isEmpty) {
      out.removeLast();
    }
    if (out.isNotEmpty) out.add('');
    out
      ..add('## $section')
      ..add('')
      ..add(joinRow(header))
      ..add(joinRow([for (final _ in header) '---']))
      ..addAll(rows.map(joinRow))
      ..add('');
    return out;
  }
  var i = t.start;
  final out = lines.sublist(0, t.start);
  if (i < t.end) {
    out.add(lines[i]); // header as it was
    i++;
  }
  if (i < t.end && isSeparatorRow(lines[i])) {
    out.add(lines[i]);
    i++;
  }
  var next = 0;
  var lastReadableAt = -1;
  for (; i < t.end; i++) {
    if (readable(lines[i])) {
      if (next < rows.length) {
        final row = rows[next++];
        // A row that did not change keeps its own text (SCB-02.f).
        out.add(_sameCells(splitRow(lines[i]), row) ? lines[i] : joinRow(row));
        lastReadableAt = out.length;
      }
    } else {
      out.add(lines[i]);
    }
  }
  if (next < rows.length) {
    final extra = rows.sublist(next).map(joinRow).toList();
    out.insertAll(
      lastReadableAt >= 0 ? lastReadableAt : out.length,
      extra,
    );
  }
  out.addAll(lines.sublist(t.end));
  return out;
}

/// Returns the new file text for the [existing] text (null when the file does
/// not exist) with the blocks and members of [body] written in. Everything
/// the board does not edit is kept as it was (SCB-02.d, SCB-02.f), and a
/// missing file is created whole (SCB-02.e).
String renderSprint(String? existing, Object? body) {
  final v = _validate(body);
  if (existing == null) {
    final out = <String>[
      '# Sprint',
      '',
      '## Blocks',
      '',
      joinRow(_blockHeader),
      joinRow([for (final _ in _blockHeader) '---']),
      ...v.blocks.map(joinRow),
      '',
      '## Members',
      '',
      joinRow(_memberHeader),
      joinRow([for (final _ in _memberHeader) '---']),
      ...v.members.map(joinRow),
      '',
      '## Review',
      '',
      '## Retrospective',
      '',
    ];
    return out.join('\n');
  }
  final newline = existing.contains('\r\n') ? '\r\n' : '\n';
  var lines = existing.split(RegExp(r'\r?\n'));
  lines = _replaceTable(
    lines,
    'Blocks',
    _blockHeader,
    v.blocks,
    (l) => _parseBlock(l) != null,
  );
  lines = _replaceTable(
    lines,
    'Members',
    _memberHeader,
    v.members,
    (l) => _parseMember(l) != null,
  );
  return lines.join(newline);
}

/// Reads the sprint file at [path]; `{exists: false, ...}` when missing.
Map<String, dynamic> readSprintFile(String path) {
  final f = File(path);
  if (!f.existsSync()) return emptySprint();
  return parseSprint(f.readAsStringSync());
}

/// Validates [body], writes the sprint file at [path] (the whole file is
/// replaced or not at all) and returns the file as it now reads.
Map<String, dynamic> writeSprintFile(String path, Object? body) {
  final f = File(path);
  final existing = f.existsSync() ? f.readAsStringSync() : null;
  final text = renderSprint(existing, body);
  f.parent.createSync(recursive: true);
  final tmp = File('$path.tmp');
  tmp.writeAsStringSync(text);
  tmp.renameSync(path);
  return parseSprint(text);
}
