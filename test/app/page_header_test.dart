import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';

import '../calendar/test_support.dart';

void main() {
  testWidgets('UIC-45: the page header has a back button first in the left zone that calls onBack', (tester) async {
    useWindow(tester);
    var backs = 0;
    await tester.pumpWidget(appFor(Column(children: [
      PageHeader(title: const Text('Settings'), onBack: () => backs++, backTooltip: 'Back'),
    ])));
    final back = find.byKey(const ValueKey('header-back'));
    expect(back, findsOneWidget);
    expect(tester.getTopLeft(back).dx, lessThan(tester.getTopLeft(find.text('Settings')).dx));
    expect(find.byTooltip('Back'), findsOneWidget);
    await tester.tap(back);
    expect(backs, 1);
  });
}
