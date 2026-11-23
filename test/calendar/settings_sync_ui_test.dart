import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/app/settings_sync.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/time/zones.dart';

import 'test_support.dart';

/// A sync that counts pushes and never touches a network.
class _FakeSync extends SettingsSync {
  _FakeSync(SharedPreferences prefs) : super(prefs: prefs, keys: const {});

  int pushes = 0;

  @override
  void push() => pushes++;

  @override
  Uri? get signInUrl => Uri.parse('https://example.test/auth/login?next=/');
}

Future<_FakeSync> _open(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final sync = _FakeSync(prefs);
  addTearDown(sync.dispose);
  const size = Size(900, 900);
  useWindow(tester, size);
  final c = makeController();
  await tester.pumpWidget(
    SettingsSyncScope(
      sync: sync,
      child: appFor(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => openSettingsDialog(context, c, prefs: prefs),
            child: const Text('open'),
          ),
        ),
        size: size,
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return sync;
}

void main() {
  setUpAll(initZones);

  testWidgets(
    'SET-15: Settings > General shows the sync state and a Sign in button only when signed out',
    (tester) async {
      final sync = await _open(tester);
      final state = find.byKey(const ValueKey('settings-sync-state'));
      final signIn = find.byKey(const ValueKey('settings-sync-sign-in'));
      final expected = {
        SyncState.notConfigured: 'Settings are kept on this device.',
        SyncState.signedOut:
            'Signed out. Settings are kept on this device until you sign in.',
        SyncState.syncing: 'Saving settings...',
        SyncState.ok: 'Settings are saved to your account.',
        SyncState.offline:
            'The server cannot be reached. Settings are kept on this device and sent again later.',
      };
      for (final entry in expected.entries) {
        sync.state.value = entry.key;
        await tester.pump();
        expect(
          tester.widget<Text>(state).data,
          entry.value,
          reason: '${entry.key}',
        );
        expect(
          signIn,
          entry.key == SyncState.signedOut ? findsOneWidget : findsNothing,
          reason: '${entry.key}',
        );
      }
      sync.userName = 'Rich';
      sync.state.value = SyncState.syncing;
      await tester.pump();
      sync.state.value = SyncState.ok;
      await tester.pump();
      expect(
        tester.widget<Text>(state).data,
        'Signed in as Rich Settings are saved to your account.',
      );
    },
  );

  testWidgets(
    'SET-15: a change in a pane and closing Settings each push the settings',
    (tester) async {
      final sync = await _open(tester);
      expect(sync.pushes, 0);
      await tester.tap(find.byKey(const ValueKey('settings-theme')));
      await tester.pumpAndSettle();
      expect(sync.pushes, 1, reason: 'leaving General pushes');
      await tester.enterText(
        find.byKey(const ValueKey('setting-popup-shadow')),
        '150',
      );
      await tester.pump();
      expect(sync.pushes, 2, reason: 'a valid typed value pushes');
      await tester.enterText(
        find.byKey(const ValueKey('setting-popup-shadow')),
        '900',
      );
      await tester.pump();
      expect(
        sync.pushes,
        2,
        reason: 'an invalid value changes nothing and pushes nothing',
      );
      await tester.tap(find.byKey(const ValueKey('setting-theme-reset')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('inline-confirm-yes')));
      await tester.pump();
      expect(sync.pushes, 3, reason: 'Reset pushes');
      await tester.tap(find.byKey(const ValueKey('settings-close')));
      await tester.pumpAndSettle();
      expect(sync.pushes, 4, reason: 'closing pushes');
    },
  );
}
