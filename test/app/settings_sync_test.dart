import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suitestream/src/app/settings_sync.dart';

final _base = Uri.parse('https://suite.example');
const _keys = {...settingsSyncBaseKeys, 'theme.popupShadow'};

Future<SettingsSync> _make(
  MockClient? client,
  Map<String, Object> initial,
) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return SettingsSync(
    prefs: prefs,
    keys: _keys,
    client: client,
    baseUrl: client == null ? null : _base,
    debounce: Duration.zero,
  );
}

http.Response _json(int status, Object body) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  test(
    'PBI-037 pull applies server values for allowlisted keys only',
    () async {
      final client = MockClient(
        (r) async => r.url.path == '/api/me'
            ? _json(200, {'name': 'Rich'})
            : _json(200, {
                'view.longPressMs': 400,
                'view.mode': 'day',
                'theme.popupShadow': 150,
                'event.defaultLengthUnit': 'hours',
              }),
      );
      final sync = await _make(client, {
        'view.longPressMs': 200,
        'view.mode': 'week',
        'theme.popupShadow': 100.0,
      });
      await sync.pull();
      expect(sync.prefs.getInt('view.longPressMs'), 400);
      expect(sync.prefs.getDouble('theme.popupShadow'), 150.0);
      expect(sync.prefs.getString('event.defaultLengthUnit'), 'hours');
      expect(
        sync.prefs.getString('view.mode'),
        'week',
        reason: 'header keys are never applied',
      );
      expect(sync.state.value, SyncState.ok);
      expect(sync.userName, 'Rich');
    },
  );

  test(
    'PBI-037 push sends only allowlisted keys and never the header keys',
    () async {
      String? body;
      final client = MockClient((r) async {
        body = r.body;
        return _json(200, {});
      });
      final sync = await _make(client, {
        'view.longPressMs': 300,
        'view.mode': 'day',
        'view.zone': 'UTC',
        'view.hourLines': 3,
        'filter.hiddenCalendars': ['a'],
        'events.v1': '[]',
      });
      sync.push();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(jsonDecode(body!), {'view.longPressMs': 300});
      expect(sync.pending, isFalse);
      expect(sync.state.value, SyncState.ok);
    },
  );

  test('PBI-037 a 401 keeps the values and the next push retries', () async {
    var status = 401;
    var calls = 0;
    final client = MockClient((r) async {
      calls++;
      return _json(status, <String, Object>{});
    });
    final sync = await _make(client, {'view.longPressMs': 300});
    sync.push();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(sync.state.value, SyncState.signedOut);
    expect(sync.pending, isTrue);
    expect(sync.prefs.getInt('view.longPressMs'), 300);
    status = 200;
    sync.push();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(calls, 2);
    expect(sync.state.value, SyncState.ok);
    expect(sync.pending, isFalse);
  });

  test(
    'PBI-037 a network failure keeps the values, and pull then sends the device copy',
    () async {
      var down = true;
      final puts = <String>[];
      final client = MockClient((r) async {
        if (down) throw http.ClientException('offline');
        if (r.method == 'PUT') puts.add(r.body);
        return _json(200, {'view.longPressMs': 999});
      });
      final sync = await _make(client, {'view.longPressMs': 300});
      sync.push();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(sync.state.value, SyncState.offline);
      expect(sync.pending, isTrue);
      down = false;
      await sync.pull();
      expect(
        sync.prefs.getInt('view.longPressMs'),
        300,
        reason: 'unsent device changes win over the server',
      );
      expect(puts, hasLength(1));
      expect(sync.pending, isFalse);
    },
  );

  test('PBI-037 not configured makes no request', () async {
    final sync = await _make(null, {'view.longPressMs': 300});
    expect(sync.state.value, SyncState.notConfigured);
    await sync.pull();
    sync.push();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(sync.state.value, SyncState.notConfigured);
    expect(sync.pending, isFalse);
  });

  test('PBI-037 the sign-in address returns to the current page', () async {
    final sync = await _make(MockClient((r) async => _json(200, {})), {});
    expect(
      sync.signInUrl.toString(),
      'https://suite.example/auth/login?next=%2F',
    );
  });
}
