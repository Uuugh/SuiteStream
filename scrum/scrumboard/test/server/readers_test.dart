import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/server/progress_usage_readers.dart';
import 'package:scrumboard/server/requirements_reader.dart';
import 'package:scrumboard/server/sprint_file.dart';

void main() {
  late Directory repo;

  setUp(() {
    repo = Directory.systemTemp.createTempSync('scb_readers_');
    Directory('${repo.path}/scrum').createSync();
  });
  tearDown(() => repo.deleteSync(recursive: true));

  void put(String rel, String text) {
    final f = File('${repo.path}/$rel')..parent.createSync(recursive: true);
    f.writeAsStringSync(text);
  }

  const header = '| ID | status | statement | test |\n|---|---|---|---|\n';

  group('SCB-03.a', () {
    test('SCB-03.a reads every row, including connections.d and plugins.d',
        () {
      put('requirements/calendar.md', '$header| CAL-01 | planned | One | — |\n');
      put('requirements/connections.d/ccs.md',
          '$header| CCCS-01 | backlog | Two | — |\n');
      put('requirements/plugins.d/google_api.md',
          '$header| PGAP-01 | proposed | Three | — |\n');
      final rows = readRequirements(repo);
      expect(rows.map((r) => r['id']), ['CAL-01', 'CCCS-01', 'PGAP-01']);
      expect(rows[1]['feature'], 'ccs');
      expect(rows[1]['file'], 'requirements/connections.d/ccs.md');
    });

    test('SCB-03.a leaves out README.md, oldkey.md and open-questions.md', () {
      put('requirements/README.md', '$header| RDM-01 | backlog | x | — |\n');
      put('requirements/oldkey.md', '$header| OLD-01 | backlog | x | — |\n');
      put('requirements/open-questions.md',
          '$header| OQ-01 | backlog | x | — |\n');
      put('requirements/connections.d/README.md',
          '$header| CRD-01 | backlog | x | — |\n');
      put('requirements/shell.md', '$header| SHL-01 | backlog | x | — |\n');
      expect(readRequirements(repo).map((r) => r['id']), ['SHL-01']);
    });

    test('SCB-03.a keeps sub-requirements and an escaped bar in a statement',
        () {
      put('requirements/a.md',
          '$header| ABC-01.a | done | One \\| two | tests |\n');
      final r = readRequirements(repo).single;
      expect(r['id'], 'ABC-01.a');
      expect(r['statement'], 'One | two');
    });

    test('SCB-03.a a missing requirements folder gives an empty list', () {
      expect(readRequirements(repo), isEmpty);
    });
  });

  test('SCB-03.b a blank status is read as backlog', () {
    put('requirements/a.md', '$header| ABC-01 |  | One | — |\n');
    expect(readRequirements(repo).single['status'], 'backlog');
  });

  group('SCB-02', () {
    const sprint = '''# Sprint 11

Intro text that stays.

## Blocks

| ID | Kind | Name | Parent | Assignee | Estimate | Usage |
|---|---|---|---|---|---|---|
| E1 | epic | ScrumBoard | | | 20 | 4 |
| S1 | story | First | E1 | Nakamura | 8 | |
| broken row |
| S2 | story | Second | E1 | | | |

## Members

| Block | Item |
|---|---|
| S1 | SCB-03 |
| S1 | #12 |

## Review

### A heading inside the review

Review text.

## Retrospective

Retro text.
''';

    test('SCB-02.a SCB-02.b SCB-02.c reads blocks and members', () {
      final s = parseSprint(sprint);
      final blocks = s['blocks'] as List<dynamic>;
      expect(blocks.length, 3);
      expect(blocks[1], {
        'id': 'S1',
        'kind': 'story',
        'name': 'First',
        'parent': 'E1',
        'assignee': 'Nakamura',
        'estimate': 8,
        'usage': null,
      });
      expect(blocks[0]['parent'], isNull);
      expect(s['members'], [
        {'block': 'S1', 'item': 'SCB-03'},
        {'block': 'S1', 'item': '#12'},
      ]);
    });

    test('SCB-02.e a missing file reads as empty and the first write creates it',
        () {
      final path = '${repo.path}/scrum/sprint.md';
      final s = readSprintFile(path);
      expect(s, {'exists': false, 'blocks': <Object>[], 'members': <Object>[]});
      final written = writeSprintFile(path, {
        'blocks': [
          {'id': 'S1', 'kind': 'story', 'name': 'New'},
        ],
        'members': [
          {'block': 'S1', 'item': '#3'},
        ],
      });
      expect(File(path).existsSync(), isTrue);
      expect(written['exists'], isTrue);
      expect((written['blocks'] as List<dynamic>).single['id'], 'S1');
      final text = File(path).readAsStringSync();
      expect(text, contains('## Review'));
      expect(text, contains('## Retrospective'));
    });

    test('SCB-02.d SCB-02.f a write keeps text, headings and unreadable rows',
        () {
      final path = '${repo.path}/scrum/sprint.md';
      File(path).writeAsStringSync(sprint);
      final current = readSprintFile(path);
      final blocks = List<Map<String, dynamic>>.from(
        (current['blocks'] as List<dynamic>).cast<Map<String, dynamic>>(),
      )..[1]['usage'] = 3.5;
      writeSprintFile(path, {
        'blocks': blocks,
        'members': current['members'],
      });
      final text = File(path).readAsStringSync();
      expect(text, contains('Intro text that stays.'));
      expect(text, contains('### A heading inside the review'));
      expect(text, contains('Review text.'));
      expect(text, contains('Retro text.'));
      expect(text, contains('| broken row |'));
      expect(text, contains('| S1 | story | First | E1 | Nakamura | 8 | 3.5 |'));
      // Unchanged except the edited cell.
      expect(
        text,
        sprint.replaceAll(
          "| S1 | story | First | E1 | Nakamura | 8 | |",
          "| S1 | story | First | E1 | Nakamura | 8 | 3.5 |",
        ),
      );
    });

    test('SCB-02.d adding and removing rows is written at once', () {
      final path = '${repo.path}/scrum/sprint.md';
      File(path).writeAsStringSync(sprint);
      final out = writeSprintFile(path, {
        'blocks': [
          {'id': 'E1', 'kind': 'epic', 'name': 'ScrumBoard'},
          {'id': 'S9', 'kind': 'story', 'name': 'Nine', 'parent': 'E1'},
          {'id': 'S8', 'kind': 'story', 'name': 'Eight', 'parent': 'E1'},
          {'id': 'S7', 'kind': 'story', 'name': 'Seven', 'parent': 'E1'},
        ],
        'members': <Object>[],
      });
      expect(
        (out['blocks'] as List<dynamic>).map((b) => (b as Map)['id']),
        ['E1', 'S9', 'S8', 'S7'],
      );
      expect(out['members'], isEmpty);
      expect(File(path).readAsStringSync(), contains('| broken row |'));
    });

    test('SCB-02.f a file with CRLF line ends keeps them', () {
      final path = '${repo.path}/scrum/sprint.md';
      File(path).writeAsStringSync(sprint.replaceAll('\n', '\r\n'));
      writeSprintFile(path, {'blocks': <Object>[], 'members': <Object>[]});
      final text = File(path).readAsStringSync();
      expect(text.contains('\r\n'), isTrue);
      expect(RegExp(r'(?<!\r)\n').hasMatch(text), isFalse);
    });

    test('SCB-02.f a file with no tables gets them added after its text', () {
      final path = '${repo.path}/scrum/sprint.md';
      File(path).writeAsStringSync('# Sprint\n\nJust notes.\n');
      writeSprintFile(path, {
        'blocks': [
          {'id': 'S1', 'kind': 'story', 'name': 'n'},
        ],
        'members': <Object>[],
      });
      final text = File(path).readAsStringSync();
      expect(text, startsWith('# Sprint\n\nJust notes.'));
      expect((parseSprint(text)['blocks'] as List<dynamic>).length, 1);
    });

    test('SCB-02.b refuses bad input', () {
      final path = '${repo.path}/scrum/sprint.md';
      expect(
        () => writeSprintFile(path, {'blocks': 'x', 'members': <Object>[]}),
        throwsA(isA<SprintFormatException>()),
      );
      expect(
        () => writeSprintFile(path, {
          'blocks': [
            {'id': 'S1', 'kind': 'story', 'name': 'a'},
            {'id': 'S1', 'kind': 'story', 'name': 'b'},
          ],
          'members': <Object>[],
        }),
        throwsA(isA<SprintFormatException>()),
      );
      expect(File(path).existsSync(), isFalse);
    });

    test('SCB-02.b a name with a bar survives a round trip', () {
      final path = '${repo.path}/scrum/sprint.md';
      writeSprintFile(path, {
        'blocks': [
          {'id': 'S1', 'kind': 'story', 'name': 'a | b'},
        ],
        'members': <Object>[],
      });
      final s = readSprintFile(path);
      expect((s['blocks'] as List<dynamic>).single['name'], 'a | b');
    });
  });

  group('progress and usage', () {
    test('SCB-12.c reads done/total files and skips the rest', () {
      put('progress/Ito', '1/4\n');
      put('progress/Tanaka', '0 / 3');
      put('progress/junk', 'hello');
      final rows = readProgress(Directory('${repo.path}/progress'));
      expect(rows, [
        {'label': 'Ito', 'done': 1, 'total': 4},
        {'label': 'Tanaka', 'done': 0, 'total': 3},
      ]);
      expect(readProgress(null), isEmpty);
    });

    test('SCB-14.g a missing usage file gives exists false', () {
      expect(readUsage(repo), {'exists': false, 'rows': <Object>[]});
    });

    test('SCB-14.g a usage file with no Usage table gives no rows', () {
      put('scrum/usage.md',
          '| Sprint | Story | Date |\n|---|---|---|\n| s1 | a | b |\n');
      expect(readUsage(repo), {'exists': true, 'rows': <Object>[]});
    });

    test('SCB-14.a reads the first table with the seven usage columns', () {
      put(
        'scrum/usage.md',
        '| Sprint | Story |\n|---|---|\n| s | t |\n\n'
        '| Block | Estimate session % | Estimate weekly % | Before session % '
        '| Before weekly % | After session % | After weekly % |\n'
        '|---|---|---|---|---|---|---|\n'
        '| S1 | 5 | 2 | 10 | 20 | 16 | – |\n',
      );
      final u = readUsage(repo);
      expect(u['exists'], isTrue);
      expect((u['rows'] as List<dynamic>).single, {
        'block': 'S1',
        'estimateSession': 5,
        'estimateWeekly': 2,
        'beforeSession': 10,
        'beforeWeekly': 20,
        'afterSession': 16,
        'afterWeekly': null,
      });
    });
  });
}
