import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/l10n/messages.dart';

Map<String, dynamic> _arb(String code) =>
    jsonDecode(File('requirements/messages/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;

void main() {
  final en = _arb('en');

  test('messages (README rule 12): every language has the keys of the English template', () {
    final keys = en.keys.where((k) => !k.startsWith('@')).toSet();
    for (final code in supportedLocales) {
      final have = _arb(code).keys.where((k) => !k.startsWith('@')).toSet();
      expect(keys.difference(have), isEmpty, reason: '$code lacks keys');
    }
  });

  test('messages: the message for a key comes from the chosen language, with its placeholders', () {
    final fr = Messages.fromMaps('fr', _arb('fr'), en);
    expect(fr('today'), _arb('fr')['today']);
    expect(Messages.fromMaps('en', en, en)('moreEvents', {'n': 3}), '+3 more');
    expect(fr('moreEvents', {'n': 3}), '+3 de plus');
    expect(Messages.fromMaps('en', en, en)('viewTooltip', {'name': 'Week'}), 'View: Week');
  });

  test('messages: a key with no translation falls back to English; an unknown key shows as itself', () {
    final partial = Messages.fromMaps('fr', {'@@locale': 'fr'}, en);
    expect(partial('today'), en['today']);
    expect(partial('noSuchKey'), 'noSuchKey');
    expect(partial.has('today'), isTrue);
    expect(partial.has('noSuchKey'), isFalse);
  });

  test('SHL-02.f: values inserted into a message are plain text, never read as markup or as placeholders', () {
    final m = Messages.fromMaps('en', en, en);
    expect(m('viewTooltip', {'name': '<b>{name}</b>'}), 'View: <b>{name}</b>');
  });
}
