/// Server configuration read from environment variables (DEP-05.a: these are
/// the settings the server needs before it can read the database).
class ServerConfig {
  ServerConfig({
    required this.issuer,
    required this.clientId,
    required this.clientSecret,
    required this.publicUrl,
    this.databaseUrl,
    this.sessionHours = 24,
    this.webDir = 'build/web',
    this.port = 8080,
  });

  /// Authentik issuer, e.g. https://auth.example.com/application/o/suitestream/
  final String issuer;
  final String clientId;
  final String clientSecret;

  /// Public address of the app, e.g. https://calendar.example.com (no path).
  /// The redirect URI sent to Authentik is `<publicUrl>/auth/callback`.
  final String publicUrl;

  /// postgresql://user:password@host:5432/dbname
  final String? databaseUrl;
  final int sessionHours;
  final String webDir;
  final int port;

  Duration get sessionLifetime => Duration(hours: sessionHours);
  bool get secureCookies => publicUrl.startsWith('https://');
  String get redirectUri => '${_trimSlash(publicUrl)}/auth/callback';
  String get origin => Uri.parse(publicUrl).origin;

  static String _trimSlash(String s) =>
      s.endsWith('/') ? s.substring(0, s.length - 1) : s;

  /// Throws [FormatException] naming every missing or invalid variable.
  factory ServerConfig.fromEnv(Map<String, String> env) {
    final missing = <String>[];
    String need(String k) {
      final v = env[k]?.trim() ?? '';
      if (v.isEmpty) missing.add(k);
      return v;
    }

    final issuer = need('OIDC_ISSUER');
    final id = need('OIDC_CLIENT_ID');
    final secret = need('OIDC_CLIENT_SECRET');
    final pub = need('PUBLIC_URL');
    if (missing.isNotEmpty) {
      throw FormatException(
          'Missing environment variables: ${missing.join(', ')}');
    }
    final hours = int.tryParse(env['SESSION_HOURS'] ?? '') ?? 24;
    if (hours < 1) {
      throw const FormatException('SESSION_HOURS must be at least 1');
    }
    final db = env['DATABASE_URL']?.trim();
    final web = env['WEB_DIR']?.trim() ?? '';
    return ServerConfig(
      issuer: issuer,
      clientId: id,
      clientSecret: secret,
      publicUrl: _trimSlash(pub),
      databaseUrl: (db == null || db.isEmpty) ? null : db,
      sessionHours: hours,
      webDir: web.isEmpty ? 'build/web' : web,
      port: int.tryParse(env['PORT'] ?? '') ?? 8080,
    );
  }
}
