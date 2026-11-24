import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/board/status_choice.dart';

Requirement _req(String id, String status) =>
    Requirement(id: id, status: status, statement: 's', feature: 'cal', file: 'requirements/cal.md');

FakeScrumBoardApi _api() => FakeScrumBoardApi(
      requirementList: [_req('CAL-02', 'backlog'), _req('CAL-03', 'planned'), _req('CAL-04', 'proposed')],
      sprintFile: const SprintFile(
        exists: true,
        blocks: [
          SprintBlock(id: 'S1', kind: 'sprint', name: 'Sprint 1'),
          SprintBlock(id: 'ST1', kind: 'story', name: 'Story one', parent: 'S1'),
          SprintBlock(id: 'ST2', kind: 'story', name: 'Story two', parent: 'S1'),
        ],
        members: [SprintMember(block: 'ST1', item: 'CAL-03')],
      ),
    );

void main() {
  test('SCB-21 SCB-19.a retired calls retire', () async {
    final api = _api();
    final r = await applyStatusChoice(api, id: 'CAL-02', choice: 'retired');
    expect(r.ok, isTrue);
    expect(api.retireCalls, ['CAL-02']);
    expect(api.statusCalls, isEmpty);
  });

  test('SCB-21 a story assigns the requirement: planned and one Members row', () async {
    final api = _api();
    final r = await applyStatusChoice(api, id: 'CAL-02', choice: 'planned', storyId: 'ST2');
    expect(r.ok, isTrue);
    expect(api.statusCalls.map((c) => '${c.id}:${c.status}'), ['CAL-02:planned']);
    expect(api.sprintFile.members.where((m) => m.item == 'CAL-02').map((m) => m.block), ['ST2']);
  });

  test('SCB-21 SCB-07.f backlog sets backlog and removes the Members rows', () async {
    final api = _api();
    final r = await applyStatusChoice(api, id: 'CAL-03', choice: 'backlog');
    expect(r.ok, isTrue);
    expect(api.statusCalls.map((c) => '${c.id}:${c.status}'), ['CAL-03:backlog']);
    expect(api.sprintFile.members.where((m) => m.item == 'CAL-03'), isEmpty);
  });

  test('SCB-21 any other choice calls setStatus only', () async {
    final api = _api();
    final r = await applyStatusChoice(api, id: 'CAL-04', choice: 'proposed');
    expect(r.ok, isTrue);
    expect(api.statusCalls.map((c) => '${c.id}:${c.status}'), ['CAL-04:proposed']);
    expect(api.calls['saveSprint'], isNull);
  });

  test('SCB-21 a refusal and a failure are ok false with the reason', () async {
    final api = _api()..refuseWith = 'order';
    expect(await applyStatusChoice(api, id: 'CAL-02', choice: 'proposed'), (ok: false, reason: 'order'));
    expect(await applyStatusChoice(api, id: 'CAL-03', choice: 'backlog'), (ok: false, reason: 'order'));
    expect(api.calls['saveSprint'], isNull);
    expect((await applyStatusChoice(api, id: 'NOPE-01', choice: 'backlog')).ok, isFalse);
    api.failWith = const ScrumBoardUnreachableException('down');
    expect(await applyStatusChoice(api, id: 'CAL-02', choice: 'retired'), (ok: false, reason: 'down'));
    expect(await applyStatusChoice(api, id: 'CAL-02', choice: 'backlog'), (ok: false, reason: 'down'));
  });
}
