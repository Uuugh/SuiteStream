import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class OidcException implements Exception {
  OidcException(this.message);
  final String message;
  @override
  String toString() => 'OidcException: $message';
}

class OidcUser {
  const OidcUser(this.sub, this.name, this.email);
  final String sub;
  final String name;
  final String email;
}

String randomToken([int bytes = 32]) {
  final r = Random.secure();
  final b = List<int>.generate(bytes, (_) => r.nextInt(256));
  return base64Url.encode(b).replaceAll('=', '');
}

/// PKCE S256 challenge for [verifier] (RFC 7636).
String pkceChallenge(String verifier) =>
    base64Url.encode(sha256.convert(ascii.encode(verifier)).bytes)
        .replaceAll('=', '');

/// OIDC authorization code flow client for Authentik. No JWT is parsed: the
/// access token is sent to the userinfo endpoint, which Authentik answers
/// only for a valid token.
class OidcClient {
  OidcClient(this.config, this._http);

  final ServerConfig config;
  final http.Client _http;
  Map<String, Object?>? _discovery;

  Future<Map<String, Object?>> _discover() async {
    final cached = _discovery;
    if (cached != null) return cached;
    final base = config.issuer.endsWith('/') ? config.issuer : '${config.issuer}/';
    final res = await _http.get(Uri.parse('$base.well-known/openid-configuration'));
    if (res.statusCode != 200) {
      throw OidcException('discovery failed (${res.statusCode})');
    }
    final body = jsonDecode(res.body);
    if (body is! Map ||
        body['authorization_endpoint'] is! String ||
        body['token_endpoint'] is! String ||
        body['userinfo_endpoint'] is! String) {
      throw OidcException('discovery document incomplete');
    }
    return _discovery = body.cast<String, Object?>();
  }

  Future<Uri> authorizeUrl(String state, String codeChallenge) async {
    final d = await _discover();
    final base = Uri.parse(d['authorization_endpoint'] as String);
    return base.replace(queryParameters: {
      ...base.queryParameters,
      'response_type': 'code',
      'client_id': config.clientId,
      'redirect_uri': config.redirectUri,
      'scope': 'openid profile email',
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });
  }

  /// Exchanges [code] and returns the signed-in user. Throws [OidcException]
  /// when Authentik refuses (ACC-02.b: a refused sign-in makes no session).
  Future<OidcUser> signIn(String code, String codeVerifier) async {
    final d = await _discover();
    final tokenRes = await _http.post(
      Uri.parse(d['token_endpoint'] as String),
      headers: {'Accept': 'application/json'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': config.redirectUri,
        'client_id': config.clientId,
        'client_secret': config.clientSecret,
        'code_verifier': codeVerifier,
      },
    );
    if (tokenRes.statusCode != 200) {
      throw OidcException('token exchange refused (${tokenRes.statusCode})');
    }
    final tokens = jsonDecode(tokenRes.body);
    final access = tokens is Map ? tokens['access_token'] : null;
    if (access is! String || access.isEmpty) {
      throw OidcException('no access token');
    }
    final infoRes = await _http.get(
      Uri.parse(d['userinfo_endpoint'] as String),
      headers: {'Authorization': 'Bearer $access', 'Accept': 'application/json'},
    );
    if (infoRes.statusCode != 200) {
      throw OidcException('userinfo refused (${infoRes.statusCode})');
    }
    final info = jsonDecode(infoRes.body);
    final sub = info is Map ? info['sub'] : null;
    if (sub is! String || sub.isEmpty) throw OidcException('no subject');
    String str(Object? v) => v is String ? v : '';
    final name = str(info['name']).isNotEmpty
        ? str(info['name'])
        : str(info['preferred_username']);
    return OidcUser(sub, name, str(info['email']));
  }
}
