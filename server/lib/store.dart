/// Storage interface (DEF-01: settings live in the database). Two
/// implementations: [MemoryStore] (tests, fake) and `PostgresStore`.
class UserRecord {
  const UserRecord(this.sub, this.name, this.email);
  final String sub;
  final String name;
  final String email;
}

class SessionRecord {
  const SessionRecord(this.id, this.userSub, this.expiresAt);
  final String id;
  final String userSub;
  final DateTime expiresAt;
}

abstract class Store {
  /// True when the database answers (DIA-03.d). Never throws.
  Future<bool> ping();

  /// Creates the user or refreshes name and email.
  Future<void> upsertUser(UserRecord user);
  Future<UserRecord?> getUser(String sub);

  /// The user's settings object; empty when nothing was saved.
  Future<Map<String, Object?>> getSettings(String sub);
  Future<void> putSettings(String sub, Map<String, Object?> data, DateTime now);

  Future<void> createSession(SessionRecord session);
  Future<SessionRecord?> getSession(String id);
  Future<void> deleteSession(String id);

  /// Removes expired sessions.
  Future<void> purgeExpired(DateTime now);
  Future<void> close();
}

/// In-memory fake. Set [available] to false to simulate a database outage.
class MemoryStore implements Store {
  bool available = true;
  final _users = <String, UserRecord>{};
  final _settings = <String, Map<String, Object?>>{};
  final _sessions = <String, SessionRecord>{};

  void _check() {
    if (!available) throw StateError('database unavailable');
  }

  @override
  Future<bool> ping() async => available;

  @override
  Future<void> upsertUser(UserRecord user) async {
    _check();
    _users[user.sub] = user;
  }

  @override
  Future<UserRecord?> getUser(String sub) async {
    _check();
    return _users[sub];
  }

  @override
  Future<Map<String, Object?>> getSettings(String sub) async {
    _check();
    return Map.of(_settings[sub] ?? const {});
  }

  @override
  Future<void> putSettings(
      String sub, Map<String, Object?> data, DateTime now) async {
    _check();
    if (!_users.containsKey(sub)) throw StateError('unknown user');
    _settings[sub] = Map.of(data);
  }

  @override
  Future<void> createSession(SessionRecord session) async {
    _check();
    _sessions[session.id] = session;
  }

  @override
  Future<SessionRecord?> getSession(String id) async {
    _check();
    return _sessions[id];
  }

  @override
  Future<void> deleteSession(String id) async {
    _check();
    _sessions.remove(id);
  }

  @override
  Future<void> purgeExpired(DateTime now) async {
    _check();
    _sessions.removeWhere((_, s) => !s.expiresAt.isAfter(now));
  }

  @override
  Future<void> close() async {}
}
