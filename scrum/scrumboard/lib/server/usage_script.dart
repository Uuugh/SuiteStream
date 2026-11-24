import 'dart:async';
import 'dart:convert';
import 'dart:io';

// SCB-14.o: the only file of the server that starts a process. It runs
// `<bash> <usage script> estimate` or `<bash> <usage script> trend`, nothing
// else; the page gives no input to it (PBI-106).

/// The usage script, relative to the repository root (`--usage-script`).
const String defaultUsageScript = 'scrum/usage/usage.sh';

/// The time limit for one run of the usage script.
const Duration usageScriptTimeout = Duration(seconds: 10);

/// The only arguments the script is ever given.
const Set<String> usageScriptModes = {'estimate', 'trend'};

/// The answer of `GET /api/usage/estimate` and `GET /api/usage/trend`.
typedef UsageScriptResult = ({bool ok, String output, String reason});

extension UsageScriptJson on UsageScriptResult {
  Map<String, Object> toJson() => {'ok': ok, 'output': output, 'reason': reason};
}

/// The default bash (must-fix 14 of the Sprint 014 plan review). On Windows it
/// is Git Bash, never a bare `bash`, which Windows resolves to
/// `C:\Windows\System32\bash.exe` (WSL): first `<git>\bin\bash.exe` for a
/// `git.exe` on PATH, then `C:\Program Files\Git\bin\bash.exe`, then the first
/// `bash.exe` on PATH outside `System32` and `WindowsApps` (the WSL
/// launchers). No Git Bash found is null. Elsewhere it is `bash`.
///
/// [environment], [isWindows] and [exists] are for tests.
String? findDefaultBash({
  Map<String, String>? environment,
  bool? isWindows,
  bool Function(String path)? exists,
}) {
  if (!(isWindows ?? Platform.isWindows)) return 'bash';
  final env = environment ?? Platform.environment;
  final there = exists ?? (String p) => File(p).existsSync();
  final pathValue = env.entries
          .where((e) => e.key.toUpperCase() == 'PATH')
          .map((e) => e.value)
          .firstOrNull ??
      '';
  final dirs = [
    for (final d in pathValue.split(';'))
      if (d.trim().isNotEmpty) d.trim().replaceAll('/', r'\').replaceAll(RegExp(r'\\+$'), ''),
  ];
  bool wsl(String p) {
    final l = p.toLowerCase();
    return l.contains(r'\system32\') || l.contains(r'\windowsapps\') || l.contains(r'\sysnative\');
  }

  final candidates = <String>[];
  for (final d in dirs) {
    if (!there('$d\\git.exe')) continue;
    // <git>\cmd, <git>\bin or <git>\mingw64\bin holds git.exe.
    final parts = d.split(r'\');
    final lower = parts.map((p) => p.toLowerCase()).toList();
    var up = 1;
    if (lower.length >= 2 && lower.last == 'bin' && lower[lower.length - 2] == 'mingw64') up = 2;
    if (parts.length > up) candidates.add('${parts.sublist(0, parts.length - up).join(r'\')}\\bin\\bash.exe');
  }
  final programFiles = env.entries
      .where((e) => e.key.toUpperCase() == 'PROGRAMFILES')
      .map((e) => e.value)
      .firstOrNull;
  if (programFiles != null) candidates.add('$programFiles\\Git\\bin\\bash.exe');
  candidates.add(r'C:\Program Files\Git\bin\bash.exe');
  for (final d in dirs) {
    candidates.add('$d\\bash.exe');
  }
  for (final c in candidates) {
    if (!wsl(c) && there(c)) return c;
  }
  return null;
}

/// Runs [script] with [mode] (`estimate` or `trend` only) through [bash] in
/// [workingDirectory]. Exit 0 is `ok: true` with the output as printed; any
/// other exit is `ok: false` with the script's output as the reason; a
/// missing script, no bash, a start failure or a run past [timeout] is
/// `ok: false` with a reason saying which. After a timeout bash is killed and
/// the answer comes at once, without waiting for its output to close (on
/// Windows an orphaned child can keep it open).
Future<UsageScriptResult> runUsageScript({
  required String? bash,
  required String script,
  required String mode,
  required String workingDirectory,
  Duration timeout = usageScriptTimeout,
}) async {
  if (!usageScriptModes.contains(mode)) {
    throw ArgumentError.value(mode, 'mode', 'only estimate or trend');
  }
  if (bash == null) {
    return (ok: false, output: '', reason: 'bash not found (Git Bash is needed on Windows)');
  }
  if (!File(script).existsSync()) {
    return (ok: false, output: '', reason: 'usage script not found: $script');
  }
  final Process process;
  try {
    process = await Process.start(bash, [script, mode], workingDirectory: workingDirectory);
  } on ProcessException catch (e) {
    return (ok: false, output: '', reason: 'could not start bash: ${e.message}');
  }
  final out = StringBuffer();
  final err = StringBuffer();
  const decoder = Utf8Decoder(allowMalformed: true);
  final outDone = process.stdout.transform(decoder).forEach(out.write);
  final errDone = process.stderr.transform(decoder).forEach(err.write);
  final int code;
  try {
    code = await process.exitCode.timeout(timeout);
  } on TimeoutException {
    process.kill(ProcessSignal.sigkill);
    return (
      ok: false,
      output: out.toString(),
      reason: 'usage script timed out after ${timeout.inMilliseconds / 1000} s',
    );
  }
  // The output normally closes with the exit; do not hang when a child keeps
  // it open.
  try {
    await Future.wait([outDone, errDone]).timeout(timeout);
  } on TimeoutException {
    // Keep what was read.
  }
  final printed = out.toString();
  if (code == 0) return (ok: true, output: printed, reason: '');
  final said = '$printed${err.toString()}'.trim();
  return (ok: false, output: printed, reason: said.isEmpty ? 'usage script exit code $code' : said);
}
