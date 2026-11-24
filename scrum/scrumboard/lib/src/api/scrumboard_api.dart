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

  /// `PUT /api/requirements/<id>/status` (SCB-13.c, SCB-13.d). A refused move
  /// is `ok: false` with the reason, not an exception.
  Future<({bool ok, String reason})> setStatus(String id, String status);

  /// `GET /api/changes` (SCB-22): a stamp that differs whenever a watched
  /// file changed.
  Future<String> changeStamp();

  /// `POST /api/requirements/<id>/retire` (SCB-19.a). A refusal is `ok: false`
  /// with the reason, not an exception.
  Future<({bool ok, String reason})> retire(String id);

  /// `GET /api/usage/estimate` (SCB-14.o): the output of `usage.sh estimate`;
  /// a missing, failing or timed-out script is `ok: false` with the reason.
  Future<({bool ok, String output, String reason})> usageEstimate();

  /// `GET /api/usage/trend` (SCB-14.o): the output of `usage.sh trend`.
  Future<({bool ok, String output, String reason})> usageTrend();

  /// `GET /api/questions` (SCB-17): the questions of `scrum/questions.md` and
  /// the verifications of `scrum/verifications.md`, each in column order
  /// (SCB-17.c: open first, then answered or closed, newest first).
  Future<({List<BoardItem> questions, List<BoardItem> verifications})>
  boardItems();

  /// `PUT /api/questions/<number>/answer` (SCB-17.b): writes [answer] under
  /// the question with this [number] AND [heading] and sets it answered. An
  /// item whose heading changed or that is gone is `ok: false` with reason
  /// `gone` (nothing written), not an exception. A line break or an empty
  /// answer is refused by the server (400, [ScrumBoardApiException]).
  Future<({bool ok, String reason})> answerQuestion(
    int number,
    String heading,
    String answer,
  );

  /// `PUT /api/verifications/<number>/result` (SCB-17.b): writes [result]
  /// and [status] (`accepted` or `returned`) for the verification with this
  /// [number] AND [heading]; `gone` as for [answerQuestion]. A line break, or
  /// `returned` with an empty result, is refused (400).
  Future<({bool ok, String reason})> setVerificationResult(
    int number,
    String heading,
    String result,
    String status,
  );
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

  @override
  Future<({bool ok, String reason})> setStatus(String id, String status) async {
    final json =
        await _send(
              'PUT',
              '/api/requirements/${Uri.encodeComponent(id)}/status',
              body: jsonEncode({'status': status}),
            )
            as Map<String, dynamic>;
    return (ok: json['ok'] == true, reason: (json['reason'] ?? '').toString());
  }

  @override
  Future<String> changeStamp() async {
    final json = await _send('GET', '/api/changes') as Map<String, dynamic>;
    return (json['stamp'] ?? '').toString();
  }

  @override
  Future<({bool ok, String reason})> retire(String id) async {
    final json =
        await _send(
              'POST',
              '/api/requirements/${Uri.encodeComponent(id)}/retire',
            )
            as Map<String, dynamic>;
    return (ok: json['ok'] == true, reason: (json['reason'] ?? '').toString());
  }

  @override
  Future<({bool ok, String output, String reason})> usageEstimate() =>
      _script('/api/usage/estimate');

  @override
  Future<({bool ok, String output, String reason})> usageTrend() =>
      _script('/api/usage/trend');

  @override
  Future<({List<BoardItem> questions, List<BoardItem> verifications})>
  boardItems() async {
    final json = await _send('GET', '/api/questions') as Map<String, dynamic>;
    List<BoardItem> list(String key) => [
      for (final i in json[key] as List<dynamic>? ?? const <dynamic>[])
        BoardItem.fromJson(i as Map<String, dynamic>),
    ];
    return (questions: list('questions'), verifications: list('verifications'));
  }

  @override
  Future<({bool ok, String reason})> answerQuestion(
    int number,
    String heading,
    String answer,
  ) => _write(
    '/api/questions/$number/answer',
    {'heading': heading, 'answer': answer},
  );

  @override
  Future<({bool ok, String reason})> setVerificationResult(
    int number,
    String heading,
    String result,
    String status,
  ) => _write(
    '/api/verifications/$number/result',
    {'heading': heading, 'result': result, 'status': status},
  );

  /// A `PUT` that answers `{ok, reason}` (SCB-17.b); a 400 throws
  /// [ScrumBoardApiException] with statusCode 400.
  Future<({bool ok, String reason})> _write(
    String path,
    Map<String, String> body,
  ) async {
    final json =
        await _send('PUT', path, body: jsonEncode(body))
            as Map<String, dynamic>;
    return (ok: json['ok'] == true, reason: (json['reason'] ?? '').toString());
  }

  Future<({bool ok, String output, String reason})> _script(String path) async {
    final json = await _send('GET', path) as Map<String, dynamic>;
    return (
      ok: json['ok'] == true,
      output: (json['output'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
    );
  }

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
    this.questionList = const [],
    this.verificationList = const [],
    this.failWith,
    this.delay = Duration.zero,
  });

  List<Requirement> requirementList;
  SprintFile sprintFile;
  List<ProgressEntry> progressList;
  UsageData usageData;

  /// What [boardItems] answers, in the order given (the server orders; a test
  /// gives the lists in column order). The writes change them.
  List<BoardItem> questionList;
  List<BoardItem> verificationList;

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

  /// What [setStatus] answers next; null means ok. Every call is recorded in
  /// [statusCalls] as `id -> status`.
  String? refuseWith;
  final List<({String id, String status})> statusCalls = [];

  @override
  Future<({bool ok, String reason})> setStatus(String id, String status) =>
      _answer('setStatus', () {
        statusCalls.add((id: id, status: status));
        final reason = refuseWith;
        if (reason != null) return (ok: false, reason: reason);
        requirementList = [
          for (final r in requirementList)
            if (r.id == id)
              Requirement(
                id: r.id,
                status: status,
                statement: r.statement,
                feature: r.feature,
                file: r.file,
              )
            else
              r,
        ];
        return (ok: true, reason: '');
      });

  int _bumps = 0;

  /// Makes [changeStamp] answer a new value, as if a file had changed.
  void bump() => _bumps++;

  /// Every id passed to [retire].
  final List<String> retireCalls = [];

  @override
  Future<String> changeStamp() => _answer(
    'changeStamp',
    () =>
        '$_bumps-'
        '${requirementList.map((r) => '${r.id}:${r.status}').join(',')}-'
        '${identityHashCode(sprintFile)}-'
        '${[...questionList, ...verificationList].map((i) => '${i.kind}${i.number}:${i.status}').join(',')}',
  );

  @override
  Future<({bool ok, String reason})> retire(String id) => _answer('retire', () {
    retireCalls.add(id);
    if (!requirementList.any((r) => r.id == id)) {
      return (ok: false, reason: 'no requirement $id');
    }
    requirementList = [
      for (final r in requirementList)
        if (r.id != id) r,
    ];
    return (ok: true, reason: '');
  });

  /// What [usageEstimate] and [usageTrend] answer (SCB-14.o).
  ({bool ok, String output, String reason}) estimateAnswer = (
    ok: true,
    output: '',
    reason: '',
  );
  ({bool ok, String output, String reason}) trendAnswer = (
    ok: true,
    output: '',
    reason: '',
  );

  @override
  Future<({bool ok, String output, String reason})> usageEstimate() =>
      _answer('usageEstimate', () => estimateAnswer);

  @override
  Future<({bool ok, String output, String reason})> usageTrend() =>
      _answer('usageTrend', () => trendAnswer);

  @override
  Future<({List<BoardItem> questions, List<BoardItem> verifications})>
  boardItems() => _answer(
    'boardItems',
    () => (
      questions: List.of(questionList),
      verifications: List.of(verificationList),
    ),
  );

  /// Every [answerQuestion] call.
  final List<({int number, String heading, String answer})> answerCalls = [];

  /// Every [setVerificationResult] call.
  final List<({int number, String heading, String result, String status})>
  resultCalls = [];

  /// Like the server: writes the answer and sets `answered` on the question
  /// with this number AND heading; `gone` when there is none; a line break or
  /// an empty answer throws the server's 400 as [HttpScrumBoardApi] would.
  @override
  Future<({bool ok, String reason})> answerQuestion(
    int number,
    String heading,
    String answer,
  ) => _answer('answerQuestion', () {
    answerCalls.add((number: number, heading: heading, answer: answer));
    if (answer.trim().isEmpty) _badRequest('the answer is empty');
    if (_hasLineBreak(answer)) _badRequest('the answer has a line break');
    final at = _find(questionList, number, heading);
    if (at < 0) return (ok: false, reason: 'gone');
    questionList = List.of(questionList)
      ..[at] = _with(questionList[at], 'answered', answer);
    return (ok: true, reason: '');
  });

  /// Like the server: writes the result and the status (`accepted` or
  /// `returned`) on the verification with this number AND heading; `gone`
  /// when there is none; the server's 400s as for [answerQuestion].
  @override
  Future<({bool ok, String reason})> setVerificationResult(
    int number,
    String heading,
    String result,
    String status,
  ) => _answer('setVerificationResult', () {
    resultCalls.add((
      number: number,
      heading: heading,
      result: result,
      status: status,
    ));
    if (status != 'accepted' && status != 'returned') {
      _badRequest('the status is not accepted or returned');
    }
    if (status == 'returned' && result.trim().isEmpty) {
      _badRequest('a returned verification needs a result');
    }
    if (_hasLineBreak(result)) _badRequest('the result has a line break');
    final at = _find(verificationList, number, heading);
    if (at < 0) return (ok: false, reason: 'gone');
    verificationList = List.of(verificationList)
      ..[at] = _with(verificationList[at], status, result);
    return (ok: true, reason: '');
  });

  static Never _badRequest(String reason) =>
      throw ScrumBoardApiException(reason, statusCode: 400);

  static bool _hasLineBreak(String s) => s.contains('\n') || s.contains('\r');

  /// The index of the item with this number AND heading; -1 when it is gone.
  static int _find(List<BoardItem> items, int number, String heading) =>
      items.indexWhere((i) => i.number == number && i.heading == heading);

  static BoardItem _with(BoardItem i, String status, String answer) =>
      BoardItem(
        kind: i.kind,
        number: i.number,
        heading: i.heading,
        status: status,
        text: i.text,
        choices: i.choices,
        pbi: i.pbi,
        answer: answer,
      );
}
