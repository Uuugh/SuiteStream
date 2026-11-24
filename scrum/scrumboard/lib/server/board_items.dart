import 'dart:io';

import 'package:scrumboard/src/api/models.dart';

/// SCB-17: reads the open questions (`scrum/questions.md`) and verifications
/// (`scrum/verifications.md`) for the Questions and Verifications column.
///
/// Each list is in column order (SCB-17.c): open items first, then answered
/// or closed ones; newest first (reverse file order) within each. Every
/// status is kept. A missing file gives an empty list.
({List<BoardItem> questions, List<BoardItem> verifications}) readBoardItems(
  String questionsPath,
  String verificationsPath,
) => (
  questions: orderBoardItems(
    parseBoardItems(_readOrEmpty(questionsPath), BoardItem.question),
  ),
  verifications: orderBoardItems(
    parseBoardItems(_readOrEmpty(verificationsPath), BoardItem.verification),
  ),
);

String _readOrEmpty(String path) {
  final file = File(path);
  try {
    return file.existsSync() ? file.readAsStringSync() : '';
  } on FileSystemException {
    // A file that vanished while reading counts as missing.
    return '';
  }
}

/// `## <n>. <heading>`; the heading may be empty.
final RegExp itemHeading = RegExp(r'^## (\d+)\. ?(.*)$');

final RegExp _pbi = RegExp(r'^PBI-\d+$');

/// Parses the items of one file in file order. CRLF and LF both read; text
/// inside a ``` fence (the Format block) is skipped, so its
/// `## <number>. ...` heading never becomes an item.
List<BoardItem> parseBoardItems(String text, String kind) {
  final lines = text
      .split('\n')
      .map((l) => l.endsWith('\r') ? l.substring(0, l.length - 1) : l);
  final items = <BoardItem>[];
  _Draft? draft;
  var fenced = false;

  void finish() {
    final d = draft;
    if (d != null) items.add(d.build(kind));
    draft = null;
  }

  for (final line in lines) {
    if (line.trimLeft().startsWith('```')) {
      fenced = !fenced;
      continue;
    }
    if (fenced) continue;
    if (line.startsWith('#')) {
      // Any heading ends the item before it.
      finish();
      final m = itemHeading.firstMatch(line);
      if (m != null) {
        draft = _Draft(int.parse(m.group(1)!), m.group(2)!.trim());
      }
      continue;
    }
    draft?.add(line);
  }
  finish();
  return items;
}

/// SCB-17.c: open first, then the rest (answered, accepted, returned or any
/// other status); newest first, that is reverse file order, within each.
List<BoardItem> orderBoardItems(List<BoardItem> items) {
  final reversed = items.reversed;
  return [
    ...reversed.where((i) => i.status == 'open'),
    ...reversed.where((i) => i.status != 'open'),
  ];
}

/// One item while its lines are read.
class _Draft {
  _Draft(this.number, this.heading);

  final int number;
  final String heading;
  String status = '';
  final List<String> text = [];
  final List<String> choices = [];
  final List<String> answer = [];

  /// The field the next plain line belongs to.
  List<String>? _current;

  static final RegExp _field = RegExp(r'^(\w+):\s?(.*)$');

  void add(String line) {
    final field = _field.firstMatch(line);
    if (field != null) {
      final value = field.group(2)!.trim();
      switch (field.group(1)!) {
        case 'Status':
          status = value.toLowerCase();
          _current = null;
          return;
        case 'Question':
        case 'Verify':
          _current = text;
          if (value.isNotEmpty) text.add(value);
          return;
        case 'Answer':
        case 'Result':
          _current = answer;
          if (value.isNotEmpty) answer.add(value);
          return;
      }
    }
    if (line.trim().isEmpty) return;
    if (_current == text && line.startsWith(RegExp(r'\s'))) {
      // An indented line under the question is a choice (a verification
      // keeps none); a `Choices:` label line with nothing after it is not.
      var choice = line.trim();
      if (choice.startsWith('Choices:')) {
        choice = choice.substring('Choices:'.length).trim();
      }
      if (choice.isNotEmpty) choices.add(choice);
      return;
    }
    _current?.add(line.trim());
  }

  BoardItem build(String kind) {
    final first = heading.split(' ').first;
    return BoardItem(
      kind: kind,
      number: number,
      heading: heading,
      status: status,
      text: text.join('\n'),
      choices: kind == BoardItem.question
          ? List.unmodifiable(choices)
          : const [],
      pbi: kind == BoardItem.verification && _pbi.hasMatch(first)
          ? first
          : null,
      answer: answer.join('\n'),
    );
  }
}
