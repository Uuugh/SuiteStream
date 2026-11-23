import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/ui/overflow_info.dart';

void main() {
  testWidgets(
    'overflow info expands a clipped label independently of its action',
    (tester) async {
      const title =
          'An event title that needs more than one line at this width';
      var activations = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: InkWell(
                  onTap: () => activations++,
                  child: const OverflowInfoText(
                    title,
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final more = find.byType(InfoPopoverButton);
      expect(more, findsOneWidget);
      expect(tester.getSize(more), const Size(24, 24));
      expect(
        tester.widget<Text>(find.text(title)).style!.fontSize,
        inInclusiveRange(13, 16),
      );
      await tester.tap(find.text(title));
      expect(activations, 1);
      await tester.tap(more);
      await tester.pumpAndSettle();
      expect(activations, 1);
      expect(find.text(title), findsNWidgets(2));
      await tester.tapAt(const Offset(16, 16));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    },
  );
}
