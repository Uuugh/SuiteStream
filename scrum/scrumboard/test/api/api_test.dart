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

  test('SCB-01.c the fake counts calls and can fail', () async {
    final fake = FakeScrumBoardApi();
    await fake.requirements();
    await fake.requirements();
    expect(fake.calls['requirements'], 2);
    fake.failWith = const ScrumBoardApiException('boom');
    expect(fake.sprint(), throwsA(isA<ScrumBoardApiException>()));
  });
}
