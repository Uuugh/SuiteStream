import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:scrumboard/server/paths.dart';
import 'package:scrumboard/server/progress_usage_readers.dart';
import 'package:scrumboard/server/requirement_status.dart';
import 'package:scrumboard/server/requirements_reader.dart';
import 'package:scrumboard/server/sprint_file.dart';

/// Default for the request body limit (the DEF-01 row "ScrumBoard request
/// body limit"; 1 MiB).
const int defaultMaxBodyBytes = 1024 * 1024;

/// The ScrumBoard server (SCB-13): serves the built web app and the API on
/// 127.0.0.1 only. It runs no shell and no process, and holds no token.
class ScrumBoardServer {
  ScrumBoardServer._(
    this._http,
    this.root,
    this.progressDir,
    this.webDir,
    this.maxBodyBytes,
  );

  /// Starts listening on 127.0.0.1:[port] (0 picks a free port).
  /// [root] is the repository; every path it reads or writes must stay inside
  /// it. [progressDir], when given, must exist. [webDir] is `build/web`.
  static Future<ScrumBoardServer> start({
    required Directory root,
    Directory? progressDir,
    Directory? webDir,
    int port = 8081,
    int maxBodyBytes = defaultMaxBodyBytes,
  }) async {
    if (!root.existsSync()) {
      throw ArgumentError('the root folder does not exist: ${root.path}');
    }
    if (progressDir != null && !progressDir.existsSync()) {
      throw ArgumentError(
        'the progress folder does not exist: ${progressDir.path}',
      );
    }
    final http = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    final server = ScrumBoardServer._(
      http,
      Directory(root.resolveSymbolicLinksSync()),
      progressDir,
      webDir,
      maxBodyBytes,
    );
    unawaited(server._serve());
    return server;
  }

  final HttpServer _http;
  final Directory root;
  final Directory? progressDir;
  final Directory? webDir;
  final int maxBodyBytes;

  int get port => _http.port;

  Future<void> close() => _http.close(force: true);

  Future<void> _serve() async {
    await for (final request in _http) {
      unawaited(_handle(request));
    }
  }

