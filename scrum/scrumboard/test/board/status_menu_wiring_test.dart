import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/board/backlog_timeline.dart';
import 'package:scrumboard/src/l10n/messages.dart';

Requirement _req(String id, String status, {String? statement}) => Requirement(
      id: id,
      status: status,
      statement: statement ?? 'Title $id',
      feature: 'cal',
      file: 'requirements/cal.md',
    );

const _sprint = SprintFile(
  exists: true,
  blocks: [
    SprintBlock(id: 'S1', kind: 'sprint', name: 'Sprint 1'),
    SprintBlock(id: 'ST1', kind: 'story', name: 'Story one', parent: 'S1'),
    SprintBlock(id: 'ST2', kind: 'story', name: 'Story two', parent: 'S1'),
  ],
  members: [SprintMember(block: 'ST1', item: 'CAL-03')],
);

FakeScrumBoardApi _api({String? longTitle}) => FakeScrumBoardApi(
      requirementList: [
        _req('CAL-02', 'backlog', statement: longTitle),
        _req('CAL-03', 'planned'),
      ],
      sprintFile: _sprint,
    );

Future<void> _pump(WidgetTester tester, ScrumBoardApi api, {Size size = const Size(1000, 700)}) async {
  final en = jsonDecode(File('assets/messages/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: MessagesScope(
        messages: Messages.fromMaps('en', en, en),
        child: Scaffold(body: BacklogTimeline(api: api)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, String id, String itemKey) async {
  await tester.tap(find.byKey(ValueKey('status-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey(itemKey)));
  await tester.pumpAndSettle();
}

Finder get _refused => find.byKey(const ValueKey('move-refused'));

void main() {
  testWidgets('SCB-21 the status token of a Backlog entry offers the story choices', (tester) async {
    await _pump(tester, _api());
    await tester.tap(find.byKey(const ValueKey('status-CAL-02')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('scbStatusMenu.story.ST1')), findsOneWidget);
    expect(find.byKey(const ValueKey('scbStatusMenu.story.ST2')), findsOneWidget);
    expect(find.text('Sprint: Story one'), findsOneWidget);
  });

  testWidgets('SCB-21 choosing a story assigns a Backlog entry and moves it into the story', (tester) async {
    final api = _api();
    await _pump(tester, api);
    await _choose(tester, 'CAL-02', 'scbStatusMenu.story.ST2');
    expect(api.statusCalls, [(id: 'CAL-02', status: 'planned')]);
    expect(api.sprintFile.members.any((m) => m.block == 'ST2' && m.item == 'CAL-02'), isTrue);
    expect(
      find.descendant(of: find.byKey(const ValueKey('block-ST2')), matching: find.byKey(const ValueKey('item-CAL-02'))),
      findsOneWidget,
    );
    expect(_refused, findsNothing);
  });

  testWidgets('SCB-21 a story member can be moved to backlog from its token', (tester) async {
    final api = _api();
    await _pump(tester, api);
    await _choose(tester, 'CAL-03', 'scbStatusMenu.backlog');
    expect(api.statusCalls, [(id: 'CAL-03', status: 'backlog')]);
    expect(api.sprintFile.members, isEmpty);
    expect(
      find.descendant(of: find.byKey(const ValueKey('backlog-block')), matching: find.byKey(const ValueKey('item-CAL-03'))),
      findsOneWidget,
    );
  });

  testWidgets('SCB-21 a refused choice shows msg:scbMoveRefused and changes nothing', (tester) async {
    final api = _api()..refuseWith = 'order check';
    await _pump(tester, api);
    await _choose(tester, 'CAL-02', 'scbStatusMenu.story.ST1');
    expect(_refused, findsOneWidget);
    expect(find.textContaining('order check'), findsOneWidget);
    expect(api.requirementList.firstWhere((r) => r.id == 'CAL-02').status, 'backlog');
  });

  testWidgets('SCB-19.c retiring from the menu removes the entry from the Backlog and from its story', (tester) async {
    final api = _api();
    await _pump(tester, api);
    await _choose(tester, 'CAL-02', 'scbStatusMenu.retired');
    expect(api.retireCalls, ['CAL-02']);
    expect(find.byKey(const ValueKey('item-CAL-02')), findsNothing);
    await _choose(tester, 'CAL-03', 'scbStatusMenu.retired');
    expect(api.retireCalls, ['CAL-02', 'CAL-03']);
    expect(find.byKey(const ValueKey('item-CAL-03')), findsNothing);
  });

  testWidgets('SCB-19.c a story member whose requirement is gone is not listed', (tester) async {
    final api = FakeScrumBoardApi(requirementList: [_req('CAL-02', 'backlog')], sprintFile: _sprint);
    await _pump(tester, api);
    expect(find.byKey(const ValueKey('item-CAL-03')), findsNothing);
    expect(find.byKey(const ValueKey('item-CAL-02')), findsOneWidget);
  });

  for (final size in [const Size(1000, 700), const Size(800, 500)]) {
    testWidgets('SCB-15.c status tokens do not overflow the board at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      await _pump(tester, _api(longTitle: 'A very long statement ' * 12), size: size);
      expect(find.byKey(const ValueKey('status-CAL-02')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
