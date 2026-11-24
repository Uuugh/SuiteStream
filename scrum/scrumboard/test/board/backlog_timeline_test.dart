import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/board/backlog_timeline.dart';
import 'package:scrumboard/src/board/board_tokens.dart';
import 'package:scrumboard/src/l10n/messages.dart';

Requirement _req(String id, String status, String statement, String feature) =>
    Requirement(id: id, status: status, statement: statement, feature: feature, file: 'requirements/$feature.md');

final _requirements = [
  _req('CAL-14', 'backlog', 'Week numbers in the header', 'calendar'),
  _req('CAL-15', 'backlog', 'Month grid', 'calendar'),
  _req('THM-02', 'backlog', 'One seed', 'theme'),
  _req('SET-05', 'done', 'Reset all settings', 'settings'),
  _req('CON-02', 'planned', 'Device-code login', 'connections'),
];

const _sprint = SprintFile(
  exists: true,
  blocks: [
    SprintBlock(id: 'S10', kind: 'sprint', name: 'Sprint 010'),
    SprintBlock(id: 'S11', kind: 'sprint', name: 'Sprint 011'),
    SprintBlock(id: 'E1', kind: 'epic', name: 'Connections', parent: 'S11'),
    SprintBlock(id: 'ST1', kind: 'story', name: 'Twitch sign-in', parent: 'E1'),
    SprintBlock(id: 'ST2', kind: 'story', name: 'Settings reset', parent: 'S10'),
  ],
  members: [
    SprintMember(block: 'ST1', item: 'CON-02'),
    SprintMember(block: 'ST1', item: '#38'),
    SprintMember(block: 'ST2', item: 'SET-05'),
  ],
);

