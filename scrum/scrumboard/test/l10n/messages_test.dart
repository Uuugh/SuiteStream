import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/l10n/messages.dart';

const _keys = [
  'scbReload', 'scbLoadFailed', 'scbServerUnreachable', 'scbRequirements', 'scbBacklog',
  'scbStatusProposed', 'scbStatusBacklog', 'scbStatusPlanned', 'scbStatusDone',
  'scbFilterFeature', 'scbFilterRequirement', 'scbFilterStatus', 'scbShownOf',
  'scbExpandRow', 'scbCollapseRow', 'scbExpandAll', 'scbFeaturesRequirements', 'scbMoveRefused',
];

// Tests run in scrum/scrumboard; the sources are at the repository root.
File _source(String code) => File('../../requirements/messages/app_$code.arb');
File _copy(String code) => File('assets/messages/app_$code.arb');

Map<String, dynamic> _arb(File f) => jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('SCB-01.d the arb copies match their sources (run tool/sync_messages.sh)', () {
    for (final code in supportedLocales) {
      expect(_copy(code).readAsBytesSync(), _source(code).readAsBytesSync(),
          reason: 'assets/messages/app_$code.arb is stale: run tool/sync_messages.sh');
    }
  });

  test('SCB-01.d every language has every scb key', () {
    for (final code in supportedLocales) {
      final have = _arb(_copy(code));
      for (final k in _keys) {
        expect(have[k], isA<String>(), reason: 'app_$code.arb lacks $k');
      }
    }
  });

  test('SCB-01.d the loader returns messages from the copies, with placeholders and fallback', () {
    final en = _arb(_copy('en'));
    final de = Messages.fromMaps('de', _arb(_copy('de')), en);
    expect(de('scbReload'), _arb(_copy('de'))['scbReload']);
    expect(Messages.fromMaps('en', en, en)('scbShownOf', {'shown': 2, 'total': 9}), '2 of 9');
    expect(Messages.fromMaps('fr', {'@@locale': 'fr'}, en)('scbReload'), en['scbReload']);
    expect(de('noSuchKey'), 'noSuchKey');
  });

  testWidgets('SCB-01.d one key loads from the asset bundle', (tester) async {
    final m = (await tester.runAsync(() => Messages.load('en')))!;
    expect(m('scbRequirements'), 'Requirements');
    expect(m('scbLoadFailed', {'reason': 'x'}), 'Could not read the data: x');
  });
}
