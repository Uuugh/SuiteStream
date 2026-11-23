import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/tokens.dart';
import 'package:suitestream/src/time/zones.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/ui/resize_bar.dart';

import 'test_support.dart';

Future<void> _open(WidgetTester tester, Size size) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  useWindow(tester, size);
  final c = makeController();
  await tester.pumpWidget(
    appFor(
      Builder(builder: (context) => TextButton(onPressed: () => openSettingsDialog(context, c, prefs: prefs), child: const Text('open'))),
      size: size,
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

const _top = ['settings-calendar', 'settings-sources', 'settingsFeeds', 'settingsRules', 'settingsTemplates', 'settingsHistory'];
const _bottom = ['settings-general', 'settings-theme', 'settings-admin'];

void main() {
  setUpAll(initZones);

  for (final width in [320.0, 400.0, 800.0]) {
    testWidgets('SET-01.e, SET-01.f, SET-01.g, SET-14, UIC-46: at $width px the menu order, the rule, no resize bar, Reset beside Close', (tester) async {
      await _open(tester, Size(width, 900));
      final wide = width >= 640;
      // SET-01.e: Calendar to History, then the rule, then General, Theme, Admin at the bottom.
      final rule = tester.getRect(find.byKey(const ValueKey('settings-menu-rule')));
      double pos(Rect r) => wide ? r.top : r.top * 10000 + r.left;
      for (final k in _top) {
        expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
        expect(tester.getRect(find.byKey(ValueKey(k))).bottom, lessThanOrEqualTo(rule.top + 0.5), reason: '$k above the rule');
      }
      for (final k in _bottom) {
        expect(tester.getRect(find.byKey(ValueKey(k))).top, greaterThanOrEqualTo(rule.bottom - 0.5), reason: '$k below the rule');
      }
      final order = [..._top, ..._bottom].map((k) => pos(tester.getRect(find.byKey(ValueKey(k))))).toList();
      expect(order, [...order]..sort());
      expect(tester.widget<Divider>(find.byKey(const ValueKey('settings-menu-rule'))).color, tester.element(find.byKey(const ValueKey('settings-menu-rule'))).tokens.line);
      if (wide) {
        // The three bottom pages sit at the bottom of the menu, below the long gap.
        final menuBottom = tester.getRect(find.byKey(const ValueKey('settings-admin'))).bottom;
        expect(menuBottom, greaterThan(tester.getRect(find.byKey(const ValueKey('settingsHistory'))).bottom + 100));
      }
      // SET-01.f: no resize bar.
      expect(find.byType(ResizeBar), findsNothing);
      expect(find.bySemanticsLabel('Stretch calendar'), findsNothing);
      // SET-01.g: Reset (on Theme) is on the same line as Close and has an icon.
      expect(find.byKey(const ValueKey('setting-theme-reset')), findsNothing);
      expect(tester.takeException(), isNull, reason: 'menu');
      await tester.ensureVisible(find.byKey(const ValueKey('settings-theme')));
      await tester.tap(find.byKey(const ValueKey('settings-theme')));
      await tester.pumpAndSettle();
      final reset = find.byKey(const ValueKey('setting-theme-reset'));
      expect(reset, findsOneWidget);
      final close = find.byKey(const ValueKey('settings-close'));
      expect(tester.getCenter(reset).dy, closeTo(tester.getCenter(close).dy, 1));
      expect(tester.getRect(reset).right, lessThan(tester.getRect(close).left));
      expect(find.descendant(of: reset, matching: find.byType(Icon)), findsOneWidget);
      expect(tester.getRect(reset).height, suiteControlHeight);
      // Leaving Theme takes Reset away; Close stays.
      expect(tester.takeException(), isNull, reason: 'theme');
      await tester.ensureVisible(find.byKey(const ValueKey('settings-admin')));
      await tester.tap(find.byKey(const ValueKey('settings-admin')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('setting-theme-reset')), findsNothing);
      expect(close, findsOneWidget);
      expect(tester.takeException(), isNull);
      // Nothing is wider than the window.
      expect(tester.getRect(close).right, lessThanOrEqualTo(width));
    });
  }
}
