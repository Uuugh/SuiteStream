import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/ui/suite_dialog.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets('shared dialog honors reduced motion: $reduced', (
      tester,
    ) async {
      final dialog = find.byKey(const ValueKey('sample-dialog'));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSuiteDialog<void>(
                  context: context,
                  builder: (_) => const Dialog(
                    key: ValueKey('sample-dialog'),
                    child: SizedBox(width: 200, height: 100),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      final route = ModalRoute.of(tester.element(dialog))!;
      expect(
        route.transitionDuration,
        reduced ? Duration.zero : const Duration(milliseconds: 200),
      );
      final transforms = tester.widgetList<Transform>(
        find.ancestor(of: dialog, matching: find.byType(Transform)),
      );
      if (!reduced) {
        expect(
          transforms.any((widget) {
            final scale = widget.transform.storage[0];
            return scale > 0.96 && scale < 1;
          }),
          isTrue,
        );
      } else {
        expect(
          transforms.any((widget) => widget.transform.storage[0] < 1),
          isFalse,
        );
      }
      expect(find.byType(BackdropFilter), findsOneWidget);
      await tester.pumpAndSettle();
      expect(dialog, findsOneWidget);
    });
  }
}
