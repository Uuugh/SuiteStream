import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/board/backlog_timeline.dart';
import 'package:scrumboard/src/features/requirement_drag_data.dart';
import 'package:scrumboard/src/l10n/messages.dart';

Requirement _req(String id, String status) =>
    Requirement(id: id, status: status, statement: 'Title $id', feature: 'cal', file: 'requirements/cal.md');

const _sprint = SprintFile(
  exists: true,
  blocks: [
    SprintBlock(id: 'S1', kind: 'sprint', name: 'Sprint 1'),
    SprintBlock(id: 'ST1', kind: 'story', name: 'Story one', parent: 'S1'),
    SprintBlock(id: 'ST2', kind: 'story', name: 'Story two', parent: 'S1'),
  ],
  members: [SprintMember(block: 'ST1', item: 'CAL-03'), SprintMember(block: 'ST1', item: 'CAL-04')],
);

FakeScrumBoardApi _api() => FakeScrumBoardApi(
      requirementList: [
        _req('CAL-01', 'proposed'),
        _req('CAL-02', 'backlog'),
        _req('CAL-03', 'planned'),
        _req('CAL-04', 'done'),
      ],
      sprintFile: _sprint,
    );

/// A stand-in for the Features column: one draggable per ID, carrying the status.
Future<void> _pump(WidgetTester tester, ScrumBoardApi api) async {
  final en = jsonDecode(File('assets/messages/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
  tester.view.physicalSize = const Size(1000, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: MessagesScope(
        messages: Messages.fromMaps('en', en, en),
        child: Scaffold(
          body: Column(
            children: [
              Row(children: [
                for (final (id, status) in [('CAL-01', 'proposed'), ('CAL-02', 'backlog'), ('CAL-03', 'planned'), ('CAL-04', 'done')])
                  Draggable<RequirementDragData>(
                    data: RequirementDragData(id, status),
                    feedback: const SizedBox(width: 20, height: 20),
                    child: Padding(padding: const EdgeInsets.all(8), child: Text('src-$id', key: ValueKey('src-$id'))),
                  ),
              ]),
              SizedBox(height: 500, child: BacklogTimeline(api: api)),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _drag(WidgetTester tester, String id, Finder target) async {
  final g = await tester.startGesture(tester.getCenter(find.byKey(ValueKey('src-$id'))));
  await tester.pump(const Duration(milliseconds: 50));
  await g.moveTo(tester.getCenter(target));
  await tester.pump();
  await g.up();
  await tester.pumpAndSettle();
}

Finder get _backlog => find.byKey(const ValueKey('backlog-block'));
Finder _inBacklog(String id) => find.descendant(of: _backlog, matching: find.byKey(ValueKey('item-$id')));
Finder _inStory(String story, String id) =>
    find.descendant(of: find.byKey(ValueKey('block-$story')), matching: find.byKey(ValueKey('item-$id')));
Finder get _backlogHeading => find.descendant(of: _backlog, matching: find.text('Backlog')).first;
Finder get _refused => find.byKey(const ValueKey('move-refused'));

Set<String> _rows(FakeScrumBoardApi api, String block) =>
    {for (final m in api.sprintFile.members) if (m.block == block) m.item};

String _status(FakeScrumBoardApi api, String id) => api.requirementList.firstWhere((r) => r.id == id).status;

void main() {
  testWidgets('SCB-07.c a drop on a sprint block changes nothing', (tester) async {
    final api = _api();
    await _pump(tester, api);
    // Aim at the sprint's own heading, not at a story inside it.
    final g = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('src-CAL-02'))));
    await tester.pump(const Duration(milliseconds: 50));
    await g.moveTo(tester.getTopLeft(find.byKey(const ValueKey('block-S1'))) + const Offset(30, 12));
    await g.up();
    await tester.pumpAndSettle();
    expect(api.statusCalls, isEmpty);
    expect(_status(api, 'CAL-02'), 'backlog');
  });

  testWidgets('SCB-07.d a proposed requirement dropped on the Backlog block becomes backlog', (tester) async {
    final api = _api();
    await _pump(tester, api);
    expect(_inBacklog('CAL-01'), findsNothing);
    await _drag(tester, 'CAL-01', _backlogHeading);
    expect(api.statusCalls, [(id: 'CAL-01', status: 'backlog')]);
    expect(_inBacklog('CAL-01'), findsOneWidget);
    expect(_refused, findsNothing);
  });

  testWidgets('SCB-07.e a requirement dropped on a story becomes planned and a member row', (tester) async {
    final api = _api();
    await _pump(tester, api);
    expect(_inBacklog('CAL-02'), findsOneWidget);
    await _drag(tester, 'CAL-02', find.byKey(const ValueKey('block-ST2')));
    expect(api.statusCalls, [(id: 'CAL-02', status: 'planned')]);
    expect(_rows(api, 'ST2'), {'CAL-02'});
    expect(_inBacklog('CAL-02'), findsNothing);
    expect(_inStory('ST2', 'CAL-02'), findsOneWidget);
    expect(api.calls['saveSprint'], 1);
  });

  testWidgets('SCB-07.f a requirement in a story dropped on the Backlog block leaves the story and is backlog',
      (tester) async {
    final api = _api();
    await _pump(tester, api);
    await _drag(tester, 'CAL-03', _backlogHeading);
    expect(api.statusCalls, [(id: 'CAL-03', status: 'backlog')]);
    expect(_rows(api, 'ST1'), {'CAL-04'});
    expect(_inStory('ST1', 'CAL-03'), findsNothing);
    expect(_inBacklog('CAL-03'), findsOneWidget);
  });

  testWidgets('SCB-07.g a refused status change changes nothing and shows msg:scbMoveRefused', (tester) async {
    final api = _api()..refuseWith = 'done cannot go back to backlog';
    await _pump(tester, api);
    await _drag(tester, 'CAL-04', _backlogHeading);
    expect(_refused, findsOneWidget);
    expect(find.text('Move refused: done cannot go back to backlog'), findsOneWidget);
    expect(_rows(api, 'ST1'), {'CAL-03', 'CAL-04'});
    expect(api.calls['saveSprint'], isNull);
    expect(_inStory('ST1', 'CAL-04'), findsOneWidget);
  });

  testWidgets('SCB-07.g a refused drop on a story leaves the member rows alone', (tester) async {
    final api = _api()..refuseWith = 'no';
    await _pump(tester, api);
    await _drag(tester, 'CAL-02', find.byKey(const ValueKey('block-ST2')));
    expect(find.text('Move refused: no'), findsOneWidget);
    expect(_rows(api, 'ST2'), isEmpty);
    expect(_status(api, 'CAL-02'), 'backlog');
  });

  testWidgets('SCB-07.h a drop where the requirement already is does nothing', (tester) async {
    final api = _api();
    await _pump(tester, api);
    await _drag(tester, 'CAL-02', _backlogHeading); // backlog on Backlog
    await _drag(tester, 'CAL-03', find.byKey(const ValueKey('block-ST1'))); // planned on its own story
    expect(api.statusCalls, isEmpty);
    expect(api.calls['saveSprint'], isNull);
    expect(_refused, findsNothing);
  });

  testWidgets('SCB-07.e a requirement row in the Backlog block can itself be dragged onto a story', (tester) async {
    final api = _api();
    await _pump(tester, api);
    final g = await tester.startGesture(tester.getCenter(_inBacklog('CAL-02')));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await g.moveTo(tester.getCenter(find.byKey(const ValueKey('block-ST2'))));
    await tester.pump();
    await g.up();
    await tester.pumpAndSettle();
    expect(_rows(api, 'ST2'), {'CAL-02'});
    expect(_status(api, 'CAL-02'), 'planned');
  });

  testWidgets('SCB-04 the Backlog block uses the shared filter bar', (tester) async {
    await _pump(tester, _api());
    expect(find.descendant(of: _backlog, matching: find.byKey(const ValueKey('scb-shown-of'))), findsOneWidget);
    expect(find.text('1 of 1'), findsOneWidget);
  });
}
