import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter/widgets.dart';

/// The languages offered, by the code of their message file.
const List<String> supportedLocales = ['en', 'es', 'fr', 'de', 'pt', 'nl'];

/// Where the copies of `requirements/messages/*.arb` live (made by
/// `tool/sync_messages.sh`; the pubspec declares this folder as assets).
const String messageAssetFolder = 'assets/messages';

/// The ScrumBoard's wording: keys read from the arb copies. A key a language
/// lacks falls back to English; an unknown key shows as itself.
class Messages {
  Messages._(this.locale, this._text, this._fallback);

  /// Builds messages from already-parsed ARB maps (used by tests).
  factory Messages.fromMaps(String locale, Map<String, dynamic> text, Map<String, dynamic> english) =>
      Messages._(locale, _strings(text), _strings(english));

  /// Loads the arb copies from the assets.
  static Future<Messages> load(String locale, {AssetBundle? bundle}) async {
    final b = bundle ?? rootBundle;
    Future<Map<String, dynamic>> read(String code) async =>
        jsonDecode(await b.loadString('$messageAssetFolder/app_$code.arb')) as Map<String, dynamic>;
    final english = await read('en');
    final code = supportedLocales.contains(locale) ? locale : 'en';
    final text = code == 'en' ? english : await read(code);
    return Messages.fromMaps(code, text, english);
  }

  final String locale;
  final Map<String, String> _text;
  final Map<String, String> _fallback;

  static Map<String, String> _strings(Map<String, dynamic> m) => {
        for (final e in m.entries)
          if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
      };

  bool has(String key) => _text.containsKey(key) || _fallback.containsKey(key);

  /// The message for [key] with each `{name}` replaced from [args], as plain text.
  String call(String key, [Map<String, Object?> args = const {}]) {
    var s = _text[key] ?? _fallback[key] ?? key;
    args.forEach((name, value) => s = s.replaceAll('{$name}', '$value'));
    return s;
  }
}

/// Gives the current [Messages] to every widget below it.
class MessagesScope extends InheritedWidget {
  const MessagesScope({super.key, required this.messages, required super.child});

  final Messages messages;

  static Messages of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MessagesScope>();
    assert(scope != null, 'No MessagesScope above this widget');
    return scope!.messages;
  }

  @override
  bool updateShouldNotify(MessagesScope old) => old.messages != messages;
}

extension MessagesContext on BuildContext {
  Messages get msg => MessagesScope.of(this);
}
