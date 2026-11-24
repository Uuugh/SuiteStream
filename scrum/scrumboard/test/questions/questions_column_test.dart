import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/server/board_items.dart';
import 'package:scrumboard/src/api/reload_scope.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/app/scrumboard_page.dart';
import 'package:scrumboard/src/features/scb_filter_bar.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/questions/questions_column.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// The server test fixtures (copies of the real files, SCB-17.a). The
/// questions copy's file order is 3, 1, 2, 4: it differs from number order.
const _fixtures = 'test/server/fixtures/board_items';

const _column = ValueKey('scbColumnQuestions');

BoardItem _q(int n, String status, {List<String> choices = const [], String answer = ''}) => BoardItem(
    kind: BoardItem.question,
    number: n,
    heading: 'Ito, Sprint 015 Question $n',
    status: status,
    text: 'Question text $n',
    choices: choices,
    answer: answer);

BoardItem _v(int n, String pbi, String status, {String answer = ''}) => BoardItem(
    kind: BoardItem.verification,
    number: n,
    heading: '$pbi Check $n',
    status: status,
    text: 'Verify text $n',
    pbi: pbi,
    answer: answer);

String _key(BoardItem i) => 'scb-item-${i.kind}-${i.number}';

Future<Messages> _messages(WidgetTester t, [String locale = 'en']) async =>
    (await t.runAsync(() => Messages.load(locale)))!;

/// The column alone, under the page's column key, in a [ReloadScope].
Future<void> _pump(WidgetTester t, ScrumBoardApi api,
    {ReloadController? reload, Size view = const Size(800, 600), bool settle = true}) async {
  t.view.physicalSize = view;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final m = await _messages(t);
  await t.pumpWidget(MaterialApp(
    theme: buildScrumTheme(Brightness.light),
    home: MessagesScope(
      messages: m,
      child: Scaffold(
        body: ReloadScope(
          controller: reload ?? ReloadController(),
          child: KeyedSubtree(key: _column, child: QuestionsColumn(api: api)),
        ),
      ),
    ),
  ));
  // A read still waiting shows the progress indicator, which never settles.
  settle ? await t.pumpAndSettle() : await t.pump();
}

/// The column in the real page at window size [s] (DEF-01), in [locale] and
/// [brightness].
Future<void> _pumpPage(WidgetTester t, ScrumBoardApi api, Size s,
    {String locale = 'en', Brightness brightness = Brightness.light}) async {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final m = await _messages(t, locale);
  await t.pumpWidget(MaterialApp(
    theme: buildScrumTheme(brightness),
    home: MessagesScope(
      messages: m,
      child: ScrumBoardPage(
        api: api,
        board: const SizedBox.shrink(),
        features: const SizedBox.shrink(),
        questions: QuestionsColumn(api: api),
      ),
    ),
  ));
  await t.pumpAndSettle();
}

typedef _Lists = ({List<BoardItem> questions, List<BoardItem> verifications});

/// Each read waits until the test completes its gate, in any order.
class _GatedApi extends FakeScrumBoardApi {
  final List<Completer<_Lists>> gates = [];

  @override
  Future<_Lists> boardItems() {
    final gate = Completer<_Lists>();
    gates.add(gate);
    return gate.future;
  }
}

/// Every write throws [failure] (a 400 or an unreachable server); reads work.
class _FailingWritesApi extends FakeScrumBoardApi {
  _FailingWritesApi(this.failure, {super.questionList, super.verificationList});

  final Exception failure;

  @override
  Future<({bool ok, String reason})> answerQuestion(int number, String heading, String answer) async => throw failure;

  @override
  Future<({bool ok, String reason})> setVerificationResult(int number, String heading, String result, String status) async =>
      throw failure;
}

Finder _inColumn(Finder f) => find.descendant(of: find.byKey(_column), matching: f);

Finder _k(String key) => find.byKey(ValueKey(key));

bool _enabled(WidgetTester t, String key) => t.widget<ButtonStyleButton>(_k(key)).onPressed != null;

String? _status(WidgetTester t, String id) => t.widget<Text>(_k('scb-item-status-$id')).data;

