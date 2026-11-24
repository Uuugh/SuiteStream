import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:scrumboard/src/api/models.dart';

export 'package:scrumboard/src/api/models.dart';

/// The server answered with an error (`{"error": "<reason>"}`, SCB-01.f).
class ScrumBoardApiException implements Exception {
  const ScrumBoardApiException(this.reason, {this.statusCode});

  /// The text for the `{reason}` placeholder of msg:scbLoadFailed.
  final String reason;
  final int? statusCode;

  @override
  String toString() => 'ScrumBoardApiException($statusCode): $reason';
}

/// The server could not be reached at all (SCB-13.h): [reason] is the text for
/// the `{reason}` placeholder of msg:scbServerUnreachable.
class ScrumBoardUnreachableException implements Exception {
  const ScrumBoardUnreachableException(this.reason);

  final String reason;

  @override
  String toString() => 'ScrumBoardUnreachableException: $reason';
}

/// What the panes use to read the data. Panes take this type, never a
/// concrete class, so widget tests pass [FakeScrumBoardApi].
abstract class ScrumBoardApi {
  /// `GET /api/requirements`.
  Future<List<Requirement>> requirements();

  /// `GET /api/sprint`.
  Future<SprintFile> sprint();

  /// `PUT /api/sprint`; returns the file as written.
  Future<SprintFile> saveSprint(SprintFile file);

  /// `GET /api/progress`.
  Future<List<ProgressEntry>> progress();

  /// `GET /api/usage`.
  Future<UsageData> usage();
}

/// Talks to the server over HTTP. [baseUri] is the page's own origin in the
/// browser (`Uri.base`), so no host or port is written in code.
class HttpScrumBoardApi implements ScrumBoardApi {
  HttpScrumBoardApi({required this.baseUri, http.Client? client})
      : _client = client ?? http.Client();

  final Uri baseUri;
  final http.Client _client;

  @override
  Future<List<Requirement>> requirements() async {
    final json = await _send('GET', '/api/requirements') as List<dynamic>;
    return [
      for (final r in json) Requirement.fromJson(r as Map<String, dynamic>),
    ];
  }

  @override
  Future<SprintFile> sprint() async => SprintFile.fromJson(
        await _send('GET', '/api/sprint') as Map<String, dynamic>,
      );

  @override
  Future<SprintFile> saveSprint(SprintFile file) async {
    final json = await _send(
      'PUT',
      '/api/sprint',
      body: jsonEncode(file.toJson()),
    );
    return SprintFile.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<ProgressEntry>> progress() async {
    final json = await _send('GET', '/api/progress') as List<dynamic>;
    return [
      for (final p in json) ProgressEntry.fromJson(p as Map<String, dynamic>),
    ];
  }

  @override
  Future<UsageData> usage() async => UsageData.fromJson(
        await _send('GET', '/api/usage') as Map<String, dynamic>,
      );

  Future<Object?> _send(String method, String path, {String? body}) async {
    final request = http.Request(method, baseUri.resolve(path));
    if (body != null) {
      request.headers['content-type'] = 'application/json; charset=utf-8';
      request.body = body;
    }
    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request));
    } on Object catch (e) {
      throw ScrumBoardUnreachableException(e.toString());
    }
    // Decode as UTF-8 whatever the headers say (SCB-13.i).
    final text = utf8.decode(response.bodyBytes);
    Object? decoded;
    try {
      decoded = text.isEmpty ? null : jsonDecode(text);
    } on FormatException {
      throw ScrumBoardApiException(
        'not JSON (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode >= 400) {
      final reason = decoded is Map<String, dynamic> && decoded['error'] != null
          ? decoded['error'].toString()
          : 'HTTP ${response.statusCode}';
      throw ScrumBoardApiException(reason, statusCode: response.statusCode);
    }
    return decoded;
  }

  void close() => _client.close();
}

/// In-memory API for widget tests. Set the fields, or set [failWith] to make
/// every call throw (to test SCB-01.f and SCB-13.h).
class FakeScrumBoardApi implements ScrumBoardApi {
  FakeScrumBoardApi({
    this.requirementList = const [],
    this.sprintFile = const SprintFile(exists: false),
    this.progressList = const [],
    this.usageData = const UsageData(exists: false),
    this.failWith,
    this.delay = Duration.zero,
  });

  List<Requirement> requirementList;
  SprintFile sprintFile;
  List<ProgressEntry> progressList;
  UsageData usageData;

  /// When set, every call throws this (a [ScrumBoardApiException] or a
  /// [ScrumBoardUnreachableException]).
  Exception? failWith;
  Duration delay;

  /// How many calls each method has had (to test Reload, SCB-01.c).
  final Map<String, int> calls = {};

  Future<T> _answer<T>(String name, T Function() value) async {
    calls[name] = (calls[name] ?? 0) + 1;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final failure = failWith;
    if (failure != null) throw failure;
    return value();
  }

  @override
  Future<List<Requirement>> requirements() =>
      _answer('requirements', () => List.of(requirementList));

  @override
  Future<SprintFile> sprint() => _answer('sprint', () => sprintFile);

  @override
  Future<SprintFile> saveSprint(SprintFile file) => _answer('saveSprint', () {
        sprintFile = SprintFile(
          exists: true,
          blocks: file.blocks,
          members: file.members,
        );
        return sprintFile;
      });

  @override
  Future<List<ProgressEntry>> progress() =>
      _answer('progress', () => List.of(progressList));

  @override
  Future<UsageData> usage() => _answer('usage', () => usageData);
}
