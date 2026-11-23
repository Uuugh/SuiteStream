import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/calendar/calendar_defaults.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/ui/cancel_save_pair.dart';

Widget _host(
  List<String> log, {
  bool reduced = false,
  String save = 'Save',
  String cancel = 'Cancel',
  Duration? time,
  bool saveEnabled = true,
  Duration? word = const Duration(seconds: 3),
}) {
  Widget pair = CancelSavePair(
    cancelKey: const ValueKey('c'),
    saveKey: const ValueKey('s'),
    cancelLabel: cancel,
    saveLabel: save,
    saveEnabled: saveEnabled,
    onCancel: () => log.add('cancel'),
    onSave: () => log.add('save'),
  );
  if (word != null) pair = SuiteStatusWordScope(duration: word, child: pair);
  if (time != null) pair = SuiteAnimationScope(duration: time, child: pair);
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: child!,
    ),
    home: Scaffold(body: Center(child: pair)),
  );
}

const _cover = ValueKey('pair-word');

double _coverWidth(WidgetTester t) => t.getSize(find.byKey(_cover)).width;
double _pairInner(WidgetTester t) => t.getSize(find.byType(CancelSavePair)).width - 2; // border
Color _coverColor(WidgetTester t) => t.widget<ColoredBox>(find.byKey(_cover)).color;

