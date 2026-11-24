import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/features/features_column.dart';
import 'package:scrumboard/src/features/outline.dart';
import 'package:scrumboard/src/features/requirement_drag_data.dart';
import 'package:scrumboard/src/features/scb_filter_bar.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

Requirement _r(String id, String status, {String feature = 'a'}) =>
    Requirement(id: id, status: status, statement: 'S $id', feature: feature, file: 'requirements/$feature.md');

final _reqs = [
  _r('AAA-01', 'done'),
  _r('AAA-01.a', 'backlog'),
  _r('AAA-01.b', 'planned'),
  _r('AAA-02', 'proposed'),
  _r('BBB-05.a', 'backlog', feature: 'b'), // parent BBB-05 not listed (SCB-11.e)
];

Future<void> _pump(WidgetTester t, ScrumBoardApi api, {double width = 600, ThemeData? theme}) async {
  final m = (await t.runAsync(() => Messages.load('en')))!;
  await t.pumpWidget(MaterialApp(
    theme: theme,
    home: MessagesScope(
      messages: m,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            height: 600,
            // The page's key for this column (scrumboard_page.dart), so the bar is found in it.
            child: KeyedSubtree(key: const ValueKey('scbColumnFeatures'), child: FeaturesColumn(api: api)),
          ),
        ),
      ),
    ),
  ));
  await t.pumpAndSettle();
}

ScrumBoardApi _api([List<Requirement>? l]) => FakeScrumBoardApi(requirementList: l ?? _reqs);
bool _has(String id) => find.byKey(ValueKey('scb-row-$id')).evaluate().isNotEmpty;

