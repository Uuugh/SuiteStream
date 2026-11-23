import 'package:flutter_test/flutter_test.dart';

import '../../tool/req_coverage.dart';

void main() {
  test('coverage reporter recognizes shared and single requirement IDs', () {
    const first = 'UIC-27.b';
    const second = 'THM-05.c';
    expect(
      requirementIdsInTestSource(
        "testWidgets('$first, $second: save look', (tester) async {})",
      ),
      [first, second],
    );
    expect(requirementIdsInTestSource("test('$first: save look', () {})"), [
      first,
    ]);
    expect(requirementIdsInTestSource("test('$first legacy style', () {})"), [
      first,
    ]);
  });
}
