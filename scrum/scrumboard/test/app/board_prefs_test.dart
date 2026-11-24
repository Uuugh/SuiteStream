import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/main.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/app/board_prefs.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// A store that cannot be read or written (SCB-24: falls back to defaults).
class _BrokenPrefs implements BoardPrefsStore {
  @override
  ({ThemeMode? theme, int? zoom}) load() => throw StateError('no storage');

  @override
  void save({ThemeMode? theme, int? zoom}) => throw StateError('no storage');
}

const _reqs = [
  Requirement(id: 'AAA-01', status: 'backlog', statement: 'Parent', feature: 'aaa', file: 'requirements/aaa.md'),
  Requirement(id: 'AAA-01.a', status: 'backlog', statement: 'Child', feature: 'aaa', file: 'requirements/aaa.md'),
  Requirement(id: 'BBB-01', status: 'backlog', statement: 'Other', feature: 'bbb', file: 'requirements/bbb.md'),
];

bool _has(String id) => find.byKey(ValueKey('scb-row-$id')).evaluate().isNotEmpty;

void main() {
  late Messages m;

  Future<void> start(WidgetTester t, {BoardPrefsStore? prefs, bool withPrefs = true}) async {
    t.view.physicalSize = const Size(1366, 768);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    m = (await t.runAsync(() => Messages.load('en')))!;
    // A new app each time: an empty tree first, so no state carries over.
    await t.pumpWidget(const SizedBox.shrink());
    await t.pumpWidget(withPrefs
        ? ScrumBoardApp(api: FakeScrumBoardApi(requirementList: _reqs), messages: m, prefs: prefs)
        : ScrumBoardApp(api: FakeScrumBoardApi(requirementList: _reqs), messages: m));
    await t.pumpAndSettle();
  }

  Brightness brightness(WidgetTester t) => Theme.of(t.element(find.byType(Scaffold))).brightness;
  double scale(WidgetTester t) => MediaQuery.of(t.element(find.byType(Scaffold))).textScaler.scale(100);

  testWidgets('SCB-24 the theme and the zoom survive a new app on the same store', (t) async {
    final prefs = MemoryBoardPrefs();
    await start(t, prefs: prefs);
    expect(brightness(t), Brightness.light);
    for (final k in ['scbTheme', 'scbZoomIn', 'scbZoomIn']) {
      await t.tap(find.byKey(ValueKey(k)));
      await t.pumpAndSettle();
    }
    expect(brightness(t), Brightness.dark);
    expect(scale(t), closeTo(120, 0.01));
    expect(prefs.load(), (theme: ThemeMode.dark, zoom: 120));

    await start(t, prefs: prefs);
    expect(brightness(t), Brightness.dark);
    expect(scale(t), closeTo(120, 0.01));
  });

  testWidgets('SCB-24 the outline state and the filters are not kept', (t) async {
    final prefs = MemoryBoardPrefs();
    await start(t, prefs: prefs);
    expect(_has('AAA-01.a'), isFalse);
    await t.tap(find.byKey(const ValueKey('scb-expand-all')));
    await t.pumpAndSettle();
    expect(_has('AAA-01.a'), isTrue);
    await t.tap(find.descendant(
      of: find.byKey(const ValueKey('scbColumnFeatures')),
      matching: find.byKey(ValueKey('scb-filter-button-${m('scbFilterFeature')}')),
    ));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('scb-filter-bbb')));
    await t.pumpAndSettle();
    expect(_has('BBB-01'), isFalse);

    await start(t, prefs: prefs);
    expect(_has('AAA-01.a'), isFalse, reason: 'the outline opens collapsed again');
    expect(_has('BBB-01'), isTrue, reason: 'the filter is not kept');
  });

  testWidgets('SCB-24 a store that cannot be read gives the default theme and zoom', (t) async {
    await start(t, prefs: _BrokenPrefs());
    expect(brightness(t), Brightness.light);
    expect(scale(t), closeTo(scrumZoomDefault, 0.01));
    await t.tap(find.byKey(const ValueKey('scbTheme')));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(brightness(t), Brightness.dark);
  });

  for (final bad in [70, 170, 115]) {
    testWidgets('SCB-24 a stored zoom of $bad (out of range or off a step) gives the default', (t) async {
      await start(t, prefs: MemoryBoardPrefs(zoom: bad));
      expect(scale(t), closeTo(scrumZoomDefault, 0.01));
    });
  }

  test('SCB-24 checkedZoom and the theme names', () {
    expect(checkedZoom(80), 80);
    expect(checkedZoom(160), 160);
    expect(checkedZoom(130), 130);
    expect(checkedZoom(79), isNull);
    expect(checkedZoom(161), isNull);
    expect(checkedZoom(105), isNull);
    expect(checkedZoom(null), isNull);
    expect(themeFromName('dark'), ThemeMode.dark);
    expect(themeFromName('light'), ThemeMode.light);
    expect(themeFromName('blue'), isNull);
    expect(themeName(ThemeMode.dark), 'dark');
  });

  testWidgets('SCB-24 an app with no store starts with the default theme and zoom (memory off the web)', (t) async {
    await start(t, withPrefs: false);
    expect(brightness(t), Brightness.light);
    expect(scale(t), closeTo(scrumZoomDefault, 0.01));
    expect(defaultBoardPrefs(), isA<MemoryBoardPrefs>());
  });
}
