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

  testWidgets('SCB-04 SCB-17 SCB-15.a the real three columns each show their own bar count',
      (t) async {
    // Task 17a: the page as main.dart builds it (ScrumBoardApp: real Features
    // column, real backlog block, real QuestionsColumn) on the fake.
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
        Requirement(
          id: 'AAA-02',
          status: 'done',
          statement: 'Second rule',
          feature: 'aaa',
          file: 'requirements/aaa.md',
        ),
      ],
      questionList: const [
        BoardItem(
          kind: BoardItem.question,
          number: 1,
          heading: 'Tanaka, Sprint 015 Question 1',
          status: 'open',
          text: 'Question text 1',
        ),
      ],
      verificationList: const [
        BoardItem(
          kind: BoardItem.verification,
          number: 1,
          heading: 'PBI-086 Check 1',
          status: 'open',
          text: 'Verify text 1',
          pbi: 'PBI-086',
        ),
        BoardItem(
          kind: BoardItem.verification,
          number: 2,
          heading: 'PBI-125 Check 2',
          status: 'open',
          text: 'Verify text 2',
          pbi: 'PBI-125',
        ),
      ],
    );
    final m = (await t.runAsync(() => Messages.load('en')))!;
    await t.pumpWidget(ScrumBoardApp(api: api, messages: m));
    await t.pumpAndSettle();

    final shownOf = find.byKey(const ValueKey('scb-shown-of'));
    expect(shownOf, findsNWidgets(3));
    String countIn(Key block) {
      final f = find.descendant(of: find.byKey(block), matching: shownOf);
      expect(f, findsOneWidget, reason: '$block');
      return t.widget<Text>(f).data!;
    }

    // Each bar counts its own items: two requirements, one backlog
    // requirement, three board items.
    expect(countIn(const ValueKey('scbColumnFeatures')),
        m('scbShownOf', {'shown': 2, 'total': 2}));
    expect(countIn(const ValueKey('backlog-block')),
        m('scbShownOf', {'shown': 1, 'total': 1}));
    expect(countIn(const ValueKey('scbColumnQuestions')),
        m('scbShownOf', {'shown': 3, 'total': 3}));
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
