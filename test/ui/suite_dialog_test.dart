import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/ui/popup_motion.dart';
import 'package:suitestream/src/ui/suite_dialog.dart';

const _dialogKey = ValueKey('sample-dialog');

Widget _app({required bool reduced, Duration? time}) {
  Widget home = Scaffold(
    body: Builder(
      builder: (context) => TextButton(
        onPressed: () => showSuiteDialog<void>(
          context: context,
          builder: (_) => const Dialog(key: _dialogKey, child: SizedBox(width: 200, height: 100)),
        ),
        child: const Text('Open'),
      ),
    ),
  );
  if (time != null) home = SuiteAnimationScope(duration: time, child: home);
  return MaterialApp(
    builder: (context, child) =>
        MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: reduced), child: child!),
    home: home,
  );
}

double _scale(WidgetTester tester) {
  final transforms = tester.widgetList<Transform>(
    find.ancestor(of: find.byKey(_dialogKey), matching: find.byType(Transform)),
  );
  return transforms.map((t) => t.transform.storage[0]).reduce((a, b) => a < b ? a : b);
}

/// UIC-47: the shared dialog transition.
void main() {
  testWidgets('UIC-47: reduced motion opens and closes at once', (tester) async {
    await tester.pumpWidget(_app(reduced: true));
    await tester.tap(find.text('Open'));
    await tester.pump();
    final route = ModalRoute.of(tester.element(find.byKey(_dialogKey)))!;
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
    expect(_scale(tester), 1);
    await tester.pumpAndSettle();
  });

  testWidgets('UIC-47: a zero animation time shows no motion', (tester) async {
    await tester.pumpWidget(_app(reduced: false, time: Duration.zero));
    await tester.tap(find.text('Open'));
    await tester.pump();
    final route = ModalRoute.of(tester.element(find.byKey(_dialogKey)))!;
    expect(route.transitionDuration, Duration.zero);
  });

  for (final ms in [200, 500, 1000]) {
    testWidgets('UIC-47: the dialog opens and closes over the animation time ($ms ms), with frames between', (
      tester,
    ) async {
      final time = Duration(milliseconds: ms);
      await tester.pumpWidget(_app(reduced: false, time: time));
      await tester.tap(find.text('Open'));
      await tester.pump();
      final route = ModalRoute.of(tester.element(find.byKey(_dialogKey)))!;
      expect(route.transitionDuration, time);
      expect(route.reverseTransitionDuration, time);

      await tester.pump(time * 0.5);
      final mid = _scale(tester);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(mid, greaterThan(suitePopupStartScale));
      expect(mid, lessThan(1));
      await tester.pump(time);
      expect(_scale(tester), 1);

      // Close: the dialog is still there part-way, and gone after the time.
      Navigator.of(tester.element(find.byKey(_dialogKey))).pop();
      await tester.pump();
      await tester.pump(time * 0.5);
      expect(find.byKey(_dialogKey), findsOneWidget);
      expect(_scale(tester), lessThan(1));
      await tester.pump(time);
      await tester.pumpAndSettle();
      expect(find.byKey(_dialogKey), findsNothing);
    });
  }
}
