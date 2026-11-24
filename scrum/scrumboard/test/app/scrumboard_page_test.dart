import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/reload_scope.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/app/load_error.dart';
import 'package:scrumboard/src/app/scrumboard_page.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

final Messages _en = Messages.fromMaps('en', {
  'scbReload': 'Reload',
  'scbLoadFailed': 'Could not read the data: {reason}',
  'scbServerUnreachable': 'The ScrumBoard server cannot be reached: {reason}',
}, {});

/// DEF-01 ScrumBoard window sizes.
const _sizes = [Size(1920, 1080), Size(1366, 768), Size(1024, 640)];

Widget _app(Widget home, {Brightness brightness = Brightness.light}) => MaterialApp(
      theme: buildScrumTheme(brightness),
      home: MessagesScope(messages: _en, child: home),
    );

/// A pane that is taller and wider than any area, to check that it is bounded.
class _Tall extends StatelessWidget {
  const _Tall(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => ListView(
        key: ValueKey('list$label'),
        children: [for (var i = 0; i < 200; i++) Text('$label $i')],
      );
}

class _Probe extends StatelessWidget {
  const _Probe(this.seen);
  final List<int> seen;
  @override
  Widget build(BuildContext context) {
    seen.add(ReloadScope.generationOf(context));
    return const SizedBox.shrink();
  }
}

void main() {
  Future<void> size(WidgetTester t, Size s) async {
    t.view.physicalSize = s;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }

  testWidgets('SCB-15.a three rows share the height 40/20/40 and the page does not scroll', (t) async {
    await size(t, _sizes[1]);
    await t.pumpWidget(_app(const ScrumBoardPage(board: _Tall('b'), features: _Tall('f'))));
    final top = t.getSize(find.byKey(const ValueKey('scbRowTop')));
    final mid = t.getSize(find.byKey(const ValueKey('scbRowMiddle')));
    final bottom = t.getSize(find.byKey(const ValueKey('scbRowBottom')));
    expect(mid.height / top.height, closeTo(0.5, 0.05));
    expect(bottom.height / top.height, closeTo(1, 0.05));
    final f = t.getSize(find.byKey(const ValueKey('scbColumnFeatures')));
    final i = t.getSize(find.byKey(const ValueKey('scbColumnIssues')));
    final q = t.getSize(find.byKey(const ValueKey('scbColumnQuestions')));
    expect(f.width, closeTo(i.width, 0.01));
    expect(q.width, closeTo(i.width, 0.01));
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('SCB-15.b each part scrolls on its own', (t) async {
    await size(t, _sizes[1]);
    await t.pumpWidget(_app(const ScrumBoardPage(board: _Tall('b'), features: _Tall('f'))));
    await t.drag(find.byKey(const ValueKey('listf')), const Offset(0, -300));
    await t.pump();
    expect(t.state<ScrollableState>(find.descendant(of: find.byKey(const ValueKey('listf')), matching: find.byType(Scrollable))).position.pixels, greaterThan(0));
    expect(t.state<ScrollableState>(find.descendant(of: find.byKey(const ValueKey('listb')), matching: find.byType(Scrollable))).position.pixels, 0);
  });

  for (final s in _sizes) {
    testWidgets('SCB-15.c nothing overflows at ${s.width.toInt()} x ${s.height.toInt()}', (t) async {
      await size(t, s);
      await t.pumpWidget(_app(const ScrumBoardPage(board: _Tall('b'), features: _Tall('f'))));
      expect(t.takeException(), isNull);
      for (final key in ['scbRowTop', 'scbRowMiddle', 'scbRowBottom']) {
        final r = t.getRect(find.byKey(ValueKey(key)));
        expect(r.bottom, lessThanOrEqualTo(s.height));
        expect(r.right, lessThanOrEqualTo(s.width));
      }
    });
  }

  for (final b in Brightness.values) {
    testWidgets('SCB-01.g the page colors come from the theme in ${b.name}', (t) async {
      await size(t, _sizes[1]);
      await t.pumpWidget(_app(const ScrumBoardPage(board: _Tall('b'), features: _Tall('f')), brightness: b));
      final scheme = buildScrumTheme(b).colorScheme;
      final box = t.widget<DecoratedBox>(find.descendant(of: find.byKey(const ValueKey('scbRowMiddle')), matching: find.byType(DecoratedBox)).first);
      expect((box.decoration as BoxDecoration).color, scheme.surfaceContainerLow);
      expect(t.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, isNull);
      expect(Theme.of(t.element(find.byType(Scaffold))).scaffoldBackgroundColor, scheme.surface);
    });
  }

  testWidgets('SCB-01.c Reload makes every pane read again', (t) async {
    await size(t, _sizes[1]);
    final seen = <int>[];
    await t.pumpWidget(_app(ScrumBoardPage(board: _Probe(seen), features: const SizedBox.shrink())));
    expect(seen.last, 0);
    await t.tap(find.text('Reload'));
    await t.pump();
    expect(seen.last, 1);
    await t.tap(find.text('Reload'));
    await t.pump();
    expect(seen.last, 2);
  });

  testWidgets('SCB-01.f a failed load shows msg:scbLoadFailed with the reason', (t) async {
    await t.pumpWidget(_app(const Scaffold(body: LoadErrorMessage(error: ScrumBoardApiException('no sprint file', statusCode: 500)))));
    expect(find.text('Could not read the data: no sprint file'), findsOneWidget);
  });

  testWidgets('SCB-13.h an unreachable server shows msg:scbServerUnreachable', (t) async {
    await t.pumpWidget(_app(const Scaffold(body: LoadErrorMessage(error: ScrumBoardUnreachableException('connection refused')))));
    expect(find.text('The ScrumBoard server cannot be reached: connection refused'), findsOneWidget);
  });

  test('SCB-01.d no widget in lib/src shows a string literal', () {
    final literal = RegExp(r'''Text(?:\.rich)?\(\s*(?:const\s+)?['"]''');
    final hits = <String>[];
    for (final f in Directory('lib/src').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      if (literal.hasMatch(f.readAsStringSync())) hits.add(f.path);
    }
    expect(hits, isEmpty);
  });
}
