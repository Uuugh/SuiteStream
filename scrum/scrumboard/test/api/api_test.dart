import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';

void main() {
  final base = Uri.parse('http://127.0.0.1:8081/');

  http.Response json(Object body, [int status = 200]) => http.Response.bytes(
        utf8.encode(jsonEncode(body)),
        status,
        headers: {'content-type': 'application/json'},
      );

  test('SCB-03 reads requirements and works out the parent from the ID',
      () async {
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((req) async {
        expect(req.url.path, '/api/requirements');
        return json([
          {
            'id': 'SCB-11.a',
            'status': 'backlog',
            'statement': 'It’s fine',
            'feature': 'scrumboard',
            'file': 'requirements/scrumboard.md',
          },
        ]);
      }),
    );
    final r = (await api.requirements()).single;
    expect(r.parentId, 'SCB-11');
    expect(r.statement, 'It’s fine');
    expect(
      const Requirement(
        id: 'SCB-11',
        status: 'backlog',
        statement: '',
        feature: '',
        file: '',
      ).parentId,
      isNull,
    );
  });

  test('SCB-13.c setStatus returns ok and reason', () async {
    late http.Request seen;
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((req) async {
        seen = req;
        return json({'ok': false, 'reason': 'planned cannot move down'});
      }),
    );
    final r = await api.setStatus('SCB-07.c', 'proposed');
    expect(seen.method, 'PUT');
    expect(seen.url.path, '/api/requirements/SCB-07.c/status');
    expect(jsonDecode(seen.body), {'status': 'proposed'});
    expect(r.ok, isFalse);
    expect(r.reason, 'planned cannot move down');
  });

  test('SCB-13.c fake setStatus changes the row or refuses', () async {
    final fake = FakeScrumBoardApi(requirementList: const [
      Requirement(
        id: 'A-1',
        status: 'backlog',
        statement: '',
        feature: 'a',
        file: 'requirements/a.md',
      ),
    ]);
    expect((await fake.setStatus('A-1', 'planned')).ok, isTrue);
    expect((await fake.requirements()).single.status, 'planned');
    fake.refuseWith = 'no';
    expect((await fake.setStatus('A-1', 'proposed')).reason, 'no');
  });

  test('SCB-22 changeStamp reads the stamp; the fake changes it', () async {
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((req) async {
        expect(req.method, 'GET');
        expect(req.url.path, '/api/changes');
        return json({'stamp': 'abc'});
      }),
    );
    expect(await api.changeStamp(), 'abc');
    final fake = FakeScrumBoardApi();
    final a = await fake.changeStamp();
    expect(await fake.changeStamp(), a);
    fake.bump();
    final b = await fake.changeStamp();
    expect(b, isNot(a));
    fake.sprintFile = const SprintFile(exists: true);
    expect(await fake.changeStamp(), isNot(b));
  });

  test('SCB-19.a retire posts and returns ok and reason; the fake removes',
      () async {
    late http.Request seen;
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((req) async {
        seen = req;
        return json({'ok': false, 'reason': 'no requirement X-1'});
      }),
    );
    final r = await api.retire('X-1');
    expect(seen.method, 'POST');
    expect(seen.url.path, '/api/requirements/X-1/retire');
    expect(r.ok, isFalse);
    expect(r.reason, 'no requirement X-1');

    final fake = FakeScrumBoardApi(requirementList: const [
      Requirement(
        id: 'A-1',
        status: 'backlog',
        statement: '',
        feature: 'a',
        file: 'requirements/a.md',
      ),
    ]);
    expect((await fake.retire('B-2')).ok, isFalse);
    expect((await fake.retire('A-1')).ok, isTrue);
    expect(await fake.requirements(), isEmpty);
  });

  test('SCB-02 reads and saves the sprint', () async {
    late String sentBody;
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((req) async {
        if (req.method == 'PUT') sentBody = req.body;
        return json({
          'exists': true,
          'blocks': [
            {
              'id': 'S1',
              'kind': 'story',
              'name': 'One',
              'parent': null,
              'assignee': null,
              'estimate': 8,
              'usage': 2.5,
            },
          ],
          'members': [
            {'block': 'S1', 'item': '#4'},
          ],
        });
      }),
    );
    final s = await api.sprint();
    expect(s.blocks.single.estimate, 8);
    expect(s.members.single.item, '#4');
    await api.saveSprint(s);
    expect(jsonDecode(sentBody)['blocks'][0]['id'], 'S1');
  });

  test('SCB-01.f an error answer becomes ScrumBoardApiException with its reason',
      () async {
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((_) async => json({'error': 'cannot read'}, 500)),
    );
    expect(
      api.requirements(),
      throwsA(
        isA<ScrumBoardApiException>()
            .having((e) => e.reason, 'reason', 'cannot read')
            .having((e) => e.statusCode, 'status', 500),
      ),
    );
  });

  test('SCB-13.h a connection failure becomes ScrumBoardUnreachableException',
      () async {
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((_) async => throw http.ClientException('refused')),
    );
    expect(api.sprint(), throwsA(isA<ScrumBoardUnreachableException>()));
  });

  test('SCB-13.i reads the answer as UTF-8 whatever the headers say',
      () async {
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('[{"label":"Ito — ’","done":1,"total":2}]'),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    expect((await api.progress()).single.label, 'Ito — ’');
  });

  test('SCB-14.g reads usage', () async {
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((_) async => json({'exists': true, 'rows': <Object>[]})),
    );
    expect((await api.usage()).rows, isEmpty);
  });

  test('SCB-14.o the client reads the estimate and the trend answers', () async {
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((req) async {
        expect(req.method, 'GET');
        return switch (req.url.path) {
          '/api/usage/estimate' => json({'ok': true, 'output': 'est out\n', 'reason': ''}),
          '/api/usage/trend' => json({'ok': false, 'output': '', 'reason': 'No rows for x'}),
          _ => json({'error': 'not found'}, 404),
        };
      }),
    );
    expect(await api.usageEstimate(), (ok: true, output: 'est out\n', reason: ''));
    expect(await api.usageTrend(), (ok: false, output: '', reason: 'No rows for x'));
  });

  test('SCB-14.o SCB-13.h an unreachable server is an exception, not empty data', () async {
    final api = HttpScrumBoardApi(
      baseUri: base,
      client: MockClient((_) async => throw http.ClientException('refused')),
    );
    expect(api.usageEstimate(), throwsA(isA<ScrumBoardUnreachableException>()));
    expect(api.usageTrend(), throwsA(isA<ScrumBoardUnreachableException>()));
  });

  test('SCB-14.o the fake answers what it is given and counts the calls', () async {
    final fake = FakeScrumBoardApi()
      ..estimateAnswer = (ok: true, output: 'e', reason: '')
      ..trendAnswer = (ok: false, output: '', reason: 'missing');
    expect(await fake.usageEstimate(), (ok: true, output: 'e', reason: ''));
    expect(await fake.usageTrend(), (ok: false, output: '', reason: 'missing'));
    expect(fake.calls['usageEstimate'], 1);
    expect(fake.calls['usageTrend'], 1);
    fake.failWith = const ScrumBoardUnreachableException('down');
    expect(fake.usageTrend(), throwsA(isA<ScrumBoardUnreachableException>()));
  });

  test('SCB-01.c the fake counts calls and can fail', () async {
    final fake = FakeScrumBoardApi();
    await fake.requirements();
    await fake.requirements();
    expect(fake.calls['requirements'], 2);
    fake.failWith = const ScrumBoardApiException('boom');
    expect(fake.sprint(), throwsA(isA<ScrumBoardApiException>()));
  });
}