/// SCB-17.b: the item is listed and has no answer controls.
void _listedWithoutControls(String id) {
  expect(_k('scb-item-$id'), findsOneWidget, reason: 'stays listed');
  for (final k in ['answer-field', 'answered', 'result-field', 'accepted', 'returned']) {
    expect(_k('scb-$k-$id'), findsNothing, reason: k);
  }
  expect(_k('scb-choice-$id-0'), findsNothing);
  expect(find.descendant(of: _k('scb-item-$id'), matching: find.byType(TextField)), findsNothing);
  expect(find.descendant(of: _k('scb-item-$id'), matching: find.byType(ButtonStyleButton)), findsNothing);
}

void main() {
  testWidgets('SCB-17 SCB-15.a the heading is msg:scbQuestions, text only, in the third column', (t) async {
    final api = FakeScrumBoardApi(questionList: [_q(1, 'open')], verificationList: [_v(1, 'PBI-086', 'open')]);
    await _pumpPage(t, api, const Size(1366, 768));
    final heading = _inColumn(find.byKey(const ValueKey('scb-questions-heading')));
    expect(heading, findsOneWidget);
    // Text only: the heading is exactly the message, with no count beside it.
    expect(t.widget<Text>(heading).data, 'Questions and Verifications');
    final row = t.widget<Padding>(find.ancestor(of: heading, matching: find.byType(Padding)).first);
    expect(row.child, isA<Text>());
    // The third column of the bottom row, right of Features and Issues.
    final q = t.getRect(find.byKey(_column));
    expect(q.left, greaterThan(t.getRect(find.byKey(const ValueKey('scbColumnIssues'))).right));
    expect(t.getRect(find.byKey(const ValueKey('scbColumnIssues'))).left,
        greaterThan(t.getRect(find.byKey(const ValueKey('scbColumnFeatures'))).right));
    expect(_inColumn(find.byKey(ValueKey(_key(_q(1, 'open'))))), findsOneWidget);
    expect(_inColumn(find.byKey(ValueKey(_key(_v(1, 'PBI-086', 'open'))))), findsOneWidget);
  });

  test('SCB-17.c the column merges the two fixture lists in one order (file order differs from number order)', () {
    final lists = readBoardItems('$_fixtures/questions.md', '$_fixtures/verifications.md');
    final merged = questionColumnOrder(lists.questions, lists.verifications);
    final got = [for (final i in merged) '${i.kind[0]}${i.number}'];
    // Questions file order 3 (answered), 1 (open), 2 (open), 4 (closed); the
    // 44 verifications are all open.
    expect(got, ['q2', 'q1', for (var n = 44; n >= 1; n--) 'v$n', 'q4', 'q3']);
  });

  test('SCB-17.c open questions, open verifications, answered questions, accepted or returned verifications', () {
    // File order (as an agent wrote them), with a reused number: the server
    // orders each list, the column merges them.
    final questions = orderBoardItems([_q(5, 'answered', answer: 'a'), _q(2, 'open'), _q(7, 'answered', answer: 'b'), _q(1, 'open')]);
    final verifications = orderBoardItems(
        [_v(9, 'PBI-001', 'accepted'), _v(3, 'PBI-002', 'open'), _v(1, 'PBI-003', 'returned', answer: 'no'), _v(2, 'PBI-004', 'open')]);
    final got = [for (final i in questionColumnOrder(questions, verifications)) '${i.kind[0]}${i.number}'];
    expect(got, ['q1', 'q2', 'v2', 'v3', 'q7', 'q5', 'v1', 'v9']);
  });

  testWidgets('SCB-17.c the column lists the items top to bottom in the merged order', (t) async {
    final lists = readBoardItems('$_fixtures/questions.md', '$_fixtures/verifications.md');
    final verifications = orderBoardItems([_v(4, 'PBI-010', 'returned', answer: 'Fails'), _v(8, 'PBI-011', 'open'), _v(6, 'PBI-012', 'accepted')]);
    final api = FakeScrumBoardApi(questionList: lists.questions, verificationList: verifications);
    await _pump(t, api, view: const Size(800, 2400));
    final expected = [
      'scb-item-question-2',
      'scb-item-question-1',
      'scb-item-verification-8',
      'scb-item-question-4',
      'scb-item-question-3',
      'scb-item-verification-6',
      'scb-item-verification-4',
    ];
    final tops = [for (final k in expected) t.getTopLeft(_inColumn(find.byKey(ValueKey(k)))).dy];
    expect(tops, [...tops]..sort(), reason: 'listed in this order');
    expect(find.byKey(const ValueKey('scb-no-questions')), findsNothing);
    expect(find.text('Returned'), findsWidgets);
    expect(find.byKey(const ValueKey('scb-item-answer-verification-4')), findsOneWidget);
  });

  testWidgets('SCB-17.c with no item the column says msg:scbNoQuestions', (t) async {
    await _pump(t, FakeScrumBoardApi());
    expect(_inColumn(find.byKey(const ValueKey('scb-no-questions'))), findsOneWidget);
    expect(find.text('No open questions or verifications'), findsOneWidget);
    expect(find.byKey(const ValueKey('scb-questions-list')), findsNothing);
  });

  testWidgets('SCB-17.a each verification shows the PBI it waits for; a question shows none', (t) async {
    final api = FakeScrumBoardApi(
      questionList: [_q(1, 'open', choices: ['a) Yes. (recommended)', 'b) No.'])],
      verificationList: [_v(1, 'PBI-108', 'open'), _v(2, 'PBI-107', 'accepted', answer: 'Works')],
    );
    await _pump(t, api);
    for (final (n, pbi) in [(1, 'PBI-108'), (2, 'PBI-107')]) {
      final shown = find.byKey(ValueKey('scb-item-pbi-verification-$n'));
      expect(find.descendant(of: find.byKey(ValueKey('scb-item-verification-$n')), matching: shown), findsOneWidget);
      expect(t.widget<Text>(shown).data, pbi);
    }
    expect(find.byKey(const ValueKey('scb-item-pbi-question-1')), findsNothing);
    expect(find.text('a) Yes. (recommended)'), findsOneWidget);
    expect(find.text('b) No.'), findsOneWidget);
  });

  testWidgets('SCB-04 the column always gives the shared bar questionFilterFields', (t) async {
    final api = FakeScrumBoardApi(questionList: [_q(1, 'open')], verificationList: [_v(1, 'PBI-086', 'open'), _v(2, 'PBI-092', 'accepted')]);
    await _pump(t, api);
    final bar = _inColumn(find.byType(ScbFilterBar<BoardItem>));
    expect(bar, findsOneWidget);
    expect(identical(t.widget<ScbFilterBar<BoardItem>>(bar).fields, questionFilterFields), isTrue);
    expect(questionFilterFields.groupName, 'scbFilterKind');
    expect(questionFilterFields.idName, 'scbFilterItem');
    expect(questionFilterFields.statuses, ['open', 'answered', 'accepted', 'returned']);
    expect(questionFilterFields.id(_q(1, 'open')), isNot(questionFilterFields.id(_v(1, 'PBI-086', 'open'))));
    expect(questionFilterFields.idText(_q(1, 'open')), '1');
    expect(questionFilterFields.idText(_v(1, 'PBI-086', 'open')), 'PBI-086');
    expect(find.descendant(of: bar, matching: find.text('3 of 3')), findsOneWidget);
    // Hiding the verification kind leaves the question listed.
    await t.tap(find.descendant(of: bar, matching: find.byKey(const ValueKey('scb-filter-button-Kind'))));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('scb-filter-verification')));
    await t.pumpAndSettle();
    await t.tapAt(const Offset(1, 1));
    await t.pumpAndSettle();
    expect(find.descendant(of: bar, matching: find.text('1 of 3')), findsOneWidget);
    expect(find.byKey(const ValueKey('scb-item-question-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('scb-item-verification-1')), findsNothing);
  });

  testWidgets('SCB-01.c SCB-22 the column reads again when the generation changes', (t) async {
    final api = FakeScrumBoardApi(questionList: [_q(1, 'open')]);
    final reload = ReloadController();
    await _pump(t, api, reload: reload);
    expect(api.calls['boardItems'], 1);
    expect(find.byKey(const ValueKey('scb-item-verification-3')), findsNothing);
    api.verificationList = [_v(3, 'PBI-126', 'open')];
    reload.reload();
    await t.pumpAndSettle();
    expect(api.calls['boardItems'], 2);
    expect(find.byKey(const ValueKey('scb-item-verification-3')), findsOneWidget);
  });

  testWidgets('SCB-01.c a slow earlier read does not overwrite a later one', (t) async {
    final api = _GatedApi();
    final reload = ReloadController();
    await _pump(t, api, reload: reload, settle: false);
    reload.reload();
    await t.pump();
    expect(api.gates, hasLength(2));
    // The later read answers first, then the earlier (stale) one.
    api.gates[1].complete((questions: <BoardItem>[], verifications: [_v(2, 'PBI-200', 'open')]));
    await t.pumpAndSettle();
    api.gates[0].complete((questions: [_q(1, 'open')], verifications: <BoardItem>[]));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('scb-item-verification-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('scb-item-question-1')), findsNothing);
  });

  testWidgets('the column reads again when given a different api', (t) async {
    final first = FakeScrumBoardApi(questionList: [_q(1, 'open')]);
    await _pump(t, first);
    expect(find.byKey(const ValueKey('scb-item-question-1')), findsOneWidget);
    final second = FakeScrumBoardApi(verificationList: [_v(5, 'PBI-300', 'open')]);
    final m = await _messages(t);
    await t.pumpWidget(MaterialApp(
      home: MessagesScope(
        messages: m,
        child: Scaffold(body: KeyedSubtree(key: _column, child: QuestionsColumn(api: second))),
      ),
    ));
    await t.pumpAndSettle();
    expect(second.calls['boardItems'], 1);
    expect(find.byKey(const ValueKey('scb-item-verification-5')), findsOneWidget);
    expect(find.byKey(const ValueKey('scb-item-question-1')), findsNothing);
  });

  testWidgets('SCB-01.f a failing server shows the message in the column', (t) async {
    await _pump(t, FakeScrumBoardApi(failWith: const ScrumBoardApiException('boom', statusCode: 500)));
    expect(find.text('Could not read the data: boom'), findsOneWidget);
    expect(find.byKey(const ValueKey('scb-questions-error')), findsOneWidget);
  });

  testWidgets('SCB-17.d SCB-15.b with more items than fit, the column\'s own Scrollbar scrolls and the page does not', (t) async {
    final api = FakeScrumBoardApi(
      questionList: [for (var n = 30; n >= 1; n--) _q(n, 'open')],
      verificationList: [for (var n = 30; n >= 1; n--) _v(n, 'PBI-${n.toString().padLeft(3, '0')}', 'open')],
    );
    await _pumpPage(t, api, const Size(1366, 768));
    final list = _inColumn(find.byKey(const ValueKey('scb-questions-list')));
    expect(list, findsOneWidget);
    // The list sits under the column's own Scrollbar.
    expect(find.ancestor(of: list, matching: find.byKey(const ValueKey('scb-questions-scrollbar'))), findsOneWidget);
    expect(t.widget(find.byKey(const ValueKey('scb-questions-scrollbar'))), isA<Scrollbar>());
    final top = t.getRect(find.byKey(const ValueKey('scbRowTop')));
    final column = t.getRect(find.byKey(_column));
    // The list's own Scrollable comes first; the answer fields hold their own.
    final position = t.state<ScrollableState>(find.descendant(of: list, matching: find.byType(Scrollable)).first).position;
    expect(position.maxScrollExtent, greaterThan(0), reason: 'more items than fit');
    await t.drag(list, const Offset(0, -300));
    await t.pumpAndSettle();
    expect(position.pixels, greaterThan(0));
    // The page does not scroll: nothing else moved.
    expect(t.getRect(find.byKey(const ValueKey('scbRowTop'))), top);
    expect(t.getRect(find.byKey(_column)), column);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('SCB-17.b answer by choice writes the choice line (trimmed, letter included); '
      'the item stays listed, answered, with no answer controls', (t) async {
    final question = _q(1, 'open', choices: ['  a) Yes, keep them. (recommended)  ', 'b) No.']);
    final api = FakeScrumBoardApi(questionList: [question]);
    await _pump(t, api);
    const id = 'question-1';
    expect(_k('scb-answer-field-$id'), findsOneWidget);
    expect(find.descendant(of: _k('scb-answer-field-$id'), matching: find.text('Your answer')), findsOneWidget);
    expect(find.descendant(of: _k('scb-answered-$id'), matching: find.text('Answered')), findsOneWidget);
    final reads = api.calls['boardItems']!;
    await t.tap(_k('scb-choice-$id-0'));
    await t.pumpAndSettle();
    expect(api.answerCalls.single, (number: 1, heading: question.heading, answer: 'a) Yes, keep them. (recommended)'));
    expect(api.calls['boardItems'], reads + 1, reason: 'reads again after the write');
    expect(_status(t, id), 'Answered');
    expect(t.widget<Text>(_k('scb-item-answer-$id')).data, 'a) Yes, keep them. (recommended)');
    _listedWithoutControls(id);
    // The choice lines are still shown, as text.
    expect(find.text('b) No.'), findsOneWidget);
    expect(_k('scb-questions-notice'), findsNothing);
  });

  testWidgets('SCB-17.b typed text is written as typed with Answered; Answered waits for text', (t) async {
    final question = _q(2, 'open', choices: ['a) Yes.', 'b) No.']);
    final api = FakeScrumBoardApi(questionList: [question]);
    await _pump(t, api);
    const id = 'question-2';
    expect(_enabled(t, 'scb-answered-$id'), isFalse, reason: 'empty');
    await t.enterText(_k('scb-answer-field-$id'), '   ');
    await t.pump();
    expect(_enabled(t, 'scb-answered-$id'), isFalse, reason: 'blank');
    await t.enterText(_k('scb-answer-field-$id'), 'b, but only after Sprint 016 ');
    await t.pump();
    expect(_enabled(t, 'scb-answered-$id'), isTrue);
    await t.tap(_k('scb-answered-$id'));
    await t.pumpAndSettle();
    expect(api.answerCalls.single, (number: 2, heading: question.heading, answer: 'b, but only after Sprint 016 '));
    expect(_status(t, id), 'Answered');
    _listedWithoutControls(id);
  });

  testWidgets('SCB-17.b an open verification: Returned is disabled while the result is empty; '
      'Returned writes the result and status returned', (t) async {
    final verification = _v(7, 'PBI-125', 'open');
    final api = FakeScrumBoardApi(verificationList: [verification]);
    await _pump(t, api);
    const id = 'verification-7';
    expect(find.descendant(of: _k('scb-result-field-$id'), matching: find.text('Result (required to return)')), findsOneWidget);
    expect(find.descendant(of: _k('scb-accepted-$id'), matching: find.text('Accepted')), findsOneWidget);
    expect(find.descendant(of: _k('scb-returned-$id'), matching: find.text('Returned')), findsOneWidget);
    expect(_enabled(t, 'scb-returned-$id'), isFalse, reason: 'empty result');
    expect(_enabled(t, 'scb-accepted-$id'), isTrue);
    await t.enterText(_k('scb-result-field-$id'), '  ');
    await t.pump();
    expect(_enabled(t, 'scb-returned-$id'), isFalse, reason: 'blank result');
    await t.enterText(_k('scb-result-field-$id'), 'The badge still shows in dark');
    await t.pump();
    expect(_enabled(t, 'scb-returned-$id'), isTrue);
    await t.tap(_k('scb-returned-$id'));
    await t.pumpAndSettle();
    expect(api.resultCalls.single,
        (number: 7, heading: verification.heading, result: 'The badge still shows in dark', status: 'returned'));
    expect(_status(t, id), 'Returned');
    expect(t.widget<Text>(_k('scb-item-answer-$id')).data, 'The badge still shows in dark');
    _listedWithoutControls(id);
  });

  testWidgets('SCB-17.b Accepted writes the result (may be empty) and status accepted; '
      'the item stays listed with no controls', (t) async {
    final verification = _v(8, 'PBI-086', 'open');
    final other = _v(9, 'PBI-126', 'open');
    final api = FakeScrumBoardApi(verificationList: [other, verification]);
    await _pump(t, api);
    await t.tap(_k('scb-accepted-verification-8'));
    await t.pumpAndSettle();
    expect(api.resultCalls.single, (number: 8, heading: verification.heading, result: '', status: 'accepted'));
    expect(_status(t, 'verification-8'), 'Accepted');
    _listedWithoutControls('verification-8');
    // The other open verification keeps its controls.
    expect(_k('scb-accepted-verification-9'), findsOneWidget);
  });

  testWidgets('SCB-17.b gone: the column says msg:scbItemGone and reads again', (t) async {
    final question = _q(3, 'open');
    final verification = _v(4, 'PBI-125', 'open');
    final api = FakeScrumBoardApi(questionList: [question], verificationList: [verification]);
    await _pump(t, api);
    // An agent changes the question's heading under the same number.
    const changed = BoardItem(
        kind: BoardItem.question, number: 3, heading: 'Ito, Sprint 015 A new title', status: 'open', text: 'New text');
    api.questionList = [changed];
    await t.enterText(_k('scb-answer-field-question-3'), 'Yes');
    await t.pump();
    final reads = api.calls['boardItems']!;
    await t.tap(_k('scb-answered-question-3'));
    await t.pumpAndSettle();
    expect(api.answerCalls.single.heading, question.heading, reason: 'sent the heading it showed');
    expect(t.widget<Text>(_inColumn(_k('scb-questions-notice'))).data,
        'An agent removed this item meanwhile; nothing was written');
    expect(api.calls['boardItems'], reads + 1, reason: 'reads again');
    expect(find.text('Ito, Sprint 015 A new title'), findsOneWidget);
    expect(_status(t, 'question-3'), 'Open', reason: 'nothing was written');
    // An agent deletes the verification.
    api.verificationList = [];
    await t.tap(_k('scb-accepted-verification-4'));
    await t.pumpAndSettle();
    expect(api.resultCalls.single.number, 4);
    expect(find.text('An agent removed this item meanwhile; nothing was written'), findsOneWidget);
    expect(_k('scb-item-verification-4'), findsNothing);
  });

  testWidgets('SCB-17.b a refused write (400) or an unreachable server is shown; nothing crashes, the item stays open',
      (t) async {
    final verification = _v(5, 'PBI-125', 'open');
    final api = _FailingWritesApi(const ScrumBoardApiException('the result has a line break', statusCode: 400),
        verificationList: [verification]);
    await _pump(t, api);
    await t.enterText(_k('scb-result-field-verification-5'), 'Fails');
    await t.pump();
    await t.tap(_k('scb-returned-verification-5'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(t.widget<Text>(_k('scb-questions-notice')).data, 'the result has a line break');
    expect(_status(t, 'verification-5'), 'Open');
    expect(_enabled(t, 'scb-returned-verification-5'), isTrue, reason: 'controls back, text kept');

    final question = _q(6, 'open', choices: ['a) Yes.']);
    await _pump(t, _FailingWritesApi(const ScrumBoardUnreachableException('connection refused'), questionList: [question]));
    await t.tap(_k('scb-choice-question-6-0'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(t.widget<Text>(_k('scb-questions-notice')).data, 'The ScrumBoard server cannot be reached: connection refused');
    expect(_k('scb-answer-field-question-6'), findsOneWidget);
  });

  // DEF-01: the narrowest ScrumBoard window size; the language whose column
  // words are longest; light and dark.
  for (final b in Brightness.values) {
    testWidgets('DEF-01 SCB-15.c SCB-17.b an open question with its answer controls and an open verification '
        '(result field, Accepted, Returned) do not clip at 1024 x 640 in the longest language (${b.name})', (t) async {
      const keys = [
        'scbQuestions', 'scbNoQuestions', 'scbKindQuestion', 'scbKindVerification', 'scbStatusOpen', //
        'scbAnswered', 'scbAccepted', 'scbReturned', 'scbFilterKind', 'scbFilterItem', 'scbFilterStatus',
        'scbAnswerHint', 'scbResultHint',
      ];
      var longest = 'en';
      var most = 0;
      for (final code in supportedLocales) {
        final m = await _messages(t, code);
        final length = keys.fold<int>(0, (n, k) => n + m(k).length);
        if (length > most) (longest, most) = (code, length);
      }
      const question = BoardItem(
        kind: BoardItem.question,
        number: 12,
        heading: 'Takahashi, Sprint 015 Which order the Questions and Verifications column lists its items in',
        status: 'open',
        text: 'Should answered questions stay listed until an agent deletes them, or leave the column at once?',
        choices: ['a) They stay listed until an agent deletes them. (recommended)', 'b) They leave at once.'],
      );
      const verification = BoardItem(
        kind: BoardItem.verification,
        number: 44,
        heading: 'PBI-105 Usage log and script with a rather long title that wraps',
        status: 'open',
        text: 'On the board, light and dark, hard refresh, at the DEF-01 window sizes: the usage chart shows.',
        pbi: 'PBI-105',
      );
      // One item at a time, so each is built in the column's short area.
      for (final shown in [question, verification]) {
        final api = FakeScrumBoardApi(
          questionList: [if (shown.kind == BoardItem.question) shown],
          verificationList: [if (shown.kind == BoardItem.verification) shown],
        );
        await _pumpPage(t, api, const Size(1024, 640), locale: longest, brightness: b);
        expect(t.takeException(), isNull);
        expect(Theme.of(t.element(find.byType(QuestionsColumn))).brightness, b);
        final column = t.getRect(find.byKey(_column));
        final id = '${shown.kind}-${shown.number}';
        final item = t.getRect(find.byKey(ValueKey('scb-item-$id')));
        expect(item.left, greaterThanOrEqualTo(column.left - 0.01), reason: id);
        expect(item.right, lessThanOrEqualTo(column.right + 0.01), reason: id);
        final status = t.getRect(find.byKey(ValueKey('scb-item-status-$id')));
        expect(status.right, lessThanOrEqualTo(item.right + 0.01), reason: id);
        for (final text in find.descendant(of: find.byKey(ValueKey('scb-item-$id')), matching: find.byType(Text)).evaluate()) {
          final r = t.getRect(find.byWidget(text.widget));
          expect(r.left, greaterThanOrEqualTo(item.left - 0.01), reason: '$id ${(text.widget as Text).data}');
          expect(r.right, lessThanOrEqualTo(item.right + 0.01), reason: '$id ${(text.widget as Text).data}');
        }
        if (shown.pbi != null) {
          expect(t.getRect(find.byKey(ValueKey('scb-item-pbi-$id'))).right, lessThanOrEqualTo(item.right + 0.01));
        }
        // SCB-17.b: the answer controls sit inside the item, each fully.
        final controls = shown.kind == BoardItem.question
            ? ['scb-answer-field-$id', 'scb-answered-$id', 'scb-choice-$id-0', 'scb-choice-$id-1']
            : ['scb-result-field-$id', 'scb-accepted-$id', 'scb-returned-$id'];
        for (final k in controls) {
          expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
          final r = t.getRect(find.byKey(ValueKey(k)));
          expect(r.left, greaterThanOrEqualTo(item.left - 0.01), reason: k);
          expect(r.right, lessThanOrEqualTo(item.right + 0.01), reason: k);
          expect(r.bottom, lessThanOrEqualTo(item.bottom + 0.01), reason: k);
          expect(r.width, greaterThan(0), reason: k);
          // Each label and hint is laid out at its full width, not cut.
          for (final text in find.descendant(of: find.byKey(ValueKey(k)), matching: find.byType(Text)).evaluate()) {
            final p = text.renderObject! as RenderParagraph;
            expect(p.didExceedMaxLines, isFalse, reason: '$k ${(text.widget as Text).data}');
            expect(t.getRect(find.byWidget(text.widget)).right, lessThanOrEqualTo(r.right + 0.01), reason: k);
          }
        }
        final heading = t.getRect(_inColumn(find.byKey(const ValueKey('scb-questions-heading'))));
        expect(heading.right, lessThanOrEqualTo(column.right + 0.01));
        final shownOf = t.getRect(_inColumn(find.byKey(const ValueKey('scb-shown-of'))));
        expect(shownOf.right, lessThanOrEqualTo(column.right + 0.01));
      }
    });
  }
}
