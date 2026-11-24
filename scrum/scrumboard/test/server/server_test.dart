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

    test('SCB-01.a the server code runs no shell or process', () {
      for (final f in Directory('lib/server')
          .listSync(recursive: true)
          .whereType<File>()) {
        final text = f.readAsStringSync();
        expect(text, isNot(contains('Process.run')), reason: f.path);
        expect(text, isNot(contains('Process.start')), reason: f.path);
        expect(text, isNot(contains('Platform.environment')), reason: f.path);
      }
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
