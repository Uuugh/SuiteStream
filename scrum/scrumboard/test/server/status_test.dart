import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/server/server.dart';

Future<({int status, Map<String, dynamic> body})> put(
  ScrumBoardServer server,
  String id,
  String status, {
  String? host,
}) async {
  final client = HttpClient();
  try {
    final req = await client.open(
      'PUT',
      '127.0.0.1',
      server.port,
      '/api/requirements/$id/status',
    );
    if (host != null) req.headers.set(HttpHeaders.hostHeader, host);
    req.headers.contentType = ContentType.json;
    req.add(utf8.encode(jsonEncode({'status': status})));
    final res = await req.close();
    final text = await utf8.decodeStream(res);
    return (
      status: res.statusCode,
      body: jsonDecode(text) as Map<String, dynamic>,
    );
  } finally {
    client.close(force: true);
  }
}

void main() {
  late Directory tmp;
  late ScrumBoardServer server;
  late File file;
  const original = '# Demo\n\n'
      '| ID | status | statement | test |\n|---|---|---|---|\n'
      '| DEM-01 | backlog | One | — |\n'
      '| DEM-02 | planned | Two | — |\n'
      '| DEM-03 | proposed | Three | — |\n'
      '| DEM-04 | done | Four | — |\n';

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('scb_status_');
    final repo = Directory('${tmp.path}/repo')..createSync();
    Directory('${repo.path}/requirements').createSync();
    file = File('${repo.path}/requirements/demo.md')
      ..writeAsStringSync(original);
    server = await ScrumBoardServer.start(root: repo, port: 0);
  });

  tearDown(() async {
    await server.close();
    tmp.deleteSync(recursive: true);
  });

  test('SCB-13.c accepts backlog to planned', () async {
    final r = await put(server, 'DEM-01', 'planned');
    expect(r.status, 200);
    expect(r.body['ok'], isTrue);
  });

  test('SCB-13.d edits only the status cell of that row', () async {
    await put(server, 'DEM-01', 'planned');
    expect(
      file.readAsStringSync(),
      original.replaceFirst(
        '| DEM-01 | backlog |',
        '| DEM-01 | planned |',
      ),
    );
    expect(File('${file.path}.tmp').existsSync(), isFalse);
  });

  test('SCB-13.c accepts planned to backlog', () async {
    final r = await put(server, 'DEM-02', 'backlog');
    expect(r.body['ok'], isTrue);
    expect(file.readAsStringSync(), contains('| DEM-02 | backlog |'));
  });

  test('SCB-13.c accepts proposed to backlog and planned to done', () async {
    expect((await put(server, 'DEM-03', 'backlog')).body['ok'], isTrue);
    expect((await put(server, 'DEM-02', 'done')).body['ok'], isTrue);
  });

  test('SCB-13.c refuses planned to proposed', () async {
    final r = await put(server, 'DEM-02', 'proposed');
    expect(r.body['ok'], isFalse);
    expect(r.body['reason'], isNotEmpty);
    expect(file.readAsStringSync(), original);
  });

  test('SCB-13.c refuses every other move down', () async {
    expect((await put(server, 'DEM-04', 'planned')).body['ok'], isFalse);
    expect((await put(server, 'DEM-04', 'backlog')).body['ok'], isFalse);
    expect((await put(server, 'DEM-01', 'proposed')).body['ok'], isFalse);
    expect(file.readAsStringSync(), original);
  });

  test('SCB-13.c refuses an unknown status and an unknown ID', () async {
    expect((await put(server, 'DEM-01', 'defect')).body['ok'], isFalse);
    expect((await put(server, 'DEM-99', 'planned')).body['ok'], isFalse);
    expect(file.readAsStringSync(), original);
  });

  test('SCB-13.a set-status refuses a foreign Host', () async {
    final r = await put(server, 'DEM-01', 'planned', host: 'evil.example');
    expect(r.status, 403);
    expect(file.readAsStringSync(), original);
  });
}
