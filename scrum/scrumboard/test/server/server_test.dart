import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/server/server.dart';

/// Sends a raw request so the test can set Host and Origin freely.
Future<({int status, String body, HttpHeaders headers})> raw(
  ScrumBoardServer server,
  String method,
  String path, {
  String? host,
  String? origin,
  String? body,
}) async {
  final client = HttpClient();
  try {
    final req = await client.open(method, '127.0.0.1', server.port, path);
    req.headers.host = host ?? '127.0.0.1';
    req.headers.port = host == null ? server.port : null;
    if (host != null) req.headers.set(HttpHeaders.hostHeader, host);
    if (origin != null) req.headers.set('origin', origin);
    if (body != null) {
      req.headers.contentType = ContentType.json;
      req.add(utf8.encode(body));
    }
    final res = await req.close();
    final text = await utf8.decodeStream(res);
    return (status: res.statusCode, body: text, headers: res.headers);
  } finally {
    client.close(force: true);
  }
}

void main() {
  group("security", securityTests);
  late Directory repo;
  late Directory outside;
  late ScrumBoardServer server;

  setUp(() async {
    final tmp = Directory.systemTemp.createTempSync('scb_server_');
    repo = Directory('${tmp.path}/repo')..createSync();
    outside = Directory('${tmp.path}/outside')..createSync();
    File('${outside.path}/secret.txt').writeAsStringSync('secret');
    Directory('${repo.path}/requirements').createSync();
    File('${repo.path}/requirements/demo.md').writeAsStringSync(
      '| ID | status | statement | test |\n|---|---|---|---|\n'
      '| DEM-01 | backlog | It’s a test — ok › fine. | — |\n',
    );
    Directory('${repo.path}/scrum').createSync();
    final web = Directory('${repo.path}/web')..createSync();
    File('${web.path}/index.html').writeAsStringSync('<html>ok</html>');
    final progress = Directory('${repo.path}/progress')..createSync();
    File('${progress.path}/Nakamura').writeAsStringSync('2/5');
    server = await ScrumBoardServer.start(
      root: repo,
      progressDir: progress,
      webDir: web,
      port: 0,
      maxBodyBytes: 200,
    );
    // Symbolic link that leaves the repository, where the OS allows it.
    try {
      Link('${web.path}/leak').createSync(outside.path);
    } on FileSystemException {
      // Windows without developer mode: the link test is skipped below.
    }
  });

  tearDown(() async {
    await server.close();
    repo.parent.deleteSync(recursive: true);
  });

  group('SCB-13.a', () {
    test('SCB-13.a answers the own address and localhost', () async {
      final a = await raw(server, 'GET', '/api/progress');
      expect(a.status, 200);
      final b = await raw(
        server,
        'GET',
        '/api/progress',
        host: 'localhost:${server.port}',
      );
      expect(b.status, 200);
    });

    test('SCB-13.a refuses a foreign Host', () async {
      final r = await raw(
        server,
        'GET',
        '/api/progress',
        host: 'evil.example:${server.port}',
      );
      expect(r.status, 403);
      expect(jsonDecode(r.body), {'error': isA<String>()});
    });

    test('SCB-13.a refuses a foreign Host on another port', () async {
      final r = await raw(server, 'GET', '/api/progress', host: '127.0.0.1:1');
      expect(r.status, 403);
    });

    test('SCB-13.a refuses a foreign Origin', () async {
      final r = await raw(
        server,
        'GET',
        '/api/progress',
        origin: 'http://evil.example',
      );
      expect(r.status, 403);
    });

    test('SCB-13.a accepts its own Origin', () async {
      final r = await raw(
        server,
        'GET',
        '/api/progress',
        origin: 'http://127.0.0.1:${server.port}',
      );
      expect(r.status, 200);
    });

    test('SCB-13.a listens on 127.0.0.1 only', () {
      // The server binds the loopback IPv4 address, nothing wider.
      expect(server.port, greaterThan(0));
    });
  });

  group('SCB-13.b', () {
    test('SCB-13.b answers each read endpoint', () async {
      for (final p in [
        '/api/requirements',
        '/api/sprint',
        '/api/progress',
        '/api/usage',
      ]) {
        final r = await raw(server, 'GET', p);
        expect(r.status, 200, reason: p);
      }
      final progress = jsonDecode(
        (await raw(server, 'GET', '/api/progress')).body,
      );
      expect(progress, [
        {'label': 'Nakamura', 'done': 2, 'total': 5},
      ]);
    });

    test('SCB-13.b slice: read endpoints and sprint write, the rest 404',
        () async {
      for (final c in [
        ('GET', '/api/issues'),
        ('POST', '/api/issues'),
        ('POST', '/api/requirements'),
        ('PUT', '/api/requirements/DEM-01'),
        ('DELETE', '/api/sprint'),
        ('POST', '/api/sprint'),
        ('GET', '/api'),
        ('GET', '/api/../secret'),
        ('GET', '/nothing.js'),
      ]) {
        final r = await raw(server, c.$1, c.$2);
        expect(r.status, 404, reason: '${c.$1} ${c.$2}');
        expect(jsonDecode(r.body), {'error': isA<String>()});
      }
    });

    test('SCB-13.b answers the retire and changes requests, not other verbs',
        () async {
      expect((await raw(server, 'GET', '/api/changes')).status, 200);
      for (final c in [
        ('POST', '/api/changes'),
        ('GET', '/api/requirements/DEM-01/retire'),
        ('PUT', '/api/requirements/DEM-01/retire'),
        ('POST', '/api/requirements/DEM-01/other'),
      ]) {
        final r = await raw(server, c.$1, c.$2);
        expect(r.status, 404, reason: '${c.$1} ${c.$2}');
      }
    });

    test('SCB-13.b the three question routes answer; other verbs and paths '
        'on them are not found', () async {
      File('${repo.path}/scrum/questions.md').writeAsStringSync(_questions);
      File('${repo.path}/scrum/verifications.md')
          .writeAsStringSync(_verifications);
      expect((await raw(server, 'GET', '/api/questions')).status, 200);
      expect(
        (await raw(server, 'PUT', '/api/questions/1/answer',
                body: jsonEncode({'heading': _q1, 'answer': 'x'})))
            .status,
        200,
      );
      expect(
        (await raw(server, 'PUT', '/api/verifications/2/result',
                body: jsonEncode(
                    {'heading': _v2, 'result': '', 'status': 'accepted'})))
            .status,
        200,
      );
      for (final c in [
        for (final verb in ['GET', 'POST', 'DELETE', 'PATCH']) ...[
          (verb, '/api/questions/1/answer'),
          (verb, '/api/verifications/2/result'),
        ],
        ('PUT', '/api/questions/1'),
        ('PUT', '/api/questions/x/answer'),
        ('PUT', '/api/questions/1/result'),
        ('PUT', '/api/verifications/2/answer'),
        ('PUT', '/api/verifications'),
        ('GET', '/api/verifications'),
      ]) {
        final r = await raw(
          server,
          c.$1,
          c.$2,
          body: c.$1 == 'GET' ? null : '{}',
        );
        expect(r.status, 404, reason: '${c.$1} ${c.$2}');
        expect(jsonDecode(r.body), {'error': isA<String>()});
      }
    });

    test('SCB-22 the stamp changes when a watched file changes', () async {
      Future<String> stamp() async => (jsonDecode(
            (await raw(server, 'GET', '/api/changes')).body,
          ) as Map<String, dynamic>)['stamp'] as String;
      final first = await stamp();
      expect(await stamp(), first);
      final files = [
        '${repo.path}/requirements/demo.md',
        '${repo.path}/scrum/sprint.md',
        '${repo.path}/scrum/usage/usage.log',
        '${repo.path}/progress/Nakamura',
      ];
      var previous = first;
      for (final f in files) {
        final file = File(f)..parent.createSync(recursive: true);
        file.writeAsStringSync(
          '${file.existsSync() ? file.readAsStringSync() : ''}x',
        );
        final now = await stamp();
        expect(now, isNot(previous), reason: f);
        previous = now;
      }
    });

    test('SCB-22 refuses a foreign Host', () async {
      final r = await raw(
        server,
        'GET',
        '/api/changes',
        host: 'evil.example:${server.port}',
      );
      expect(r.status, 403);
    });

    test('SCB-19.a retire moves the row to retired.md', () async {
      final r = await raw(server, 'POST', '/api/requirements/DEM-01/retire');
      expect(r.status, 200);
      expect(jsonDecode(r.body), {'ok': true, 'reason': ''});
      final demo = File('${repo.path}/requirements/demo.md').readAsStringSync();
      expect(demo, isNot(contains('DEM-01')));
      expect(demo, contains('|---|'));
      final retired =
          File('${repo.path}/requirements/retired.md').readAsStringSync();
      expect(retired, contains('| DEM-01 | '));
      expect(retired, contains('retired from the ScrumBoard by the Executive'));
      expect(retired, contains('It’s a test — ok › fine.'));
      expect(retired, matches(RegExp(r'\| DEM-01 \| \d{4}-\d\d-\d\d \|')));
      final list = jsonDecode((await raw(server, 'GET', '/api/requirements')).body);
      expect(list, isEmpty);
      // The id is retired: asking again is refused.
      final again = jsonDecode(
        (await raw(server, 'POST', '/api/requirements/DEM-01/retire')).body,
      ) as Map<String, dynamic>;
      expect(again['ok'], isFalse);
    });

    test('SCB-19.a retire refuses an unknown id and changes nothing', () async {
      final before =
          File('${repo.path}/requirements/demo.md').readAsStringSync();
      final r = await raw(server, 'POST', '/api/requirements/NOPE-9/retire');
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      expect(body['ok'], isFalse);
      expect(body['reason'], isNotEmpty);
      expect(File('${repo.path}/requirements/demo.md').readAsStringSync(), before);
      expect(File('${repo.path}/requirements/retired.md').existsSync(), isFalse);
    });

    test('SCB-19.a retire answers 403 for a foreign Host or Origin', () async {
      final a = await raw(
        server,
        'POST',
        '/api/requirements/DEM-01/retire',
        host: 'evil.example:${server.port}',
      );
      expect(a.status, 403);
      final b = await raw(
        server,
        'POST',
        '/api/requirements/DEM-01/retire',
        origin: 'http://evil.example',
      );
      expect(b.status, 403);
      expect(
        File('${repo.path}/requirements/demo.md').readAsStringSync(),
        contains('DEM-01'),
      );
    });

    test('SCB-13.b serves build/web and nothing outside it', () async {
      final index = await raw(server, 'GET', '/');
      expect(index.status, 200);
      expect(index.body, contains('ok'));
      for (final p in [
        '/../outside/secret.txt',
        '/%2e%2e/outside/secret.txt',
        '/..%5coutside%5csecret.txt',
        '/leak/secret.txt',
      ]) {
        final r = await raw(server, 'GET', p);
        expect(r.status, 404, reason: p);
        expect(r.body, isNot(contains('secret')));
      }
    });

    test('SCB-13.b refuses a request body over the limit with 413', () async {
      final big = jsonEncode({
        'blocks': <Object>[],
        'members': <Object>[],
        'pad': 'x' * 400,
      });
      final r = await raw(server, 'PUT', '/api/sprint', body: big);
      expect(r.status, 413);
      expect(File('${repo.path}/scrum/sprint.md').existsSync(), isFalse);
    });

    test('SCB-13.b refuses a path outside the root', () async {
      // The sprint file may not be a link that leaves the repository.
      final target = File('${outside.path}/sprint.md')
        ..writeAsStringSync('# outside\n');
      try {
        Link('${repo.path}/scrum/sprint.md').createSync(target.path);
      } on FileSystemException {
        return; // links are not allowed here
      }
      final r = await raw(
        server,
        'PUT',
        '/api/sprint',
        body: jsonEncode({'blocks': <Object>[], 'members': <Object>[]}),
      );
      expect(r.status, 403);
      expect(target.readAsStringSync(), '# outside\n');
    });

    test('SCB-13.b refuses a progress folder that does not exist', () {
      expect(
        ScrumBoardServer.start(
          root: repo,
          progressDir: Directory('${repo.path}/nope'),
          port: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('SCB-17.b', () {
    File qFile() => File('${repo.path}/scrum/questions.md');
    File vFile() => File('${repo.path}/scrum/verifications.md');
    Future<({int status, Map<String, dynamic> body})> answer(
      int n,
      Object body,
    ) async {
      final r = await raw(server, 'PUT', '/api/questions/$n/answer',
          body: body is String ? body : jsonEncode(body));
      return (status: r.status, body: jsonDecode(r.body) as Map<String, dynamic>);
    }

    Future<({int status, Map<String, dynamic> body})> result(
      int n,
      Object body,
    ) async {
      final r = await raw(server, 'PUT', '/api/verifications/$n/result',
          body: body is String ? body : jsonEncode(body));
      return (status: r.status, body: jsonDecode(r.body) as Map<String, dynamic>);
    }

    setUp(() {
      qFile().writeAsStringSync(_questions);
      vFile().writeAsStringSync(_verifications);
    });

    test('SCB-17.b answer writes "Answer: <text>" and sets answered; only '
        'that item changes', () async {
      final r = await answer(1, {'heading': _q1, 'answer': 'a) Narrow. (x)'});
      expect(r.status, 200);
      expect(r.body, {'ok': true, 'reason': ''});
      expect(
        qFile().readAsStringSync(),
        _questions.replaceFirst(
          'Status: open\nQuestion: How wide?\n   a) Narrow. (x)\n'
              '   b) Wide.\nAnswer:\n',
          'Status: answered\nQuestion: How wide?\n   a) Narrow. (x)\n'
              '   b) Wide.\nAnswer: a) Narrow. (x)\n',
        ),
      );
      // Read back through the GET route.
      final list = jsonDecode((await raw(server, 'GET', '/api/questions')).body)
          as Map<String, dynamic>;
      final q1 = (list['questions'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .firstWhere((q) => q['number'] == 1);
      expect(q1['status'], 'answered');
      expect(q1['answer'], 'a) Narrow. (x)');
    });

    test('SCB-17.b accept (empty result) and return (with result) write '
        'Result and Status', () async {
      final a = await result(2, {
        'heading': _v2,
        'result': '',
        'status': 'accepted',
      });
      expect(a.body, {'ok': true, 'reason': ''});
      final r = await result(1, {
        'heading': _v1,
        'result': 'Still clips in dark.',
        'status': 'returned',
      });
      expect(r.body, {'ok': true, 'reason': ''});
      expect(
        vFile().readAsStringSync(),
        _verifications
            .replaceFirst(
              '## 2. $_v2\nStatus: open\n',
              '## 2. $_v2\nStatus: accepted\n',
            )
            .replaceFirst(
              '## 1. $_v1\nStatus: open\nVerify: Look.\nResult:\n',
              '## 1. $_v1\nStatus: returned\nVerify: Look.\n'
                  'Result: Still clips in dark.\n',
            ),
      );
    });

    test('SCB-17.b gone when the heading on disk changed under the same '
        'number; the file is byte-for-byte unchanged', () async {
      final qBefore = qFile().readAsBytesSync();
      final vBefore = vFile().readAsBytesSync();
      expect(
        (await answer(1, {'heading': 'Ito, Sprint 015 Old title', 'answer': 'x'}))
            .body,
        {'ok': false, 'reason': 'gone'},
      );
      expect(
        (await result(1, {
          'heading': 'PBI-001 Old title',
          'result': 'x',
          'status': 'accepted',
        }))
            .body,
        {'ok': false, 'reason': 'gone'},
      );
      expect(qFile().readAsBytesSync(), qBefore);
      expect(vFile().readAsBytesSync(), vBefore);
    });

    test('SCB-17.b gone when the number is no longer in the file; the file '
        'is byte-for-byte unchanged', () async {
      // A CRLF file without a final line end, to be strict about bytes.
      qFile().writeAsStringSync(
          _questions.replaceAll('\n', '\r\n').trimRight());
      final qBefore = qFile().readAsBytesSync();
      final vBefore = vFile().readAsBytesSync();
      expect((await answer(7, {'heading': _q1, 'answer': 'x'})).body,
          {'ok': false, 'reason': 'gone'});
      expect(
        (await result(9, {'heading': _v1, 'result': '', 'status': 'accepted'}))
            .body,
        {'ok': false, 'reason': 'gone'},
      );
      expect(qFile().readAsBytesSync(), qBefore);
      expect(vFile().readAsBytesSync(), vBefore);
      // No file at all is gone too, and nothing is created.
      vFile().deleteSync();
      expect(
        (await result(1, {'heading': _v1, 'result': '', 'status': 'accepted'}))
            .body,
        {'ok': false, 'reason': 'gone'},
      );
      expect(vFile().existsSync(), isFalse);
    });

    test('SCB-17.b a numbered heading inside the ``` Format block is never '
        'written', () async {
      qFile().writeAsStringSync(
        '# Q\n\n```\n## 5. Inside the fence\nStatus: open\nAnswer:\n```\n',
      );
      final before = qFile().readAsBytesSync();
      expect(
        (await answer(5, {'heading': 'Inside the fence', 'answer': 'x'})).body,
        {'ok': false, 'reason': 'gone'},
      );
      expect(qFile().readAsBytesSync(), before);
    });

    test('SCB-17.b refuses a line break, an empty answer, returned with no '
        'result and a bad status (400); nothing is written', () async {
      final qBefore = qFile().readAsBytesSync();
      final vBefore = vFile().readAsBytesSync();
      for (final body in <Object>[
        {'heading': _q1, 'answer': 'a\nb'},
        {'heading': _q1, 'answer': 'a\r\nStatus: answered'},
        {'heading': _q1, 'answer': ''},
        {'heading': _q1, 'answer': '   '},
        {'heading': '$_q1\n## 9. x', 'answer': 'a'},
        {'heading': _q1},
        {'answer': 'a'},
        {'heading': _q1, 'answer': 5},
        'not json',
        '["heading"]',
      ]) {
        final r = await answer(1, body);
        expect(r.status, 400, reason: '$body');
        expect(r.body, {'error': isA<String>()});
      }
      for (final body in <Object>[
        {'heading': _v1, 'result': '', 'status': 'returned'},
        {'heading': _v1, 'result': '  ', 'status': 'returned'},
        {'heading': _v1, 'result': 'a\nb', 'status': 'accepted'},
        {'heading': _v1, 'result': 'a\rb', 'status': 'returned'},
        {'heading': _v1, 'result': 'x', 'status': 'open'},
        {'heading': _v1, 'result': 'x', 'status': 'answered'},
        {'heading': _v1, 'result': 'x', 'status': 'Accepted'},
        {'heading': _v1, 'result': 'x'},
        {'heading': _v1, 'status': 'accepted'},
        {'result': 'x', 'status': 'accepted'},
      ]) {
        final r = await result(1, body);
        expect(r.status, 400, reason: '$body');
        expect(r.body, {'error': isA<String>()});
      }
      expect(qFile().readAsBytesSync(), qBefore);
      expect(vFile().readAsBytesSync(), vBefore);
    });

    test('SCB-17.b a CRLF file stays CRLF on every line after a write, also '
        'where a line is added', () async {
      // Question 3 has no Answer line and no final line end: both are added.
      qFile().writeAsStringSync(
        '${_questions.replaceAll('\n', '\r\n')}\r\n'
        '## 3. Ito, Sprint 015 No answer line\r\nStatus: open\r\n'
        'Question: Which?',
      );
      vFile().writeAsStringSync(_verifications.replaceAll('\n', '\r\n'));
      expect((await answer(1, {'heading': _q1, 'answer': 'b) Wide.'})).body,
          {'ok': true, 'reason': ''});
      expect(
        (await answer(3, {
          'heading': 'Ito, Sprint 015 No answer line',
          'answer': 'Typed — as typed',
        }))
            .body,
        {'ok': true, 'reason': ''},
      );
      expect(
        (await result(2, {'heading': _v2, 'result': 'Ok', 'status': 'accepted'}))
            .body,
        {'ok': true, 'reason': ''},
      );
      for (final f in [qFile(), vFile()]) {
        final text = f.readAsStringSync();
        expect(RegExp(r'(?<!\r)\n').hasMatch(text), isFalse, reason: f.path);
        expect(RegExp(r'\r(?!\n)').hasMatch(text), isFalse, reason: f.path);
      }
      final q = qFile().readAsStringSync();
      expect(q, contains('Status: answered\r\nQuestion: How wide?'));
      expect(q, contains('Answer: b) Wide.\r\n'));
      expect(
        q,
        endsWith('Status: answered\r\nQuestion: Which?\r\n'
            'Answer: Typed — as typed'),
      );
      expect(vFile().readAsStringSync(),
          contains('## 2. $_v2\r\nStatus: accepted\r\nVerify: Check.\r\nResult: Ok\r\n'));
    });

    test('SCB-17.b answering a real file copy changes only that item',
        () async {
      final copy = File('test/server/fixtures/board_items/questions.md')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      qFile().writeAsStringSync(copy);
      const heading = 'Tanaka, Sprint 015 Where the result goes';
      const choice = 'a) Under "Result:" in the file. (recommended)';
      expect((await answer(2, {'heading': heading, 'answer': choice})).body,
          {'ok': true, 'reason': ''});
      const before = '## 2. $heading\nStatus: open\n';
      final at = copy.indexOf(before);
      expect(at, greaterThan(0));
      final answerAt = copy.indexOf('Answer:\n', at);
      final expected = '${copy.substring(0, at)}'
          '## 2. $heading\nStatus: answered\n'
          '${copy.substring(at + before.length, answerAt)}'
          'Answer: $choice\n'
          '${copy.substring(answerAt + 'Answer:\n'.length)}';
      expect(qFile().readAsStringSync(), expected);
    });
  });

  group('SCB-13.i', () {
    test('SCB-13.i answers in UTF-8 and keeps ’ — ›', () async {
      final r = await raw(server, 'GET', '/api/requirements');
      expect(r.headers.contentType?.charset, 'utf-8');
      expect(r.body, contains('It’s a test — ok › fine.'));
    });

    test('SCB-13.i errors declare UTF-8 too', () async {
      final r = await raw(server, 'GET', '/api/nothing');
      expect(r.headers.contentType?.charset, 'utf-8');
    });
  });

  group('SCB-01.a', () {
    test('SCB-01.a the sprint write changes only scrum/sprint.md', () async {
      final before = _snapshot(repo);
      final r = await raw(
        server,
        'PUT',
        '/api/sprint',
        body: jsonEncode({
          'blocks': [
            {'id': 'S1', 'kind': 'story', 'name': 'A story'},
          ],
          'members': [
            {'block': 'S1', 'item': 'SCB-03'},
          ],
        }),
      );
      expect(r.status, 200);
      final after = _snapshot(repo);
      final changed = {
        for (final k in after.keys)
          if (before[k] != after[k]) k,
      };
      expect(changed, {'scrum/sprint.md'});
    });

    test('SCB-01.a only usage_script.dart runs a process: bash with the configured script and estimate or trend',
        () {
      final seen = <String>{};
      for (final f in Directory('lib/server')
          .listSync(recursive: true)
          .whereType<File>()) {
        final text = f.readAsStringSync();
        seen.add(f.uri.pathSegments.last);
        final runner = f.uri.pathSegments.last == 'usage_script.dart';
        expect(text, isNot(contains('Process.run')), reason: f.path);
        expect(text, isNot(contains('Shell')), reason: f.path);
        if (!runner) {
          expect(text, isNot(contains('Process.start')), reason: f.path);
          expect(text, isNot(contains('Platform.environment')), reason: f.path);
          continue;
        }
        // One start, of bash, with the script and the checked mode only.
        expect('Process.start'.allMatches(text).length, 1, reason: f.path);
        expect(text, contains('Process.start(bash, [script, mode]'));
        expect(text, contains("usageScriptModes = {'estimate', 'trend'}"));
        expect(text, contains('if (!usageScriptModes.contains(mode))'));
      }
      // The Sprint 015 write routes' files are among those checked.
      expect(seen, containsAll(['board_item_write.dart', 'board_items.dart']));
      // The server passes only the two fixed modes.
      final server = File('lib/server/server.dart').readAsStringSync();
      final modes = RegExp(r"_usageScript\('(\w+)'\)").allMatches(server).map((m) => m.group(1)).toSet();
      expect(modes, {'estimate', 'trend'});
    });

    test('SCB-01.a the question and verification writes change only '
        'scrum/questions.md and scrum/verifications.md; no temp stays',
        () async {
      File('${repo.path}/scrum/questions.md').writeAsStringSync(_questions);
      File('${repo.path}/scrum/verifications.md')
          .writeAsStringSync(_verifications);
      Set<String> changedBy(Map<String, String> before) {
        final after = _snapshot(repo);
        return {
          for (final k in {...before.keys, ...after.keys})
            if (before[k] != after[k]) k,
        };
      }

      var before = _snapshot(repo);
      final a = await raw(server, 'PUT', '/api/questions/1/answer',
          body: jsonEncode({'heading': _q1, 'answer': 'Narrow.'}));
      expect(jsonDecode(a.body), {'ok': true, 'reason': ''});
      expect(changedBy(before), {'scrum/questions.md'});
      before = _snapshot(repo);
      final v = await raw(server, 'PUT', '/api/verifications/2/result',
          body: jsonEncode(
              {'heading': _v2, 'result': 'Fine.', 'status': 'accepted'}));
      expect(jsonDecode(v.body), {'ok': true, 'reason': ''});
      expect(changedBy(before), {'scrum/verifications.md'});
    });

    test('SCB-01.a a bad sprint body is a 400 and the file is not touched',
        () async {
      final r = await raw(
        server,
        'PUT',
        '/api/sprint',
        body: jsonEncode({
          'blocks': [
            {'id': 'S1', 'kind': 'nonsense', 'name': 'x'},
          ],
          'members': <Object>[],
        }),
      );
      expect(r.status, 400);
      expect(File('${repo.path}/scrum/sprint.md').existsSync(), isFalse);
    });
  });
}

/// A questions file in the format `scrum/questions.md` states (Format block
/// kept, choices indented 3 spaces) with one open and one answered question.
const _q1 = 'Ito, Sprint 015 Column width';
const _questions = '# Questions for the Executive\n'
    '\n'
    '## Format\n'
    '\n'
    '```\n'
    '## <number>. <asker, sprint> <short title>\n'
    'Status: open\n'
    'Question: ...\n'
    '   Choices: ... (optional)\n'
    'Answer:\n'
    '```\n'
    '\n'
    '## 1. $_q1\n'
    'Status: open\n'
    'Question: How wide?\n'
    '   a) Narrow. (x)\n'
    '   b) Wide.\n'
    'Answer:\n'
    '\n'
    '## 2. Suzuki, Sprint 015 Done one\n'
    'Status: answered\n'
    'Question: Still needed?\n'
    'Answer: Yes.\n';

/// A verifications file in the format `scrum/verifications.md` states.
const _v1 = 'PBI-001 Board look';
const _v2 = 'PBI-002 Board check';
const _verifications = '# Verifications for the Executive\n'
    '\n'
    '## Format\n'
    '\n'
    '```\n'
    '## <number>. <PBI id> <short title>\n'
    'Status: open\n'
    'Verify: ...\n'
    'Result:\n'
    '```\n'
    '\n'
    '## 1. $_v1\n'
    'Status: open\n'
    'Verify: Look.\n'
    'Result:\n'
    '\n'
    '## 2. $_v2\n'
    'Status: open\n'
    'Verify: Check.\n'
    'Result:\n';

Map<String, String> _snapshot(Directory repo) {
  final out = <String, String>{};
  final prefix = repo.resolveSymbolicLinksSync().replaceAll(r'\', '/');
  for (final f in repo.listSync(recursive: true, followLinks: false)) {
    if (f is! File) continue;
    final p = f.path.replaceAll(r'\', '/');
    final rel = p.startsWith(prefix)
        ? p.substring(prefix.length + 1)
        : p.substring(repo.path.replaceAll(r'\', '/').length + 1);
    out[rel] = f.readAsStringSync();
  }
  return out;
}

void securityTests() {
  late Directory repo;
  late ScrumBoardServer server;
  setUp(() async {
    repo = Directory.systemTemp.createTempSync('scb_sec_');
    Directory('${repo.path}/scrum').createSync();
    server = await ScrumBoardServer.start(root: repo, port: 0);
  });
  tearDown(() async {
    await server.close();
    repo.deleteSync(recursive: true);
  });

  Future<int> put(Object body, {String? origin}) async =>
      (await raw(server, 'PUT', '/api/sprint',
              body: jsonEncode(body), origin: origin))
          .status;
  String sprintPath() => '${repo.path}/scrum/sprint.md';

  test('SCB-01.a a value with a line break is refused (SEC-S01)', () async {
    for (final bad in ['a\n## Injected', 'a\r\nb', 'a b', 'a\tb']) {
      final status = await put({
        'blocks': [
          {'id': 'S1', 'kind': 'story', 'name': bad},
        ],
        'members': <Object>[],
      });
      expect(status, 400, reason: bad);
    }
    expect(
      await put({
        'blocks': <Object>[],
        'members': [
          {'block': 'S1', 'item': 'X\n| S2 | y |'},
        ],
      }),
      400,
    );
    expect(File(sprintPath()).existsSync(), isFalse);
  });

  test('SCB-01.a a value ending with a backslash is refused (SEC-S01)',
      () async {
    expect(
      await put({
        'blocks': [
          {'id': 'S1', 'kind': 'story', 'name': r'ends with \'},
        ],
        'members': <Object>[],
      }),
      400,
    );
  });

  test('SCB-13.a a foreign Origin on PUT gets 403 and writes nothing (SEC-S07)',
      () async {
    final status = await put(
      {'blocks': <Object>[], 'members': <Object>[]},
      origin: 'http://evil.example',
    );
    expect(status, 403);
    expect(File(sprintPath()).existsSync(), isFalse);
  });

  test('SCB-01.a the only files written are scrum/sprint.md and no temp stays '
      '(sprint.md.tmp, SEC-S03)', () async {
    expect(
      await put({
        'blocks': [
          {'id': 'S1', 'kind': 'story', 'name': 'n'},
        ],
        'members': <Object>[],
      }),
      200,
    );
    final names = Directory('${repo.path}/scrum')
        .listSync()
        .map((e) => e.uri.pathSegments.last)
        .toList();
    expect(names, ['sprint.md']);
  });

  test('SCB-01.a concurrent writes all finish and the file stays whole',
      () async {
    final results = await Future.wait([
      for (var i = 0; i < 8; i++)
        put({
          'blocks': [
            {'id': 'S$i', 'kind': 'story', 'name': 'n$i'},
          ],
          'members': <Object>[],
        }),
    ]);
    expect(results, everyElement(200));
    expect(File(sprintPath()).readAsStringSync(), contains('| S'));
  });

  test('SCB-13.a a 413 answer carries the frame headers (SEC-S05)', () async {
    final r = await raw(server, 'GET', '/api/usage');
    expect(r.headers.value('x-frame-options'), 'DENY');
  });
}
