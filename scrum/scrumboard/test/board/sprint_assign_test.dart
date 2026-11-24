import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/board/backlog_timeline.dart';
import 'package:scrumboard/src/board/sprint_assign.dart';
import 'package:scrumboard/src/l10n/messages.dart';

Requirement _req(String id, String status) =>
    Requirement(id: id, status: status, statement: 'Title $id', feature: 'cal', file: 'requirements/cal.md');

const _sprint = SprintFile(
  exists: true,
  blocks: [
    SprintBlock(id: 'S1', kind: 'sprint', name: 'Sprint 1'),
    SprintBlock(id: 'ST1', kind: 'story', name: 'One', parent: 'S1'),
    SprintBlock(id: 'E1', kind: 'epic', name: 'Epic', parent: 'S1'),
    SprintBlock(id: 'ST2', kind: 'story', name: 'Two', parent: 'E1'),
    SprintBlock(id: 'ST3', kind: 'story', name: 'Three'),
    SprintBlock(id: 'ST4', kind: 'story', name: 'Four'),
  ],
  members: [SprintMember(block: 'ST1', item: 'CAL-03'), SprintMember(block: 'ST1', item: 'GONE-01')],
);

FakeScrumBoardApi _api() => FakeScrumBoardApi(
      requirementList: [_req('CAL-02', 'backlog'), _req('CAL-03', 'planned')],
      sprintFile: _sprint,
    );

void main() {
  test('SCB-21 upcomingStories lists the first stories in file order', () {
    expect(upcomingStories(_sprint).map((s) => s.id), ['ST1', 'ST2', 'ST3']);
    expect(upcomingStories(_sprint, limit: 1), [(id: 'ST1', name: 'One')]);
    expect(upcomingStories(const SprintFile(exists: false)), isEmpty);
  });

  test('SCB-21 assigning sets planned and adds the member row', () async {
    final api = _api();
    final r = await assignRequirementToSprint(api, 'CAL-02', 'ST2');
    expect(r.ok, isTrue);
    expect(api.statusCalls, [(id: 'CAL-02', status: 'planned')]);
    expect(api.sprintFile.members.where((m) => m.item == 'CAL-02').map((m) => m.block), ['ST2']);
  });

  test('SCB-21 a planned requirement moves between stories without a status change', () async {
    final api = _api();
    final r = await assignRequirementToSprint(api, 'CAL-03', 'ST2');
    expect(r.ok, isTrue);
    expect(api.statusCalls, isEmpty);
    expect(api.sprintFile.members.where((m) => m.item == 'CAL-03').map((m) => m.block), ['ST2']);
  });

  test('SCB-13.c SCB-21 a refused status change returns the reason and changes nothing', () async {
    final api = _api()..refuseWith = 'not allowed';
    final r = await assignRequirementToSprint(api, 'CAL-02', 'ST2');
    expect(r, (ok: false, reason: 'not allowed'));
    expect(api.calls['saveSprint'], isNull);
  });

  testWidgets('SCB-19.c a member whose requirement is retired is not listed', (tester) async {
    final en = jsonDecode(File('assets/messages/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: MessagesScope(
        messages: Messages.fromMaps('en', en, en),
        child: Scaffold(body: BacklogTimeline(api: _api())),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('item-CAL-03')), findsOneWidget);
    expect(find.byKey(const ValueKey('item-GONE-01')), findsNothing);
  });
}