Future<void> _pump(
  WidgetTester tester,
  ScrumBoardApi api, {
  double width = 1000,
  double height = 420,
}) async {
  final en = jsonDecode(File('assets/messages/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
  final messages = Messages.fromMaps('en', en, en);
  await tester.pumpWidget(
    MaterialApp(
      home: MessagesScope(
        messages: messages,
        child: Scaffold(
          body: SizedBox(width: width, height: height, child: BacklogTimeline(api: api)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

FakeScrumBoardApi _api({SprintFile? sprint}) =>
    FakeScrumBoardApi(requirementList: _requirements, sprintFile: sprint ?? _sprint);

void main() {
  testWidgets('SCB-06.a the Backlog block holds the backlog requirements only', (tester) async {
    await _pump(tester, _api());
    final block = find.byKey(const ValueKey('backlog-block'));
    expect(find.descendant(of: block, matching: find.text('Backlog')).first, findsOneWidget);
    expect(find.descendant(of: block, matching: find.text('3')), findsOneWidget);
    expect(find.descendant(of: block, matching: find.byKey(const ValueKey('item-CAL-14'))), findsOneWidget);
    expect(find.descendant(of: block, matching: find.byKey(const ValueKey('item-THM-02'))), findsOneWidget);
    expect(find.descendant(of: block, matching: find.byKey(const ValueKey('item-SET-05'))), findsNothing);
    expect(find.descendant(of: block, matching: find.byKey(const ValueKey('item-CON-02'))), findsNothing);
  });

  testWidgets('SCB-06.a the Backlog block stays fixed while the timeline scrolls', (tester) async {
    await _pump(tester, _api());
    final before = tester.getTopLeft(find.byKey(const ValueKey('backlog-block')));
    await tester.drag(find.byKey(const ValueKey('timeline')), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(const ValueKey('backlog-block'))), before);
  });

  testWidgets('SCB-06.e the timeline opens at its right end and slides under the Backlog block', (tester) async {
    await _pump(tester, _api());
    final scroll = tester.firstState<ScrollableState>(
      find.descendant(of: find.byKey(const ValueKey('timeline')), matching: find.byType(Scrollable)),
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    expect(scroll.position.pixels, scroll.position.maxScrollExtent);

    // Oldest sprint (left) is behind the Backlog block at the right end; newest is in view.
    final backlogRight = tester.getTopRight(find.byKey(const ValueKey('backlog-block'))).dx;
    expect(tester.getTopLeft(find.byKey(const ValueKey('block-S10'))).dx, lessThan(backlogRight));
    expect(tester.getTopRight(find.byKey(const ValueKey('block-S11'))).dx, lessThanOrEqualTo(1000));

    // Scrolled to the start, the first block rests right of the Backlog block.
    scroll.position.jumpTo(0);
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(const ValueKey('block-S10'))).dx, greaterThanOrEqualTo(backlogRight));
  });

  testWidgets('SCB-06.e sprints run oldest on the left, newest on the right', (tester) async {
    await _pump(tester, _api());
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('block-S10'))).dx,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('block-S11'))).dx),
    );
  });

  testWidgets('SCB-06.g every top-level block, and the Backlog block, has the same width', (tester) async {
    await _pump(tester, _api());
    for (final key in ['backlog-block', 'block-S10', 'block-S11']) {
      expect(tester.getSize(find.byKey(ValueKey(key))).width, BoardTokens.blockWidth, reason: key);
    }
  });

  testWidgets('SCB-06.g contents scroll inside a block that is too small', (tester) async {
    final many = [for (var i = 0; i < 40; i++) _req('FEA-$i', 'backlog', 'Item $i', 'feat')];
    await _pump(tester, FakeScrumBoardApi(requirementList: many, sprintFile: _sprint), height: 320);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('item-FEA-39')), findsNothing, reason: 'offscreen rows are not built');
    await tester.drag(
      find.descendant(of: find.byKey(const ValueKey('backlog-block')), matching: find.byType(ListView)),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('item-FEA-39')), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('backlog-block'))).height, 320 - 2 * BoardTokens.gap);
  });

  testWidgets('SCB-06.c a block is drawn inside the block it sits in', (tester) async {
    await _pump(tester, _api());
    Finder inside(String outer, String inner) =>
        find.descendant(of: find.byKey(ValueKey('block-$outer')), matching: find.byKey(ValueKey('block-$inner')));
    expect(inside('S11', 'E1'), findsOneWidget);
    expect(inside('E1', 'ST1'), findsOneWidget);
    expect(inside('S11', 'ST1'), findsOneWidget);
    expect(inside('S10', 'ST2'), findsOneWidget);
    expect(inside('S10', 'ST1'), findsNothing);
    // The nested block lies within the bounds of its parent.
    final outer = tester.getRect(find.byKey(const ValueKey('block-S11')));
    final nested = tester.getRect(find.byKey(const ValueKey('block-ST1')));
    expect(outer.contains(nested.topLeft), isTrue);
  });

  testWidgets('SCB-06.c a loop in the parents does not recurse forever', (tester) async {
    const loop = SprintFile(
      exists: true,
      blocks: [
        SprintBlock(id: 'A', kind: 'sprint', name: 'A'),
        SprintBlock(id: 'B', kind: 'epic', name: 'B', parent: 'A'),
      ],
    );
    await _pump(tester, _api(sprint: loop));
    expect(find.byKey(const ValueKey('block-B')), findsOneWidget);
  });

  testWidgets('SCB-06.d a story shows each member with its ID and title', (tester) async {
    await _pump(tester, _api());
    final story = find.byKey(const ValueKey('block-ST1'));
    final req = find.descendant(of: story, matching: find.byKey(const ValueKey('item-CON-02')));
    expect(req, findsOneWidget);
    expect(tester.widget<Text>(req).textSpan!.toPlainText(), contains('CON-02'));
    expect(tester.widget<Text>(req).textSpan!.toPlainText(), contains('Device-code login'));
    // An issue number is shown as written.
    expect(find.descendant(of: story, matching: find.byKey(const ValueKey('item-#38'))), findsOneWidget);
    // A done requirement placed in a story keeps its title.
    final done = find.descendant(
      of: find.byKey(const ValueKey('block-ST2')),
      matching: find.byKey(const ValueKey('item-SET-05')),
    );
    expect(tester.widget<Text>(done).textSpan!.toPlainText(), contains('Reset all settings'));
  });

  testWidgets('SCB-06 without a sprint file only the Backlog block shows', (tester) async {
    await _pump(tester, FakeScrumBoardApi(requirementList: _requirements));
    expect(find.byKey(const ValueKey('backlog-block')), findsOneWidget);
    expect(find.byKey(const ValueKey('block-S10')), findsNothing);
  });

  testWidgets('SCB-01.f a failed read shows the load-failed message in the pane', (tester) async {
    await _pump(tester, FakeScrumBoardApi(failWith: const ScrumBoardApiException('boom', statusCode: 500)));
    expect(find.text('Could not read the data: boom'), findsOneWidget);
  });

  testWidgets('SCB-13.h no answer shows the server-unreachable message in the pane', (tester) async {
    await _pump(tester, FakeScrumBoardApi(failWith: const ScrumBoardUnreachableException('down')));
    expect(find.text('The ScrumBoard server cannot be reached: down'), findsOneWidget);
  });
}
