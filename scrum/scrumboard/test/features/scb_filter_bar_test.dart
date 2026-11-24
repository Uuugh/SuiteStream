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
}
