import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:suitestream_server/app.dart';
import 'package:suitestream_server/config.dart';
import 'package:suitestream_server/oidc.dart';
import 'package:suitestream_server/store.dart';
import 'package:test/test.dart';

import 'fake_oidc.dart';

const _base = 'https://cal.example.com';

void main() {
  late FakeOidc idp;
  late MemoryStore store;
  late Handler handler;
  late ServerConfig config;
  var clock = DateTime.utc(2026, 11, 23, 12);
  late Directory webDir;

  setUp(() async {
    idp = await FakeOidc.start();
    store = MemoryStore();
    clock = DateTime.utc(2026, 11, 23, 12);
    webDir = Directory.systemTemp.createTempSync('ss_web');
    File('${webDir.path}/index.html').writeAsStringSync('<html>app</html>');
    File('${webDir.path}/main.js').writeAsStringSync('js');
    config = ServerConfig(
      issuer: idp.issuer,
      clientId: idp.clientId,
      clientSecret: idp.clientSecret,
      publicUrl: _base,
      sessionHours: 2,
      webDir: webDir.path,
    );
    handler = buildHandler(
      config: config,
      store: store,
      oidc: OidcClient(config, http.Client()),
      now: () => clock,
    );
  });

  tearDown(() async {
    await idp.close();
    webDir.deleteSync(recursive: true);
  });

  Future<Response> call(String method, String path,
      {Map<String, String>? headers, String? body}) {
    return Future.sync(() => handler(Request(method, Uri.parse('$_base$path'),
        headers: headers, body: body)));
  }

  String cookieValue(Response r, String name) {
    final raw = r.headersAll['set-cookie'] ?? const [];
    for (final c in raw) {
      if (c.startsWith('$name=')) return c;
    }
    return '';
  }

  /// Plays the browser through the whole sign-in; returns the session cookie
  /// header value ("ss_session=...").
  Future<String> signIn(String sub,
      {String name = 'Ann', String email = 'ann@example.com', String? next}) async {
    final login = await call('GET', '/auth/login${next == null ? '' : '?next=${Uri.encodeQueryComponent(next)}'}');
    expect(login.statusCode, 302);
    final loc = Uri.parse(login.headers['location']!);
    final stateCookie = cookieValue(login, 'ss_oidc').split(';').first;
    final code = idp.issueCode(loc.queryParameters['code_challenge']!,
        {'sub': sub, 'name': name, 'email': email});
    final cb = await call(
        'GET', '/auth/callback?code=$code&state=${loc.queryParameters['state']}',
        headers: {'cookie': stateCookie});
    expect(cb.statusCode, 302, reason: cb.headers['location']);
    return cookieValue(cb, 'ss_session').split(';').first;
  }

  Future<Map<String, Object?>> jsonOf(Response r) async =>
      (jsonDecode(await r.readAsString()) as Map).cast<String, Object?>();

  group('health (DIA-03)', () {
    test('ok without sign-in', () async {
      final r = await call('GET', '/api/health');
      expect(r.statusCode, 200);
      expect(await jsonOf(r), {'ok': true});
    });

    test('503 databaseUnavailable when the store is down', () async {
      store.available = false;
      final r = await call('GET', '/api/health');
      expect(r.statusCode, 503);
      expect((await jsonOf(r))['error'], 'databaseUnavailable');
    });

    test('healthz alias answers the same', () async {
      expect((await call('GET', '/healthz')).statusCode, 200);
    });
  });

  group('login redirect (ACC-02)', () {
    test('goes to the authorize endpoint with state and PKCE', () async {
      final r = await call('GET', '/auth/login');
      expect(r.statusCode, 302);
      final loc = Uri.parse(r.headers['location']!);
      expect('${loc.scheme}://${loc.host}:${loc.port}${loc.path}', idp.authorizeEndpoint);
      final q = loc.queryParameters;
      expect(q['response_type'], 'code');
      expect(q['client_id'], idp.clientId);
      expect(q['redirect_uri'], '$_base/auth/callback');
      expect(q['code_challenge_method'], 'S256');
      expect(q['code_challenge'], isNotEmpty);
      expect(q['state'], isNotEmpty);
      expect(q['scope'], contains('openid'));
      expect(cookieValue(r, 'ss_oidc'), contains('HttpOnly'));
    });

    test('502 when the identity provider is unreachable', () async {
      await idp.close();
      final r = await call('GET', '/auth/login');
      expect(r.statusCode, 502);
      idp = await FakeOidc.start(); // for tearDown
    });
  });

  group('callback', () {
    test('success creates a user, a session and an HttpOnly cookie', () async {
      final login = await call('GET', '/auth/login');
      final loc = Uri.parse(login.headers['location']!);
      final stateCookie = cookieValue(login, 'ss_oidc').split(';').first;
      final code = idp.issueCode(loc.queryParameters['code_challenge']!,
          {'sub': 's1', 'name': 'Ann', 'email': 'a@x.org'});
      final cb = await call('GET',
          '/auth/callback?code=$code&state=${loc.queryParameters['state']}',
          headers: {'cookie': stateCookie});
      expect(cb.statusCode, 302);
      expect(cb.headers['location'], '/');
      final c = cookieValue(cb, 'ss_session');
      expect(c, contains('HttpOnly'));
      expect(c, contains('SameSite=Lax'));
      expect(c, contains('Secure')); // PUBLIC_URL is https
      expect(c, contains('Max-Age=7200')); // SESSION_HOURS = 2
      expect((await store.getUser('s1'))!.name, 'Ann');
    });

    test('cookie is not Secure for an http public URL', () async {
      config = ServerConfig(
          issuer: idp.issuer,
          clientId: idp.clientId,
          clientSecret: idp.clientSecret,
          publicUrl: 'http://localhost:8080',
          webDir: webDir.path);
      handler = buildHandler(
          config: config, store: store, oidc: OidcClient(config, http.Client()));
      final login = await handler(
          Request('GET', Uri.parse('http://localhost:8080/auth/login')));
      final loc = Uri.parse(login.headers['location']!);
      final code = idp.issueCode(loc.queryParameters['code_challenge']!,
          {'sub': 's1', 'name': 'A', 'email': ''});
      final cb = await handler(Request(
          'GET',
          Uri.parse(
              'http://localhost:8080/auth/callback?code=$code&state=${loc.queryParameters['state']}'),
          headers: {'cookie': cookieValue(login, 'ss_oidc').split(';').first}));
      expect(cookieValue(cb, 'ss_session'), isNot(contains('Secure')));
      expect(cookieValue(cb, 'ss_session'), startsWith('ss_session='));
    });

    test('state mismatch refuses and makes no session', () async {
      final login = await call('GET', '/auth/login');
      final loc = Uri.parse(login.headers['location']!);
      final code = idp.issueCode(loc.queryParameters['code_challenge']!,
          {'sub': 's1', 'name': 'A', 'email': ''});
      final cb = await call('GET', '/auth/callback?code=$code&state=wrong',
          headers: {'cookie': cookieValue(login, 'ss_oidc').split(';').first});
      expect(cb.statusCode, 302);
      expect(cb.headers['location'], contains('signInError=state'));
      expect(cookieValue(cb, 'ss_session'), '');
      expect(await store.getUser('s1'), isNull);
    });

    test('state without the browser cookie is refused', () async {
      final login = await call('GET', '/auth/login');
      final loc = Uri.parse(login.headers['location']!);
      final code = idp.issueCode(loc.queryParameters['code_challenge']!,
          {'sub': 's1', 'name': 'A', 'email': ''});
      final cb = await call('GET',
          '/auth/callback?code=$code&state=${loc.queryParameters['state']}');
      expect(cb.headers['location'], contains('signInError=state'));
    });

    test('a state works once', () async {
      final login = await call('GET', '/auth/login');
      final loc = Uri.parse(login.headers['location']!);
      final cookie = cookieValue(login, 'ss_oidc').split(';').first;
      final state = loc.queryParameters['state'];
      final code = idp.issueCode(loc.queryParameters['code_challenge']!,
          {'sub': 's1', 'name': 'A', 'email': ''});
      await call('GET', '/auth/callback?code=$code&state=$state',
          headers: {'cookie': cookie});
      final again = await call('GET', '/auth/callback?code=$code&state=$state',
          headers: {'cookie': cookie});
      expect(again.headers['location'], contains('signInError'));
    });

    test('a code Authentik refuses makes no session (ACC-02.b)', () async {
      final login = await call('GET', '/auth/login');
      final loc = Uri.parse(login.headers['location']!);
      final cb = await call('GET',
          '/auth/callback?code=bogus&state=${loc.queryParameters['state']}',
          headers: {'cookie': cookieValue(login, 'ss_oidc').split(';').first});
      expect(cb.headers['location'], contains('signInError=refused'));
      expect(cookieValue(cb, 'ss_session'), '');
    });

    test('an error from the provider makes no session', () async {
      final login = await call('GET', '/auth/login');
      final loc = Uri.parse(login.headers['location']!);
      final cb = await call('GET',
          '/auth/callback?error=access_denied&state=${loc.queryParameters['state']}',
          headers: {'cookie': cookieValue(login, 'ss_oidc').split(';').first});
      expect(cb.headers['location'], contains('signInError=denied'));
    });

    test('next path on this site is followed, others are not (ACC-02.f)', () async {
      expect(safeNext('/week?d=1'), '/week?d=1');
      expect(safeNext('//evil.com'), '/');
      expect(safeNext('/\\evil.com'), '/');
      expect(safeNext('/\t/evil.com'), '/');
      expect(safeNext('https://evil.com'), '/');
      expect(safeNext(null), '/');
      final session = await signIn('s1', next: '/month');
      expect(session, startsWith('ss_session='));
    });
  });

  group('session and API', () {
    test('401 without a session', () async {
      for (final path in ['/api/me', '/api/settings']) {
        final r = await call('GET', path);
        expect(r.statusCode, 401, reason: path);
      }
      final put = await call('PUT', '/api/settings',
          headers: {'content-type': 'application/json'}, body: '{}');
      expect(put.statusCode, 401);
    });

    test('401 with an unknown session cookie', () async {
      final r = await call('GET', '/api/me', headers: {'cookie': 'ss_session=nope'});
      expect(r.statusCode, 401);
    });

    test('me returns the signed-in user', () async {
      final c = await signIn('s1', name: 'Ann', email: 'ann@example.com');
      final r = await call('GET', '/api/me', headers: {'cookie': c});
      expect(r.statusCode, 200);
      expect(await jsonOf(r),
          {'sub': 's1', 'name': 'Ann', 'email': 'ann@example.com'});
    });

    test('session expires after SESSION_HOURS', () async {
      final c = await signIn('s1');
      clock = clock.add(const Duration(hours: 2, minutes: 1));
      final r = await call('GET', '/api/me', headers: {'cookie': c});
      expect(r.statusCode, 401);
    });

    test('logout ends the session', () async {
      final c = await signIn('s1');
      final out = await call('POST', '/auth/logout', headers: {'cookie': c});
      expect(out.statusCode, 302);
      expect(cookieValue(out, 'ss_session'), contains('Max-Age=0'));
      final r = await call('GET', '/api/me', headers: {'cookie': c});
      expect(r.statusCode, 401);
    });

    test('settings are empty at first, saved, and read back', () async {
      final c = await signIn('s1');
      final h = {'cookie': c, 'content-type': 'application/json'};
      expect(await jsonOf(await call('GET', '/api/settings', headers: h)), {});
      final put = await call('PUT', '/api/settings',
          headers: h, body: '{"theme.mode":"dark","view.longPressMs":200}');
      expect(put.statusCode, 200);
      final got = await jsonOf(await call('GET', '/api/settings', headers: h));
      expect(got, {'theme.mode': 'dark', 'view.longPressMs': 200});
    });

    test('PUT replaces the whole object', () async {
      final c = await signIn('s1');
      final h = {'cookie': c, 'content-type': 'application/json'};
      await call('PUT', '/api/settings', headers: h, body: '{"a":1,"b":2}');
      await call('PUT', '/api/settings', headers: h, body: '{"a":3}');
      expect(await jsonOf(await call('GET', '/api/settings', headers: h)), {'a': 3});
    });

    test('two users see only their own settings', () async {
      final a = await signIn('alice', name: 'Alice');
      final b = await signIn('bob', name: 'Bob');
      jsonHeaders(String c) => {'cookie': c, 'content-type': 'application/json'};
      await call('PUT', '/api/settings', headers: jsonHeaders(a), body: '{"x":"alice"}');
      await call('PUT', '/api/settings', headers: jsonHeaders(b), body: '{"x":"bob"}');
      expect(await jsonOf(await call('GET', '/api/settings', headers: jsonHeaders(a))), {'x': 'alice'});
      expect(await jsonOf(await call('GET', '/api/settings', headers: jsonHeaders(b))), {'x': 'bob'});
    });

    test('settings survive a new sign-in of the same user', () async {
      final c1 = await signIn('s1');
      await call('PUT', '/api/settings',
          headers: {'cookie': c1, 'content-type': 'application/json'},
          body: '{"k":1}');
      final c2 = await signIn('s1');
      expect(await jsonOf(await call('GET', '/api/settings', headers: {'cookie': c2})), {'k': 1});
    });

    test('PUT validation', () async {
      final c = await signIn('s1');
      Future<int> put(String body, {String type = 'application/json', Map<String, String>? extra}) async =>
          (await call('PUT', '/api/settings',
                  headers: {'cookie': c, 'content-type': type, ...?extra},
                  body: body))
              .statusCode;
      expect(await put('[1,2]'), 400);
      expect(await put('"text"'), 400);
      expect(await put('{not json'), 400);
      expect(await put('{"a":1}', type: 'text/plain'), 415);
      expect(await put('{"a":"${'x' * (maxSettingsBytes + 1)}"}'), 413);
      expect(await put('{"a":1}', extra: {'origin': 'https://evil.example'}), 403);
      expect(await put('{"a":1}', extra: {'origin': _base}), 200);
    });

    test('database down: API answers 503 databaseUnavailable', () async {
      final c = await signIn('s1');
      store.available = false;
      final r = await call('GET', '/api/settings', headers: {'cookie': c});
      expect(r.statusCode, 503);
      expect((await jsonOf(r))['error'], 'databaseUnavailable');
    });

    test('unknown API path is 404', () async {
      expect((await call('GET', '/api/nothing')).statusCode, 404);
    });
  });

  group('web build', () {
    test('serves files and falls back to index.html (SPA)', () async {
      final js = await call('GET', '/main.js');
      expect(js.statusCode, 200);
      expect(await js.readAsString(), 'js');
      final root = await call('GET', '/');
      expect(await root.readAsString(), contains('app'));
      final deep = await call('GET', '/week/2026-11-23');
      expect(deep.statusCode, 200);
      expect(await deep.readAsString(), contains('app'));
    });
  });

  group('configuration', () {
    test('reads variables, names the missing ones', () {
      expect(
          () => ServerConfig.fromEnv({'OIDC_ISSUER': 'x'}),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              allOf(contains('OIDC_CLIENT_ID'), contains('PUBLIC_URL')))));
      final c = ServerConfig.fromEnv({
        'OIDC_ISSUER': 'https://a/o/s/',
        'OIDC_CLIENT_ID': 'id',
        'OIDC_CLIENT_SECRET': 's',
        'PUBLIC_URL': 'https://cal.example.com/',
        'DATABASE_URL': 'postgresql://u:p@db/x',
        'SESSION_HOURS': '12',
        'WEB_DIR': '/web',
      });
      expect(c.publicUrl, 'https://cal.example.com');
      expect(c.redirectUri, 'https://cal.example.com/auth/callback');
      expect(c.sessionLifetime, const Duration(hours: 12));
      expect(c.webDir, '/web');
      expect(c.secureCookies, isTrue);
    });
  });
}
