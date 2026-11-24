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

  test(
    'SCB-17.b the HTTP writes answer ok: false until the write routes',
    () async {
      final api = HttpScrumBoardApi(
        baseUri: base,
        client: MockClient((_) async => fail('no request expected')),
      );
      expect(await api.answerQuestion(1, _question.heading, 'a'), (
        ok: false,
        reason: boardWritesNotAvailable,
      ));
      expect(
        await api.setVerificationResult(
          1,
          _verification.heading,
          '',
          'accepted',
        ),
        (ok: false, reason: boardWritesNotAvailable),
      );
    },
  );

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
