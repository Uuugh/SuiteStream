import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/ui/resize_bar.dart';

void main() {
  testWidgets('the resize handle keeps whole units for drag and keyboard', (
    tester,
  ) async {
    var value = 2;
    var expanded = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ResizeBar(
              value: value,
              minimum: 1,
              unitExtent: 20,
              expanded: expanded,
              sliderLabel: 'Stretch calendar',
              collapseLabel: 'Collapse calendar',
              expandLabel: 'Expand calendar',
              onChanged: (next) => setState(() => value = next),
              onToggle: () => setState(() {
                value = expanded ? 1 : 4;
                expanded = !expanded;
              }),
            ),
          ),
        ),
      ),
    );

    final handle = find.bySemanticsLabel('Stretch calendar');
    expect(handle, findsOneWidget);
    final data = tester.getSemantics(handle).getSemanticsData();
    expect(data.value, '2');
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);

    await tester.drag(handle, const Offset(0, 39));
    await tester.pump();
    expect(value, 4);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(value, 3);

    await tester.tap(find.byTooltip('Collapse calendar'));
    await tester.pump();
    expect(value, 1);
    expect(find.byTooltip('Expand calendar'), findsOneWidget);
    expect(
      tester
          .getSemantics(handle)
          .getSemanticsData()
          .hasAction(SemanticsAction.decrease),
      isFalse,
    );
  });
}
