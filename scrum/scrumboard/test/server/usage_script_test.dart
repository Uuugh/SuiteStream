import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/server/server.dart';
import 'package:scrumboard/server/usage_script.dart';

import 'server_test.dart' show raw;

/// The fake scripts (SCB-14.o), absolute so the server finds them from any root.
String _fixture(String name) => File('test/server/fixtures/$name').absolute.path;

/// The same lookup as the server (must-fix 14).
final String? _bash = findDefaultBash();

void main() {
  late Directory tmp;
  late Directory repo;
  final servers = <ScrumBoardServer>[];

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('scb_usage_');
    repo = Directory('${tmp.path}/repo')..createSync();
  });

  tearDown(() async {
    for (final s in servers) {
      await s.close();
    }
    servers.clear();
    try {
      tmp.deleteSync(recursive: true);
    } on FileSystemException {
      // An orphaned child of a timed-out run can still hold the folder on
      // Windows; the system temp folder is cleaned later.
    }
  });

  Future<ScrumBoardServer> serve({String? script, String? bash, Duration? timeout}) async {
    final s = await ScrumBoardServer.start(
      root: repo,
      port: 0,
      usageScript: script ?? defaultUsageScript,
      bash: bash ?? _bash,
      usageTimeout: timeout ?? usageScriptTimeout,
    );
    servers.add(s);
    return s;
  }

  Future<Map<String, dynamic>> get(ScrumBoardServer s, String path) async {
    final r = await raw(s, 'GET', path);
    expect(r.status, 200, reason: path);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  final noBash = _bash == null ? 'no bash on this machine' : null;

  test('SCB-13.b SCB-14.o both usage routes answer {ok, output, reason} with the script output', () async {
    final s = await serve(script: _fixture('usage_ok.sh'));
    expect(await get(s, '/api/usage/estimate'),
        {'ok': true, 'output': 'fake estimate: session 2.0 % per point\n', 'reason': ''});
    expect(await get(s, '/api/usage/trend'),
        {'ok': true, 'output': 'fake trend: session 2.0 % per point\n', 'reason': ''});
  }, skip: noBash);

  test('SCB-13.b the usage routes take GET only and no other path under them', () async {
    final s = await serve(script: _fixture('usage_ok.sh'));
    for (final c in [
      ('POST', '/api/usage/estimate'),
      ('PUT', '/api/usage/trend'),
      ('GET', '/api/usage/project'),
      ('GET', '/api/usage/estimate/x'),
    ]) {
      expect((await raw(s, c.$1, c.$2)).status, 404, reason: '${c.$1} ${c.$2}');
    }
  });

  test('SCB-14.o the default script under the root is used; missing gives ok false with a reason', () async {
    final s = await serve();
    final a = await get(s, '/api/usage/estimate');
    expect(a['ok'], isFalse);
    expect(a['reason'], contains('usage script not found'));
    expect(a['output'], '');
    File('${repo.path}/scrum/usage/usage.sh')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(File(_fixture('usage_ok.sh')).readAsStringSync());
    expect((await get(s, '/api/usage/trend'))['output'], 'fake trend: session 2.0 % per point\n');
  }, skip: noBash);

  test('SCB-14.o bash not found gives ok false with a reason', () async {
    final r = await runUsageScript(
      bash: null,
      script: _fixture('usage_ok.sh'),
      mode: 'estimate',
      workingDirectory: repo.path,
    );
    expect(r.ok, isFalse);
    expect(r.reason, contains('bash not found'));
    final s = await serve(script: _fixture('usage_ok.sh'), bash: '${tmp.path}/no-such-bash.exe');
    final a = await get(s, '/api/usage/estimate');
    expect(a['ok'], isFalse);
    expect(a['reason'], contains('could not start bash'));
  });

  test('SCB-14.o a non-zero exit gives ok false with the script output as the reason', () async {
    final s = await serve(script: _fixture('usage_fail.sh'));
    final a = await get(s, '/api/usage/trend');
    expect(a['ok'], isFalse);
    expect(a['reason'], 'No rows for fake-model');
  }, skip: noBash);

  test('SCB-14.o a run past the time limit gives ok false at once', () async {
    final watch = Stopwatch()..start();
    final r = await runUsageScript(
      bash: _bash,
      script: _fixture('usage_sleep.sh'),
      mode: 'estimate',
      workingDirectory: repo.path,
      timeout: const Duration(milliseconds: 500),
    );
    expect(r.ok, isFalse);
    expect(r.reason, contains('timed out'));
    expect(watch.elapsed, lessThan(const Duration(seconds: 3)));
    expect(usageScriptTimeout, const Duration(seconds: 10));
  }, skip: noBash);

  test('SCB-01.a SCB-14.o the runner takes estimate or trend only', () {
    for (final bad in ['project', 'estimate x', '', 'trend; rm -rf /']) {
      expect(
        () => runUsageScript(bash: _bash, script: _fixture('usage_ok.sh'), mode: bad, workingDirectory: repo.path),
        throwsArgumentError,
        reason: bad,
      );
    }
    expect(usageScriptModes, {'estimate', 'trend'});
  });

  group('must-fix 14 the Windows bash lookup', () {
    const sys = r'C:\Windows\System32';
    const apps = r'C:\Users\u\AppData\Local\Microsoft\WindowsApps';
    String? look(String path, Set<String> files, {String? programFiles}) => findDefaultBash(
          environment: {'Path': path, 'ProgramFiles': ?programFiles},
          isWindows: true,
          exists: files.contains,
        );

    test('a git.exe on PATH gives <git>\\bin\\bash.exe', () {
      expect(look('$sys;D:\\Tools\\Git\\cmd', {'$sys\\bash.exe', r'D:\Tools\Git\cmd\git.exe', r'D:\Tools\Git\bin\bash.exe'}),
          r'D:\Tools\Git\bin\bash.exe');
      expect(look(r'D:\G\mingw64\bin', {r'D:\G\mingw64\bin\git.exe', r'D:\G\bin\bash.exe'}), r'D:\G\bin\bash.exe');
    });

    test('the usual install path is used when PATH has no git', () {
      expect(look(sys, {'$sys\\bash.exe', r'C:\Program Files\Git\bin\bash.exe'}), r'C:\Program Files\Git\bin\bash.exe');
    });

    test('a bash.exe on PATH outside System32 and WindowsApps', () {
      expect(look('$sys;$apps;E:\\msys\\usr\\bin', {'$sys\\bash.exe', '$apps\\bash.exe', r'E:\msys\usr\bin\bash.exe'}),
          r'E:\msys\usr\bin\bash.exe');
    });

    test('never a path under System32: only the WSL bash gives null', () {
      expect(look('$sys;$apps', {'$sys\\bash.exe', '$apps\\bash.exe'}), isNull);
      expect(look('', {}), isNull);
    });

    test('this machine: the default bash is not under System32', () {
      final b = findDefaultBash();
      if (b != null) expect(b.toLowerCase(), isNot(contains('system32')));
    });

    test('elsewhere the default is bash', () {
      expect(findDefaultBash(isWindows: false), 'bash');
    });
  });
}
