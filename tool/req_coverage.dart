// Reports which requirement IDs have tests (README rule 11).
//
// A test names the requirement IDs it verifies at the start of its name, for
// example `test('TIM-01: ...')` or `test('TIM-01, TIM-02: ...')`. Usage:
//
//   dart run tool/req_coverage.dart           report only
//   dart run tool/req_coverage.dart --apply   also set each tested row to
//                                             `planned` with its test file in
//                                             the test cell
import 'dart:io';

final _testIds = RegExp(
  r"""(?:test|testWidgets)\(\s*['"]((?:[A-Z]{3,4}-\d+(?:\.[a-z]+)?)(?:,\s*[A-Z]{3,4}-\d+(?:\.[a-z]+)?)*)\s*(?::|\b)""",
);
final _id = RegExp(r'[A-Z]{3,4}-\d+(?:\.[a-z]+)?');

List<String> requirementIdsInTestSource(String source) => [
  for (final test in _testIds.allMatches(source))
    for (final id in _id.allMatches(test.group(1)!)) id.group(0)!,
];

void main(List<String> args) {
  final apply = args.contains('--apply');

  // 1. Tests: id -> test file.
  final tested = <String, String>{};
  for (final f in Directory('test').listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('_test.dart')) continue;
    final path = f.path.replaceAll('\\', '/');
    for (final id in requirementIdsInTestSource(f.readAsStringSync())) {
      tested.putIfAbsent(id, () => path);
    }
  }

  // 2. Requirements: every table row `| ID | status | statement | test |`.
  final row = RegExp(r'^\| ([A-Z]{3,4}-\d+(?:\.[a-z]+)?) \| (\w+) \| ');
  final known = <String>{};
  var total = 0;
  var withTest = 0;
  for (final f in Directory('requirements').listSync(recursive: true).whereType<File>()) {
    final p = f.path.replaceAll('\\', '/');
    if (!p.endsWith('.md') || p.endsWith('oldkey.md') || p.endsWith('README.md')) continue;
    final lines = f.readAsLinesSync();
    var changed = false;
    for (var i = 0; i < lines.length; i++) {
      final m = row.firstMatch(lines[i]);
      if (m == null) continue;
      final id = m.group(1)!;
      known.add(id);
      total++;
      final testFile = tested[id];
      if (testFile != null) {
        withTest++;
        if (apply && m.group(2) != "done") {
          final cells = lines[i].split(RegExp(r'(?<!\\)\|'));
          // cells: '', ' ID ', ' status ', ' statement ', ' test ', ''
          if (cells.length == 6) {
            cells[2] = ' planned ';
            cells[4] = ' $testFile ';
            lines[i] = cells.join('|');
            changed = true;
          }
        }
      }
    }
    if (changed) f.writeAsStringSync('${lines.join('\n')}\n');
  }

  final unknown = tested.keys.where((id) => !known.contains(id)).toList()..sort();
  stdout.writeln('Requirement rows: $total');
  stdout.writeln('Rows with a test: $withTest');
  stdout.writeln('Tested IDs: ${tested.length}');
  if (unknown.isNotEmpty) {
    stdout.writeln('Tests naming an ID that is not in requirements/: ${unknown.join(', ')}');
    exitCode = 1;
  }
}
