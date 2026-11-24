import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import 'config.dart';
import 'oidc.dart';
import 'store.dart';

const sessionCookie = 'ss_session';
const stateCookie = 'ss_oidc';
const maxSettingsBytes = 256 * 1024;
const _pendingLifetime = Duration(minutes: 10);

class _Pending {
  _Pending(this.verifier, this.next, this.expires);
  final String verifier;
  final String next;
  final DateTime expires;
}

/// ACC-02.f: only a path on this site is followed after sign-in.
String safeNext(String? next) {
  if (next == null || next.isEmpty) return '/';
  if (!next.startsWith('/') || next.startsWith('//')) return '/';
  if (next.contains(r'\')) return '/';
  for (final u in next.codeUnits) {
    if (u < 0x20 || u == 0x7f) return '/';
  }
  return next;
}

Response _json(int status, Object body, {Map<String, Object>? headers}) =>
    Response(status,
        body: jsonEncode(body),
        headers: {'content-type': 'application/json', ...?headers});

/// Builds the request handler: API, sign-in routes, then the web build.
/// [now] is injectable for tests.
Handler buildHandler({
  required ServerConfig config,
  required Store store,
  required OidcClient oidc,
  DateTime Function()? now,
}) {
  final clock = now ?? DateTime.now;
  final pending = <String, _Pending>{};

  String cookie(String name, String value, {int? maxAge}) {
    final parts = [
      '$name=$value',
      'Path=/',
      'HttpOnly',
      'SameSite=Lax',
      if (maxAge != null) 'Max-Age=$maxAge',
      if (config.secureCookies) 'Secure',
    ];
    return parts.join('; ');
  }

  String? readCookie(Request req, String name) {
    final header = req.headers['cookie'];
    if (header == null) return null;
    for (final part in header.split(';')) {
      final i = part.indexOf('=');
      if (i < 0) continue;
      if (part.substring(0, i).trim() == name) return part.substring(i + 1).trim();
    }
    return null;
  }

  /// The signed-in user of the request, or null (no cookie, unknown or
  /// expired session). A database failure propagates (answered 503).
  Future<UserRecord?> currentUser(Request req) async {
    final id = readCookie(req, sessionCookie);
    if (id == null || id.isEmpty) return null;
    final s = await store.getSession(id);
    if (s == null) return null;
    if (!s.expiresAt.isAfter(clock())) {
      await store.deleteSession(id);
      return null;
    }
    return store.getUser(s.userSub);
  }

  Response unauthorized() =>
      _json(401, {'error': 'signInAgain'});

  Response unavailable() =>
      _json(503, {'ok': false, 'error': 'databaseUnavailable'});

  final api = Router();

  // DIA-03.b/d: needs no sign-in, discloses no database details.
  Future<Response> health(Request req) async =>
      await store.ping() ? _json(200, {'ok': true}) : unavailable();
  api.get('/api/health', health);
  api.get('/healthz', health);

  api.get('/api/me', (Request req) async {
    final u = await currentUser(req);
    if (u == null) return unauthorized();
    return _json(200, {'sub': u.sub, 'name': u.name, 'email': u.email});
  });

  api.get('/api/settings', (Request req) async {
    final u = await currentUser(req);
    if (u == null) return unauthorized();
    return _json(200, await store.getSettings(u.sub));
  });

  api.put('/api/settings', (Request req) async {
    final u = await currentUser(req);
    if (u == null) return unauthorized();
    // CSRF: a cross-site form cannot send JSON; also refuse a foreign Origin.
    final origin = req.headers['origin'];
    if (origin != null && origin != config.origin) {
      return _json(403, {'error': 'forbidden'});
    }
    final type = req.headers['content-type'] ?? '';
    if (!type.toLowerCase().startsWith('application/json')) {
      return _json(415, {'error': 'jsonRequired'});
    }
    final declared = req.contentLength;
    if (declared != null && declared > maxSettingsBytes) {
      return _json(413, {'error': 'tooLarge'});
    }
    final bytes = <int>[];
    await for (final chunk in req.read()) {
      bytes.addAll(chunk);
      if (bytes.length > maxSettingsBytes) {
        return _json(413, {'error': 'tooLarge'});
      }
    }
    Object? body;
    try {
      body = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      return _json(400, {'error': 'invalidJson'});
    }
    if (body is! Map) return _json(400, {'error': 'objectRequired'});
    final data = body.cast<String, Object?>();
    await store.putSettings(u.sub, data, clock());
    return _json(200, data);
  });

  api.all('/api/<rest|.*>', (Request req) => _json(404, {'error': 'notFound'}));

  // --- sign-in -----------------------------------------------------------
  final auth = Router();

  auth.get('/auth/login', (Request req) async {
    final state = randomToken();
    final verifier = randomToken(48);
    final next = safeNext(req.url.queryParameters['next']);
    final at = clock();
    pending.removeWhere((_, p) => p.expires.isBefore(at));
    pending[state] = _Pending(verifier, next, at.add(_pendingLifetime));
    final Uri url;
    try {
      url = await oidc.authorizeUrl(state, pkceChallenge(verifier));
    } catch (_) {
      return _json(502, {'error': 'identityProviderUnavailable'});
    }
    return Response.found(url, headers: {
      // Binds the state to this browser (login CSRF protection).
      'set-cookie': cookie(stateCookie, state, maxAge: 600),
    });
  });

  Response failed(String reason) => Response.found('/?signInError=$reason',
      headers: {'set-cookie': cookie(stateCookie, '', maxAge: 0)});

  auth.get('/auth/callback', (Request req) async {
    final q = req.url.queryParameters;
    final state = q['state'];
    final bound = readCookie(req, stateCookie);
    final p = state == null ? null : pending.remove(state);
    if (state == null ||
        p == null ||
        bound != state ||
        p.expires.isBefore(clock())) {
      return failed('state');
    }
    final code = q['code'];
    if (q.containsKey('error') || code == null || code.isEmpty) {
      return failed('denied');
    }
    final OidcUser user;
    try {
      user = await oidc.signIn(code, p.verifier);
    } on OidcException {
      return failed('refused');
    } catch (_) {
      return failed('unavailable');
    }
    final id = randomToken();
    try {
      await store.upsertUser(UserRecord(user.sub, user.name, user.email));
      await store.createSession(
          SessionRecord(id, user.sub, clock().add(config.sessionLifetime)));
    } catch (_) {
      return failed('unavailable');
    }
    return Response.found(p.next, headers: {
      'set-cookie': [
        cookie(sessionCookie, id, maxAge: config.sessionLifetime.inSeconds),
        cookie(stateCookie, '', maxAge: 0),
      ],
    });
  });

  // GET and POST both end the session. The Authentik session is NOT ended
  // here (ACC-02.c is only half covered).
  Future<Response> logout(Request req) async {
    final id = readCookie(req, sessionCookie);
    if (id != null) {
      try {
        await store.deleteSession(id);
      } catch (_) {/* cookie is cleared anyway */}
    }
    return Response.found('/', headers: {
      'set-cookie': cookie(sessionCookie, '', maxAge: 0),
    });
  }

  auth.get('/auth/logout', logout);
  auth.post('/auth/logout', logout);

  // --- web build with SPA fallback ----------------------------------------
  final webDir = Directory(config.webDir);
  final indexFile = File('${config.webDir}/index.html');
  final staticHandler = webDir.existsSync()
      ? createStaticHandler(config.webDir, defaultDocument: 'index.html')
      : (Request _) => Response.notFound('not found');
  Response spa(Request req) {
    final first = req.url.pathSegments.isEmpty ? '' : req.url.pathSegments.first;
    if (req.method != 'GET' ||
        first == 'api' ||
        first == 'auth' ||
        !indexFile.existsSync()) {
      return Response.notFound('not found');
    }
    return Response.ok(indexFile.openRead(),
        headers: {'content-type': 'text/html; charset=utf-8'});
  }

  final cascade = Cascade(statusCodes: [404])
      .add(api.call)
      .add(auth.call)
      .add(staticHandler)
      .add(spa)
      .handler;

  // Router answers 404 for unmatched paths; Cascade moves on. A store
  // failure (database down) becomes 503 databaseUnavailable.
  return (Request req) async {
    try {
      return await cascade(req);
    } catch (_) {
      return unavailable();
    }
  };
}
