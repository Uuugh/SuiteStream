import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// PBI-037 / DEF-01: where the settings copy stands.
enum SyncState { notConfigured, signedOut, syncing, ok, offline }

/// Every preference key that is a Setting (DEF-01: stored in the database), except the Theme
/// pane keys, which [SettingsSync] receives as a parameter. Header keys (view.mode,
/// view.zone, view.hourLines, filter.*) are not listed and are never sent.
const Set<String> settingsSyncBaseKeys = {
  'timing.statusWordMs',
  'event.defaultLength',
  'event.defaultLengthUnit',
  'event.defaultStartMinutes',
  'view.longPressMs',
  'view.animationMs',
  'view.timeFormat',
  'settings.fixedZone',
  'theme.mode',
};

/// Keeps the Settings in the database through `/api/settings`. SharedPreferences stays the
/// local cache and the fallback: nothing is lost when the API is unreachable or the user is
/// signed out; a pending flag makes the next [push] or [pull] send the device copy.
class SettingsSync {
  SettingsSync({
    required this.prefs,
    required Set<String> keys,
    this.client,
    this.baseUrl,
    this.debounce = const Duration(milliseconds: 800),
    this.requestTimeout = const Duration(seconds: 5),
    this.currentPath = '/',
  }) : keys = Set.unmodifiable(keys),
       state = ValueNotifier(
         client != null && baseUrl != null
             ? SyncState.offline
             : SyncState.notConfigured,
       );

  /// Same origin on the web, not configured elsewhere (and in tests unless injected).
  factory SettingsSync.forPlatform({
    required SharedPreferences prefs,
    required Set<String> keys,
  }) {
    if (!kIsWeb) return SettingsSync(prefs: prefs, keys: keys);
    return SettingsSync(
      prefs: prefs,
      keys: keys,
      client: http.Client(),
      baseUrl: Uri.parse(Uri.base.origin),
      currentPath: Uri.base.path,
    );
  }

  static const pendingKey = 'sync.pending';

  final SharedPreferences prefs;
  final Set<String> keys;
  final http.Client? client;
  final Uri? baseUrl;
  final Duration debounce;
  final Duration requestTimeout;
  final String currentPath;
  final ValueNotifier<SyncState> state;

  /// Name shown for the signed-in user (null when unknown).
  String? userName;
  Timer? _timer;

  bool get configured => client != null && baseUrl != null;
  bool get pending => prefs.getBool(pendingKey) ?? false;

  /// Where to send the browser to sign in (navigate, not fetch); returns here afterwards.
  Uri? get signInUrl => baseUrl
      ?.resolve('/auth/login')
      .replace(
        queryParameters: {
          'next': currentPath.startsWith('/') ? currentPath : '/',
        },
      );

  Map<String, Object> _collect() => {
    for (final key in keys)
      if (prefs.get(key) case final Object value) key: value,
  };

  Future<http.Response?> _call(
    String method,
    String path, [
    String? body,
  ]) async {
    final request = http.Request(method, baseUrl!.resolve(path));
    if (body != null) {
      request.headers['content-type'] = 'application/json';
      request.body = body;
    }
    try {
      return await http.Response.fromStream(
        await client!.send(request),
      ).timeout(requestTimeout);
    } on Exception {
      return null;
    }
  }

  /// At startup, before the models load: the server copy wins, unless the device holds
  /// changes that were never sent (then those are sent instead).
  Future<void> pull() async {
    if (!configured) return;
    state.value = SyncState.syncing;
    final response = await _call('GET', '/api/settings');
    if (response == null || response.statusCode >= 500) {
      state.value = SyncState.offline;
      return;
    }
    if (response.statusCode == 401) {
      state.value = SyncState.signedOut;
      return;
    }
    if (response.statusCode != 200) {
      state.value = SyncState.offline;
      return;
    }
    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      state.value = SyncState.offline;
      return;
    }
    if (decoded is! Map<String, Object?>) {
      state.value = SyncState.offline;
      return;
    }
    if (pending || (decoded.isEmpty && _collect().isNotEmpty)) {
      await _flush();
    } else {
      for (final entry in decoded.entries) {
        if (keys.contains(entry.key)) await _store(entry.key, entry.value);
      }
      state.value = SyncState.ok;
    }
    await _loadName();
  }

  Future<void> _loadName() async {
    final response = await _call('GET', '/api/me');
    if (response == null || response.statusCode != 200) return;
    try {
      final me = jsonDecode(response.body);
      if (me is Map<String, Object?>) {
        userName = (me['name'] ?? me['email']) as String?;
      }
    } on FormatException {
      // The name is optional.
    }
  }

  Future<void> _store(String key, Object? value) async {
    switch (value) {
      case final bool b:
        await prefs.setBool(key, b);
      case final int i:
        // A stored double keeps its type (JSON writes 1.0 as 1 on some platforms).
        await (prefs.get(key) is double
            ? prefs.setDouble(key, i.toDouble())
            : prefs.setInt(key, i));
      case final double d:
        await prefs.setDouble(key, d);
      case final String s:
        await prefs.setString(key, s);
      case final List<Object?> l when l.every((e) => e is String):
        await prefs.setStringList(key, List<String>.from(l));
      default:
        break;
    }
  }

  /// Call after every settings change: sends the whole allowlisted set after a short pause.
  void push() {
    if (!configured) return;
    unawaited(prefs.setBool(pendingKey, true));
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(_flush()));
  }

  Future<void> _flush() async {
    if (!configured) return;
    _timer?.cancel();
    state.value = SyncState.syncing;
    await prefs.setBool(pendingKey, true);
    final response = await _call(
      'PUT',
      '/api/settings',
      jsonEncode(_collect()),
    );
    if (response == null ||
        response.statusCode == 503 ||
        response.statusCode >= 500) {
      state.value = SyncState.offline;
    } else if (response.statusCode == 401) {
      state.value = SyncState.signedOut;
    } else if (response.statusCode == 200) {
      await prefs.setBool(pendingKey, false);
      state.value = SyncState.ok;
    } else {
      state.value = SyncState.offline;
    }
  }

  void dispose() {
    _timer?.cancel();
    state.dispose();
  }
}

/// Gives the settings screens access to the sync (null in tests that do not provide it).
class SettingsSyncScope extends InheritedWidget {
  const SettingsSyncScope({
    super.key,
    required this.sync,
    required super.child,
  });

  final SettingsSync sync;

  static SettingsSync? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsSyncScope>()?.sync;

  @override
  bool updateShouldNotify(SettingsSyncScope oldWidget) =>
      sync != oldWidget.sync;
}