void main() {
  testWidgets('SCB-03 and SCB-03.c rows show ID, status message, statement, feature; heading', (t) async {
    await _pump(t, _api());
    expect(find.text('Features & Requirements'), findsOneWidget);
    expect(find.text('AAA-01'), findsOneWidget);
    expect(find.text('S AAA-01'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
  });

  testWidgets('SCB-03.b a status shows its message', (t) async {
    await _pump(t, _api([_r('AAA-09', 'backlog'), _r('AAA-10', 'proposed')]));
    expect(find.text('Backlog'), findsWidgets);
    expect(find.text('Proposed'), findsWidgets);
  });

  testWidgets('SCB-11.d opens collapsed; SCB-11.b triangles only on parents', (t) async {
    await _pump(t, _api());
    expect(_has('AAA-01'), isTrue);
    expect(_has('AAA-01.a'), isFalse);
    expect(find.byKey(const ValueKey('scb-toggle-AAA-01')), findsOneWidget);
    expect(find.byKey(const ValueKey('scb-toggle-AAA-02')), findsNothing);
    expect(find.byIcon(Icons.arrow_right), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('scb-toggle-AAA-01')));
    await t.pumpAndSettle();
    expect(_has('AAA-01.a'), isTrue);
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
  });

  testWidgets('SCB-11.a sub-requirements are indented; SCB-11.e orphan is not', (t) async {
    await _pump(t, _api());
    await t.tap(find.byKey(const ValueKey('scb-toggle-AAA-01')));
    await t.pumpAndSettle();
    final idTop = t.getTopLeft(find.text('AAA-01')).dx;
    final idSub = t.getTopLeft(find.text('AAA-01.a')).dx;
    expect(idSub - idTop, subRequirementIndent);
    expect(t.getTopLeft(find.text('BBB-05.a')).dx, idTop);
  });

  testWidgets('SCB-11.c and SCB-11.f expand-all switch, at the right of the filter row', (t) async {
    await _pump(t, _api());
    final sw = find.byKey(const ValueKey('scb-expand-all'));
    final count = find.byKey(const ValueKey('scb-shown-of'));
    expect(t.getTopRight(sw).dx, greaterThan(t.getTopRight(count).dx));
    expect(t.getCenter(sw).dy, closeTo(t.getCenter(count).dy, 30));
    await t.tap(sw);
    await t.pumpAndSettle();
    expect(_has('AAA-01.a') && _has('AAA-01.b'), isTrue);
    await t.tap(sw);
    await t.pumpAndSettle();
    expect(_has('AAA-01.a'), isFalse);
    expect(_has('AAA-01') && _has('AAA-02') && _has('BBB-05.a'), isTrue);
  });

  test('SCB-11.e outline is built from listed entries only', () {
    final rows = buildOutline([_r('X-1.a', 'done'), _r('X-1.a.b', 'done')], {'X-1.a'});
    expect([for (final r in rows) '${r.requirement.id}:${r.depth}'], ['X-1.a:0', 'X-1.a.b:1']);
  });

  testWidgets('SCB-04.a and SCB-04.d feature choices, filter, shown-of count', (t) async {
    await _pump(t, _api());
    expect(find.text('5 of 5'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('scb-filter-button-Feature')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('scb-filter-a')), findsOneWidget);
    expect(find.byKey(const ValueKey('scb-filter-b')), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('scb-filter-b')));
    await t.pumpAndSettle();
    expect(find.text('4 of 5'), findsOneWidget);
    expect(_has('BBB-05.a'), isFalse);
    await t.tap(find.byKey(const ValueKey('scb-filter-none-Feature')));
    await t.pumpAndSettle();
    expect(find.text('0 of 5'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('scb-filter-all-Feature')));
    await t.pumpAndSettle();
    expect(find.text('5 of 5'), findsOneWidget);
  });

  testWidgets('SCB-04.b and SCB-04.c requirement and status choices', (t) async {
    await _pump(t, _api());
    await t.tap(find.byKey(const ValueKey('scb-filter-button-Requirement')));
    await t.pumpAndSettle();
    for (final r in _reqs) {
      expect(find.byKey(ValueKey('scb-filter-${r.id}')), findsOneWidget);
    }
    await t.tapAt(const Offset(1, 1));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('scb-filter-button-Status')));
    await t.pumpAndSettle();
    for (final s in ['proposed', 'backlog', 'planned', 'done']) {
      expect(find.byKey(ValueKey('scb-filter-$s')), findsOneWidget);
    }
    await t.tap(find.byKey(const ValueKey('scb-filter-done')));
    await t.pumpAndSettle();
    expect(find.text('4 of 5'), findsOneWidget);
    expect(_has('AAA-01'), isFalse);
    // SCB-11.e: AAA-01 is not listed, so its sub-requirement stands alone.
    expect(_has('AAA-01.a'), isTrue);
  });

  testWidgets('SCB-07.c a requirement row is draggable and carries its ID and status', (t) async {
    await _pump(t, _api());
    final d = t.widget<LongPressDraggable<RequirementDragData>>(find.byKey(const ValueKey('scb-drag-AAA-02')));
    expect(d.data, const RequirementDragData('AAA-02', 'proposed'));
  });

  Future<void> choose(WidgetTester t, String id, String item) async {
    await t.tap(find.descendant(of: find.byKey(ValueKey('scb-status-$id')), matching: find.byType(Text)));
    await t.pumpAndSettle();
    await t.tap(find.byKey(ValueKey(item)));
    await t.pumpAndSettle();
  }

  FakeScrumBoardApi withStory() => FakeScrumBoardApi(
        requirementList: [_r('AAA-02', 'proposed'), _r('AAA-03', 'backlog')],
        sprintFile: const SprintFile(
          exists: true,
          blocks: [SprintBlock(id: 'S1', kind: 'story', name: 'First story')],
        ),
      );

  testWidgets('SCB-21 the status menu offers the stories; retired removes the row (SCB-19.c)', (t) async {
    final api = withStory();
    await _pump(t, api);
    await t.tap(find.descendant(of: find.byKey(const ValueKey('scb-status-AAA-02')), matching: find.byType(Text)));
    await t.pumpAndSettle();
    expect(find.text('Sprint: First story'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('scbStatusMenu.retired')));
    await t.pumpAndSettle();
    expect(api.retireCalls, ['AAA-02']);
    expect(_has('AAA-02'), isFalse);
    expect(_has('AAA-03'), isTrue);
  });

  testWidgets('SCB-21 backlog and a story set the status; the column reloads', (t) async {
    final api = withStory();
    await _pump(t, api);
    await choose(t, 'AAA-02', 'scbStatusMenu.backlog');
    expect(api.statusCalls, [(id: 'AAA-02', status: 'backlog')]);
    await choose(t, 'AAA-03', 'scbStatusMenu.story.S1');
    expect(api.statusCalls.last, (id: 'AAA-03', status: 'planned'));
    expect(api.sprintFile.members.any((m) => m.item == 'AAA-03' && m.block == 'S1'), isTrue);
    expect(find.text('Planned'), findsOneWidget);
  });

  testWidgets('SCB-21 a refusal shows msg:scbMoveRefused and changes nothing', (t) async {
    final api = withStory()..refuseWith = 'wrong order';
    await _pump(t, api);
    await choose(t, 'AAA-02', 'scbStatusMenu.backlog');
    expect(find.textContaining('wrong order'), findsOneWidget);
    expect(find.byKey(const ValueKey('move-refused')), findsOneWidget);
  });

  testWidgets('SCB-21 SCB-07.f choosing backlog for a planned story member removes its Members row', (t) async {
    final api = FakeScrumBoardApi(
      requirementList: [_r('AAA-04', 'planned'), _r('AAA-05', 'planned')],
      sprintFile: const SprintFile(
        exists: true,
        blocks: [SprintBlock(id: 'S1', kind: 'story', name: 'First story')],
        members: [SprintMember(block: 'S1', item: 'AAA-04'), SprintMember(block: 'S1', item: 'AAA-05')],
      ),
    );
    await _pump(t, api);
    await choose(t, 'AAA-04', 'scbStatusMenu.backlog');
    expect(api.statusCalls, [(id: 'AAA-04', status: 'backlog')]);
    expect(api.sprintFile.members.where((m) => m.item == 'AAA-04'), isEmpty);
    expect(api.sprintFile.members.map((m) => m.item), ['AAA-05'], reason: 'other members stay');
    expect(find.byKey(const ValueKey('move-refused')), findsNothing);
  });

  // SCB-23: about a third of the narrowest DEF-01 window (1024), the width the
  // page gives the column there (SCB-15.a), in light and dark (SCB-15.c).
  for (final dark in [false, true]) {
    testWidgets('SCB-23 SCB-15.c the status token is right-aligned on the first line, sub-rows too '
        '(${dark ? 'dark' : 'light'})', (t) async {
      final reqs = [
        _r('AAA-01', 'done', feature: 'a-rather-long-feature-name-that-wraps'),
        _r('AAA-01.a', 'backlog'),
        _r('AAA-02', 'proposed'),
      ];
      await _pump(t, _api(reqs),
          width: 320, theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light));
      await t.tap(find.byKey(const ValueKey('scb-toggle-AAA-01')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      double? tokenRight;
      for (final id in ['AAA-01', 'AAA-01.a', 'AAA-02']) {
        final row = t.getRect(find.byKey(ValueKey('scb-row-$id')));
        final token = t.getRect(find.byKey(ValueKey('scb-status-$id')));
        final idText = t.getRect(find.text(id));
        final statement = t.getRect(find.text('S $id'));
        // At the end of the row: only the row's right padding follows it.
        expect(row.right - token.right, closeTo(scrumPartGap, 0.01), reason: id);
        expect(token.left, greaterThan(idText.right), reason: id);
        // On the first line, above the statement.
        expect(token.top, closeTo(idText.top, 4), reason: id);
        expect(token.bottom, lessThanOrEqualTo(statement.top + 0.01), reason: id);
        tokenRight ??= token.right;
        expect(token.right, closeTo(tokenRight, 0.01), reason: '$id lines up with the others');
      }
    });
  }

  testWidgets('SCB-04 the column uses the shared ScbFilterBar', (t) async {
    await _pump(t, _api());
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('scbColumnFeatures')),
        matching: find.byType(ScbFilterBar<Requirement>),
      ),
      findsOneWidget,
    );
  });

  testWidgets('SCB-01.f a failing server shows the message in the column', (t) async {
    await _pump(t, FakeScrumBoardApi(failWith: const ScrumBoardApiException('boom', statusCode: 500)));
    expect(find.text('Could not read the data: boom'), findsOneWidget);
  });
}
