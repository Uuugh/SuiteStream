import 'dart:convert';

import 'package:postgres/postgres.dart';

import 'store.dart';

/// Postgres implementation of [Store], written against postgres 3.7.0
/// (Pool.withUrl, Session.execute with positional `$n` parameters, runTx).
///
/// NOT TESTED: no Postgres server was available when this was written
/// (Sprint 010, PBI-063a). Only the in-memory store is covered by tests.
/// jsonb is passed as a JSON text parameter and cast in SQL (`$2::text::jsonb`)
/// and read back as text (`data::text`), so no jsonb codec behavior is
/// relied on.
class PostgresStore implements Store {
  PostgresStore._(this._pool);

  final Pool<void> _pool;

  /// Opens the pool and creates missing tables. [url] is
  /// postgresql://user:password@host:5432/dbname (add ?sslmode=disable for a
  /// database inside the Docker network).
  static Future<PostgresStore> open(String url) async {
    final store = PostgresStore._(Pool.withUrl(url));
    await store._migrate();
    return store;
  }

  Future<void> _migrate() async {
    // Create-if-missing; safe to run at every start.
    await _pool.runTx((tx) async {
      await tx.execute('''
CREATE TABLE IF NOT EXISTS users (
  sub text PRIMARY KEY,
  name text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
)''');
      await tx.execute('''
CREATE TABLE IF NOT EXISTS settings (
  user_sub text PRIMARY KEY REFERENCES users(sub) ON DELETE CASCADE,
  data jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now()
)''');
      await tx.execute('''
CREATE TABLE IF NOT EXISTS sessions (
  id text PRIMARY KEY,
  user_sub text NOT NULL REFERENCES users(sub) ON DELETE CASCADE,
  expires_at timestamptz NOT NULL
)''');
    });
  }

  @override
  Future<bool> ping() async {
    try {
      await _pool.execute('SELECT 1').timeout(const Duration(seconds: 3));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> upsertUser(UserRecord user) async {
    await _pool.execute(
      r'''INSERT INTO users (sub, name, email) VALUES ($1, $2, $3)
ON CONFLICT (sub) DO UPDATE SET name = EXCLUDED.name, email = EXCLUDED.email''',
      parameters: [user.sub, user.name, user.email],
    );
  }

  @override
  Future<UserRecord?> getUser(String sub) async {
    final r = await _pool.execute(
      r'SELECT sub, name, email FROM users WHERE sub = $1',
      parameters: [sub],
    );
    if (r.isEmpty) return null;
    final row = r.first;
    return UserRecord(row[0] as String, row[1] as String, row[2] as String);
  }

  @override
  Future<Map<String, Object?>> getSettings(String sub) async {
    final r = await _pool.execute(
      r'SELECT data::text FROM settings WHERE user_sub = $1',
      parameters: [sub],
    );
    if (r.isEmpty) return {};
    final decoded = jsonDecode(r.first[0] as String);
    return decoded is Map ? decoded.cast<String, Object?>() : {};
  }

  @override
  Future<void> putSettings(
      String sub, Map<String, Object?> data, DateTime now) async {
    await _pool.execute(
      r'''INSERT INTO settings (user_sub, data, updated_at)
VALUES ($1, $2::text::jsonb, $3)
ON CONFLICT (user_sub) DO UPDATE SET data = EXCLUDED.data, updated_at = EXCLUDED.updated_at''',
      parameters: [sub, jsonEncode(data), now.toUtc()],
    );
  }

  @override
  Future<void> createSession(SessionRecord s) async {
    await _pool.execute(
      r'INSERT INTO sessions (id, user_sub, expires_at) VALUES ($1, $2, $3)',
      parameters: [s.id, s.userSub, s.expiresAt.toUtc()],
    );
  }

  @override
  Future<SessionRecord?> getSession(String id) async {
    final r = await _pool.execute(
      r'SELECT id, user_sub, expires_at FROM sessions WHERE id = $1',
      parameters: [id],
    );
    if (r.isEmpty) return null;
    final row = r.first;
    return SessionRecord(
        row[0] as String, row[1] as String, row[2] as DateTime);
  }

  @override
  Future<void> deleteSession(String id) async {
    await _pool
        .execute(r'DELETE FROM sessions WHERE id = $1', parameters: [id]);
  }

  @override
  Future<void> purgeExpired(DateTime now) async {
    await _pool.execute(r'DELETE FROM sessions WHERE expires_at <= $1',
        parameters: [now.toUtc()]);
  }

  @override
  Future<void> close() => _pool.close();
}
