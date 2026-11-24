import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/server/board_items.dart';
import 'package:scrumboard/server/server.dart';
import 'package:scrumboard/src/api/models.dart';

import 'server_test.dart' show raw;

/// Fixtures copied from the real files on 2026-11-24 (SCB-17.a):
/// - `verifications.md` is `scrum/verifications.md` as it was.
/// - `questions.md` is `scrum/questions.md` as it was. That file had no open
///   question, so its Format block is kept as is and four question items
///   written in that format (choice lines indented 3 spaces) are added after
///   it. Their file order (3, 1, 2, 4) differs from number order: number 1 is
///   a reused number written after 3 (SCB-17.c).
const _fixtures = 'test/server/fixtures/board_items';

/// The fixture with LF line ends, whatever git did on checkout.
String _lf(String name) =>
    File('$_fixtures/$name').readAsStringSync().replaceAll('\r\n', '\n');

String _crlf(String name) => _lf(name).replaceAll('\n', '\r\n');

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('scb_items_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  String write(String name, String text) {
    final f = File('${tmp.path}/$name')..writeAsStringSync(text);
    return f.path;
  }

  group('SCB-17.a', () {
    test('SCB-17.a the real file copies parse; Format blocks give no item', () {
      final items = readBoardItems(
        write('q.md', _lf('questions.md')),
        write('v.md', _lf('verifications.md')),
      );
      // Questions: only the four added items; the Format block's
      // `## <number>. ...` heading is not one.
      expect(items.questions.map((q) => q.number).toSet(), {1, 2, 3, 4});
      expect(
        items.questions.every((q) => q.kind == BoardItem.question),
        isTrue,
      );
      final two = items.questions.firstWhere((q) => q.number == 2);
      expect(two.heading, 'Tanaka, Sprint 015 Where the result goes');
      expect(two.status, 'open');
      expect(two.text, 'Where does the board write a verification result?');
      expect(two.choices, [
        'a) Under "Result:" in the file. (recommended)',
        'b) In a new file.',
        'c) Nowhere; the Executive writes it.',
      ]);
      expect(two.answer, '');
      expect(two.pbi, isNull);
      final three = items.questions.firstWhere((q) => q.number == 3);
      expect(three.answer, 'a) The current week. (recommended)');
      expect(three.choices, hasLength(2));

      // Verifications: one item per numbered heading of the real copy, each
      // with its PBI and Verify text; no choices.
      final headings = RegExp(
        r'^## \d+\. ',
        multiLine: true,
      ).allMatches(_lf('verifications.md')).length;
      expect(headings, greaterThan(0));
      expect(items.verifications, hasLength(headings));
      for (final v in items.verifications) {
        expect(v.kind, BoardItem.verification);
        expect(v.pbi, matches(RegExp(r'^PBI-\d+$')), reason: v.heading);
        expect(v.heading, startsWith(v.pbi!));
        expect(v.text, isNotEmpty, reason: v.heading);
        expect(v.choices, isEmpty);
      }
      final one = items.verifications.firstWhere((v) => v.number == 1);
      expect(one.heading, 'PBI-108 Features column backlog choice');
      expect(one.text, startsWith('On the board, choose backlog'));
    });

    test('SCB-17.a a CRLF copy parses the same as the LF copy', () {
      final lf = readBoardItems(
        write('q.md', _lf('questions.md')),
        write('v.md', _lf('verifications.md')),
      );
      final crlf = readBoardItems(
        write('qc.md', _crlf('questions.md')),
        write('vc.md', _crlf('verifications.md')),
      );
      String dump(List<BoardItem> l) => jsonEncode([for (final i in l) i]);
      expect(dump(crlf.questions), dump(lf.questions));
      expect(dump(crlf.verifications), dump(lf.verifications));
      expect(crlf.questions.any((q) => q.heading.contains('\r')), isFalse);
    });

    test(
      'SCB-17.a a numbered heading inside the ``` Format block is skipped',
      () {
        final items = parseBoardItems(
          '# T\n\n## Format\n\n```\n## 9. Inside the fence\nStatus: open\n'
          '```\n\n## 5. Real one\nStatus: open\nQuestion: Q?\nAnswer:\n',
          BoardItem.question,
        );
        expect(items.map((i) => i.number), [5]);
      },
    );

    test('SCB-17.a a missing file gives an empty list', () {
      final items = readBoardItems(
        '${tmp.path}/none_q.md',
        '${tmp.path}/none_v.md',
      );
      expect(items.questions, isEmpty);
      expect(items.verifications, isEmpty);
    });
  });

  group('SCB-17.c', () {
    test('SCB-17.c open first, then answered or closed, newest first', () {
      final items = readBoardItems(
        write('q.md', _lf('questions.md')),
        write('v.md', ''),
      );
      // File order 3 (answered), 1 (open), 2 (open), 4 (closed).
      expect(items.questions.map((q) => q.number), [2, 1, 4, 3]);
      expect(items.questions.map((q) => q.status), [
        'open',
        'open',
        'closed',
        'answered',
      ]);
    });

    test('SCB-17.c verifications: every status kept, same order', () {
      final items = parseBoardItems(
        '## 2. PBI-1 a\nStatus: accepted\nVerify: x\nResult: ok\n\n'
        '## 1. PBI-2 b\nStatus: open\nVerify: y\nResult:\n\n'
        '## 3. PBI-3 c\nStatus: returned\nVerify: z\nResult: no\n\n'
        '## 4. PBI-4 d\nStatus: open\nVerify: w\nResult:\n',
        BoardItem.verification,
      );
      expect(orderBoardItems(items).map((v) => v.number), [4, 1, 3, 2]);
    });

    test('SCB-17.c empty files give empty lists', () {
      final items = readBoardItems(write('q.md', ''), write('v.md', ''));
      expect(items.questions, isEmpty);
      expect(items.verifications, isEmpty);
    });
  });

  group('server', () {
    late Directory repo;
    late ScrumBoardServer server;

    setUp(() async {
      repo = Directory('${tmp.path}/repo')..createSync();
      Directory('${repo.path}/scrum').createSync();
      server = await ScrumBoardServer.start(root: repo, port: 0);
    });

    tearDown(() => server.close());

    test(
      'SCB-17.a GET /api/questions answers both lists in column order',
      () async {
        File(
          '${repo.path}/scrum/questions.md',
        ).writeAsStringSync(_crlf('questions.md'));
        File(
          '${repo.path}/scrum/verifications.md',
        ).writeAsStringSync(_lf('verifications.md'));
        final r = await raw(server, 'GET', '/api/questions');
        expect(r.status, 200);
        final body = jsonDecode(r.body) as Map<String, dynamic>;
        expect(body.keys, unorderedEquals(['questions', 'verifications']));
        final questions = [
          for (final q in body['questions'] as List<dynamic>)
            BoardItem.fromJson(q as Map<String, dynamic>),
        ];
        expect(questions.map((q) => q.number), [2, 1, 4, 3]);
        expect(questions.first.choices, hasLength(3));
        final verifications = [
          for (final v in body['verifications'] as List<dynamic>)
            BoardItem.fromJson(v as Map<String, dynamic>),
        ];
        expect(verifications, isNotEmpty);
        expect(verifications.first.pbi, matches(RegExp(r'^PBI-\d+$')));
        // All open in the copy: newest (last in the file) first.
        expect(
          verifications.first.number,
          greaterThan(verifications.last.number),
        );
      },
    );

    test(
      'SCB-17.a GET /api/questions with neither file gives empty lists',
      () async {
        final r = await raw(server, 'GET', '/api/questions');
        expect(r.status, 200);
        expect(jsonDecode(r.body), {
          'questions': <Object>[],
          'verifications': <Object>[],
        });
      },
    );

    test(
      'SCB-13.b GET /api/questions answers; other verbs are not found',
      () async {
        expect((await raw(server, 'GET', '/api/questions')).status, 200);
        for (final verb in ['POST', 'PUT', 'DELETE', 'PATCH']) {
          final r = await raw(server, verb, '/api/questions');
          expect(r.status, 404, reason: verb);
          expect(jsonDecode(r.body), {'error': isA<String>()});
        }
      },
    );

    test('SCB-22 a change to either file changes the stamp', () async {
      Future<String> stamp() async =>
          (jsonDecode((await raw(server, 'GET', '/api/changes')).body)
                  as Map<String, dynamic>)['stamp']
              as String;
      var previous = await stamp();
      for (final name in ['questions.md', 'verifications.md']) {
        final f = File('${repo.path}/scrum/$name');
        // Created, then changed.
        f.writeAsStringSync('# x\n');
        var now = await stamp();
        expect(now, isNot(previous), reason: '$name created');
        previous = now;
        f.writeAsStringSync('# x\n## 1. y\nStatus: open\n');
        now = await stamp();
        expect(now, isNot(previous), reason: '$name changed');
        previous = now;
      }
    });
  });
}
