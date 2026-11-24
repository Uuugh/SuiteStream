import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/features/scb_filter_bar.dart';
import 'package:scrumboard/src/l10n/messages.dart';

Requirement _r(String id, String status, String feature) =>
    Requirement(id: id, status: status, statement: 'S $id', feature: feature, file: 'requirements/$feature.md');

final _items = [_r('A-1', 'done', 'a'), _r('A-2', 'backlog', 'a'), _r('B-1', 'planned', 'b')];

class _Host extends StatefulWidget {
  const _Host();
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  ScbHiddenFilters hidden = const ScbHiddenFilters();
  @override
  Widget build(BuildContext context) => Column(children: [
        ScbFilterBar(
          items: _items,
          hidden: hidden,
          onChanged: (h) => setState(() => hidden = h),
          trailing: const Text('TRAIL'),
        ),
        Text('listed ${hidden.apply(_items).map((r) => r.id).join(',')}'),
      ]);
}

Future<void> _pump(WidgetTester t) async {
  final m = (await t.runAsync(() => Messages.load('en')))!;
  await t.pumpWidget(MaterialApp(
    home: MessagesScope(messages: m, child: const Scaffold(body: SizedBox(width: 700, child: _Host()))),
  ));
  await t.pumpAndSettle();
}

void main() {
  test('SCB-04.d ScbHiddenFilters lists an entry only when all three filters show it', () {
    const h = ScbHiddenFilters(features: {'b'}, ids: {'A-2'}, statuses: {'done'});
    expect(h.apply(_items), isEmpty);
    expect(const ScbHiddenFilters(ids: {'A-2'}).apply(_items).map((r) => r.id), ['A-1', 'B-1']);
    expect(const ScbHiddenFilters().copyWith(statuses: {'done'}).statuses, {'done'});
  });

  testWidgets('SCB-04 the bar has the three filters, the count and the trailing widget', (t) async {
    await _pump(t);
    for (final l in ['Feature', 'Requirement', 'Status']) {
      expect(find.byKey(ValueKey('scb-filter-button-$l')), findsOneWidget);
    }
    expect(find.text('3 of 3'), findsOneWidget);
    expect(find.text('TRAIL'), findsOneWidget);
  });

  testWidgets('SCB-04.a to SCB-04.d choices, hiding, and the shown-of count', (t) async {
    await _pump(t);
    await t.tap(find.byKey(const ValueKey('scb-filter-button-Feature')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('scb-filter-a')));
    await t.pumpAndSettle();
    expect(find.text('1 of 3'), findsOneWidget);
    expect(find.text('listed B-1'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('scb-filter-all-Feature')));
    await t.pumpAndSettle();
    expect(find.text('3 of 3'), findsOneWidget);
  });

  test('SCB-04 requirementFilterFields reads feature, id and status; applyWith matches apply', () {
    expect(requirementFilterFields.groupName, 'scbFilterFeature');
    expect(requirementFilterFields.idName, 'scbFilterRequirement');
    expect(requirementFilterFields.statuses, ['proposed', 'backlog', 'planned', 'done']);
    const h = ScbHiddenFilters(features: {'b'}, statuses: {'done'});
    expect(h.applyWith(_items, requirementFilterFields).map((r) => r.id), h.apply(_items).map((r) => r.id));
  });

  testWidgets('SCB-04 a bar on BoardItem hides by kind, by item and by status', (t) async {
    final m = (await t.runAsync(() => Messages.load('en')))!;
    // scbColumnQuestions is the page's column key (scrumboard_page.dart); the
    // column itself (task 10) is not built yet, so the bar sits under a
    // stand-in with that key and is found through it.
    await t.pumpWidget(MaterialApp(
      home: MessagesScope(
        messages: m,
        child: const Scaffold(
          body: KeyedSubtree(key: ValueKey('scbColumnQuestions'), child: SizedBox(width: 900, child: _ItemHost())),
        ),
      ),
    ));
    await t.pumpAndSettle();
    final bar = find.descendant(
      of: find.byKey(const ValueKey('scbColumnQuestions')),
      matching: find.byType(ScbFilterBar<BoardItem>),
    );
    expect(bar, findsOneWidget);
    Finder inBar(String key) => find.descendant(of: bar, matching: find.byKey(ValueKey(key)));
    Future<void> hide(String label, String value) async {
      await t.tap(inBar('scb-filter-button-$label'));
      await t.pumpAndSettle();
      await t.tap(find.byKey(ValueKey('scb-filter-$value')));
      await t.pumpAndSettle();
      await t.tap(inBar('scb-filter-button-$label'), warnIfMissed: false);
      await t.pumpAndSettle();
    }

    Future<void> showAll(String label) async {
      await t.tap(inBar('scb-filter-button-$label'));
      await t.pumpAndSettle();
      await t.tap(find.byKey(ValueKey('scb-filter-all-$label')));
      await t.pumpAndSettle();
      await t.tap(inBar('scb-filter-button-$label'), warnIfMissed: false);
      await t.pumpAndSettle();
    }

    for (final l in ['Kind', 'Number or PBI', 'Status']) {
      expect(inBar('scb-filter-button-$l'), findsOneWidget);
    }
    expect(find.descendant(of: bar, matching: find.text('4 of 4')), findsOneWidget);

    // By kind.
    await hide('Kind', BoardItem.verification);
    expect(find.text('listed question-1,question-2'), findsOneWidget);
    expect(find.text('2 of 4'), findsOneWidget);
    await showAll('Kind');

    // By item: question 1 and verification 1 share a number but are apart.
    await hide('Number or PBI', 'question-1');
    expect(find.text('listed question-2,verification-1,verification-2'), findsOneWidget);
    expect(find.text('3 of 4'), findsOneWidget);
    await showAll('Number or PBI');

    // By status.
    await hide('Status', 'open');
    expect(find.text('listed question-2,verification-2'), findsOneWidget);
    expect(find.text('2 of 4'), findsOneWidget);
  });
}

