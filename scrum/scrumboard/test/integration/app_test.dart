import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/main.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/l10n/messages.dart';

void main() {
  testWidgets('SCB-15.a SCB-01.c the page shows both panes and Reload reads again',
      (t) async {
    t.view.physicalSize = const Size(1366, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final api = FakeScrumBoardApi(
      requirementList: const [
        Requirement(
          id: 'AAA-01',
          status: 'backlog',
          statement: 'First rule',
          feature: 'aaa',
          file: 'requirements/aaa.md',
        ),
      ],
    );
    final m = (await t.runAsync(() => Messages.load('en')))!;
    await t.pumpWidget(ScrumBoardApp(api: api, messages: m));
    await t.pumpAndSettle();
    expect(find.text('Requirements'), findsWidgets);
    expect(find.text('AAA-01'), findsWidgets);
    final before = api.calls['requirements'] ?? 0;
    await t.tap(find.byKey(const ValueKey('scbReload')));
    await t.pumpAndSettle();
    expect(api.calls['requirements'], greaterThan(before));
  });

  testWidgets('SCB-01.f SCB-13.h an unreachable server is said in the panes',
      (t) async {
    t.view.physicalSize = const Size(1366, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final api = FakeScrumBoardApi(
      failWith: const ScrumBoardUnreachableException('refused'),
    );
    final m = (await t.runAsync(() => Messages.load('en')))!;
    await t.pumpWidget(ScrumBoardApp(api: api, messages: m));
    await t.pumpAndSettle();
    expect(find.textContaining('refused'), findsWidgets);
  });
}
