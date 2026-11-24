import 'dart:io';

import 'package:scrumboard/server/server.dart';
import 'package:scrumboard/server/usage_script.dart';

const String _usage = '''
ScrumBoard server (127.0.0.1 only)

  dart run bin/server.dart [--port 8081] [--progress <dir>] [--root <repo>] [--web <build/web>]
                           [--usage-script <path>] [--bash <path>]

  --port          port to listen on (default 8081)
  --progress      folder of agent progress files (must exist)
  --root          the repository (default ../.. from scrum/scrumboard)
  --web           the built web app (default build/web next to bin/)
  --usage-script  the usage script run for the estimate and the trend
                  (default scrum/usage/usage.sh under the root)
  --bash          the bash that runs it (default: Git Bash on Windows, bash
                  elsewhere; never the WSL bash of System32)
''';

Future<void> main(List<String> args) async {
  var port = 8081;
  String? progress;
  var root = '../..';
  String? web;
  var usageScript = defaultUsageScript;
  String? bash;
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
        case '--usage-script':
          usageScript = value();
        case '--bash':
          bash = value();
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
      usageScript: usageScript,
      bash: bash,
    );
    stdout.writeln('ScrumBoard at http://127.0.0.1:${server.port}');
  } on Object catch (e) {
    stderr.writeln('Could not start: $e');
    exitCode = 1;
  }
}
