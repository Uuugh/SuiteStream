import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/theme_mode_controller.dart';

Set<String> _arbKeys(String code) =>
    (jsonDecode(File('requirements/messages/app_$code.arb').readAsStringSync()) as Map<String, dynamic>)
        .keys
        .where((k) => !k.startsWith('@'))
        .toSet();

void main() {
  test('arb-only rule: every message key used in lib/ (m(\'key\'), msg(\'key\'), messages(\'key\')) exists in all six arb files', () {
    final call = RegExp(r"\b(?:m|msg|messages)\(\s*'([A-Za-z][A-Za-z0-9]*)'");
    final used = <String, String>{};
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      for (final match in call.allMatches(f.readAsStringSync())) {
        used.putIfAbsent(match.group(1)!, () => f.path);
      }
    }
    expect(used, isNotEmpty);
    for (final code in supportedLocales) {
      final have = _arbKeys(code);
      final missing = used.keys.where((k) => !have.contains(k)).map((k) => '$k (${used[k]})').toList();
      expect(missing, isEmpty, reason: 'app_$code.arb lacks keys used in lib/');
    }
  });

  test('arb-only rule: the theme menu and Admin pane keys exist in all six arb files', () {
    final keys = {
      for (final mode in ThemeMode.values) themeModeMessageKey(mode),
      'themeName',
      'themeTooltip',
      'adminAdded',
      'adminFailed',
      'adminRemoved',
      'adminRemoveConfirm',
      'adminTestDataHelp',
      'adminAddTestCalendars',
      'adminRemoveTestData',
    };
    for (final code in supportedLocales) {
      expect(keys.difference(_arbKeys(code)), isEmpty, reason: 'app_$code.arb');
    }
  });
}
