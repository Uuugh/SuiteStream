import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/reload_scope.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/app/load_error.dart';
import 'package:scrumboard/src/features/requirement_drag_data.dart';
import 'package:scrumboard/src/app/scrumboard_page.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

final Messages _en = Messages.fromMaps('en', {
  'scbZoomOut': 'Zoom out',
  'scbZoomIn': 'Zoom in',
  'scbTheme': 'Theme',
  'scbRetire': 'Retire',
  'scbAdd': 'Add',
  'scbMoveRefused': 'Move refused: {reason}',
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
    await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const _Tall('b'), features: const _Tall('f'))));
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
    await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const _Tall('b'), features: const _Tall('f'))));
    await t.drag(find.byKey(const ValueKey('listf')), const Offset(0, -300));
    await t.pump();
    expect(t.state<ScrollableState>(find.descendant(of: find.byKey(const ValueKey('listf')), matching: find.byType(Scrollable))).position.pixels, greaterThan(0));
    expect(t.state<ScrollableState>(find.descendant(of: find.byKey(const ValueKey('listb')), matching: find.byType(Scrollable))).position.pixels, 0);
  });

  for (final s in _sizes) {
    testWidgets('SCB-15.c nothing overflows at ${s.width.toInt()} x ${s.height.toInt()}', (t) async {
      await size(t, s);
      await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const _Tall('b'), features: const _Tall('f'))));
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
      await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const _Tall('b'), features: const _Tall('f')), brightness: b));
      final scheme = buildScrumTheme(b).colorScheme;
      final box = t.widget<DecoratedBox>(find.descendant(of: find.byKey(const ValueKey('scbRowMiddle')), matching: find.byType(DecoratedBox)).first);
      expect((box.decoration as BoxDecoration).color, scheme.surfaceContainerLow);
      expect(t.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, isNull);
      expect(Theme.of(t.element(find.byType(Scaffold))).scaffoldBackgroundColor, scheme.surface);
    });
  }

  const poll = Duration(milliseconds: 100);

  testWidgets('SCB-01.c SCB-22 a changed stamp makes every pane read again; no Reload control; errors ignored', (t) async {
    await size(t, _sizes[1]);
    final api = FakeScrumBoardApi();
    final seen = <int>[];
    await t.pumpWidget(_app(ScrumBoardPage(api: api, pollInterval: poll, board: _Probe(seen), features: const SizedBox.shrink())));
    expect(find.byKey(const ValueKey('scbReload')), findsNothing);
    await t.pump(poll);
    await t.pump(poll);
    expect(seen.last, 0);
    api.bump();
    await t.pump(poll);
    await t.pump();
    expect(seen.last, 1);
    api.failWith = const ScrumBoardUnreachableException('down');
    await t.pump(poll);
    await t.pump(poll);
    expect(t.takeException(), isNull);
    expect(seen.last, 1);
  });

  testWidgets('SCB-22 the page asks for the stamp at the interval', (t) async {
    await size(t, _sizes[1]);
    final api = FakeScrumBoardApi();
    await t.pumpWidget(_app(ScrumBoardPage(api: api, pollInterval: poll, board: const SizedBox.shrink(), features: const SizedBox.shrink())));
    await t.pump(poll);
    await t.pump(poll);
    await t.pump(poll);
    // One baseline read at the start (PBI-107) and one per interval.
    expect(api.calls['changeStamp'], 4);
    expect(scrumPollInterval, const Duration(seconds: 2));
  });

  testWidgets('SCB-22 a change made before the first poll reloads the panes (PBI-107)', (t) async {
    await size(t, _sizes[1]);
    final api = FakeScrumBoardApi();
    final seen = <int>[];
    await t.pumpWidget(_app(ScrumBoardPage(api: api, pollInterval: poll, board: _Probe(seen), features: const SizedBox.shrink())));
    await t.pump();
    expect(api.calls['changeStamp'], 1);
    expect(seen.last, 0);
    api.bump();
    await t.pump(poll);
    await t.pump();
    expect(seen.last, 1);
  });

  testWidgets('SCB-15.d SCB-20 the header right zone holds zoom, theme, bin and a disabled add, in that order', (t) async {
    await size(t, _sizes[1]);
    await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const SizedBox.shrink(), features: const SizedBox.shrink(), onZoomChanged: (_) {}, onToggleTheme: () {})));
    final keys = ['scbZoomOut', 'scbZoomIn', 'scbTheme', 'scbRetire', 'scbAdd'];
    final xs = [for (final k in keys) t.getCenter(find.byKey(ValueKey(k))).dx];
    expect(xs, [...xs]..sort());
    expect(t.widget<IconButton>(find.byKey(const ValueKey('scbAdd'))).onPressed, isNull);
    expect(find.byType(BottomAppBar), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(t.getRect(find.byKey(const ValueKey('scbRowBottom'))).bottom, closeTo(_sizes[1].height - scrumPagePadding, 0.01));
  });

  testWidgets('SCB-20 the zoom is one icon whose left half is zoom out and right half zoom in', (t) async {
    await size(t, _sizes[1]);
    await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const SizedBox.shrink(), features: const SizedBox.shrink(), onZoomChanged: (_) {})));
    expect(find.byIcon(Icons.zoom_in), findsNothing);
    expect(find.byIcon(Icons.zoom_out), findsNothing);
    final icon = t.getRect(find.byKey(const ValueKey('scbZoom')));
    final out = t.getRect(find.byKey(const ValueKey('scbZoomOut')));
    final inn = t.getRect(find.byKey(const ValueKey('scbZoomIn')));
    expect(icon.width, scrumZoomIconWidth);
    expect(out.left, icon.left);
    expect(inn.right, icon.right);
    expect(out.right, closeTo(inn.left, 0.01));
    expect(find.byTooltip('Zoom out'), findsOneWidget);
    expect(find.byTooltip('Zoom in'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('scbZoom')), matching: find.byType(CustomPaint)), findsWidgets);
  });

  for (final b in Brightness.values) {
    testWidgets('SCB-20 SCB-15.c the zoom icon draws in ${b.name} with no overflow at every DEF-01 size', (t) async {
      for (final s in _sizes) {
        await size(t, s);
        await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const SizedBox.shrink(), features: const SizedBox.shrink(), zoomPercent: scrumZoomMax, onZoomChanged: (_) {}), brightness: b));
        expect(t.takeException(), isNull);
        expect(t.getRect(find.byKey(const ValueKey('scbZoom'))).right, lessThanOrEqualTo(s.width));
      }
    });
  }

  testWidgets('SCB-20.a the minus half zooms out one step and the plus half zooms in one step', (t) async {
    await size(t, _sizes[1]);
    final got = <int>[];
    await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const SizedBox.shrink(), features: const SizedBox.shrink(), zoomPercent: 120, onZoomChanged: got.add)));
    await t.tap(find.byKey(const ValueKey('scbZoomOut')));
    await t.tap(find.byKey(const ValueKey('scbZoomIn')));
    expect(got, [110, 130]);
  });

  testWidgets('SCB-20.a at 80 % the minus half is disabled and the plus half works', (t) async {
    await size(t, _sizes[1]);
    final got = <int>[];
    await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const SizedBox.shrink(), features: const SizedBox.shrink(), zoomPercent: scrumZoomMin, onZoomChanged: got.add)));
    expect(t.widget<InkWell>(find.byKey(const ValueKey('scbZoomOut'))).onTap, isNull);
    await t.tap(find.byKey(const ValueKey('scbZoomOut')));
    await t.tap(find.byKey(const ValueKey('scbZoomIn')));
    expect(got, [90]);
  });

  testWidgets('SCB-20.a at 160 % the plus half is disabled and the minus half works', (t) async {
    await size(t, _sizes[1]);
    final got = <int>[];
    await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const SizedBox.shrink(), features: const SizedBox.shrink(), zoomPercent: scrumZoomMax, onZoomChanged: got.add)));
    expect(t.widget<InkWell>(find.byKey(const ValueKey('scbZoomIn'))).onTap, isNull);
    await t.tap(find.byKey(const ValueKey('scbZoomIn')));
    await t.tap(find.byKey(const ValueKey('scbZoomOut')));
    expect(got, [150]);
  });

  testWidgets('SCB-20.a zoom steps by 10 % between 80 % and 160 % and the half is disabled at a limit', (t) async {
    await size(t, _sizes[1]);
    var zoom = 100;
    late StateSetter set;
    await t.pumpWidget(_app(StatefulBuilder(builder: (c, s) {
      set = s;
      return ScrumBoardPage(
        api: FakeScrumBoardApi(),
        board: const SizedBox.shrink(),
        features: const SizedBox.shrink(),
        zoomPercent: zoom,
        onZoomChanged: (z) => set(() => zoom = z),
      );
    })));
    bool enabled(String k) => t.widget<InkWell>(find.byKey(ValueKey(k))).onTap != null;
    await t.tap(find.byKey(const ValueKey('scbZoomOut')));
    await t.pump();
    expect(zoom, 90);
    await t.tap(find.byKey(const ValueKey('scbZoomOut')));
    await t.pump();
    expect(zoom, 80);
    expect(enabled('scbZoomOut'), isFalse);
    expect(enabled('scbZoomIn'), isTrue);
    for (var i = 0; i < 8; i++) {
      await t.tap(find.byKey(const ValueKey('scbZoomIn')));
      await t.pump();
    }
    expect(zoom, 160);
    expect(enabled('scbZoomIn'), isFalse);
  });

  testWidgets('SCB-20 the theme button calls back', (t) async {
    await size(t, _sizes[1]);
    var n = 0;
    await t.pumpWidget(_app(ScrumBoardPage(api: FakeScrumBoardApi(), board: const SizedBox.shrink(), features: const SizedBox.shrink(), onToggleTheme: () => n++)));
    await t.tap(find.byKey(const ValueKey('scbTheme')));
    expect(n, 1);
  });

  Future<void> dragToBin(WidgetTester t, FakeScrumBoardApi api, String id) async {
    await t.pumpWidget(_app(ScrumBoardPage(
      api: api,
      board: Center(
        child: Draggable<RequirementDragData>(
          data: RequirementDragData(id, 'backlog'),
          feedback: const SizedBox(width: 20, height: 20),
          child: const SizedBox(width: 80, height: 30, child: ColoredBox(key: ValueKey('src'), color: Colors.blue)),
        ),
      ),
      features: const SizedBox.shrink(),
    )));
    final g = await t.startGesture(t.getCenter(find.byKey(const ValueKey('src'))));
    await g.moveBy(const Offset(0, 40));
    await t.pump();
    final to = t.getCenter(find.byKey(const ValueKey('scbRetire')));
    final from = t.getCenter(find.byKey(const ValueKey('src')));
    for (var i = 1; i <= 10; i++) {
      await g.moveTo(from + (to - from) * (i / 10));
      await t.pump();
    }
    await t.pump();
    await t.pump();
    await g.up();
    await t.pump();
    await t.pump();
  }

  testWidgets('SCB-19 dropping a requirement on the bin retires it', (t) async {
    await size(t, _sizes[1]);
    final api = FakeScrumBoardApi(requirementList: const [
      Requirement(id: 'AAA-01', status: 'backlog', statement: 's', feature: 'aaa', file: 'requirements/aaa.md'),
    ]);
    await dragToBin(t, api, 'AAA-01');
    expect(api.retireCalls, ['AAA-01']);
    expect(find.textContaining('Move refused'), findsNothing);
  });

  testWidgets('SCB-19 a refused retirement shows msg:scbMoveRefused', (t) async {
    await size(t, _sizes[1]);
    final api = FakeScrumBoardApi();
    await dragToBin(t, api, 'NOPE-01');
    expect(api.retireCalls, ['NOPE-01']);
    expect(find.textContaining('Move refused: '), findsOneWidget);
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