void main() {
  _statusWordTests();
  // These tests exercise the hold itself: undo the suite-wide "no hold" default.
  setUp(() => CancelSavePair.debugHold = null);
  tearDown(() => CancelSavePair.debugHold = Duration.zero);

  test('one animation time, 0.5 s by default; the word time is 1 s by default (DEF-01)', () {
    expect(defaultAnimationDuration, const Duration(milliseconds: 500));
    expect(defaultStatusWordTime, const Duration(seconds: 1));
  });

  testWidgets('Save slides from the right to cover the pair, then holds Saved and calls back', (t) async {
    final log = <String>[];
    await t.pumpWidget(_host(log));
    expect(find.text('Saved'), findsNothing);
    await t.tap(find.byKey(const ValueKey('s')));
    await t.pump();
    expect(find.text('Saved'), findsOneWidget);
    final full = _pairInner(t);
    expect(_coverWidth(t), closeTo(full / 2, 0.5));
    final right = t.getBottomRight(find.byKey(_cover)).dx;
    await t.pump(const Duration(milliseconds: 250));
    final mid = _coverWidth(t);
    expect(mid, greaterThan(full / 2 + 1));
    expect(mid, lessThan(full - 1));
    expect(t.getBottomRight(find.byKey(_cover)).dx, closeTo(right, 0.5)); // anchored right
    await t.pump(const Duration(milliseconds: 250));
    expect(_coverWidth(t), closeTo(full, 0.5));
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Saved'), findsOneWidget);
    expect(log, isEmpty);
    await t.pump(const Duration(milliseconds: 480));
    expect(log, isEmpty);
    await t.pump(const Duration(milliseconds: 20));
    expect(log, ['save']);
    await t.pump();
    expect(find.text('Saved'), findsNothing);
    expect(find.byKey(_cover), findsNothing);
  });

  testWidgets('Cancel slides from the left and reads Cancelled', (t) async {
    final log = <String>[];
    await t.pumpWidget(_host(log));
    await t.tap(find.byKey(const ValueKey('c')));
    await t.pump();
    final left = t.getTopLeft(find.byKey(_cover)).dx;
    await t.pump(const Duration(milliseconds: 250));
    expect(t.getTopLeft(find.byKey(_cover)).dx, closeTo(left, 0.5)); // anchored left
    expect(_coverWidth(t), greaterThan(_pairInner(t) / 2 + 1));
    await t.pump(const Duration(milliseconds: 250));
    expect(find.text('Cancelled'), findsOneWidget);
    expect(_coverWidth(t), closeTo(_pairInner(t), 0.5));
    expect(log, isEmpty);
    await t.pump(const Duration(seconds: 2, milliseconds: 501));
    expect(log, ['cancel']);
  });

  testWidgets('the cover pulses gently once it covers the pair', (t) async {
    await t.pumpWidget(_host([]));
    await t.tap(find.byKey(const ValueKey('s')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    final rest = _coverColor(t);
    await t.pump(const Duration(milliseconds: 250)); // the pulse starts
    await t.pump(const Duration(milliseconds: 250));
    final pulsing = _coverColor(t);
    expect(pulsing, isNot(rest));
    expect(_coverWidth(t), closeTo(_pairInner(t), 0.5)); // stays full
    await t.pump(const Duration(milliseconds: 250));
    expect(_coverColor(t), isNot(pulsing));
  });

  testWidgets('the animation time comes from the setting', (t) async {
    final log = <String>[];
    await t.pumpWidget(_host(log, time: const Duration(seconds: 2)));
    await t.tap(find.byKey(const ValueKey('s')));
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    final full = _pairInner(t);
    expect(_coverWidth(t), lessThan(full - 1)); // still sliding after 1 s
    await t.pump(const Duration(seconds: 1));
    expect(_coverWidth(t), closeTo(full, 0.5));
    expect(log, isEmpty);
    // The hold (3 s) counts from the press.
    await t.pump(const Duration(seconds: 1, milliseconds: 1));
    expect(log, ['save']);
  });

  testWidgets('a shorter time slides faster', (t) async {
    await t.pumpWidget(_host([], time: const Duration(milliseconds: 100)));
    await t.tap(find.byKey(const ValueKey('s')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(_coverWidth(t), closeTo(_pairInner(t), 0.5));
  });

  testWidgets('a second press during the hold is ignored', (t) async {
    final log = <String>[];
    await t.pumpWidget(_host(log));
    await t.tap(find.byKey(const ValueKey('s')));
    await t.pump(const Duration(seconds: 1));
    await t.tap(find.byKey(const ValueKey('c')), warnIfMissed: false);
    await t.pump(const Duration(seconds: 3));
    expect(log, ['save']);
  });

  testWidgets('reduced motion or 0 seconds: covers at once, same hold, no pulse', (t) async {
    for (final reduced in [true, false]) {
      final log = <String>[];
      await t.pumpWidget(_host(log, reduced: reduced, time: reduced ? null : Duration.zero));
      await t.tap(find.byKey(const ValueKey('s')));
      await t.pump();
      expect(_coverWidth(t), closeTo(_pairInner(t), 0.5));
      final color = _coverColor(t);
      await t.pump(const Duration(milliseconds: 250));
      expect(_coverColor(t), color);
      await t.pump(const Duration(seconds: 2));
      expect(log, isEmpty);
      await t.pump(const Duration(seconds: 1, milliseconds: 1));
      expect(log, ['save']);
      await t.pump();
      expect(find.byKey(_cover), findsNothing);
    }
  });

  testWidgets('the idle Save pulse follows the animation time', (t) async {
    Future<Color?> sample(Duration time) async {
      await t.pumpWidget(_host([], time: time, saveEnabled: false));
      await t.pumpWidget(_host([], time: time, saveEnabled: true));
      await t.pump(time); // one animation time = the pulse's peak
      final m = t.widget<Material>(
        find.descendant(of: find.byKey(const ValueKey('s')), matching: find.byType(Material)).first,
      );
      return m.color;
    }

    final fast = await sample(const Duration(milliseconds: 200));
    final slow = await sample(const Duration(seconds: 2));
    expect(fast, slow); // the same phase of the pulse, reached in proportion to the time
  });

  testWidgets('No | Yes and Print show their own label', (t) async {
    final log = <String>[];
    await t.pumpWidget(_host(log, save: 'Yes', cancel: 'No'));
    await t.tap(find.byKey(const ValueKey('s')));
    await t.pump();
    expect(find.text('Yes'), findsNWidgets(2));
    expect(find.text('Saved'), findsNothing);
    await t.pump(const Duration(seconds: 3, milliseconds: 1));
    expect(log, ['save']);
  });

  testWidgets('debugHold test hook shortens the hold', (t) async {
    CancelSavePair.debugHold = const Duration(milliseconds: 10);
    addTearDown(() => CancelSavePair.debugHold = null);
    final log = <String>[];
    await t.pumpWidget(_host(log));
    await t.tap(find.byKey(const ValueKey('s')));
    await t.pump(const Duration(milliseconds: 11));
    expect(log, ['save']);
  });
}

void _statusWordTests() {
  testWidgets('UIC-27.a, SET-03.m: with no scope the word is held 1 s from the press', (t) async {
    final log = <String>[];
    await t.pumpWidget(_host(log, word: null, time: const Duration(milliseconds: 100)));
    await t.tap(find.byKey(const ValueKey('s')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 900));
    expect(log, isEmpty);
    await t.pump(const Duration(milliseconds: 101));
    expect(log, ['save']);
  });

  testWidgets('UIC-27.a, SET-03.m: the Status word scope changes the hold; holdDuration still wins', (t) async {
    final log = <String>[];
    await t.pumpWidget(_host(log, word: const Duration(seconds: 5), time: const Duration(milliseconds: 100)));
    await t.tap(find.byKey(const ValueKey('s')));
    await t.pump();
    await t.pump(const Duration(seconds: 4, milliseconds: 900));
    expect(log, isEmpty);
    await t.pump(const Duration(milliseconds: 101));
    expect(log, ['save']);

    final log2 = <String>[];
    await t.pumpWidget(
      SuiteStatusWordScope(
        duration: const Duration(seconds: 5),
        child: MaterialApp(
          home: Scaffold(
            body: CancelSavePair(
              saveKey: const ValueKey('s2'),
              cancelLabel: 'Cancel',
              saveLabel: 'Save',
              holdDuration: const Duration(milliseconds: 600),
              onCancel: () {},
              onSave: () => log2.add('save'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.byKey(const ValueKey('s2')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 601));
    expect(log2, ['save']);
  });
}
