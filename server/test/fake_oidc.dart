import 'dart:convert';
import 'dart:io';

import 'package:suitestream_server/oidc.dart';

/// A minimal fake Authentik on a local dart:io HttpServer: discovery, token
/// and userinfo endpoints. The authorize endpoint is never fetched; tests play
/// the browser and call [issueCode] with the PKCE challenge from the redirect.
class FakeOidc {
  FakeOidc._(this._server, this.clientId, this.clientSecret);

  final HttpServer _server;
  final String clientId;
  final String clientSecret;

  final _codes = <String, ({String challenge, Map<String, Object?> user})>{};
  final _tokens = <String, Map<String, Object?>>{};
  bool refuseToken = false;

  String get issuer => 'http://127.0.0.1:${_server.port}/application/o/suitestream/';
  String get authorizeEndpoint => 'http://127.0.0.1:${_server.port}/authorize/';

  static Future<FakeOidc> start(
      {String clientId = 'cid', String clientSecret = 'secret'}) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final f = FakeOidc._(server, clientId, clientSecret);
    server.listen(f._handle);
    return f;
  }

  /// The user signs in at Authentik: returns the authorization code.
  String issueCode(String challenge, Map<String, Object?> user) {
    final code = randomToken(12);
    _codes[code] = (challenge: challenge, user: user);
    return code;
  }

  Future<void> close() => _server.close(force: true);

  Future<void> _send(HttpRequest req, int status, Object body) async {
    req.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await req.response.close();
  }

  Future<void> _handle(HttpRequest req) async {
    final path = req.uri.path;
    if (path.endsWith('/.well-known/openid-configuration')) {
      final base = 'http://127.0.0.1:${_server.port}';
      return _send(req, 200, {
        'issuer': issuer,
        'authorization_endpoint': '$base/authorize/',
        'token_endpoint': '$base/token/',
        'userinfo_endpoint': '$base/userinfo/',
      });
    }
    if (path == '/token/' && req.method == 'POST') {
      final form = Uri.splitQueryString(await utf8.decodeStream(req));
      final entry = _codes.remove(form['code']);
      final verifierOk = entry != null &&
          pkceChallenge(form['code_verifier'] ?? '') == entry.challenge;
      if (refuseToken ||
          entry == null ||
          !verifierOk ||
          form['client_id'] != clientId ||
          form['client_secret'] != clientSecret ||
          form['grant_type'] != 'authorization_code') {
        return _send(req, 400, {'error': 'invalid_grant'});
      }
      final token = randomToken(12);
      _tokens[token] = entry.user;
      return _send(req, 200, {'access_token': token, 'token_type': 'Bearer'});
    }
    if (path == '/userinfo/') {
      final auth = req.headers.value('authorization') ?? '';
      final user = _tokens[auth.replaceFirst('Bearer ', '')];
      if (user == null) return _send(req, 401, {'error': 'invalid_token'});
      return _send(req, 200, user);
    }
    return _send(req, 404, {'error': 'notFound'});
  }
}
