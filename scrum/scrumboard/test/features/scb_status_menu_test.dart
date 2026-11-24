import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/features/scb_status_menu.dart';
import 'package:scrumboard/src/l10n/messages.dart';

const _stories = [(id: 'st-1', name: 'Alpha'), (id: 'st-2', name: 'Beta')];

Future<List<(String, String?)>> _pump(WidgetTester t, {String status = 'backlog'}) async {
  final got = <(String, String?)>[];
  final m = (await t.runAsync(() => Messages.load('en')))!;
  await t.pumpWidget(MaterialApp(
    home: MessagesScope(
      messages: m,
      child: Scaffold(
        body: Center(
          child: ScbStatusMenu(
            status: status,
            stories: _stories,
            onSelected: (s, id) => got.add((s, id)),
            child: const Text('TOKEN'),
          ),
        ),
      ),
    ),
  ));
  return got;
}

void main() {
  testWidgets('SCB-21 tapping the child lists proposed, backlog, each story and retired', (t) async {
    await _pump(t);
    expect(find.text('Proposed'), findsNothing);
    await t.tap(find.text('TOKEN'));
    await t.pumpAndSettle();
    final labels = ['Proposed', 'Backlog', 'Sprint: Alpha', 'Sprint: Beta', 'Retired'];
    for (final l in labels) {
      expect(find.text(l), findsOneWidget, reason: l);
    }
    final ys = [for (final l in labels) t.getTopLeft(find.text(l)).dy];
    expect([...ys]..sort(), ys);
  });

  testWidgets('SCB-21 choosing reports lower-case status and the story id', (t) async {
    final got = await _pump(t);
    for (final label in ['Proposed', 'Sprint: Beta', 'Retired']) {
      await t.tap(find.text('TOKEN'));
      await t.pumpAndSettle();
      await t.tap(find.text(label));
      await t.pumpAndSettle();
    }
    expect(got, [('proposed', null), ('planned', 'st-2'), ('retired', null)]);
  });

  testWidgets('SCB-21 the current status item cannot be chosen', (t) async {
    final got = await _pump(t);
    await t.tap(find.text('TOKEN'));
    await t.pumpAndSettle();
    await t.tap(find.text('Backlog'));
    await t.pumpAndSettle();
    expect(got, isEmpty);
  });
}
