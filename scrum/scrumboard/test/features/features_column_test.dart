import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/features/features_column.dart';
import 'package:scrumboard/src/features/outline.dart';
import 'package:scrumboard/src/l10n/messages.dart';

Requirement _r(String id, String status, {String feature = 'a'}) =>
    Requirement(id: id, status: status, statement: 'S $id', feature: feature, file: 'requirements/$feature.md');

final _reqs = [
  _r('AAA-01', 'done'),
  _r('AAA-01.a', 'backlog'),
  _r('AAA-01.b', 'planned'),
  _r('AAA-02', 'proposed'),
  _r('BBB-05.a', 'backlog', feature: 'b'), // parent BBB-05 not listed (SCB-11.e)
];

Future<void> _pump(WidgetTester t, ScrumBoardApi api) async {
  final m = (await t.runAsync(() => Messages.load('en')))!;
  await t.pumpWidget(MaterialApp(
    home: MessagesScope(
      messages: m,
      child: Scaffold(body: SizedBox(width: 600, height: 600, child: FeaturesColumn(api: api))),
    ),
  ));
  await t.pumpAndSettle();
}

ScrumBoardApi _api([List<Requirement>? l]) => FakeScrumBoardApi(requirementList: l ?? _reqs);
bool _has(String id) => find.byKey(ValueKey('scb-row-$id')).evaluate().isNotEmpty;

void main() {
  testWidgets('SCB-03 and SCB-03.c rows show ID, status message, statement, feature; heading', (t) async {
    await _pump(t, _api());
    expect(find.text('Requirements'), findsOneWidget);
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

  testWidgets('SCB-01.f a failing server shows the message in the column', (t) async {
    await _pump(t, FakeScrumBoardApi(failWith: const ScrumBoardApiException('boom', statusCode: 500)));
    expect(find.text('Could not read the data: boom'), findsOneWidget);
  });
}
