import 'dart:io';

import 'package:scrumboard/server/server.dart';

const String _usage = '''
ScrumBoard server (127.0.0.1 only)

  dart run bin/server.dart [--port 8081] [--progress <dir>] [--root <repo>] [--web <build/web>]

  --port      port to listen on (default 8081)
  --progress  folder of agent progress files (must exist)
  --root      the repository (default ../.. from scrum/scrumboard)
  --web       the built web app (default build/web next to bin/)
''';

Future<void> main(List<String> args) async {
  var port = 8081;
  String? progress;
  var root = '../..';
  String? web;
  try {
    for (var i = 0; i < args.length; i++) {
      final a = args[i];
      String value() {
        if (i + 1 >= args.length) throw FormatException('$a needs a value');
        return args[++i];
      }

      switch (a) {
        case '--port':
          port = int.parse(value());
        case '--progress':
          progress = value();
        case '--root':
          root = value();
        case '--web':
          web = value();
        case '--help' || '-h':
          stdout.write(_usage);
          return;
        default:
          throw FormatException('unknown argument $a');
      }
    }
  } on FormatException catch (e) {
    stderr
      ..writeln(e.message)
      ..write(_usage);
    exitCode = 64;
    return;
  }
  final webDir = Directory(
    web ??
        File.fromUri(Platform.script)
            .parent
            .parent
            .uri
            .resolve('build/web')
            .toFilePath(),
  );
  try {
    final server = await ScrumBoardServer.start(
      root: Directory(root),
      progressDir: progress == null ? null : Directory(progress),
      webDir: webDir,
      port: port,
    );
    stdout.writeln('ScrumBoard at http://127.0.0.1:${server.port}');
  } on Object catch (e) {
    stderr.writeln('Could not start: $e');
    exitCode = 1;
  }
}