const _boardItems = [
  BoardItem(kind: BoardItem.question, number: 1, heading: 'Q one', status: 'open'),
  BoardItem(kind: BoardItem.question, number: 2, heading: 'Q two', status: 'answered', answer: 'a'),
  BoardItem(kind: BoardItem.verification, number: 1, heading: 'V one', status: 'open', pbi: 'PBI-086'),
  BoardItem(kind: BoardItem.verification, number: 2, heading: 'V two', status: 'accepted', pbi: 'PBI-092'),
];

String _itemKind(BoardItem i) => i.kind;
String _itemId(BoardItem i) => '${i.kind}-${i.number}';
String _itemStatus(BoardItem i) => i.status;
String _itemIdText(BoardItem i) => i.pbi ?? '${i.number}';
String _kindText(Messages m, String kind) =>
    kind == BoardItem.question ? m('scbKindQuestion') : m('scbKindVerification');
String _itemStatusText(Messages m, String s) => switch (s) {
      'open' => m('scbStatusOpen'),
      'answered' => m('scbAnswered'),
      'accepted' => m('scbAccepted'),
      'returned' => m('scbReturned'),
      _ => s,
    };

// The fields the questions column gives the bar (task 10 owns the real
// questionFilterFields); here only to drive the shared bar on BoardItem.
const _itemFields = ScbFilterFields<BoardItem>(
  group: _itemKind,
  id: _itemId,
  status: _itemStatus,
  statuses: ['open', 'answered', 'accepted', 'returned'],
  groupName: 'scbFilterKind',
  idName: 'scbFilterItem',
  groupText: _kindText,
  statusText: _itemStatusText,
  idText: _itemIdText,
);

class _ItemHost extends StatefulWidget {
  const _ItemHost();
  @override
  State<_ItemHost> createState() => _ItemHostState();
}

class _ItemHostState extends State<_ItemHost> {
  ScbHiddenFilters hidden = const ScbHiddenFilters();
  @override
  Widget build(BuildContext context) => Column(children: [
        ScbFilterBar<BoardItem>(
          items: _boardItems,
          fields: _itemFields,
          hidden: hidden,
          onChanged: (h) => setState(() => hidden = h),
        ),
        Text('listed ${hidden.applyWith(_boardItems, _itemFields).map(_itemId).join(',')}'),
      ]);
}
