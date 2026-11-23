import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf_io.dart' as io;
import 'package:suitestream_server/app.dart';
import 'package:suitestream_server/config.dart';
import 'package:suitestream_server/oidc.dart';
import 'package:suitestream_server/postgres_store.dart';
import 'package:suitestream_server/store.dart';

/// DEP-01.e: retry the database at this interval for up to this long (the
/// DEF-01 values are not yet defined; adjust when DEF-01 names them).
const _dbRetryEvery = Duration(seconds: 2);
const _dbRetryFor = Duration(seconds: 60);

Future<void> main(List<String> args) async {
  if (args.contains('--healthcheck')) {
    // Used by the Docker HEALTHCHECK (the runtime image has no curl).
    final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
    try {
      final res = await http
          .get(Uri.parse('http://127.0.0.1:$port/api/health'))
          .timeout(const Duration(seconds: 4));
      exit(res.statusCode == 200 ? 0 : 1);
    } catch (_) {
      exit(1);
    }
  }
  final ServerConfig config;
  try {
    config = ServerConfig.fromEnv(Platform.environment);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    exit(2);
  }
  final url = config.databaseUrl;
  if (url == null) {
    stderr.writeln('Missing environment variable: DATABASE_URL');
    exit(2);
  }

  Store? store;
  final deadline = DateTime.now().add(_dbRetryFor);
  Object? lastError;
  while (store == null) {
    try {
      store = await PostgresStore.open(url);
    } catch (e) {
      lastError = e;
      if (DateTime.now().isAfter(deadline)) {
        stderr.writeln('The database cannot be reached: $lastError');
        exit(1);
      }
      await Future<void>.delayed(_dbRetryEvery);
    }
  }

  final handler = buildHandler(
    config: config,
    store: store,
    oidc: OidcClient(config, http.Client()),
  );
  final server = await io.serve(handler, InternetAddress.anyIPv4, config.port);
  stdout.writeln('SuiteStream server listening on ${server.port}');

  Timer.periodic(const Duration(hours: 1), (_) async {
    try {
      await store!.purgeExpired(DateTime.now());
    } catch (_) {}
  });

  Future<void> stop(ProcessSignal _) async {
    await server.close(force: true);
    await store!.close();
    exit(0);
  }

  ProcessSignal.sigterm.watch().listen(stop);
  ProcessSignal.sigint.watch().listen(stop);
}
