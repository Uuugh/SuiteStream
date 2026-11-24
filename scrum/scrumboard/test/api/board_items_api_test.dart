import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';

const _question = BoardItem(
  kind: BoardItem.question,
  number: 1,
  heading: 'Ito, Sprint 015 Column width',
  status: 'open',
  text: 'How wide?',
  choices: ['a) Narrow. (recommended)', 'b) Wide.'],
);

const _verification = BoardItem(
  kind: BoardItem.verification,
  number: 1,
  heading: 'PBI-108 Features column backlog choice',
  status: 'open',
  text: 'Choose backlog.',
  pbi: 'PBI-108',
);

void main() {
  final base = Uri.parse('http://127.0.0.1:8081/');

  test(
    'SCB-17.a the client reads GET /api/questions into both lists',
    () async {
      final api = HttpScrumBoardApi(
        baseUri: base,
        client: MockClient((req) async {
          expect(req.method, 'GET');
          expect(req.url.path, '/api/questions');
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'questions': [_question.toJson()],
                'verifications': [_verification.toJson()],
              }),
            ),
            200,
          );
        }),
      );
      final items = await api.boardItems();
      expect(jsonEncode(items.questions), jsonEncode([_question]));
      expect(jsonEncode(items.verifications), jsonEncode([_verification]));
      expect(items.questions.single.choices, hasLength(2));
      expect(items.verifications.single.pbi, 'PBI-108');
    },
  );

  test('SCB-17.a a BoardItem survives JSON both ways', () {
    for (final item in [_question, _verification]) {
      final back = BoardItem.fromJson(
        jsonDecode(jsonEncode(item)) as Map<String, dynamic>,
      );
      expect(jsonEncode(back), jsonEncode(item));
    }
  });

  group('SCB-17.b HTTP writes', () {
    final requests = <http.Request>[];
    late ({int status, Map<String, Object?> body}) next;
    late HttpScrumBoardApi api;

    setUp(() {
      requests.clear();
      next = (status: 200, body: {'ok': true, 'reason': ''});
      api = HttpScrumBoardApi(
        baseUri: base,
        client: MockClient((req) async {
          requests.add(req);
          return http.Response.bytes(
            utf8.encode(jsonEncode(next.body)),
            next.status,
          );
        }),
      );
    });

    test('answerQuestion PUTs {heading, answer} to the answer route', () async {
      expect(
        await api.answerQuestion(1, _question.heading, 'a) Narrow. (recommended)'),
        (ok: true, reason: ''),
      );
      final req = requests.single;
      expect(req.method, 'PUT');
      expect(req.url.path, '/api/questions/1/answer');
      expect(req.headers['content-type'], startsWith('application/json'));
      expect(jsonDecode(utf8.decode(req.bodyBytes)), {
        'heading': _question.heading,
        'answer': 'a) Narrow. (recommended)',
      });
    });

    test(
      'setVerificationResult PUTs {heading, result, status} to the result '
      'route',
      () async {
        expect(
          await api.setVerificationResult(
            44,
            _verification.heading,
            'Too narrow — again',
            'returned',
          ),
          (ok: true, reason: ''),
        );
        final req = requests.single;
        expect(req.method, 'PUT');
        expect(req.url.path, '/api/verifications/44/result');
        expect(jsonDecode(utf8.decode(req.bodyBytes)), {
          'heading': _verification.heading,
          'result': 'Too narrow — again',
          'status': 'returned',
        });
      },
    );

    test('gone comes back as ok: false with reason gone', () async {
      next = (status: 200, body: {'ok': false, 'reason': 'gone'});
      expect(await api.answerQuestion(1, 'Changed', 'x'), (
        ok: false,
        reason: 'gone',
      ));
      expect(
        await api.setVerificationResult(9, 'Gone', '', 'accepted'),
        (ok: false, reason: 'gone'),
      );
    });

    test('a 400 throws ScrumBoardApiException with statusCode 400, as the '
        'fake does', () async {
      next = (status: 400, body: {'error': 'the answer is empty'});
      final bad = throwsA(
        isA<ScrumBoardApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.reason, 'reason', 'the answer is empty'),
      );
      await expectLater(api.answerQuestion(1, _question.heading, ' '), bad);
      await expectLater(
        api.setVerificationResult(1, _verification.heading, '', 'returned'),
        bad,
      );
      // The fake refuses the same calls the same way.
      final fake = FakeScrumBoardApi(
        questionList: [_question],
        verificationList: [_verification],
      );
      final fakeBad = throwsA(
        isA<ScrumBoardApiException>().having(
          (e) => e.statusCode,
          'statusCode',
          400,
        ),
      );
      await expectLater(fake.answerQuestion(1, _question.heading, ' '), fakeBad);
      await expectLater(
        fake.setVerificationResult(1, _verification.heading, '', 'returned'),
        fakeBad,
      );
    });
  });

  group('FakeScrumBoardApi', () {
    late FakeScrumBoardApi fake;
    setUp(
      () => fake = FakeScrumBoardApi(
        questionList: [_question],
        verificationList: [_verification],
      ),
    );

    test('SCB-17.b answer writes the answer and sets answered', () async {
      final stamp = await fake.changeStamp();
      expect(
        await fake.answerQuestion(
          1,
          _question.heading,
          'a) Narrow. (recommended)',
        ),
        (ok: true, reason: ''),
      );
      final q = (await fake.boardItems()).questions.single;
      expect(q.status, 'answered');
      expect(q.answer, 'a) Narrow. (recommended)');
      expect(q.choices, _question.choices);
      expect(await fake.changeStamp(), isNot(stamp));
      expect(fake.answerCalls.single.answer, 'a) Narrow. (recommended)');
    });

    test('SCB-17.b accept and return write the result and status', () async {
      expect(
        await fake.setVerificationResult(
          1,
          _verification.heading,
          '',
          'accepted',
        ),
        (ok: true, reason: ''),
      );
      expect((await fake.boardItems()).verifications.single.status, 'accepted');
      expect(
        await fake.setVerificationResult(
          1,
          _verification.heading,
          'Too narrow',
          'returned',
        ),
        (ok: true, reason: ''),
      );
      final v = (await fake.boardItems()).verifications.single;
      expect(v.status, 'returned');
      expect(v.answer, 'Too narrow');
      expect(v.pbi, 'PBI-108');
    });

    test(
      'SCB-17.b gone when the heading changed or the number is gone',
      () async {
        expect(await fake.answerQuestion(1, 'Another heading', 'x'), (
          ok: false,
          reason: 'gone',
        ));
        expect(
          await fake.setVerificationResult(
            2,
            _verification.heading,
            'x',
            'accepted',
          ),
          (ok: false, reason: 'gone'),
        );
        final items = await fake.boardItems();
        expect(items.questions.single.status, 'open');
        expect(items.verifications.single.status, 'open');
      },
    );

    test(
      'SCB-17.b the server 400s: empty answer, line break, returned empty',
      () async {
        final bad = throwsA(
          isA<ScrumBoardApiException>().having(
            (e) => e.statusCode,
            'statusCode',
            400,
          ),
        );
        await expectLater(fake.answerQuestion(1, _question.heading, ' '), bad);
        await expectLater(
          fake.answerQuestion(1, _question.heading, 'a\nb'),
          bad,
        );
        await expectLater(
          fake.setVerificationResult(1, _verification.heading, '', 'returned'),
          bad,
        );
        await expectLater(
          fake.setVerificationResult(
            1,
            _verification.heading,
            'a\r\nb',
            'accepted',
          ),
          bad,
        );
        await expectLater(
          fake.setVerificationResult(1, _verification.heading, 'x', 'open'),
          bad,
        );
        expect((await fake.boardItems()).questions.single.status, 'open');
      },
    );

    test('SCB-01.f failWith makes boardItems throw', () async {
      fake.failWith = const ScrumBoardApiException('cannot read');
      await expectLater(
        fake.boardItems(),
        throwsA(isA<ScrumBoardApiException>()),
      );
      expect(fake.calls['boardItems'], 1);
    });
  });
}
