import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/main.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

void main() {
  testWidgets('SCB-15.a SCB-01.c SCB-22 the page shows both panes and a changed stamp reads again',
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
    expect(find.text('Features & Requirements'), findsWidgets);
    expect(find.text('AAA-01'), findsWidgets);
    final before = api.calls['requirements'] ?? 0;
    await t.pump(scrumPollInterval);
    api.bump();
    await t.pump(scrumPollInterval);
    await t.pump(scrumPollInterval);
    await t.pumpAndSettle();
    expect(api.calls['requirements'], greaterThan(before));
  });

  testWidgets('SCB-19 SCB-01.c a retire removes the requirement from the list',
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
    expect(find.text('AAA-01'), findsWidgets);
    await t.pump(scrumPollInterval);
    final result = await api.retire('AAA-01');
    expect(result.ok, isTrue);
    await t.pump(scrumPollInterval);
    await t.pump(scrumPollInterval);
    await t.pumpAndSettle();
    expect(find.text('AAA-01'), findsNothing);
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
