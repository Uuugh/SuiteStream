import 'dart:convert';
import 'dart:io';

import 'package:scrumboard/server/board_items.dart';

/// The statuses a verification result may set (SCB-17.b).
const Set<String> verificationResultStatuses = {'accepted', 'returned'};

/// The reason a write is refused when no item has the number AND heading
/// (an agent changed or deleted it meanwhile, SCB-17.b).
const String boardItemGone = 'gone';

bool _hasLineBreak(String s) => s.contains('\n') || s.contains('\r');

/// SCB-17.b: why the body of `PUT /api/questions/{n}/answer` is refused (400),
/// or null when it is fine.
String? answerRefusal(Object? heading, Object? answer) {
  if (heading is! String) return 'heading is missing';
  if (answer is! String) return 'answer is missing';
  if (_hasLineBreak(heading) || _hasLineBreak(answer)) {
    return 'a line break is not allowed';
  }
  if (answer.trim().isEmpty) return 'the answer is empty';
  return null;
}

/// SCB-17.b: why the body of `PUT /api/verifications/{n}/result` is refused
/// (400), or null when it is fine. The result may be empty only when
/// accepted.
String? resultRefusal(Object? heading, Object? result, Object? status) {
  if (heading is! String) return 'heading is missing';
  if (result is! String) return 'result is missing';
  if (status is! String || !verificationResultStatuses.contains(status)) {
    return 'status must be accepted or returned';
  }
  if (_hasLineBreak(heading) || _hasLineBreak(result)) {
    return 'a line break is not allowed';
  }
  if (status == 'returned' && result.trim().isEmpty) {
    return 'a returned verification needs a result';
  }
  return null;
}

/// SCB-17.b: writes the answer of question [number] with [heading] in the
/// questions file at [path] and sets it answered. See [_writeItem].
Map<String, Object?> writeQuestionAnswer(
  String path,
  int number,
  String heading,
  String answer,
) => _writeItem(path, number, heading, 'Answer', answer, 'answered');

/// SCB-17.b: writes the result of verification [number] with [heading] in the
/// verifications file at [path] and sets [status] (`accepted` or `returned`).
/// See [_writeItem].
Map<String, Object?> writeVerificationResult(
  String path,
  int number,
  String heading,
  String result,
  String status,
) => _writeItem(path, number, heading, 'Result', result, status);

/// One line of the file with its own line end (`\r\n`, `\n`, or empty for a
/// last line without one), so untouched lines are written back as they were.
class _Line {
  _Line(this.text, this.end);
  String text;
  String end;
}

/// Reads the file again, finds the item `## <number>. <heading>` (outside the
/// ``` Format block; an open one first when two match) and changes only its
/// `Status:` line and its `<field>:` line: `Status: <status>` and
/// `<field>: <value>` (`<field>:` alone when [value] is empty), dropping the
/// field's old continuation lines. A missing line is added (status after the
/// heading, field after the item's last text line) with the file's line end
/// (CRLF when the file has any). Every other byte stays. The file is replaced
/// whole through a temp file and a rename. Returns `{ok, reason}`; with no
/// such item (or no file) nothing is written and the reason is `gone`.
Map<String, Object?> _writeItem(
  String path,
  int number,
  String heading,
  String field,
  String value,
  String status,
) {
  final file = File(path);
  if (!file.existsSync()) return {'ok': false, 'reason': boardItemGone};
  final text = utf8.decode(file.readAsBytesSync());
  final lines = _splitLines(text);
  final newline = text.contains('\r\n') ? '\r\n' : '\n';

  // Each item: [start, end) line range, its heading line at start.
  final matches = <(int, int)>[];
  var fenced = false;
  int? start;
  void close(int end) {
    final s = start;
    if (s != null) matches.add((s, end));
    start = null;
  }

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].text;
    if (line.trimLeft().startsWith('```')) {
      fenced = !fenced;
      continue;
    }
    if (fenced || !line.startsWith('#')) continue;
    close(i);
    final m = itemHeading.firstMatch(line);
    if (m != null &&
        int.parse(m.group(1)!) == number &&
        m.group(2)!.trim() == heading) {
      start = i;
    }
  }
  close(lines.length);
  if (matches.isEmpty) return {'ok': false, 'reason': boardItemGone};

  final statusLine = RegExp(r'^Status:');
  bool isOpen((int, int) r) {
    for (var i = r.$1 + 1; i < r.$2; i++) {
      if (statusLine.hasMatch(lines[i].text)) {
        return lines[i].text.substring('Status:'.length).trim().toLowerCase() ==
            'open';
      }
    }
    return false;
  }

  final (from, to) = matches.firstWhere(isOpen, orElse: () => matches.first);
  final item = lines.sublist(from, to);
  final fieldLine = RegExp('^$field:');
  final anyField = RegExp(r'^\w+:');
  final newStatus = 'Status: $status';
  final newField = value.isEmpty ? '$field:' : '$field: $value';

  // Status line: replace, or add after the heading.
  final s = item.indexWhere((l) => statusLine.hasMatch(l.text), 1);
  if (s > 0) {
    item[s].text = newStatus;
  } else {
    _insert(item, 1, newStatus, newline);
  }

  // Field line: replace and drop its continuation lines, or add after the
  // item's last non-blank line.
  final f = item.indexWhere((l) => fieldLine.hasMatch(l.text), 1);
  if (f > 0) {
    item[f].text = newField;
    var j = f + 1;
    while (j < item.length &&
        item[j].text.trim().isNotEmpty &&
        !anyField.hasMatch(item[j].text)) {
      j++;
    }
    if (j > f + 1) {
      // Keep the line end of the last dropped line when it was the file's
      // last line (no line end after it).
      final lastEnd = item[j - 1].end;
      item.removeRange(f + 1, j);
      if (lastEnd.isEmpty && f + 1 == item.length) item[f].end = '';
    }
  } else {
    var last = item.length - 1;
    while (last > 0 && item[last].text.trim().isEmpty) {
      last--;
    }
    _insert(item, last + 1, newField, newline);
  }

  lines.replaceRange(from, to, item);
  final out = StringBuffer();
  for (final l in lines) {
    out
      ..write(l.text)
      ..write(l.end);
  }
  final tmp = File('$path.tmp');
  try {
    tmp.writeAsBytesSync(utf8.encode(out.toString()));
    tmp.renameSync(path);
  } finally {
    if (tmp.existsSync()) tmp.deleteSync();
  }
  return {'ok': true, 'reason': ''};
}

/// Splits [text] into lines, each with its own line end.
List<_Line> _splitLines(String text) {
  final lines = <_Line>[];
  var at = 0;
  while (at < text.length) {
    final nl = text.indexOf('\n', at);
    if (nl < 0) {
      lines.add(_Line(text.substring(at), ''));
      break;
    }
    final cr = nl > at && text.codeUnitAt(nl - 1) == 0x0D;
    lines.add(
      _Line(text.substring(at, cr ? nl - 1 : nl), cr ? '\r\n' : '\n'),
    );
    at = nl + 1;
  }
  return lines;
}

/// Inserts a line with [newline] at [index] of [item]. When it goes after a
/// line with no line end (the file's last line), that line gets [newline] and
/// the new line takes over the missing end.
void _insert(List<_Line> item, int index, String text, String newline) {
  final before = item[index - 1];
  if (before.end.isEmpty) {
    before.end = newline;
    item.insert(index, _Line(text, ''));
  } else {
    item.insert(index, _Line(text, newline));
  }
}
