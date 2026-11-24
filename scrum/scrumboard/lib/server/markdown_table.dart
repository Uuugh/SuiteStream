/// Small helpers for the Markdown pipe tables the server reads and writes.
library;

/// True when [line] is a table line (starts with `|` after spaces).
bool isTableLine(String line) => line.trimLeft().startsWith('|');

/// Splits a table line into trimmed cells. `\|` stays inside a cell (and
/// becomes `|`). Returns an empty list for a line that is not a table line.
List<String> splitRow(String line) {
  final t = line.trim();
  if (!t.startsWith('|')) return const [];
  final cells = <String>[];
  final buf = StringBuffer();
  var i = 1;
  while (i < t.length) {
    final c = t[i];
    if (c == r'\' && i + 1 < t.length && t[i + 1] == '|') {
      buf.write('|');
      i += 2;
      continue;
    }
    if (c == '|') {
      cells.add(buf.toString().trim());
      buf.clear();
    } else {
      buf.write(c);
    }
    i++;
  }
  // Text after the last pipe (a row without a closing pipe) is a cell too.
  final rest = buf.toString().trim();
  if (rest.isNotEmpty) cells.add(rest);
  return cells;
}

/// True for the `|---|:--:|` line under a header.
bool isSeparatorRow(String line) {
  final cells = splitRow(line);
  return cells.isNotEmpty &&
      cells.every((c) => RegExp(r'^:?-{3,}:?$').hasMatch(c));
}

/// Writes [cells] as a table line, escaping `|`.
String joinRow(List<String> cells) =>
    '| ${cells.map((c) => c.replaceAll('|', r'\|')).join(' | ')} |';
