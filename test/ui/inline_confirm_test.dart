import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/ui/inline_confirm.dart';

/// UIC-48: the one inline confirm.
void main() {
  final messages = Messages.fromMaps('en', {'areYouSure': 'Are you sure?', 'yes': 'Yes', 'no': 'No'}, {});

  Future<void> pump(WidgetTester tester, void Function() onConfirm) => tester.pumpWidget(
        MaterialApp(
          theme: buildSuiteTheme(Brightness.light),
          home: MessagesScope(
            messages: messages,
            child: Scaffold(
              body: Column(
                children: [
                  InlineConfirmButton(
                    color: Colors.red,
                    onConfirm: onConfirm,
                    builder: (context, start) => TextButton(onPressed: start, child: const Text('Reset')),
                  ),
                  const TextField(key: ValueKey('other')),
                ],
              ),
            ),
          ),
        ),
      );

  testWidgets('pressing turns the button into the question with Yes and No, 34 px high', (tester) async {
    await pump(tester, () {});
    expect(find.text('Are you sure?'), findsNothing);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('Reset'), findsNothing);
    expect(find.text('Are you sure?'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Are you sure?')).style!.color, Colors.red);
    expect(tester.getSize(find.byKey(const ValueKey('inline-confirm-yes'))).height, 34);
    expect(suiteControlHeight, 34);
  });

  testWidgets('Yes confirms once and restores the button', (tester) async {
    var confirmed = 0;
    await pump(tester, () => confirmed++);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(confirmed, 1);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('No returns to the button and does nothing', (tester) async {
    var confirmed = 0;
    await pump(tester, () => confirmed++);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(confirmed, 0);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Are you sure?'), findsNothing);
  });

  testWidgets('Escape returns to the button and does nothing', (tester) async {
    var confirmed = 0;
    await pump(tester, () => confirmed++);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(confirmed, 0);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('losing focus returns to the button and does nothing', (tester) async {
    var confirmed = 0;
    await pump(tester, () => confirmed++);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('other')));
    await tester.pumpAndSettle();
    expect(confirmed, 0);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Are you sure?'), findsNothing);
  });
}
