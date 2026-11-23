import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/ui/overflow_info.dart';
import 'package:suitestream/src/ui/popup_motion.dart';
import 'package:suitestream/src/ui/suite_dropdown.dart';

/// UIC-47: menus and popups built by an overlay use the one transition.
Widget host(Widget child, {Duration? time, bool reduced = false}) => MaterialApp(
  theme: buildSuiteTheme(Brightness.light),
  builder: (context, c) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
    child: time == null ? c! : SuiteAnimationScope(duration: time, child: c!),
  ),
  home: Scaffold(body: Align(alignment: Alignment.topLeft, child: child)),
);

double opacityOf(WidgetTester tester, Finder f) =>
    tester.widget<Opacity>(find.ancestor(of: f, matching: find.byType(Opacity)).first).opacity;

Widget dropdown() => SuiteDropdown<int>(
  icon: Icons.filter_list,
  items: const [DropdownItem(value: 1, label: 'One')],
  selected: const {},
  onChanged: (_) {},
);

void main() {
  testWidgets('suitePopupAnimationStyle follows the animation time and reduced motion', (tester) async {
    late AnimationStyle style;
    Widget probe({Duration? time, bool reduced = false}) => host(
      Builder(
        builder: (context) {
          style = suitePopupAnimationStyle(context);
          return const SizedBox();
        },
      ),
      time: time,
      reduced: reduced,
    );
    await tester.pumpWidget(probe(time: const Duration(milliseconds: 300)));
    expect(style.duration, const Duration(milliseconds: 300));
    expect(style.reverseDuration, const Duration(milliseconds: 300));
    await tester.pumpWidget(probe(reduced: true));
    expect(style, AnimationStyle.noAnimation);
    await tester.pumpWidget(probe(time: Duration.zero));
    expect(style, AnimationStyle.noAnimation);
  });

  testWidgets('SuitePopupMotion fades in, then runs back and reports closed', (tester) async {
    var closed = 0;
    Widget build(bool open) => host(
      SuitePopupMotion(
        open: open,
        onClosed: () => closed++,
        child: const SizedBox(key: ValueKey('body'), width: 50, height: 50),
      ),
      time: const Duration(milliseconds: 400),
    );
    await tester.pumpWidget(build(true));
    final body = find.byKey(const ValueKey('body'));
    expect(opacityOf(tester, body), 0);
    await tester.pump(const Duration(milliseconds: 200));
    final mid = opacityOf(tester, body);
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(opacityOf(tester, body), 1);

    await tester.pumpWidget(build(false));
    await tester.pump(const Duration(milliseconds: 200));
    expect(opacityOf(tester, body), lessThan(1));
    expect(closed, 0);
    await tester.pump(const Duration(milliseconds: 300));
    expect(closed, 1);
  });

  testWidgets('SuitePopupMotion with a zero time is shown and closed at once', (tester) async {
    var closed = 0;
    Widget build(bool open) => host(
      SuitePopupMotion(
        open: open,
        onClosed: () => closed++,
        child: const SizedBox(key: ValueKey('body'), width: 50, height: 50),
      ),
      time: Duration.zero,
    );
    await tester.pumpWidget(build(true));
    expect(opacityOf(tester, find.byKey(const ValueKey('body'))), 1);
    await tester.pumpWidget(build(false));
    expect(closed, 1);
  });

  testWidgets('the dropdown menu opens and closes with the transition', (tester) async {
    await tester.pumpWidget(host(dropdown(), time: const Duration(milliseconds: 400)));
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    final item = find.byKey(const ValueKey('dropdown-item-1'));
    expect(item, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    final mid = opacityOf(tester, item);
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(opacityOf(tester, item), 1);

    await tester.tap(item);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(item, findsOneWidget); // closing, not gone yet
    expect(opacityOf(tester, item), lessThan(1));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(item, findsNothing);
  });

  testWidgets('the dropdown menu closes at once with reduced motion', (tester) async {
    await tester.pumpWidget(host(dropdown(), reduced: true));
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    final item = find.byKey(const ValueKey('dropdown-item-1'));
    expect(opacityOf(tester, item), 1);
    await tester.tap(item);
    await tester.pump();
    expect(item, findsNothing);
  });

  testWidgets('the info popup opens with the transition', (tester) async {
    await tester.pumpWidget(
      host(const InfoPopoverButton(text: 'Hello popup'), time: const Duration(milliseconds: 400)),
    );
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final text = find.text('Hello popup');
    final mid = opacityOf(tester, text);
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));
    await tester.pumpAndSettle();
    expect(opacityOf(tester, text), 1);
  });
}
