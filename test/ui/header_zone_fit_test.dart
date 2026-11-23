import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/ui/zoned_row.dart';

/// UIC-14.c: a header row of zones fits at narrow and wide widths: nothing overflows and
/// every zone stays inside the row.
const _long = 'A very long header title that cannot possibly fit a narrow phone width on one line';

Widget header({String title = _long}) => ZonedRow(
  leftMinWidth: 200,
  centerMinWidth: 100,
  rightMinWidth: 200,
  left: [
    const IconButton(onPressed: null, icon: Icon(Icons.arrow_back)),
    Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
  ],
  center: const [Text('Center')],
  right: [for (var i = 0; i < 5; i++) IconButton(onPressed: () {}, icon: const Icon(Icons.settings))],
);

void main() {
  for (final width in [320.0, 400.0, 800.0]) {
    testWidgets('UIC-14.c: the header zones fit at $width px', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSuiteTheme(Brightness.light),
          home: Scaffold(body: header()),
        ),
      );
      expect(tester.takeException(), isNull);
      final row = tester.getRect(find.byType(ZonedRow));
      expect(row.width, width);
      for (final key in ['zone-left', 'zone-center', 'zone-right']) {
        final zone = tester.getRect(find.byKey(ValueKey(key)));
        expect(zone.left, greaterThanOrEqualTo(row.left - 0.01), reason: key);
        expect(zone.right, lessThanOrEqualTo(row.right + 0.01), reason: key);
      }
      // Narrow rows stack (UIC-14 step 1); wide ones keep one line.
      expect(find.byKey(const ValueKey('zones-stacked')), width < 800 ? findsOneWidget : findsNothing);
    });
  }

  testWidgets('UIC-14.c: a long title ends in a triple dot instead of overflowing at 320 px', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSuiteTheme(Brightness.light),
        home: Scaffold(body: header()),
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.text(_long));
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.getSize(find.text(_long)).width, lessThanOrEqualTo(320));
  });
}