  /// SCB-13.a: the Host is this address or `localhost` with our port, and an
  /// Origin, when present, is the same.
  bool _allowed(HttpRequest request) {
    final host = request.headers.value(HttpHeaders.hostHeader);
    if (host == null) return false;
    final names = {
      '127.0.0.1:$port',
      'localhost:$port',
    };
    if (!names.contains(host.toLowerCase())) return false;
    final origin = request.headers.value('origin');
    if (origin == null) return true;
    return origin == 'http://127.0.0.1:$port' ||
        origin.toLowerCase() == 'http://localhost:$port';
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      if (!_allowed(request)) {
        return await _json(request, 403, {'error': 'forbidden host or origin'});
      }
      final path = request.uri.path;
      final method = request.method;
      if (path == '/api/requirements' && method == 'GET') {
        return await _json(request, 200, readRequirements(root));
      }
      if (path == '/api/sprint' && method == 'GET') {
        return await _json(
          request,
          200,
          readSprintFile(resolveInside(root, 'scrum/sprint.md')),
        );
      }
      if (path == '/api/sprint' && method == 'PUT') {
        final body = await _readBody(request);
        if (body == null) {
          return await _json(request, 413, {'error': 'body too large'});
        }
        Object? decoded;
        try {
          decoded = jsonDecode(utf8.decode(body));
        } on FormatException {
          return await _json(request, 400, {'error': 'the body is not JSON'});
        }
        try {
          final saved = await _serialized(
            () => writeSprintFile(
              resolveInside(root, 'scrum/sprint.md'),
              decoded,
            ),
          );
          return await _json(request, 200, saved);
        } on SprintFormatException catch (e) {
          return await _json(request, 400, {'error': e.reason});
        }
      }
      final statusMatch =
          RegExp(r'^/api/requirements/([^/]+)/status$').firstMatch(path);
      if (statusMatch != null && method == 'PUT') {
        final body = await _readBody(request);
        if (body == null) {
          return await _json(request, 413, {'error': 'body too large'});
        }
        Object? decoded;
        try {
          decoded = jsonDecode(utf8.decode(body));
        } on FormatException {
          return await _json(request, 400, {'error': 'the body is not JSON'});
        }
        final status = decoded is Map<String, dynamic> ? decoded['status'] : null;
        if (status is! String) {
          return await _json(request, 400, {'error': 'status is missing'});
        }
        final id = Uri.decodeComponent(statusMatch.group(1)!);
        final answer = await _serialized(
          () => setRequirementStatus(root, id, status),
        );
        return await _json(request, 200, answer);
      }
      if (path == '/api/progress' && method == 'GET') {
        return await _json(request, 200, readProgress(progressDir));
      }
      if (path == '/api/usage' && method == 'GET') {
        return await _json(request, 200, readUsage(root));
      }
      if (!path.startsWith('/api') && (method == 'GET' || method == 'HEAD')) {
        if (await _static(request)) return;
      }
      await _json(request, 404, {'error': 'not found'});
    } on PathOutsideRoot {
      await _json(request, 403, {'error': 'path outside the root'});
    } on Object catch (e) {
      // The detail (it can hold local paths) goes to stderr, not to the client.
      stderr.writeln('ScrumBoard server error: $e');
      await _json(request, 500, {'error': 'internal error'});
    }
  }

  Future<void> _lastWrite = Future<void>.value();

  /// Runs writes one at a time (one in flight).
  Future<T> _serialized<T>(T Function() job) {
    final result = _lastWrite.then((_) => job());
    _lastWrite = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  /// Reads the body, or returns null when it is over [maxBodyBytes].
  Future<List<int>?> _readBody(HttpRequest request) async {
    if (request.contentLength > maxBodyBytes) {
      // Do not read an oversize body: the caller answers 413 and closes.
      return null;
    }
    final bytes = <int>[];
    var total = 0;
    var exceeded = false;
    await for (final chunk in request) {
      total += chunk.length;
      if (exceeded || total > maxBodyBytes) {
        // Stop keeping the data; read on so the answer can be sent, but give
        // up on the connection when a client keeps sending.
        exceeded = true;
        bytes.clear();
        if (total > maxBodyBytes * 64) break;
        continue;
      }
      bytes.addAll(chunk);
    }
    return exceeded ? null : bytes;
  }

  Future<void> _json(HttpRequest request, int status, Object? body) async {
    final bytes = utf8.encode(jsonEncode(body));
    final response = request.response
      ..statusCode = status
      ..headers.set('content-type', 'application/json; charset=utf-8')
      ..headers.set('cache-control', 'no-store')
      ..headers.set('x-content-type-options', 'nosniff')
      ..headers.set('x-frame-options', 'DENY')
      ..headers.set('content-security-policy', "frame-ancestors 'none'")
      ..persistentConnection = status != 413
      ..contentLength = bytes.length;
    if (request.method != 'HEAD') response.add(bytes);
    await response.close();
  }

  static const Map<String, String> _types = {
    'html': 'text/html; charset=utf-8',
    'js': 'text/javascript; charset=utf-8',
    'mjs': 'text/javascript; charset=utf-8',
    'css': 'text/css; charset=utf-8',
    'json': 'application/json; charset=utf-8',
    'wasm': 'application/wasm',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'svg': 'image/svg+xml',
    'ico': 'image/x-icon',
    'txt': 'text/plain; charset=utf-8',
    'otf': 'font/otf',
    'ttf': 'font/ttf',
    'woff2': 'font/woff2',
    'map': 'application/json; charset=utf-8',
  };

  /// Serves a file of `build/web`; false when there is none (then 404).
  Future<bool> _static(HttpRequest request) async {
    final web = webDir;
    if (web == null || !web.existsSync()) return false;
    final segments = request.uri.pathSegments.where((s) => s.isNotEmpty);
    if (segments.any(
      (s) =>
          s == '..' ||
          s == '.' ||
          s.contains(r'\') ||
          s.contains('/') ||
          s.contains('\u0000') ||
          s.contains(':'),
    )) {
      return false;
    }
    if (Platform.isWindows &&
        segments.any(
          (s) => RegExp(
            r'^(con|prn|aux|nul|com[0-9]|lpt[0-9])(.|$)',
            caseSensitive: false,
          ).hasMatch(s),
        )) {
      return false;
    }
    final relative = segments.isEmpty ? 'index.html' : segments.join('/');
    final String resolved;
    try {
      resolved = resolveInside(web, relative);
    } on PathOutsideRoot {
      return false;
    }
    final file = File(resolved);
    if (!file.existsSync()) return false;
    final ext = relative.contains('.') ? relative.split('.').last : '';
    final response = request.response
      ..statusCode = 200
      ..headers.set(
        'content-type',
        _types[ext.toLowerCase()] ?? 'application/octet-stream',
      )
      ..headers.set('cache-control', 'no-cache')
      ..headers.set('x-content-type-options', 'nosniff')
      ..headers.set('x-frame-options', 'DENY')
      ..headers.set('content-security-policy', "frame-ancestors 'none'")
      ..contentLength = file.lengthSync();
    if (request.method != 'HEAD') await response.addStream(file.openRead());
    await response.close();
    return true;
  }
}
